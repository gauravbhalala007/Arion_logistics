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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/recruiting_application.dart';
import '../models/recruiting_form_config.dart';
import '../services/recruiting_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String _publicFormUrl(RecruitingChannel channel) {
    final base = Uri.base;
    return '${base.origin}/#/recruiting?dsp=${widget.adminUid}'
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
                      spacing: 10,
                      runSpacing: 4,
                      children: [
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

  Future<void> _onboardAsDriver() async {
    final app = widget.app;
    final fullName = app.displayName;
    setState(() => _onboardingBusy = true);
    final ok = await showAddDriverDialog(
      context: context,
      dspUid: widget.adminUid,
      defaultPassword: '',
      prefilledName: fullName,
      prefilledEmail: app.email,
      prefilledPhone: app.phoneWhatsApp,
    );
    if (!mounted) return;
    setState(() => _onboardingBusy = false);
    if (ok) {
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
                // Onboard hand-off — visible once status reaches
                // Eingestellt. Pre-fills the standard add-driver flow
                // with the applicant's basics.
                if (_status == RecruitingStatus.hired) ...[
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
                                'Hired — ready to onboard',
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
        for (final entry in answers.entries) {
          final field = byId[entry.key];
          final label =
              field?.label ?? 'Custom field (${entry.key})';
          final v = entry.value;
          rows.add(_DetailRow(label, _formatAnswer(v)));
        }
        if (rows.isEmpty) return const SizedBox.shrink();
        return _DetailGroup(
          title: 'Custom questions',
          rows: rows,
        );
      },
    );
  }

  String _formatAnswer(dynamic v) {
    if (v == null) return '—';
    if (v is bool) return v ? 'Yes · Ja' : 'No · Nein';
    if (v is String) return v.isEmpty ? '—' : v;
    return v.toString();
  }
}

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({required this.doc});
  final RecruitingDocument doc;

  String _labelFor(String label) {
    switch (label) {
      case 'passport':
        return 'Pass / Personalausweis';
      case 'license_front':
        return 'Führerschein · Front';
      case 'license_back':
        return 'Führerschein · Back';
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
