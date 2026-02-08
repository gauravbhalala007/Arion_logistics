// lib/screens/drivers_hub_page.dart
import 'dart:typed_data';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;

import '../services/driver_csv.dart';
import '../widgets/web_preview.dart'
    if (dart.library.html) '../widgets/web_preview_web.dart';
import '../widgets/notification_pin_dialogs.dart';


// Keep this out of source control by passing --dart-define=DEFAULT_DRIVER_PASSWORD=...
const String kDefaultDriverPassword = String.fromEnvironment(
  'DEFAULT_DRIVER_PASSWORD',
  defaultValue: 'CHANGE_ME_LOCALLY',
);



class DriversHubPage extends StatefulWidget {
  const DriversHubPage({super.key});

  @override
  State<DriversHubPage> createState() => _DriversHubPageState();
}

class _DriversHubPageState extends State<DriversHubPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _user => _auth.currentUser;
  String? get _uid => _user?.uid;

  bool _busyCsv = false;
  bool _busyList = false;

  // 🔹 New: bulk/default password controller + bulk action busy flag
  final TextEditingController _bulkPwdCtrl =
      TextEditingController(text: kDefaultDriverPassword);
  bool _busyBulkLogins = false;
  // 🔹 New: visibility toggle for default password field
  bool _bulkPwdVisible = false;



  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(child: _buildDriversList()),
          ],
        ),
      );
  }

  // ---------- Common pill-shaped text field decoration ----------
  InputDecoration _pillInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // ADMIN: Inline edit any onboarding field (pencil icon per row)
  // ---------------------------------------------------------------------------

  Future<void> _adminEditField({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String label,
    required String fieldKey,
    required String initialValue,
    bool isDate = false,
  }) async {
    String _formatDate(DateTime d) {
      final day = d.day.toString().padLeft(2, '0');
      final m = d.month.toString().padLeft(2, '0');
      final y = d.year.toString().padLeft(4, '0');
      return '$day/$m/$y';
    }

    DateTime? _parseDate(String text) {
      final cleaned = text.trim();
      if (cleaned.isEmpty) return null;
      final slashMatch = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{4})$');
      final match = slashMatch.firstMatch(cleaned);
      if (match != null) {
        final d = int.tryParse(match.group(1)!);
        final m = int.tryParse(match.group(2)!);
        final y = int.tryParse(match.group(3)!);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
      try {
        return DateTime.parse(cleaned);
      } catch (_) {
        return null;
      }
    }

    String _normalizeDateText(String text) {
      final parsed = _parseDate(text);
      return parsed == null ? text : _formatDate(parsed);
    }

    DateTime _parseExistingOrNow(String text) {
      return _parseDate(text) ?? DateTime.now();
    }

    final ctrl = TextEditingController(
      text: isDate ? _normalizeDateText(initialValue) : initialValue,
    );

    Future<void> _pickDate() async {
      final initial = _parseExistingOrNow(ctrl.text);
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        ctrl.text = _formatDate(picked);
      }
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $label'),
        content: SizedBox(
          width: 520,
          child: TextFormField(
            controller: ctrl,
            readOnly: isDate,
            decoration: InputDecoration(
              labelText: label,
              hintText: isDate ? 'DD/MM/YYYY' : null,
              border: const OutlineInputBorder(),
              suffixIcon: isDate
                  ? IconButton(
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      onPressed: _pickDate,
                    )
                  : null,
            ),
            onTap: isDate ? _pickDate : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true) {
      ctrl.dispose();
      return;
    }

    try {
      await driverRef.set({
        'onboarding': {
          fieldKey: ctrl.text.trim(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $label: $e')),
      );
    } finally {
      ctrl.dispose();
    }
  }

  // ---------- Reusable detail row with copy & edit button ----------
  String _formatDisplayDate(String raw) {
    final parsed = _parseIsoDate(raw);
    if (parsed == null) return raw;
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  Widget _detailRowEditable({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String label,
    required dynamic value,
    required String fieldKey,
    bool isDate = false,
  }) {
    final rawText = (value ?? '').toString();
    final displayText = isDate ? _formatDisplayDate(rawText) : rawText;
    final hasText = displayText.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: SelectableText(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    hasText ? displayText : '—',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),

                // ✏️ Edit
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Edit $label',
                  onPressed: () => _adminEditField(
                    driverRef: driverRef,
                    label: label,
                    fieldKey: fieldKey,
                    initialValue: rawText,
                    isDate: isDate,
                  ),
                ),

                // 📋 Copy
                if (hasText) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy $label',
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: displayText),
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$label copied')),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRowReadOnly({
    required String label,
    required String value,
  }) {
    final hasText = value.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: SelectableText(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    hasText ? value : '—',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                if (hasText) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy $label',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: value));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$label copied')),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 800;

    return Row(
      children: [
        Text(
          'Drivers Hub',
          style: TextStyle(
            fontSize: isSmall ? 20 : 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        SizedBox(
          height: isSmall ? 32 : 36,
          child: FilledButton.icon(
            onPressed: _busyCsv ? null : _onImportCsv,
            icon: _busyCsv
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.file_upload_outlined, size: 18),
            label: Text(
              'Import CSV',
              style: TextStyle(fontSize: isSmall ? 12 : 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: isSmall ? 32 : 36,
          child: OutlinedButton.icon(
            onPressed: _busyList ? null : _createDriverManually,
            icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
            label: Text(
              'Add driver',
              style: TextStyle(fontSize: isSmall ? 12 : 14),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CSV import
  // ---------------------------------------------------------------------------

  Future<void> _onImportCsv() async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to import CSVs.')),
      );
      return;
    }

    setState(() => _busyCsv = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final f = result.files.first;
      final Uint8List? bytes = f.bytes;
      if (bytes == null) throw Exception('No file bytes');

      await DriverCsvService.importForUser(
        uid: _uid!,
        csvBytes: bytes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Driver CSV imported for your DSP (${f.name}).'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Driver CSV import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyCsv = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Manual driver creation
  // ---------------------------------------------------------------------------

  Future<void> _createDriverManually() async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add drivers.')),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add / edit driver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Driver name',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(
                labelText: 'Transporter ID (login ID)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final name = nameCtrl.text.trim();
    final tid = idCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (tid.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and Transporter ID are required.'),
        ),
      );
      return;
    }

    final db = FirebaseFirestore.instance;
    final doc = db
        .collection('users')
        .doc(_uid!)
        .collection('drivers')
        .doc(tid.toUpperCase());

    await doc.set({
      'transporterId': tid.toUpperCase(),
      'driverName': name,
      'email': email.isEmpty ? null : email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'hasLogin': false,
      'active': true,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Driver "$name" saved.')),
    );
  }

  // Helper: build suggested driver email from DSP email + driver name
  String _buildSuggestedDriverEmail({
    required String driverName,
    required String transporterId,
  }) {
    final dspEmail = _auth.currentUser?.email ?? '';
    final atIdx = dspEmail.indexOf('@');
    if (atIdx <= 0) return '';

    final domain = dspEmail.substring(atIdx + 1).trim();
    if (domain.isEmpty) return '';

    String local = driverName.trim().toLowerCase();
    if (local.isEmpty) {
      // fallback to transporterId if no name
      local = transporterId.toLowerCase();
    }

    // Replace non-alnum with '.', collapse dots, trim dots
    local = local
        .replaceAll(RegExp(r'[^a-z0-9]+'), '.')
        .replaceAll(RegExp(r'\.+'), '.')
        .replaceAll(RegExp(r'^\.|\.$'), '');

    if (local.isEmpty) {
      local = 'driver';
    }

    return '$local@$domain';
  }

  // ---------------------------------------------------------------------------
  // Row actions (create/reset login, suspend, delete)
  // ---------------------------------------------------------------------------

  Future<void> _onCreateOrResetLogin(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
  ) async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to manage driver logins.'),
        ),
      );
      return;
    }

    final data = driverDoc.data() ?? {};
    final name = (data['driverName'] ?? '').toString();
    final tidOriginal = (data['transporterId'] ?? '').toString();

    final existingEmail = (data['email'] ?? '').toString();
    final suggestedEmail = _buildSuggestedDriverEmail(
      driverName: name,
      transporterId: tidOriginal,
    );

    final tidCtrl = TextEditingController(text: tidOriginal);
    final emailCtrl = TextEditingController(
      text: existingEmail.isNotEmpty ? existingEmail : suggestedEmail,
    );
    // 🔹 Use the current default/bulk password from the top field, fallback to constant
    final defaultPwd = _bulkPwdCtrl.text.trim().isEmpty
        ? kDefaultDriverPassword
        : _bulkPwdCtrl.text.trim();

    final pwdCtrl = TextEditingController(text: defaultPwd);
    final pwd2Ctrl = TextEditingController(text: defaultPwd);



    // --- Custom dialog with white background + pill fields ---
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final width = MediaQuery.of(ctx).size.width;
        final dialogWidth = width < 480 ? width - 32 : 480.0;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set driver login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Driver: ${name.isEmpty ? '(no name)' : name}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: tidCtrl,
                    decoration:
                        _pillInputDecoration('Transporter ID (login ID)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: _pillInputDecoration('Driver email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pwdCtrl,
                    decoration: _pillInputDecoration('Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pwd2Ctrl,
                    decoration: _pillInputDecoration('Confirm password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (ok != true) return;

    final newTidRaw = tidCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pwd = pwdCtrl.text.trim();
    final pwd2 = pwd2Ctrl.text.trim();

    if (newTidRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transporter ID is required.')),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A valid driver email is required.'),
        ),
      );
      return;
    }

    if (pwd.isEmpty || pwd2.isEmpty || pwd != pwd2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords must match and not be empty.'),
        ),
      );
      return;
    }

    final newTid = newTidRaw.toUpperCase();
    final oldTid = tidOriginal.toUpperCase();
    final tidChanged = newTid != oldTid;

    try {
      // Decide which document we will finally use
      DocumentReference<Map<String, dynamic>> targetRef =
          driverDoc.reference;

      if (tidChanged) {
        // move driver document to new ID
        final driversCol = driverDoc.reference.parent;
        final newDocRef = driversCol.doc(newTid);

        final existingData = Map<String, dynamic>.from(data);
        existingData['transporterId'] = newTid;
        existingData['email'] = email;
        existingData['updatedAt'] = FieldValue.serverTimestamp();

        await newDocRef.set(existingData, SetOptions(merge: true));
        await driverDoc.reference.delete();

        targetRef = newDocRef;
      } else {
        // just update email + transporterId
        await driverDoc.reference.set(
          {
            'email': email,
            'transporterId': newTid,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      // Call function with NEW transporterId
      final callable =
          FirebaseFunctions.instance.httpsCallable('createDriverLogin');
      await callable.call(<String, dynamic>{
        'dspUid': _uid!,
        'transporterId': newTid,
        'password': pwd,
      });

      // Mark login state on target doc
      await targetRef.set(
        {
          'hasLogin': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      // Dialog with copy buttons for ID, Email, Password
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Driver login created'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CopyRow(label: 'Transporter ID', value: newTid),
              const SizedBox(height: 8),
              _CopyRow(label: 'Email', value: email),
              const SizedBox(height: 8),
              _CopyRow(label: 'Password', value: pwd),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver login saved successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set login: $e')),
      );
    }
  }

  /// Toggle active / suspended state.
  Future<void> _onToggleActiveDriver(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
    bool currentlyActive,
  ) async {
    final newActive = !currentlyActive;

    await driverDoc.reference.set(
      {
        'active': newActive,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newActive ? 'Driver activated.' : 'Driver suspended.',
        ),
      ),
    );
  }

  Future<void> _onDeleteDriver(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
  ) async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in.')),
      );
      return;
    }

    final data = driverDoc.data() ?? {};
    final name = (data['driverName'] ?? '').toString();
    final tid = (data['transporterId'] ?? driverDoc.id).toString().trim();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete driver'),
        content: Text(
          'Are you sure you want to delete driver "$name"?\n'
          'This will remove them and delete their login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('deleteDriverAccount');
      await callable.call(<String, dynamic>{
        'dspUid': _uid,
        'transporterId': tid,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Driver deleted.')),
    );
  }

    Future<void> _onCreateLoginsForAllDrivers() async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to manage driver logins.'),
        ),
      );
      return;
    }

    final pwd = _bulkPwdCtrl.text.trim().isEmpty
        ? kDefaultDriverPassword
        : _bulkPwdCtrl.text.trim();

    if (pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default password cannot be empty.')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create logins for all drivers'),
        content: Text(
          'This will create logins for all drivers that do not yet have a login,\n'
          'using the password:\n\n'
          '$pwd\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _busyBulkLogins = true);
    try {
      final db = FirebaseFirestore.instance;
      final driversSnap = await db
          .collection('users')
          .doc(_uid!)
          .collection('drivers')
          .get();

      if (driversSnap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No drivers found for this DSP.')),
        );
        return;
      }

      final callable =
          FirebaseFunctions.instance.httpsCallable('createDriverLogin');

      int created = 0;
      int skipped = 0;

      for (final d in driversSnap.docs) {
        final data = d.data();
        final hasLogin = (data['hasLogin'] as bool?) ?? false;
        final tidRaw = (data['transporterId'] ?? '').toString().trim();

        if (tidRaw.isEmpty) {
          skipped++;
          continue;
        }

        // Only create logins for drivers that don't already have one
        if (hasLogin) {
          skipped++;
          continue;
        }

        final tid = tidRaw.toUpperCase();

        // ✅ Ensure driver has an email before calling the function
        final existingEmail = (data['email'] ?? '').toString().trim();
        String emailToUse = existingEmail;

        if (emailToUse.isEmpty) {
          final driverName = (data['driverName'] ?? '').toString();
          emailToUse = _buildSuggestedDriverEmail(
            driverName: driverName,
            transporterId: tid,
          );
        }

        // If still empty, skip (avoids creating @drivers.dsp-copilot.local)
        if (emailToUse.isEmpty) {
          skipped++;
          continue;
        }

        // ✅ Update driver doc FIRST (same behavior as single-driver flow)
        await d.reference.set(
          {
            'transporterId': tid,
            'email': emailToUse,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        // Call function
        await callable.call(<String, dynamic>{
          'dspUid': _uid!,
          'transporterId': tid,
          'password': pwd,
        });

        // Mark login state
        await d.reference.set(
          {
            'hasLogin': true,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        created++;
      }


      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Created logins for $created drivers. Skipped $skipped (already had login or missing ID).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create logins: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _busyBulkLogins = false);
      }
    }
  }






  // ---------------------------------------------------------------------------
  // ADMIN: Upload docs + edit expiry dates (contract + other expiry)
  // ---------------------------------------------------------------------------

  String _adminDocTypeLabel(String docType) {
    switch (docType) {
      case 'resident_permit':
        return 'Work permit';
      case 'driver_license_front':
        return 'Driving licence (front)';
      case 'driver_license_back':
        return 'Driving licence (back)';
      case 'id_card_front':
        return 'ID card (front)';
      case 'id_card_back':
        return 'ID card (back)';
      case 'passport_front':
        return 'Passport (front)';
      case 'passport_back':
        return 'Passport (back)';
      case 'tax_id':
        return 'Tax ID';
      case 'insurance':
        return 'Insurance';
      case 'contract':
        return 'Contract';
      default:
        return docType;
    }
  }

  Future<void> _adminPickAndUploadDriverDoc({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String docType,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final f = result.files.first;
      final bytes = f.bytes;
      if (bytes == null) throw Exception('Could not read file bytes.');

      final originalName = f.name;
      final typeLabel = _adminDocTypeLabel(docType);

      String displayName = typeLabel;
      final dotIndex = originalName.lastIndexOf('.');
      if (dotIndex != -1 && dotIndex < originalName.length - 1) {
        final ext = originalName.substring(dotIndex + 1);
        displayName = '$typeLabel.$ext';
      }

      final storage = fb.FirebaseStorage.instance;
      final docsCol = driverRef.collection('documents');

      final ref = storage
          .ref()
          .child('driver_docs')
          .child(driverRef.id)
          .child('${DateTime.now().millisecondsSinceEpoch}_$originalName');

      await ref.putData(bytes);
      final url = await ref.getDownloadURL();

      await docsCol.doc(docType).set({
        'fileName': displayName,
        'downloadUrl': url,
        'uploadedAt': FieldValue.serverTimestamp(),
        'uploadedAtClient': Timestamp.now(),
        'size': f.size,
        'docType': docType,
        'uploadedBy': 'admin',
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$typeLabel uploaded.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload document: $e')),
      );
    }
  }

  Future<void> _showAdminUploadDocDialog(
    DocumentReference<Map<String, dynamic>> driverRef,
  ) async {
    String selected = 'contract';

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setLocal) {
            return AlertDialog(
              title: const Text('Upload driver document'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selected,
                    decoration: const InputDecoration(
                      labelText: 'Document type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'contract', child: Text('Contract')),
                      DropdownMenuItem(value: 'resident_permit', child: Text('Work permit')),
                      DropdownMenuItem(value: 'id_card_front', child: Text('ID card (front)')),
                      DropdownMenuItem(value: 'id_card_back', child: Text('ID card (back)')),
                      DropdownMenuItem(value: 'passport_front', child: Text('Passport (front)')),
                      DropdownMenuItem(value: 'passport_back', child: Text('Passport (back)')),
                      DropdownMenuItem(value: 'driver_license_front', child: Text('Driving licence (front)')),
                      DropdownMenuItem(value: 'driver_license_back', child: Text('Driving licence (back)')),
                      DropdownMenuItem(value: 'tax_id', child: Text('Tax ID')),
                      DropdownMenuItem(value: 'insurance', child: Text('Insurance')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setLocal(() => selected = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'This will create/replace the slot: documents/$selected',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx2).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx2).pop();
                    await _adminPickAndUploadDriverDoc(
                      driverRef: driverRef,
                      docType: selected,
                    );
                  },
                  icon: const Icon(Icons.upload_outlined, size: 18),
                  label: const Text('Choose file'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  // ---------------------------------------------------------------------------
  // Driver details dialog: responsive layout (no stats / weekly scores)
  // ---------------------------------------------------------------------------

  Future<void> _openDriverDetails(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        final media = MediaQuery.of(ctx).size;
        bool showPin = false;

        return StatefulBuilder(
          builder: (ctxState, setStateDialog) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 980,
                  maxHeight: media.height - 32,
                ),
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: driverDoc.reference.snapshots(),
                  builder: (ctx2, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snap.data!.data() ?? {};
                    final name = (data['driverName'] ?? '').toString();
                    final email = (data['email'] ?? '').toString();
                    final tid = (data['transporterId'] ?? '').toString();
                    final pin = (data['notificationPin'] ?? '').toString().trim();
                    final canEditPin = (_uid != null && tid.isNotEmpty);

                    // onboarding map
                    final raw = data['onboarding'];
                    Map<String, dynamic> onboarding = const {};
                    if (raw is Map<String, dynamic>) {
                      onboarding = raw;
                    } else if (raw is Map) {
                      onboarding =
                          raw.map((k, v) => MapEntry(k.toString(), v));
                    }
                    final hasOnboarding = onboarding.isNotEmpty;
                    final profileImage = _profileImageFromOnboarding(onboarding);

                    return Container(
                      color: const Color(0xFFF4F5FB),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Scrollable content
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                              // ------------------------------------------------------------------
                              // TOP CARD (responsive)
                              // ------------------------------------------------------------------
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isNarrow =
                                        constraints.maxWidth < 720;

                                    // LEFT: avatar + ID/licence preview
                                    final left = SizedBox(
                                      width: isNarrow ? double.infinity : 230,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(18),
                                            child: Container(
                                              height: 180,
                                              width: double.infinity,
                                              color: const Color(0xFFE5E7EB),
                                              child: profileImage == null
                                                  ? const Icon(
                                                      Icons.person,
                                                      size: 72,
                                                      color: Color(0xFF9CA3AF),
                                                    )
                                                  : Image(
                                                      image: profileImage,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: StreamBuilder<
                                                DocumentSnapshot<Map<String, dynamic>>>(
                                              stream: snap.data!.reference
                                                  .collection('documents')
                                                  .doc('driver_license_front')
                                                  .snapshots(),
                                              builder: (context, docSnap) {
                                                final docData =
                                                    docSnap.data?.data() ??
                                                        const <String, dynamic>{};
                                                final url =
                                                    (docData['downloadUrl'] ?? '')
                                                        .toString();
                                                final fileName =
                                                    (docData['fileName'] ?? '')
                                                        .toString();
                                                final hasUrl = url.isNotEmpty;
                                                final path = Uri.tryParse(url)
                                                        ?.path
                                                        .toLowerCase() ??
                                                    '';
                                                final isImage = path.endsWith('.png') ||
                                                    path.endsWith('.jpg') ||
                                                    path.endsWith('.jpeg') ||
                                                    path.endsWith('.webp');

                                                Widget child;
                                                if (!hasUrl) {
                                                  child = Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFE5E7EB)
                                                              .withOpacity(0.9),
                                                          borderRadius:
                                                              BorderRadius.circular(10),
                                                        ),
                                                        child: const Icon(
                                                          Icons.badge,
                                                          size: 24,
                                                          color: Color(0xFF4B5563),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      const Expanded(
                                                        child: Text(
                                                          'Driving licence (front) preview',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Color(0xFF6B7280),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else if (isImage) {
                                                  child = kIsWeb
                                                      ? buildWebImagePreview(url)
                                                      : Image.network(
                                                          url,
                                                          fit: BoxFit.cover,
                                                          loadingBuilder: (context,
                                                              child,
                                                              loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2),
                                                            );
                                                          },
                                                          errorBuilder: (context,
                                                              error, stackTrace) {
                                                            return const Center(
                                                              child: Icon(
                                                                Icons
                                                                    .image_not_supported_outlined,
                                                                color:
                                                                    Color(0xFF9CA3AF),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                } else {
                                                  child = Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.insert_drive_file,
                                                        size: 18,
                                                        color: Color(0xFF6B7280),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          fileName.isEmpty
                                                              ? 'Driving licence (front)'
                                                              : fileName,
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Color(0xFF6B7280),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }

                                                return Container(
                                                  height: 80,
                                                  width: double.infinity,
                                                  color: const Color(0xFFF3F4F6),
                                                  padding: hasUrl && isImage
                                                      ? EdgeInsets.zero
                                                      : const EdgeInsets.all(10),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    // ---------- Onboarding details with sections ----------
                                    Widget buildOnboardingDetails(bool narrow) {
                                      // ----- full list of fields, grouped into sections -----

                                      final personalSection = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Personal details',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFA8a29e),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Full name',
                                            value: onboarding['fullName'],
                                            fieldKey: 'fullName',
                                          ),

                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Name at birth',
                                            value: onboarding['nameAtBirth'],
                                            fieldKey: 'nameAtBirth'
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Date of birth',
                                            value: onboarding['dateOfBirth'],
                                            fieldKey: 'dateOfBirth',
                                            isDate: true,
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Phone',
                                            value: onboarding['phone'],
                                            fieldKey: 'phone',
                                          ),
                                        ],
                                      );

                                      final originSection = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Origin',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFA8a29e),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'City of birth',
                                            value: onboarding['birthCity'],
                                            fieldKey: 'birthCity',
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'State of birth',
                                            value: onboarding['birthState'],
                                            fieldKey: 'birthState',
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Nationality (ID card)',
                                            value: onboarding['nationalityIdCard'],
                                            fieldKey: 'nationalityIdCard',
                                          ),
                                        ],
                                      );

                                      final addressSection = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Address',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFA8a29e),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Street address',
                                            value: onboarding['address'],
                                            fieldKey: 'address',
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'City',
                                            value: onboarding['city'],
                                            fieldKey: 'city',
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Postal code',
                                            value: onboarding['postalCode'],
                                            fieldKey: 'postalCode',
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Country',
                                            value: onboarding['country'],
                                            fieldKey: 'country',
                                          ),
                                        ],
                                      );

                                      final documentsDatesSection = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Document expiry dates',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFA8a29e),
                                            ),
                                          ),
                                          const SizedBox(height: 4),

                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Work start date',
                                            value: onboarding['workStartDate'],
                                            fieldKey: 'workStartDate',
                                            isDate: true,
                                          ),

                                          _detailRowReadOnly(
                                            label: 'Probezeit end',
                                            value: (() {
                                              final start = _parseIsoDate(
                                                  onboarding['workStartDate']?.toString());
                                              final end = _probationEndFromStart(start);
                                              return end == null ? '' : _formatDate(end);
                                            })(),
                                          ),

                                          // ✅ Contract expiry now visible
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Contract expiry',
                                            value: onboarding['contractExpiry'],
                                            fieldKey: 'contractExpiry',
                                            isDate: true,
                                          ),

                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Work permit expiry',
                                            value: onboarding['residencePermitExpiry'],
                                            fieldKey: 'residencePermitExpiry',
                                            isDate: true,
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'ID card / passport expiry',
                                            value: onboarding['idDocExpiry'],
                                            fieldKey: 'idDocExpiry',
                                            isDate: true,
                                          ),
                                        ],
                                      );

                                      final licenseSection = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Driving license',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFA8a29e),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Driving license number',
                                            value: onboarding['licenseNumber'],
                                            fieldKey: 'licenseNumber',
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'License expiry date',
                                            value: onboarding['licenseExpiry'],
                                            fieldKey: 'licenseExpiry',
                                            isDate: true,
                                          ),
                                        ],
                                      );

                                      final emergencySection = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Emergency contact',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFA8a29e),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Emergency contact name',
                                            value: onboarding['emergencyContactName'],
                                            fieldKey: 'emergencyContactName',
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Emergency contact phone',
                                            value: onboarding['emergencyContactPhone'],
                                            fieldKey: 'emergencyContactPhone',
                                          ),
                                        ],
                                      );

                                      final paymentSection = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Payment & tax',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFA8a29e),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Bank IBAN',
                                            value: onboarding['bankIban'],
                                            fieldKey: 'bankIban',
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Insurance company',
                                            value: onboarding['insuranceCompany'],
                                            fieldKey: 'insuranceCompany',
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Tax ID',
                                            value: onboarding['taxId'],
                                            fieldKey: 'taxId',
                                          ),
                                        ],
                                      );

                                      final uniformSection = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Uniform',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFA8a29e),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'T-shirt size',
                                            value: onboarding['tShirtSize'],
                                            fieldKey: 'tShirtSize',
                                          ),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Shoe size',
                                            value: onboarding['shoeSize'],
                                            fieldKey: 'shoeSize',
                                          ),
                                        ],
                                      );

                                      final notesSection = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Other notes',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFA8a29e),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _detailRowEditable(
                                            driverRef: snap.data!.reference,
                                            label: 'Notes',
                                            value: onboarding['notes'],
                                            fieldKey: 'notes',
                                          ),
                                        ],
                                      );

                                      if (narrow) {
                                        // Mobile / narrow: all sections in ONE column
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            personalSection,
                                            originSection,
                                            addressSection,
                                            documentsDatesSection,
                                            licenseSection,
                                            emergencySection,
                                            paymentSection,
                                            uniformSection,
                                            notesSection,
                                          ],
                                        );
                                      } else {
                                        // Wide: split sections into two columns
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  personalSection,
                                                  originSection,
                                                  addressSection,
                                                  // emergencySection,
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  documentsDatesSection,
                                                  licenseSection,
                                                  paymentSection,
                                                  uniformSection,
                                                  // notesSection,
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    }

                                    // ---------- RIGHT column: header + onboarding details ----------
                                    final rightColumn = Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SelectableText(
                                                    name.isEmpty ? '(No name)' : name,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  if (email.isNotEmpty)
                                                    SelectableText(
                                                      email,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Color(0xFF6B7280),
                                                      ),
                                                    ),
                                                  if (tid.isNotEmpty)
                                                    SelectableText(
                                                      'Transporter ID: $tid',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xFF9CA3AF),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                _statusChipFromData(data),
                                                const SizedBox(height: 6),
                                                _loginChipFromData(data),
                                                const SizedBox(height: 6),
                                                _expiryChipDetailedFromOnboardingRaw(onboarding),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: const Color(0xFFE5E7EB)),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Notification PIN',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF6B7280),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      pin.isEmpty
                                                          ? 'Not set'
                                                          : (showPin ? pin : '••••'),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w800,
                                                        color: Color(0xFF111827),
                                                        letterSpacing: 2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (pin.isNotEmpty)
                                                IconButton(
                                                  tooltip: showPin ? 'Hide PIN' : 'Show PIN',
                                                  onPressed: () =>
                                                      setStateDialog(() => showPin = !showPin),
                                                  icon: Icon(
                                                    showPin
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color: const Color(0xFF6B7280),
                                                  ),
                                                ),
                                              const SizedBox(width: 6),
                                              OutlinedButton(
                                                onPressed: !canEditPin
                                                    ? null
                                                    : () async {
                                                        await showDialog<void>(
                                                          context: ctx2,
                                                          barrierDismissible: false,
                                                          builder: (_) => SetNotificationPinDialog(
                                                            dspUid: _uid!,
                                                            transporterId: tid.toUpperCase(),
                                                            force: true,
                                                          ),
                                                        );
                                                      },
                                                child: Text(
                                                  pin.isEmpty ? 'Set PIN' : 'Change PIN',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        buildOnboardingDetails(isNarrow),
                                      ],
                                    );

                                    // ---------- Layout: one column on narrow, side-by-side on wide ----------
                                    if (isNarrow) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          left,
                                          const SizedBox(height: 16),
                                          rightColumn, // no Expanded here → avoids the flex error in scroll
                                        ],
                                      );
                                    } else {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          left,
                                          const SizedBox(width: 24),
                                          Expanded(child: rightColumn),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ------------------------------------------------------------------
                              // DOCUMENTS CARD
                              // ------------------------------------------------------------------
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _AdminDriverToolsRow(
                                      onUploadDoc: () => _showAdminUploadDocDialog(snap.data!.reference),
                                    ),
                                    const SizedBox(height: 12),
                                    _DriverDocumentsList(
                                      driverRef: snap.data!.reference,
                                      driverName: name,
                                      onUploadDoc: (docType) =>
                                          _adminPickAndUploadDriverDoc(
                                        driverRef: snap.data!.reference,
                                        docType: docType,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Close'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: !hasOnboarding
                                    ? null
                                    : () {
                                        _exportOnboardingPdf(
                                          driverName: name,
                                          transporterId: tid,
                                          onboarding: onboarding,
                                        );
                                      },
                                child: const Text('Export PDF'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportOnboardingPdf({
    required String driverName,
    required String transporterId,
    required Map<String, dynamic> onboarding,
  }) async {
    final doc = pw.Document();

    pw.Widget _field(String label, dynamic value) {
      final text = (value ?? '').toString();
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 130,
              child: pw.Text(
                label,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Expanded(
              child: pw.Text(text.isEmpty ? '-' : text),
            ),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        build: (ctx) => [
          pw.Text(
            'Driver Onboarding',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Driver: $driverName'),
          pw.Text('Transporter ID: $transporterId'),
          pw.SizedBox(height: 16),
          _field('Full name', onboarding['fullName']),
          _field('Name at birth', onboarding['nameAtBirth']),
          _field('Date of birth', onboarding['dateOfBirth']),
          _field('Phone', onboarding['phone']),
          _field('Street address', onboarding['address']),
          _field('City', onboarding['city']),
          _field('Postal code', onboarding['postalCode']),
          _field('Country', onboarding['country']),
          pw.SizedBox(height: 10),
          _field(
            'Residence permit expiry',
            onboarding['residencePermitExpiry'],
          ),
          pw.SizedBox(height: 10),
          _field('License number', onboarding['licenseNumber']),
          _field('License expiry', onboarding['licenseExpiry']),
          pw.SizedBox(height: 10),
          _field('Emergency contact', onboarding['emergencyContactName']),
          _field('Emergency phone', onboarding['emergencyContactPhone']),
          pw.SizedBox(height: 10),
          _field('Bank IBAN', onboarding['bankIban']),
          _field('Insurance company', onboarding['insuranceCompany']),
          _field('Tax ID', onboarding['taxId']),
          _field('T-shirt size', onboarding['tShirtSize']),
          _field('Notes', onboarding['notes']),
        ],
      ),
    );

    await Printing.layoutPdf(
      name: 'onboarding_$transporterId.pdf',
      onLayout: (format) async => doc.save(),
    );
  }

  // ---------------------------------------------------------------------------
  // Driver list – unified desktop-style layout (for all screen sizes)
  // ---------------------------------------------------------------------------

  Widget _buildDriversList() {
    if (_uid == null) {
      return const Center(
        child: Text('You must be logged in to view drivers.'),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 800;

    return Column(
      children: [
        // 🔹 Top row: default password + "Create login for all" button
        Row(
            children: [
                // 🔍 Search pill
                Expanded(
                flex: 3,
                child: TextField(
                    decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search by name or email...',
                    isDense: isSmall,
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                    ),
                    ),
                    onChanged: (value) {
                    setState(() {
                        _search = value.toLowerCase();
                    });
                    },
                ),
                ),
                const SizedBox(width: 12),

                // 🔐 Default password pill + eye icon
                Expanded(
                flex: 2,
                child: TextField(
                    controller: _bulkPwdCtrl,
                    obscureText: !_bulkPwdVisible,
                    decoration: InputDecoration(
                    labelText: 'Default driver password',
                    isDense: isSmall,
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                        icon: Icon(
                        _bulkPwdVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                        setState(() {
                            _bulkPwdVisible = !_bulkPwdVisible;
                        });
                        },
                    ),
                    ),
                ),
                ),
                const SizedBox(width: 12),

                // 🔑 "Create login for all" button
                SizedBox(
                height: isSmall ? 32 : 36,
                child: FilledButton.icon(
                    onPressed:
                        _busyBulkLogins ? null : _onCreateLoginsForAllDrivers,
                    icon: _busyBulkLogins
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                        )
                        : const Icon(Icons.vpn_key_outlined, size: 18),
                    label: Text(
                    'Create login for all',
                    style: TextStyle(fontSize: isSmall ? 11 : 13),
                    ),
                ),
                ),
            ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_uid!)
                .collection('drivers')
                .orderBy('transporterId')
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snap.hasError) {
                return Center(
                  child: Text('Error: ${snap.error}'),
                );
              }

              final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                  (snap.data?.docs ??
                          <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                      .toList();

              List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered = docs;
              if (_search.isNotEmpty) {
                filtered = docs.where((d) {
                  final data = d.data();
                  final name =
                      (data['driverName'] ?? '').toString().toLowerCase();
                  final email =
                      (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(_search) || email.contains(_search);
                }).toList();
              }

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'No drivers yet.\nImport a CSV or add a driver manually.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              // Single desktop-style layout for all sizes.
              // On very small screens user can scroll horizontally if needed.
              return LayoutBuilder(
                builder: (context, constraints) {
                  final table = Column(
                    children: [
                      // header row
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _headerCell('Profile', flex: 5),
                            _headerCell('Status', flex: 2),
                            _headerCell('Working', flex: 2),
                            _headerCell('Login', flex: 2),
                            _headerCell(
                              'Action',
                              flex: 3,
                              alignment: Alignment.centerRight,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final d = filtered[index];
                            final data = d.data();
                            final name =
                                (data['driverName'] ?? '').toString();
                            final email =
                                (data['email'] ?? '').toString();
                            final hasLogin =
                                (data['hasLogin'] as bool?) ?? false;
                            final active =
                                (data['active'] as bool?) ?? true;

                            final onboardingRaw = data['onboarding'];
                            bool hasOnboarding = false;
                            if (onboardingRaw is Map &&
                                onboardingRaw.isNotEmpty) {
                              hasOnboarding = true;
                            }

                            final statusChip = _statusChipFromData(data);
                            final loginChip = _loginChipFromData(data);
                            final expiryChip =
                                _expiryChipFromOnboardingRaw(onboardingRaw);

                            final profileImage =
                                _profileImageFromOnboarding(onboardingRaw);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: InkWell(
                                      onTap: () => _openDriverDetails(d),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                const Color(0xFFE5E7EB),
                                            backgroundImage: profileImage,
                                            child: profileImage == null
                                                ? Text(
                                                    _initials(name),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          Color(0xFF111827),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name.isEmpty
                                                    ? '(No name)'
                                                    : name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                              if (email.isNotEmpty)
                                                Text(
                                                  email,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              if (hasOnboarding)
                                                const Text(
                                                  'Onboarding completed',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF9CA3AF),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        statusChip,
                                        const SizedBox(height: 4),
                                        expiryChip,
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Switch(
                                          value: active,
                                          onChanged: (_) =>
                                              _onToggleActiveDriver(
                                                  d, active),
                                          activeColor:
                                              const Color(0xFF2563EB),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          active ? 'On' : 'Off',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF4B5563),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: loginChip,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          tooltip: 'View details',
                                          onPressed: () =>
                                              _openDriverDetails(d),
                                          icon: const Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 18,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: hasLogin
                                              ? 'Reset login'
                                              : 'Create login',
                                          onPressed: () =>
                                              _onCreateOrResetLogin(d),
                                          icon: const Icon(
                                            Icons.vpn_key_outlined,
                                            size: 18,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Delete driver',
                                          onPressed: () =>
                                              _onDeleteDriver(d),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );

                  // If screen is very narrow, allow horizontal scroll so layout stays same.
                  if (constraints.maxWidth < 600) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 600,
                        child: table,
                      ),
                    );
                  }

                  return table;
                },
              );
            },
          ),
        ),
      ],
    );
  }

}

// ---------------------------------------------------------------------------
// Small widgets & helpers
// ---------------------------------------------------------------------------

class _DriverActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _DriverActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 800;

    final double vPad = isSmall ? 6 : 10;
    final double hPad = isSmall ? 10 : 14;
    final double fontSize = isSmall ? 11 : 13;

    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        minimumSize: Size(0, isSmall ? 30 : 36),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Small reusable row with label, selectable value, and copy button
class _CopyRow extends StatelessWidget {
  final String label;
  final String value;

  const _CopyRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SelectableText(
            '$label: $value',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: 'Copy $label',
          onPressed: () async {
            if (value.isEmpty) return;
            await Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label copied')),
            );
          },
        ),
      ],
    );
  }
}

