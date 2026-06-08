// lib/Screens/admin_recruiting_panel.dart
//
// Admin Recruiting panel — lives inside the Drivers Hub as a top-level
// tab. Internally split by PillTabBar into:
//   • Local / EU — applicants who don't need a work-visa workflow.
//   • Non-EU / Working Visa — applicants for whom we have to file
//     an Arbeitsvisum request.
//
// Each tab streams `users/{adminUid}/recruiting_applications` filtered
// by channel. A Share-Link button copies the public URL of the form
// so the admin can hand it out via WhatsApp / email.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/recruiting_application.dart';
import '../models/recruiting_form_config.dart';
import '../services/recruiting_repository.dart';
import '../services/recruiting_slug_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/co_button.dart';
import '../widgets/pill_tab_bar.dart';
import 'add_driver_dialog.dart';
import 'admin_recruiting_form_builder_page.dart';

class AdminRecruitingPanel extends StatefulWidget {
  const AdminRecruitingPanel({super.key, required this.adminUid});
  final String adminUid;

  @override
  State<AdminRecruitingPanel> createState() => _AdminRecruitingPanelState();
}

class _AdminRecruitingPanelState extends State<AdminRecruitingPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _repo = RecruitingRepository();
  String? _brandSlug; // e.g. "arion" — looked up once on init.

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadBrandSlug();
  }

  Future<void> _loadBrandSlug() async {
    final slug = await RecruitingSlugService.slugFor(widget.adminUid);
    if (!mounted) return;
    setState(() => _brandSlug = slug);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String _publicFormUrl(RecruitingChannel channel) {
    final base = Uri.base;
    // Prefer the short branded slug URL when available; otherwise fall
    // back to the legacy ?dsp=<long-uid>&type=… form so existing
    // customers without a slug keep working.
    if (_brandSlug != null && _brandSlug!.isNotEmpty) {
      final typeSegment = channel == RecruitingChannel.visa ? '/visa' : '';
      return '${base.origin}/#/jobs/$_brandSlug$typeSegment';
    }
    return '${base.origin}/#/jobs?dsp=${widget.adminUid}'
        '&type=${channel.value}';
  }

  Future<void> _shareLink(RecruitingChannel channel) async {
    final url = _publicFormUrl(channel);
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.codriverDeep,
        content: Text(
          'Link copied · $url',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _openLink(RecruitingChannel channel) async {
    final url = Uri.parse(_publicFormUrl(channel));
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _openFormBuilder() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AdminRecruitingFormBuilderPage(
          adminUid: widget.adminUid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: PillTabBar(
                controller: _tabs,
                tabs: const ['Local / EU', 'Non-EU / Working Visa'],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _openFormBuilder,
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Form builder',
              color: AppColors.codriverDeep,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.green50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.codriverGreen
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _ChannelTab(
                channel: RecruitingChannel.local,
                stream: _repo.watchByChannel(
                  adminUid: widget.adminUid,
                  channel: RecruitingChannel.local,
                ),
                onShareLink: () => _shareLink(RecruitingChannel.local),
                onOpenLink: () => _openLink(RecruitingChannel.local),
                onUpdateStatus: (id, status) => _repo.updateStatus(
                  adminUid: widget.adminUid,
                  applicationId: id,
                  status: status,
                ),
                onDelete: (id) => _repo.delete(
                  adminUid: widget.adminUid,
                  applicationId: id,
                ),
              ),
              _ChannelTab(
                channel: RecruitingChannel.visa,
                stream: _repo.watchByChannel(
                  adminUid: widget.adminUid,
                  channel: RecruitingChannel.visa,
                ),
                onShareLink: () => _shareLink(RecruitingChannel.visa),
                onOpenLink: () => _openLink(RecruitingChannel.visa),
                onUpdateStatus: (id, status) => _repo.updateStatus(
                  adminUid: widget.adminUid,
                  applicationId: id,
                  status: status,
                ),
                onDelete: (id) => _repo.delete(
                  adminUid: widget.adminUid,
                  applicationId: id,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChannelTab extends StatelessWidget {
  const _ChannelTab({
    required this.channel,
    required this.stream,
    required this.onShareLink,
    required this.onOpenLink,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  final RecruitingChannel channel;
  final Stream<List<RecruitingApplication>> stream;
  final VoidCallback onShareLink;
  final VoidCallback onOpenLink;
  final Future<void> Function(String id, RecruitingStatus status)
      onUpdateStatus;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RecruitingApplication>>(
      stream: stream,
      builder: (context, snap) {
        final apps = snap.data ?? const <RecruitingApplication>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      AppColors.codriverGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    color: AppColors.codriverDeep,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          channel == RecruitingChannel.visa
                              ? 'Non-EU / Working Visa form'
                              : 'Local / EU form',
                          style: AppTypography.subheadline.copyWith(
                            color: AppColors.codriverDeep,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Send this link to applicants — no login '
                          'required.',
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.codriverDeep
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CoButton(
                    onPressed: onShareLink,
                    label: 'Copy link',
                    icon: Icons.content_copy_rounded,
                    variant: CoButtonVariant.secondaryOutlined,
                  ),
                  const SizedBox(width: 6),
                  CoButton(
                    onPressed: onOpenLink,
                    label: 'Open',
                    icon: Icons.open_in_new_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _buildBody(context, snap, apps),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<List<RecruitingApplication>> snap,
    List<RecruitingApplication> apps,
  ) {
    if (snap.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Color(0xFFB91C1C),
              ),
              const SizedBox(height: 10),
              Text(
                'Stream error',
                style: AppTypography.title3.copyWith(
                  color: const Color(0xFFB91C1C),
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                snap.error.toString(),
                textAlign: TextAlign.center,
                style: AppTypography.caption1.copyWith(
                  color: const Color(0xFF991B1B),
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (snap.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor:
              AlwaysStoppedAnimation<Color>(AppColors.codriverGreen),
        ),
      );
    }
    if (apps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_rounded,
                size: 44,
                color: AppColors.labelSecondaryLight,
              ),
              const SizedBox(height: 12),
              Text(
                'No applications yet',
                style: AppTypography.title3.copyWith(
                  color: AppColors.codriverGraphite,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Share the link above — submissions will appear here.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.labelSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: apps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _ApplicationRow(
        app: apps[i],
        onTap: () => _openDetail(ctx, apps[i]),
        onUpdateStatus: (s) => onUpdateStatus(apps[i].id, s),
      ),
    );
  }

  Future<void> _openDetail(
    BuildContext context,
    RecruitingApplication app,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RecruitingApplicationDetailPage(
          app: app,
          adminUid: app.adminUid,
          onUpdateStatus: (s) => onUpdateStatus(app.id, s),
          onDelete: () => onDelete(app.id),
        ),
      ),
    );
  }
}

class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({
    required this.app,
    required this.onTap,
    required this.onUpdateStatus,
  });

  final RecruitingApplication app;
  final VoidCallback onTap;
  final Future<void> Function(RecruitingStatus status) onUpdateStatus;

  Color _statusColor(RecruitingStatus s) {
    switch (s) {
      case RecruitingStatus.newApp:
        return const Color(0xFFB45309);
      case RecruitingStatus.onboarded:
        return const Color(0xFF1D4ED8);
      case RecruitingStatus.scheduledTraining:
        return const Color(0xFF7C3AED);
      case RecruitingStatus.ready:
        return AppColors.codriverGreen;
      case RecruitingStatus.contacted:
        return const Color(0xFF1D4ED8);
      case RecruitingStatus.scheduled:
        return const Color(0xFF7C3AED);
      case RecruitingStatus.zavRequest:
        return const Color(0xFF0369A1);
      case RecruitingStatus.preApproval:
        return const Color(0xFF7C3AED);
      case RecruitingStatus.contractEzb:
        return const Color(0xFFC2410C);
      case RecruitingStatus.hired:
        return AppColors.codriverGreen;
      case RecruitingStatus.rejected:
        return const Color(0xFFB91C1C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.green50,
                child: Text(
                  _initials(app.displayName),
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverDeep,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            app.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.subheadline.copyWith(
                              color: const Color(0xFF111827),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(app.status)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            app.status.label,
                            style: AppTypography.caption2.copyWith(
                              color: _statusColor(app.status),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (_ContractTypePill.forKey(
                              (app.customAnswers['employmentInterest'] ?? '')
                                  .toString(),
                            ) !=
                            null)
                          _ContractTypePill.forKey(
                            (app.customAnswers['employmentInterest'] ?? '')
                                .toString(),
                          )!,
                        _MetaChip(
                          icon: Icons.flag_outlined,
                          text: app.nationality.isEmpty
                              ? '—'
                              : app.nationality,
                        ),
                        _MetaChip(
                          icon: Icons.phone_rounded,
                          text: app.phoneWhatsApp.isEmpty
                              ? '—'
                              : app.phoneWhatsApp,
                        ),
                        _MetaChip(
                          icon: Icons.email_outlined,
                          text: app.email.isEmpty ? '—' : app.email,
                        ),
                        _MetaChip(
                          icon: Icons.schedule_rounded,
                          text:
                              DateFormat('dd.MM.yyyy HH:mm')
                                  .format(app.submittedAt),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts
        .take(2)
        .map((p) => p[0].toUpperCase())
        .toList()
        .join();
    return letters.isEmpty ? '?' : letters;
  }
}

class _ContractTypePill extends StatelessWidget {
  const _ContractTypePill({required this.label, required this.color});
  final String label;
  final Color color;

  static _ContractTypePill? forKey(String key) {
    switch (key) {
      case 'fulltime':
        return const _ContractTypePill(
          label: 'Vollzeit',
          color: Color(0xFF1D7F5A),
        );
      case 'parttime':
        return const _ContractTypePill(
          label: 'Teilzeit',
          color: Color(0xFF0369A1),
        );
      case 'minijob':
        return const _ContractTypePill(
          label: 'Minijob',
          color: Color(0xFF6B7280),
        );
      case 'werkstudent':
        return const _ContractTypePill(
          label: 'Werkstudent',
          color: Color(0xFF7C3AED),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.caption2.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption2.copyWith(
              color: const Color(0xFF374151),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-page detail view for one recruiting application. Routed via
/// `Navigator.push` from the admin Recruiting panel — replaces the
/// previous popup so we have room for the (potentially long) pipeline
/// + custom-question data.
class RecruitingApplicationDetailPage extends StatefulWidget {
  const RecruitingApplicationDetailPage({
    super.key,
    required this.app,
    required this.adminUid,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  final RecruitingApplication app;
  final String adminUid;
  final Future<void> Function(RecruitingStatus status) onUpdateStatus;
  final Future<void> Function() onDelete;

  @override
  State<RecruitingApplicationDetailPage> createState() =>
      _RecruitingApplicationDetailPageState();
}

class _RecruitingApplicationDetailPageState
    extends State<RecruitingApplicationDetailPage> {
  late RecruitingStatus _status = widget.app.status;
  bool _busy = false;
  bool _onboardingBusy = false;
  late Map<String, dynamic>? _convertedToDriver = widget.app.convertedToDriver;

  Future<void> _onboardAsDriver() async {
    final app = widget.app;
    final fullName = app.displayName;
    setState(() => _onboardingBusy = true);
    // Standard-Passwort des Admins vorbefüllen (wie im Drivers-Hub).
    final defaultPwd = await readDefaultDriverPassword(widget.adminUid);
    if (!mounted) return;
    final ok = await showAddDriverDialog(
      context: context,
      dspUid: widget.adminUid,
      defaultPassword: defaultPwd,
      prefilledName: fullName,
      prefilledEmail: app.email,
      prefilledPhone: app.phoneWhatsApp,
      sourceApplication: app,
    );
    if (!mounted) return;
    setState(() => _onboardingBusy = false);
    if (ok) {
      // Markierung wurde vom Dialog geschrieben — frisch nachladen,
      // damit Badge + Disable sofort greifen.
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.adminUid)
            .collection('recruiting_applications')
            .doc(app.id)
            .get();
        final conv = snap.data()?['convertedToDriver'];
        if (mounted && conv is Map) {
          setState(() =>
              _convertedToDriver = Map<String, dynamic>.from(conv));
        }
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.codriverDeep,
          content: Text(
            'Driver created for "$fullName".',
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _convertedDriverSubtitle() {
    final tid = (_convertedToDriver?['tid'] ?? '').toString().trim();
    if (tid.isEmpty) {
      return 'Dieser Bewerber wurde bereits in einen Driver übernommen.';
    }
    return 'Driver-ID: $tid · Daten & Dokumente wurden übernommen.';
  }

  String _fmtDate(DateTime? d) =>
      d == null ? '—' : DateFormat('dd.MM.yyyy').format(d);

  /// Baut den gesamten Bewerber-Datensatz als formatierten Text und kopiert
  /// ihn in die Zwischenablage.
  Future<void> _copyAll() async {
    final app = widget.app;
    final b = StringBuffer();
    void line(String k, String v) =>
        b.writeln('$k: ${v.trim().isEmpty ? '—' : v.trim()}');

    b.writeln(app.displayName);
    b.writeln('────────────────────');
    line('Kanal',
        app.channel == RecruitingChannel.visa ? 'Non-EU / Visa' : 'EU / Local');
    line('Status', app.status.label);
    line('Eingegangen', _fmtDate(app.submittedAt));
    b.writeln();
    line('Vorname', app.firstName);
    line('Nachname', app.lastName);
    line('Geburtsdatum', _fmtDate(app.birthDate));
    line('Geburtsort', app.birthPlace);
    line('Nationalität', app.nationality);
    b.writeln();
    line('Straße', app.street);
    line('PLZ', app.postalCode);
    line('Stadt', app.city);
    if (app.channel == RecruitingChannel.visa) {
      line('Wohnhaft seit', _fmtDate(app.livingHereSince));
    }
    b.writeln();
    line('E-Mail', app.email);
    line('Telefon / WhatsApp', app.phoneWhatsApp);
    line('T-Shirt-Größe', app.shirtSize);
    line('Schuhgröße', app.shoeSize);
    line('Lkw-Führerschein', app.truckLicense);
    if (app.customAnswers.isNotEmpty) {
      b.writeln();
      b.writeln('Weitere Angaben:');
      app.customAnswers.forEach((k, v) => line('  $k', '$v'));
    }
    if (app.documents.isNotEmpty) {
      b.writeln();
      b.writeln('Dokumente:');
      for (final d in app.documents) {
        b.writeln('  ${d.label}: ${d.downloadUrl}');
      }
    }

    await Clipboard.setData(ClipboardData(text: b.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alle Daten in die Zwischenablage kopiert.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        title: Text(
          app.displayName,
          style: AppTypography.title3.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Alle Daten kopieren',
            onPressed: _copyAll,
            icon: const Icon(Icons.copy_all_rounded),
            color: AppColors.codriverDeep,
          ),
          IconButton(
            onPressed: _busy
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete application'),
                        content: Text(
                          'Permanently delete "${app.displayName}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.of(ctx).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFB91C1C),
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true || !mounted) return;
                    setState(() => _busy = true);
                    await widget.onDelete();
                    if (mounted) Navigator.of(context).pop();
                  },
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete application',
            color: const Color(0xFFB91C1C),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PipelineStrip(
                  current: _status,
                  channel: app.channel,
                ),
                const SizedBox(height: 16),
                _StatusSelector(
                  value: _status,
                  channel: app.channel,
                  onChanged: (s) async {
                    setState(() => _busy = true);
                    await widget.onUpdateStatus(s);
                    if (mounted) {
                      setState(() {
                        _status = s;
                        _busy = false;
                      });
                    }
                  },
                ),
                // Bereits übernommen → Badge statt Onboard-Box.
                if (_convertedToDriver != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.codriverGreen
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.codriverDeep,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Als Driver übernommen',
                                style: AppTypography.subheadline.copyWith(
                                  color: AppColors.codriverDeep,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                _convertedDriverSubtitle(),
                                style: AppTypography.caption2.copyWith(
                                  color: AppColors.codriverDeep
                                      .withValues(alpha: 0.75),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
                // Onboard hand-off — visible at the final pipeline stage:
                // Visa → Eingestellt (hired), Local/EU → Ready.
                // Pre-fills the standard add-driver flow.
                else if (_status == RecruitingStatus.hired ||
                    _status == RecruitingStatus.ready) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.codriverGreen
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_add_alt_rounded,
                          color: AppColors.codriverDeep,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ready to onboard',
                                style: AppTypography.subheadline
                                    .copyWith(
                                  color: AppColors.codriverDeep,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Create the driver record with this '
                                'applicant\'s data pre-filled.',
                                style: AppTypography.caption2.copyWith(
                                  color: AppColors.codriverDeep
                                      .withValues(alpha: 0.75),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CoButton(
                          onPressed: _onboardingBusy
                              ? null
                              : _onboardAsDriver,
                          label: 'Onboard as driver',
                          icon: Icons.person_add_alt_rounded,
                          busy: _onboardingBusy,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _DetailGroup(
                  title: 'Identity',
                  rows: [
                    _DetailRow('First name', app.firstName),
                    _DetailRow('Last name', app.lastName),
                    _DetailRow(
                      'Date of birth',
                      app.birthDate == null
                          ? '—'
                          : DateFormat('dd.MM.yyyy')
                              .format(app.birthDate!),
                    ),
                    _DetailRow('Place of birth', app.birthPlace),
                    _DetailRow('Nationality', app.nationality),
                  ],
                ),
                _DetailGroup(
                  title: 'Address',
                  rows: [
                    _DetailRow('Street', app.street),
                    _DetailRow('Postal code', app.postalCode),
                    _DetailRow('City', app.city),
                    _DetailRow(
                      'Living here since',
                      app.livingHereSince == null
                          ? '—'
                          : DateFormat('dd.MM.yyyy')
                              .format(app.livingHereSince!),
                    ),
                  ],
                ),
                _DetailGroup(
                  title: 'Contact & sizing',
                  rows: [
                    _DetailRow('Email', app.email),
                    _DetailRow('Phone (WhatsApp)', app.phoneWhatsApp),
                    _DetailRow('T-shirt size', app.shirtSize),
                    _DetailRow('Shoe size', app.shoeSize),
                  ],
                ),
                _DetailGroup(
                  title: 'Truck license',
                  rows: [
                    _DetailRow('Answer', app.truckLicense),
                  ],
                ),
                if (app.customAnswers.isNotEmpty)
                  _CustomAnswersGroup(
                    answers: app.customAnswers,
                    adminUid: widget.adminUid,
                    channel: app.channel,
                  ),
                const SizedBox(height: 14),
                Text(
                  'DOCUMENTS',
                  style: AppTypography.caption2.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                for (final d in app.documents)
                  _DocumentPreview(doc: d),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Visual pipeline strip — green chip for current/past stages, grey
/// for upcoming. Helps the admin instantly see where the applicant
/// is in the funnel (Neu / ZAV / Vorabzustimmung / Vertrag / Hired).
class _PipelineStrip extends StatelessWidget {
  const _PipelineStrip({required this.current, required this.channel});
  final RecruitingStatus current;
  final RecruitingChannel channel;

  @override
  Widget build(BuildContext context) {
    final pipeline = RecruitingStatus.pipelineFor(channel)
        .where((s) => s != RecruitingStatus.rejected)
        .toList();
    final isRejected = current == RecruitingStatus.rejected;
    final idx = pipeline.indexOf(current);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < pipeline.length; i++) ...[
            _PipelineDot(
              label: pipeline[i].label,
              reached: !isRejected && idx >= i,
              active: !isRejected && idx == i,
            ),
            if (i < pipeline.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  color: !isRejected && idx > i
                      ? AppColors.codriverGreen
                      : const Color(0xFFE5E7EB),
                ),
              ),
          ],
          if (isRejected) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Rejected',
                style: AppTypography.caption2.copyWith(
                  color: const Color(0xFFB91C1C),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PipelineDot extends StatelessWidget {
  const _PipelineDot({
    required this.label,
    required this.reached,
    required this.active,
  });
  final String label;
  final bool reached;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: active ? 22 : 18,
          height: active ? 22 : 18,
          decoration: BoxDecoration(
            color: reached
                ? AppColors.codriverGreen
                : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
            border: active
                ? Border.all(
                    color:
                        AppColors.codriverGreen.withValues(alpha: 0.3),
                    width: 4,
                  )
                : null,
          ),
          child: reached
              ? const Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 78,
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: AppTypography.caption2.copyWith(
              color: reached
                  ? AppColors.codriverDeep
                  : const Color(0xFF6B7280),
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({
    required this.value,
    required this.channel,
    required this.onChanged,
  });
  final RecruitingStatus value;
  final RecruitingChannel channel;
  final ValueChanged<RecruitingStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final pipeline = RecruitingStatus.pipelineFor(channel);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final s in pipeline)
          ChoiceChip(
            label: Text(s.label),
            selected: value == s,
            onSelected: (_) => onChanged(s),
            selectedColor: s == RecruitingStatus.rejected
                ? const Color(0xFFB91C1C)
                : AppColors.codriverGreen,
            backgroundColor: const Color(0xFFF9FAFB),
            side: BorderSide(
              color: value == s
                  ? (s == RecruitingStatus.rejected
                      ? const Color(0xFFB91C1C)
                      : AppColors.codriverGreen)
                  : const Color(0xFFE5E7EB),
            ),
            labelStyle: AppTypography.caption1.copyWith(
              color: value == s
                  ? Colors.white
                  : const Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _DetailGroup extends StatelessWidget {
  const _DetailGroup({required this.title, required this.rows});
  final String title;
  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.caption2.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                for (final r in rows) r,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.caption1.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value.isEmpty ? '—' : value,
              style: AppTypography.body.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          if (value.trim().isNotEmpty)
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: value.trim()));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('„${label.trim()}" kopiert.'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.copy_rounded,
                  size: 15,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Renders the DSP's custom-question answers under their original
/// labels. Pulls the live form config so it can show the question
/// text even if the DSP later renames a field — old submissions
/// keep their answer keyed by ID.
class _CustomAnswersGroup extends StatelessWidget {
  const _CustomAnswersGroup({
    required this.answers,
    required this.adminUid,
    required this.channel,
  });

  final Map<String, dynamic> answers;
  final String adminUid;
  final RecruitingChannel channel;

  /// Built-in keys (those written by the recruiting form itself, not by
  /// admin-configured custom questions) get human labels here so the
  /// applicant detail view shows „Krankenkasse" instead of „healthInsurance".
  static const Map<String, String> _builtInLabels = {
    'employmentInterest': 'Beschäftigungs-Wunsch',
    'parttimeDaysPerWeek': 'Teilzeit-Tage pro Woche',
    'birthCountry': 'Geburtsland',
    'taxId': 'Steueridentifikationsnummer',
    'taxIdSubmitLater': 'Steuer-ID wird nachgereicht',
    'socialSecurityNumber': 'Sozialversicherungsnummer',
    'socialSecuritySubmitLater': 'Sozialversicherungs-Nr. wird nachgereicht',
    'healthInsuranceStatus': 'Status Krankenkasse',
    'healthInsurance': 'Krankenkasse',
    'aokBayernRegisterRequested': 'AOK-Bayern-Anmeldung gewünscht',
    'maritalStatus': 'Familienstand',
    'childrenChoice': 'Kinder',
    'childrenCount': 'Anzahl Kinder',
    'notes': 'Anmerkungen',
  };

  /// Stable display order for built-in keys, so the admin always sees
  /// payroll → family → notes in the same sequence regardless of map
  /// iteration order.
  static const List<String> _builtInOrder = [
    'employmentInterest',
    'parttimeDaysPerWeek',
    'birthCountry',
    'taxId',
    'taxIdSubmitLater',
    'socialSecurityNumber',
    'socialSecuritySubmitLater',
    'healthInsuranceStatus',
    'healthInsurance',
    'aokBayernRegisterRequested',
    'maritalStatus',
    'childrenChoice',
    'childrenCount',
    'notes',
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RecruitingFormConfig>(
      stream: RecruitingRepository().watchFormConfig(
        adminUid: adminUid,
        channel: channel,
      ),
      builder: (context, snap) {
        final cfg = snap.data ?? RecruitingFormConfig.empty();
        final byId = <String, RecruitingCustomField>{
          for (final f in cfg.fields) f.id: f,
        };
        final rows = <_DetailRow>[];

        // 1) Built-in keys first, in a stable, predictable order.
        for (final key in _builtInOrder) {
          if (!answers.containsKey(key)) continue;
          rows.add(_DetailRow(
            _builtInLabels[key] ?? key,
            _formatAnswer(key, answers[key]),
          ));
        }

        // 2) Admin-configured custom questions next, falling back to the
        //    key name only if no label is configured (avoids the raw
        //    „Custom field (xyz)" placeholder we used before).
        for (final entry in answers.entries) {
          if (_builtInLabels.containsKey(entry.key)) continue;
          final field = byId[entry.key];
          final label = field?.label ?? entry.key;
          rows.add(_DetailRow(label, _formatAnswer(entry.key, entry.value)));
        }

        if (rows.isEmpty) return const SizedBox.shrink();
        return _DetailGroup(
          title: 'Custom questions',
          rows: rows,
        );
      },
    );
  }

  String _formatAnswer(String key, dynamic v) {
    if (v == null) return '—';
    if (v is bool) return v ? 'Ja' : 'Nein';
    final s = v is String ? v : v.toString();
    if (s.isEmpty) return '—';
    switch (key) {
      case 'employmentInterest':
        return const {
              'fulltime': 'Vollzeit',
              'parttime': 'Teilzeit',
              'minijob': 'Minijob',
              'werkstudent': 'Werkstudent',
            }[s] ??
            s;
      case 'healthInsuranceStatus':
        return const {
              'has': 'Vorhanden',
              'none': 'Aktuell nicht versichert',
            }[s] ??
            s;
      case 'parttimeDaysPerWeek':
        return '$s Tage';
      case 'maritalStatus':
        return const {
              'single': 'Ledig',
              'divorced': 'Geschieden',
              'married_or_separated': 'Verheiratet oder getrennt lebend',
              'widowed': 'Verwitwet',
              'married': 'Verheiratet', // legacy
              'later': 'Wird nachgereicht',
            }[s] ??
            s;
      case 'childrenChoice':
        return const {
              'none': 'Keine Kinder',
              'count': 'Ja',
              'later': 'Wird nachgereicht',
            }[s] ??
            s;
      case 'taxId':
      case 'socialSecurityNumber':
        return s == 'later' ? 'Wird später nachgereicht' : s;
    }
    return s;
  }
}

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({required this.doc});
  final RecruitingDocument doc;

  String _labelFor(String label) {
    switch (label) {
      case 'passport':
        return 'Pass / Personalausweis · Vorderseite';
      case 'id_back':
        return 'Personalausweis · Rückseite';
      case 'selfie':
        return 'Selfie · Driver Badge';
      case 'license_front':
        return 'Führerschein · Vorderseite';
      case 'license_back':
        return 'Führerschein · Rückseite';
      default:
        return label;
    }
  }

  Future<void> _open(BuildContext context) async {
    Uri? uri;
    if (doc.hasUrl) {
      uri = Uri.tryParse(doc.downloadUrl);
    } else if (doc.hasBase64) {
      final mime =
          doc.mimeType.isEmpty ? 'application/pdf' : doc.mimeType;
      uri = Uri.parse('data:$mime;base64,${doc.fileBase64}');
    }
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage = doc.mimeType.startsWith('image/');
    // For URL-backed docs we use Image.network; for legacy base64 we
    // decode inline. Either way the thumb is 60×60 with a fallback
    // PDF icon for non-image content.
    Uint8List? legacyBytes;
    if (isImage && doc.hasBase64 && !doc.hasUrl) {
      try {
        legacyBytes = base64Decode(doc.fileBase64);
      } catch (_) {}
    }
    Widget thumb;
    if (isImage && doc.hasUrl) {
      thumb = Image.network(
        doc.downloadUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported_rounded,
          color: Color(0xFF6B7280),
        ),
      );
    } else if (legacyBytes != null) {
      thumb = Image.memory(legacyBytes, fit: BoxFit.cover);
    } else {
      thumb = const Icon(
        Icons.picture_as_pdf_rounded,
        color: Color(0xFF6B7280),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        child: InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: thumb,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _labelFor(doc.label),
                        style: AppTypography.subheadline.copyWith(
                          color: const Color(0xFF111827),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        doc.filename,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption2.copyWith(
                          color: const Color(0xFF6B7280),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
