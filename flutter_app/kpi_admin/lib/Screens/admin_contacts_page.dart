// lib/Screens/admin_contacts_page.dart
//
// „Kontakte" — eigene Seite für Werkstätten, Leasing-/Mietpartner und
// sonstige Ansprechpartner des DSP.
//
// Die Daten liegen weiterhin unter users/{dspUid}/fleet_references
// (gleiche Collection wie die bisherigen Fleet-Hub-„Referenzen") — so
// bleiben alle bestehenden Einträge erhalten und der Grounding-Dialog
// im Fleet Hub kann sie unverändert zur Zuordnung anbieten.
// Schema je Doc: {name, url, email, phone, address, category, note,
// createdAt, updatedAt} — nur `name` ist Pflicht. Die Adresse ist
// klickbar: gespeicherter Maps-Link gewinnt, sonst Google-Maps-Suche
// nach der Adresse.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_scope.dart';
import '../widgets/clearable_search_field.dart';

/// Feste Kategorien — bewusst kurz gehalten; „Sonstiges" fängt alles ab.
const List<String> kContactCategories = <String>[
  'workshop',
  'leasing',
  'rental',
  'insurance',
  'other',
];

String contactCategoryLabel(String category, bool de) {
  switch (category) {
    case 'workshop':
      return de ? 'Werkstatt' : 'Workshop';
    case 'leasing':
      return de ? 'Leasingpartner' : 'Leasing partner';
    case 'rental':
      return de ? 'Vermietung' : 'Rental';
    case 'insurance':
      return de ? 'Versicherung' : 'Insurance';
    default:
      return de ? 'Sonstiges' : 'Other';
  }
}

IconData _contactCategoryIcon(String category) {
  switch (category) {
    case 'workshop':
      return Icons.build_circle_outlined;
    case 'leasing':
      return Icons.request_quote_outlined;
    case 'rental':
      return Icons.car_rental_outlined;
    case 'insurance':
      return Icons.shield_outlined;
    default:
      return Icons.contacts_outlined;
  }
}

class AdminContactsPage extends StatefulWidget {
  const AdminContactsPage({super.key});

  @override
  State<AdminContactsPage> createState() => _AdminContactsPageState();
}