class _AdminDriverToolsRow extends StatelessWidget {
  final VoidCallback onUploadDoc;

  const _AdminDriverToolsRow({
    required this.onUploadDoc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Admin tools',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: onUploadDoc,
          icon: const Icon(Icons.upload_outlined, size: 18),
          label: const Text('Upload doc'),
        ),
      ],
    );
  }
}



class _DriverDocumentsList extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> driverRef;
  final String driverName;
  final Future<void> Function(String docType) onUploadDoc;

  const _DriverDocumentsList({
    required this.driverRef,
    required this.driverName,
    required this.onUploadDoc,
  });

  String _docLabel(String docType) {
    switch (docType) {
      case 'resident_permit':
        return 'Work permit';
      case 'driver_license_front':
        return 'Driving licence (front)';
      case 'driver_license_back':
        return 'Driving licence (back)';
      case 'id_card_front':
        return 'ID card (front)';
      case 'id_card_back':
        return 'ID card (back)';
      case 'passport_front':
        return 'Passport (front)';
      case 'passport_back':
        return 'Passport (back)';
      case 'tax_id':
        return 'Tax ID';
      case 'insurance':
        return 'Insurance';
      case 'contract':
        return 'Contract';
      default:
        return docType;
    }
  }

  String _fileExtension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return '';
    return name.substring(dot + 1);
  }

  String _sanitizeToken(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s*/\s*'), '_')
        .replaceAll(RegExp(r'[()]'), '')
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String _downloadNameForDoc({
    required String docType,
    required String url,
    required String fileName,
  }) {
    final label = _docLabel(docType);
    var base = _sanitizeToken(label);
    if (base.isEmpty) base = _sanitizeToken(docType);
    final driver = _sanitizeToken(driverName);
    if (driver.isNotEmpty) {
      base = '${base}_$driver';
    }

    var ext = fileName.isNotEmpty ? _fileExtension(fileName) : '';
    if (ext.isEmpty) {
      final path = Uri.tryParse(url)?.path ?? '';
      ext = _fileExtension(path.split('/').last);
    }
    return ext.isEmpty ? base : '$base.$ext';
  }

  Future<void> _downloadDoc({
    required BuildContext context,
    required String url,
    required String fileName,
  }) async {
    if (url.isEmpty) return;
    if (kIsWeb) {
      try {
        final bytes = await fb.FirebaseStorage.instance
            .refFromURL(url)
            .getData(50 * 1024 * 1024);
        if (bytes != null) {
          await downloadWebBytes(bytes, fileName);
          return;
        }
      } catch (_) {
        // Fall back to URL download when blob access is blocked.
      }
    }
    try {
      await downloadWebFile(url, fileName);
    } catch (e) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch document URL'),
          ),
        );
      }
    }
  }

  Future<void> _deleteDoc({
    required BuildContext context,
    required String docType,
    required String url,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete document?'),
          content: Text('This will delete ${_docLabel(docType)}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      if (url.isNotEmpty) {
        await fb.FirebaseStorage.instance.refFromURL(url).delete();
      }
      await driverRef.collection('documents').doc(docType).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_docLabel(docType)} deleted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete document: $e')),
      );
    }
  }

  Future<void> _showDocPreview({
    required BuildContext context,
    required String docType,
    required String label,
    required String url,
    required String fileName,
  }) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    final isImage = path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp');
    final isPdf = path.endsWith('.pdf');

    if (isImage) {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 500),
                    child: InteractiveViewer(
                      child: kIsWeb
                          ? buildWebImagePreview(url)
                          : Image.network(
                              url,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Preview unavailable for this image.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton(
                                        onPressed: () => _downloadDoc(
                                          context: context,
                                          url: url,
                                          fileName: _downloadNameForDoc(
                                            docType: docType,
                                            url: url,
                                            fileName: fileName,
                                          ),
                                        ),
                                        child: const Text('Download'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    if (isPdf) {
      if (kIsWeb) {
        await showDialog<void>(
          context: context,
          builder: (ctx) {
            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 520,
                      child: buildWebPdfPreview(url),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 520,
                    child: FutureBuilder<Uint8List>(
                      future: () async {
                        final data = await NetworkAssetBundle(uri).load('');
                        return data.buffer.asUint8List();
                      }(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2));
                        }
                        if (snap.hasError || snap.data == null) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Failed to load PDF preview.'),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () => _downloadDoc(
                                    context: context,
                                    url: url,
                                    fileName: _downloadNameForDoc(
                                      docType: docType,
                                      url: url,
                                      fileName: fileName,
                                    ),
                                  ),
                                  child: const Text('Download'),
                                ),
                              ],
                            ),
                          );
                        }
                        return PdfPreview(
                          build: (format) async => snap.data!,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          allowPrinting: false,
                          allowSharing: false,
                          useActions: false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(label),
          content: const Text(
            'Preview is not available for this file type. Use Download to open it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _downloadDoc(
                  context: context,
                  url: url,
                  fileName: _downloadNameForDoc(
                    docType: docType,
                    url: url,
                    fileName: fileName,
                  ),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driverRef
          .collection('documents')
          .orderBy('uploadedAt', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }

        final docs = snap.data?.docs ?? [];
        final docsByType = <String, Map<String, dynamic>>{
          for (final d in docs) (d.data()['docType'] ?? d.id).toString(): d.data(),
        };

        const docTypes = <String>[
          'contract',
          'resident_permit',
          'tax_id',
          'insurance',
        ];

        const docPairs = <List<String>>[
          ['id_card_front', 'id_card_back'],
          ['passport_front', 'passport_back'],
          ['driver_license_front', 'driver_license_back'],
        ];

        Widget docTile(String docType) {
          final data = docsByType[docType] ?? const <String, dynamic>{};
          final name = (data['fileName'] ?? 'Not uploaded').toString();
          final url = (data['downloadUrl'] ?? '').toString();
          final hasUrl = url.isNotEmpty;

          return Material(
            color: Colors.transparent,
            child: InkWell(
                  onTap: !hasUrl
                      ? null
                      : () => _showDocPreview(
                            context: context,
                            docType: docType,
                            label: _docLabel(docType),
                            url: url,
                            fileName: name,
                          ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE1E4EA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _docLabel(docType),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => onUploadDoc(docType),
                      icon: const Icon(Icons.upload_outlined, size: 16),
                      label: const Text('Upload'),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.download, size: 18),
                      tooltip: 'Download',
                      onPressed: !hasUrl
                          ? null
                          : () => _downloadDoc(
                                context: context,
                                url: url,
                                fileName: _downloadNameForDoc(
                                  docType: docType,
                                  url: url,
                                  fileName: name,
                                ),
                              ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: 'Delete',
                      onPressed: !hasUrl
                          ? null
                          : () => _deleteDoc(
                                context: context,
                                docType: docType,
                                url: url,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            ...docTypes.map((docType) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: docTile(docType),
              );
            }),
            ...docPairs.map((pair) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: docTile(pair[0])),
                    const SizedBox(width: 10),
                    Expanded(child: docTile(pair[1])),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// helpers for Dribbble-style layout

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  final firstTwo = parts.take(2).toList();
  if (firstTwo.isEmpty) return '?';
  if (firstTwo.length == 1) {
    return firstTwo.first.characters.first.toUpperCase();
  }
  return (firstTwo[0].characters.first + firstTwo[1].characters.first)
      .toUpperCase();
}

Widget _headerCell(
  String text, {
  int flex = 1,
  Alignment alignment = Alignment.centerLeft,
}) {
  return Expanded(
    flex: flex,
    child: Align(
      alignment: alignment,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
    ),
  );
}

Widget _statusChipFromData(Map<String, dynamic> data) {
  final active = (data['active'] as bool?) ?? true;
  final onboardingRaw = data['onboarding'];
  final hasOnboarding = onboardingRaw is Map && onboardingRaw.isNotEmpty;

  String label;
  Color bg;
  Color fg;

  if (!hasOnboarding) {
    label = 'Pending';
    bg = const Color(0xFFFDE68A);
    fg = const Color(0xFF92400E);
  } else if (active) {
    label = 'Approved';
    bg = const Color(0xFFD1FAE5);
    fg = const Color(0xFF065F46);
  } else {
    label = 'Rejected';
    bg = const Color(0xFFFEE2E2);
    fg = const Color(0xFF991B1B);
  }

  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    ),
  );
}

Widget _loginChipFromData(Map<String, dynamic> data) {
  final hasLogin = (data['hasLogin'] as bool?) ?? false;

  final label = hasLogin ? 'Login created' : 'No login';
  final bg = hasLogin ? const Color(0xFFDCFCE7) : const Color(0xFFE5E7EB);
  final fg = hasLogin ? const Color(0xFF166534) : const Color(0xFF4B5563);

  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Expiry helper + chip (licence / residence permit)
// ---------------------------------------------------------------------------

DateTime? _parseIsoDate(String? value) {
  final t = value?.trim();
  if (t == null || t.isEmpty) return null;
  final slashMatch = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{4})$');
  final match = slashMatch.firstMatch(t);
  if (match != null) {
    final d = int.tryParse(match.group(1)!);
    final m = int.tryParse(match.group(2)!);
    final y = int.tryParse(match.group(3)!);
    if (d != null && m != null && y != null) {
      return DateTime(y, m, d);
    }
  }
  try {
    return DateTime.parse(t);
  } catch (_) {
    return null;
  }
}

DateTime _addMonthsClamped(DateTime date, int months) {
  final totalMonths = (date.month - 1) + months;
  final year = date.year + (totalMonths ~/ 12);
  final month = (totalMonths % 12) + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = date.day <= lastDay ? date.day : lastDay;
  return DateTime(year, month, day);
}

DateTime? _probationEndFromStart(DateTime? start) {
  if (start == null) return null;
  final sixMonthsLater = _addMonthsClamped(start, 6);
  return sixMonthsLater.subtract(const Duration(days: 1));
}

/// Returns 'expired', 'soon', or null
String? _expiryFlag(String? date1, String? date2) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  bool anyExpired = false;
  bool anySoon = false;

  void check(String? s) {
    final d = _parseIsoDate(s);
    if (d == null) return;
    final diff = d.difference(today).inDays;
    if (diff < 0) {
      anyExpired = true;
    } else if (diff <= 30) {
      anySoon = true;
    }
  }

  check(date1);
  check(date2);

  if (anyExpired) return 'expired';
  if (anySoon) return 'soon';
  return null;
}

Widget _expiryChipFromOnboardingRaw(dynamic onboardingRaw) {
  Map<String, dynamic> onboarding = const {};
  if (onboardingRaw is Map<String, dynamic>) {
    onboarding = onboardingRaw;
  } else if (onboardingRaw is Map) {
    onboarding = onboardingRaw.map((k, v) => MapEntry(k.toString(), v));
  }

  if (onboarding.isEmpty) return const SizedBox.shrink();

  final contractDate =
      _parseIsoDate(onboarding['contractExpiry']?.toString());
  final probationEnd = _probationEndFromStart(
      _parseIsoDate(onboarding['workStartDate']?.toString()));

  final workPermitDate =
      _parseIsoDate(onboarding['residencePermitExpiry']?.toString());
  final licenseDate =
      _parseIsoDate(onboarding['licenseExpiry']?.toString());
  final idDocDate =
      _parseIsoDate(onboarding['idDocExpiry']?.toString());

  if (contractDate == null &&
      workPermitDate == null &&
      licenseDate == null &&
      idDocDate == null &&
      probationEnd == null) {
    return const SizedBox.shrink();
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  int expiredCount = 0;
  int soonCount = 0;
  bool pExpired = false;
  bool pSoon = false;

  void check(DateTime? d) {
    if (d == null) return;
    final diff = d.difference(today).inDays;
    if (diff < 0) {
      expiredCount++;
    } else if (diff <= 30) {
      soonCount++;
    }
  }

  check(contractDate);
  check(workPermitDate);
  check(licenseDate);
  check(idDocDate);
  if (probationEnd != null) {
    final diff = probationEnd.difference(today).inDays;
    if (diff < 0) {
      pExpired = true;
      expiredCount++;
    } else if (diff <= 30) {
      pSoon = true;
      soonCount++;
    }
  }

  if (expiredCount == 0 && soonCount == 0) return const SizedBox.shrink();

  late String label;
  late Color bg;
  late Color fg;

  if (expiredCount > 0) {
    final onlyProbation = pExpired && expiredCount == 1 && soonCount == 0;
    label = onlyProbation
        ? 'Probezeit expired'
        : '$expiredCount document${expiredCount > 1 ? 's' : ''} expired';
    bg = const Color(0xFFFEE2E2);
    fg = const Color(0xFF991B1B);
  } else {
    final onlyProbation = pSoon && soonCount == 1;
    label = onlyProbation
        ? 'Probezeit expiring soon'
        : '$soonCount document${soonCount > 1 ? 's' : ''} expiring soon';
    // ✅ ORANGE for "soon"
    bg = const Color(0xFFFFEDD5);
    fg = const Color(0xFF9A3412);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: fg,
      ),
    ),
  );
}




String _joinNames(List<String> names) {
  if (names.isEmpty) return '';
  if (names.length == 1) return names[0];
  if (names.length == 2) return '${names[0]} & ${names[1]}';
  return names.join(', ');
}

Widget _expiryChipDetailedFromOnboardingRaw(dynamic onboardingRaw) {
  Map<String, dynamic> onboarding = const {};
  if (onboardingRaw is Map<String, dynamic>) {
    onboarding = onboardingRaw;
  } else if (onboardingRaw is Map) {
    onboarding = onboardingRaw.map((k, v) => MapEntry(k.toString(), v));
  }

  if (onboarding.isEmpty) return const SizedBox.shrink();

  final contractDate =
      _parseIsoDate(onboarding['contractExpiry']?.toString());
  final probationEnd = _probationEndFromStart(
      _parseIsoDate(onboarding['workStartDate']?.toString()));
  final workPermitDate =
      _parseIsoDate(onboarding['residencePermitExpiry']?.toString());
  final licenseDate = _parseIsoDate(onboarding['licenseExpiry']?.toString());
  final idDocDate = _parseIsoDate(onboarding['idDocExpiry']?.toString());

  if (contractDate == null &&
      workPermitDate == null &&
      licenseDate == null &&
      idDocDate == null &&
      probationEnd == null) {
    return const SizedBox.shrink();
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  bool cExpired = false, cSoon = false;
  bool wpExpired = false, wpSoon = false;
  bool licExpired = false, licSoon = false;
  bool idExpired = false, idSoon = false;
  bool pExpired = false, pSoon = false;

  void check(DateTime? d, void Function() markExpired, void Function() markSoon) {
    if (d == null) return;
    final diff = d.difference(today).inDays;
    if (diff < 0) {
      markExpired();
    } else if (diff <= 30) {
      markSoon();
    }
  }

  check(contractDate, () => cExpired = true, () => cSoon = true);
  check(workPermitDate, () => wpExpired = true, () => wpSoon = true);
  check(licenseDate, () => licExpired = true, () => licSoon = true);
  check(idDocDate, () => idExpired = true, () => idSoon = true);
  check(probationEnd, () => pExpired = true, () => pSoon = true);

  final expiredDocs = <String>[];
  final soonDocs = <String>[];

  if (cExpired) expiredDocs.add('Contract');
  if (wpExpired) expiredDocs.add('Work permit');
  if (licExpired) expiredDocs.add('Driving licence');
  if (idExpired) expiredDocs.add('ID / Passport');
  if (pExpired) expiredDocs.add('Probezeit');

  if (!cExpired && cSoon) soonDocs.add('Contract');
  if (!wpExpired && wpSoon) soonDocs.add('Work permit');
  if (!licExpired && licSoon) soonDocs.add('Driving licence');
  if (!idExpired && idSoon) soonDocs.add('ID / Passport');
  if (!pExpired && pSoon) soonDocs.add('Probezeit');

  if (expiredDocs.isEmpty && soonDocs.isEmpty) return const SizedBox.shrink();

  Widget pill(String label, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  // Build separate pills (red + orange), stacked neatly
  final pills = <Widget>[];

  if (expiredDocs.isNotEmpty) {
    pills.add(
      pill(
        '${_joinNames(expiredDocs)} expired',
        bg: const Color(0xFFFEE2E2),
        fg: const Color(0xFF991B1B),
      ),
    );
  }

  if (soonDocs.isNotEmpty) {
    pills.add(
      pill(
        '${_joinNames(soonDocs)} expiring soon',
        bg: const Color(0xFFFFEDD5), // orange
        fg: const Color(0xFF9A3412),
      ),
    );
  }

  if (pills.length == 1) return pills.first;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pills[0],
      const SizedBox(height: 6),
      pills[1],
    ],
  );
}




// ---------------------------------------------------------------------------
// Profile image helper (from onboarding.profilePhotoBase64)
// ---------------------------------------------------------------------------

ImageProvider? _profileImageFromOnboarding(dynamic onboardingRaw) {
  if (onboardingRaw == null) return null;

  Map<String, dynamic> onboarding;

  if (onboardingRaw is Map<String, dynamic>) {
    onboarding = onboardingRaw;
  } else if (onboardingRaw is Map) {
    onboarding = onboardingRaw.map((k, v) => MapEntry(k.toString(), v));
  } else {
    return null;
  }

  final val = onboarding['profilePhotoBase64'];
  if (val == null) return null;
  final s = val.toString();
  if (s.isEmpty) return null;

  try {
    final bytes = base64Decode(s);
    return MemoryImage(bytes);
  } catch (_) {
    return null;
  }
}