class _AdminContactsPageState extends State<AdminContactsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  String? _categoryFilter; // null = alle

  String? get _uid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fleet_references');

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openLink(String raw) async {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _editContact({
    DocumentSnapshot<Map<String, dynamic>>? existing,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final de = Localizations.localeOf(context).languageCode == 'de';
    final data = existing?.data() ?? const <String, dynamic>{};

    final nameCtrl =
        TextEditingController(text: (data['name'] ?? '').toString());
    final urlCtrl = TextEditingController(text: (data['url'] ?? '').toString());
    final emailCtrl =
        TextEditingController(text: (data['email'] ?? '').toString());
    final phoneCtrl =
        TextEditingController(text: (data['phone'] ?? '').toString());
    final addressCtrl =
        TextEditingController(text: (data['address'] ?? '').toString());
    final noteCtrl =
        TextEditingController(text: (data['note'] ?? '').toString());
    var category = (data['category'] ?? 'other').toString();
    if (!kContactCategories.contains(category)) category = 'other';

    InputDecoration deco(String label, {String? hint}) => InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            existing == null
                ? (de ? 'Kontakt anlegen' : 'Add contact')
                : (de ? 'Kontakt bearbeiten' : 'Edit contact'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: existing == null,
                    textCapitalization: TextCapitalization.words,
                    decoration: deco(de ? 'Name *' : 'Name *'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: deco(de ? 'Kategorie' : 'Category'),
                    items: [
                      for (final c in kContactCategories)
                        DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(_contactCategoryIcon(c),
                                  size: 16, color: const Color(0xFF6B7280)),
                              const SizedBox(width: 8),
                              Text(contactCategoryLabel(c, de)),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => category = v ?? 'other'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: deco(de ? 'Telefon' : 'Phone'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: deco('E-Mail'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: deco(
                      de ? 'Adresse' : 'Address',
                      hint: de
                          ? 'Straße Nr., PLZ Ort'
                          : 'Street no., ZIP city',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: urlCtrl,
                    keyboardType: TextInputType.url,
                    decoration: deco(
                      de ? 'Link (Maps, Website …)' : 'Link (Maps, website …)',
                      hint: 'https://…',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: deco(
                      de ? 'Notiz' : 'Note',
                      hint: de
                          ? 'z. B. Ansprechpartner, Öffnungszeiten'
                          : 'e.g. contact person, opening hours',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(de ? 'Abbrechen' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.of(ctx).pop(true);
              },
              child: Text(de ? 'Speichern' : 'Save'),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !mounted) return;

    final payload = <String, dynamic>{
      'name': nameCtrl.text.trim(),
      'url': urlCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'note': noteCtrl.text.trim(),
      'category': category,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    try {
      if (existing == null) {
        payload['createdAt'] = FieldValue.serverTimestamp();
        await _col(uid).add(payload);
      } else {
        await existing.reference.set(payload, SetOptions(merge: true));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFB42318),
          content: Text(
            de ? 'Speichern fehlgeschlagen: $e' : 'Save failed: $e',
          ),
        ),
      );
    }
  }

  Future<void> _deleteContact(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final name = (doc.data()?['name'] ?? '').toString();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          de ? 'Kontakt löschen?' : 'Delete contact?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Text(
          de
              ? '„$name" wird entfernt. Bereits gespeicherte Grounding-'
                  'Zuordnungen behalten den Namen als Text.'
              : '"$name" will be removed. Existing grounding assignments '
                  'keep the name as plain text.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: const Color(0xFFB42318)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(de ? 'Löschen' : 'Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await doc.reference.delete();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          de ? 'Kontakte' : 'Contacts',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          de
                              ? 'Werkstätten, Leasing- und Mietpartner — im '
                                  'Fleet Hub beim Grounding auswählbar.'
                              : 'Workshops, leasing and rental partners — '
                                  'selectable when grounding in the Fleet Hub.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _editContact(),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(de ? 'Kontakt' : 'Contact'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _search = v),
                      decoration: InputDecoration(
                        hintText: de ? 'Suchen …' : 'Search…',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: buildSearchClearButton(
                          context: context,
                          value: _search,
                          onClear: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text(de ? 'Alle' : 'All'),
                      selected: _categoryFilter == null,
                      onSelected: (_) =>
                          setState(() => _categoryFilter = null),
                    ),
                    for (final c in kContactCategories) ...[
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: Text(contactCategoryLabel(c, de)),
                        selected: _categoryFilter == c,
                        onSelected: (_) =>
                            setState(() => _categoryFilter = c),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _col(uid).orderBy('name').snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting &&
                        !snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final needle = _search.trim().toLowerCase();
                    final docs = (snap.data?.docs ?? const [])
                        .where((d) {
                          final x = d.data();
                          final cat = (x['category'] ?? 'other').toString();
                          if (_categoryFilter != null &&
                              cat != _categoryFilter) {
                            return false;
                          }
                          if (needle.isEmpty) return true;
                          return <String>[
                            (x['name'] ?? '').toString(),
                            (x['email'] ?? '').toString(),
                            (x['phone'] ?? '').toString(),
                            (x['note'] ?? '').toString(),
                          ].any((v) => v.toLowerCase().contains(needle));
                        })
                        .toList(growable: false);

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.contacts_outlined,
                                size: 40, color: Color(0xFF9CA3AF)),
                            const SizedBox(height: 10),
                            Text(
                              de
                                  ? 'Noch keine Kontakte. Lege den ersten an '
                                      '— z. B. deine Werkstatt.'
                                  : 'No contacts yet. Add your first one — '
                                      'e.g. your workshop.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final x = doc.data();
                        final name = (x['name'] ?? '').toString();
                        final cat = (x['category'] ?? 'other').toString();
                        final phone = (x['phone'] ?? '').toString().trim();
                        final email = (x['email'] ?? '').toString().trim();
                        final url = (x['url'] ?? '').toString().trim();
                        final address =
                            (x['address'] ?? '').toString().trim();
                        final note = (x['note'] ?? '').toString().trim();

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.codriverGreen
                                      .withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _contactCategoryIcon(cat),
                                  size: 19,
                                  color: AppColors.codriverDeep,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            contactCategoryLabel(cat, de),
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (note.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        note,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                    if (phone.isNotEmpty ||
                                        email.isNotEmpty ||
                                        address.isNotEmpty ||
                                        url.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: [
                                          if (phone.isNotEmpty)
                                            _ContactActionChip(
                                              icon: Icons.phone_outlined,
                                              label: phone,
                                              onTap: () =>
                                                  _openLink('tel:$phone'),
                                            ),
                                          if (email.isNotEmpty)
                                            _ContactActionChip(
                                              icon: Icons.mail_outline,
                                              label: email,
                                              onTap: () =>
                                                  _openLink('mailto:$email'),
                                            ),
                                          // Adresse klickbar: der
                                          // hinterlegte Maps-Link gewinnt,
                                          // sonst Google-Maps-Suche nach
                                          // der Adresse.
                                          if (address.isNotEmpty)
                                            _ContactActionChip(
                                              icon: Icons.location_on_outlined,
                                              label: address,
                                              onTap: () => _openLink(
                                                url.isNotEmpty
                                                    ? url
                                                    : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
                                              ),
                                            ),
                                          if (url.isNotEmpty &&
                                              address.isEmpty)
                                            _ContactActionChip(
                                              icon: Icons.map_outlined,
                                              label: 'Google Maps',
                                              onTap: () => _openLink(url),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: de ? 'Bearbeiten' : 'Edit',
                                onPressed: () =>
                                    _editContact(existing: doc),
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18, color: Color(0xFF6B7280)),
                              ),
                              IconButton(
                                tooltip: de ? 'Löschen' : 'Delete',
                                onPressed: () => _deleteContact(doc),
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: Color(0xFFB42318)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactActionChip extends StatelessWidget {
  const _ContactActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.codriverGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.codriverGreen.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.codriverDeep),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.codriverDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
