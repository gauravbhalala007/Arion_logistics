import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

const String _academyTestsCollection = 'academy_tests';
const Color _kBg = Color(0xFFF3F6F7);
const Color _kText = Color(0xFF1F2937);
const Color _kMuted = Color(0xFF6B7280);
const Color _kPrimary = Color(0xFF1D7F5A);
const Color _kBlue = Color(0xFF1788C3);

class DriverAmazonDeliveryPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverAmazonDeliveryPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverAmazonDeliveryPage> createState() =>
      _DriverAmazonDeliveryPageState();
}

class _DriverAmazonDeliveryPageState extends State<DriverAmazonDeliveryPage> {
  _AmazonDeliveryView _view = _AmazonDeliveryView.module;

  bool _loading = true;
  bool _saving = false;

  bool _activity1Completed = false;
  int _activity1Step = 0;
  DateTime? _activity1CompletedAt;

  static const List<_ActivityMeta> _activities = [
    _ActivityMeta(
      id: 'activity_1',
      titleKey: 'driver_academy_delivery_title',
      subtitleKey: 'delivery_training_activity_subtitle',
      durationMinutes: 10,
      required: true,
    ),
    _ActivityMeta(
      id: 'activity_2',
      titleKey: 'delivery_training_module_activity_2_title',
      subtitleKey: 'delivery_training_module_activity_2_subtitle',
      durationMinutes: 10,
    ),
    _ActivityMeta(
      id: 'activity_3',
      titleKey: 'delivery_training_module_activity_3_title',
      subtitleKey: 'delivery_training_module_activity_3_subtitle',
      durationMinutes: 10,
    ),
    _ActivityMeta(
      id: 'activity_4',
      titleKey: 'delivery_training_module_activity_4_title',
      subtitleKey: 'delivery_training_module_activity_4_subtitle',
      durationMinutes: 10,
    ),
    _ActivityMeta(
      id: 'activity_5',
      titleKey: 'delivery_training_module_activity_5_title',
      subtitleKey: 'delivery_training_module_activity_5_subtitle',
      durationMinutes: 10,
    ),
    _ActivityMeta(
      id: 'activity_6',
      titleKey: 'delivery_training_module_activity_6_title',
      subtitleKey: 'delivery_training_module_activity_6_subtitle',
      durationMinutes: 10,
    ),
    _ActivityMeta(
      id: 'activity_7',
      titleKey: 'delivery_training_module_activity_7_title',
      subtitleKey: 'delivery_training_module_activity_7_subtitle',
      durationMinutes: 10,
    ),
  ];

  static final List<_CoachStep> _activity1Steps = [
    _CoachStep(
      instructionKey: 'delivery_training_step_launch',
      screen: _MockScreen.welcome,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_type_of_deliveries',
      screen: _MockScreen.typeOfDeliveries,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_door_to_door',
      screen: _MockScreen.doorToDoor,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_lockers',
      screen: _MockScreen.lockers,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_counters',
      screen: _MockScreen.counters,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_otr_supplies',
      screen: _MockScreen.otrSupplies,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_otp_badge',
      screen: _MockScreen.otpBadge,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_otp_badge_visual',
      screen: _MockScreen.otpBadgeVisual,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_weather_bags',
      screen: _MockScreen.weatherBags,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_ready_to_go',
      screen: _MockScreen.readyToGo,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_customer_arrival_contact',
      screen: _MockScreen.customerArrivalContact,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_customer_feedback',
      screen: _MockScreen.customerFeedback,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_concessions',
      screen: _MockScreen.concessions,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_delivery_app_usage',
      screen: _MockScreen.deliveryAppUsage,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_delivery_app_overview',
      screen: _MockScreen.deliveryAppOverview,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_transportation_method',
      screen: _MockScreen.transportationMethod,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_verify_identity',
      screen: _MockScreen.verifyIdentity,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_delivery_app_overview_maps',
      screen: _MockScreen.deliveryAppOverviewMaps,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_offline_maps_prompt',
      screen: _MockScreen.offlineMapsPrompt,
      target: _HotspotTarget.menu,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_settings_prompt',
      screen: _MockScreen.settingsPrompt,
      target: _HotspotTarget.settingsItem,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_offline_maps_settings_prompt',
      screen: _MockScreen.offlineMapsSettingsPrompt,
      target: _HotspotTarget.offlineMapsItem,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_offline_maps_download_prompt',
      screen: _MockScreen.offlineMapsDownloadPrompt,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_offline_maps_downloaded_prompt',
      screen: _MockScreen.offlineMapsDownloadedPrompt,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_offline_maps_connectivity_prompt',
      screen: _MockScreen.offlineMapsConnectivityPrompt,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_country_selection',
      screen: _MockScreen.overviewIntroPrompt,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_open_itinerary_tab',
      screen: _MockScreen.overviewTabsPrompt,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_itinerary_overview',
      screen: _MockScreen.overviewItineraryTapPrompt,
      target: _HotspotTarget.tabItinerary,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_itinerary_locations_prompt',
      screen: _MockScreen.itineraryOverviewPrompt,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_itinerary_delivery_type_prompt',
      screen: _MockScreen.itineraryDeliveryTypePrompt,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_itinerary_map_tap_prompt',
      screen: _MockScreen.itineraryMapTapPrompt,
      target: _HotspotTarget.tabMap,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_itinerary_map_locations_prompt',
      screen: _MockScreen.itineraryMapLocationsPrompt,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_itinerary_summary_tap_prompt',
      screen: _MockScreen.itinerarySummaryTapPrompt,
      target: _HotspotTarget.tabSummary,
    ),
    _CoachStep(
      instructionKey:
          'delivery_training_step_itinerary_summary_overview_prompt',
      screen: _MockScreen.itinerarySummaryOverviewPrompt,
      target: _HotspotTarget.coachContinue,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_open_stop',
      screen: _MockScreen.itinerary,
      target: _HotspotTarget.stopCard,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_customer_notes',
      screen: _MockScreen.stopDetails,
      target: _HotspotTarget.notes,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_delivery_access',
      screen: _MockScreen.stopDetails,
      target: _HotspotTarget.key,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_external_navigation',
      screen: _MockScreen.stopDetails,
      target: _HotspotTarget.externalNav,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_open_map_tab',
      screen: _MockScreen.overview,
      target: _HotspotTarget.tabMap,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_map_guidance',
      screen: _MockScreen.map,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_open_summary_tab',
      screen: _MockScreen.overview,
      target: _HotspotTarget.tabSummary,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_summary_guidance',
      screen: _MockScreen.summary,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_open_menu',
      screen: _MockScreen.overview,
      target: _HotspotTarget.menu,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_open_settings',
      screen: _MockScreen.menu,
      target: _HotspotTarget.settingsItem,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_offline_maps',
      screen: _MockScreen.settings,
      target: _HotspotTarget.offlineMapsItem,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_help_menu',
      screen: _MockScreen.overview,
      target: _HotspotTarget.help,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_otp_support',
      screen: _MockScreen.stopDetails,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_identity_verification',
      screen: _MockScreen.overview,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_feedback_quality',
      screen: _MockScreen.summary,
    ),
    _CoachStep(
      instructionKey: 'delivery_training_step_completion',
      screen: _MockScreen.overview,
    ),
  ];

  DocumentReference<Map<String, dynamic>> get _academyResultRef {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid.trim())
        .collection('drivers')
        .doc(widget.driverTransporterId.trim().toUpperCase())
        .collection(_academyTestsCollection)
        .doc('amazon_delivery');
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final snap = await _academyResultRef.get();
      final data = snap.data() ?? const <String, dynamic>{};

      final completed = _readBool(data, const [
        'activity1Completed',
        'deliveryWorkflowActivity1Completed',
      ]);
      final step = _readInt(data, const [
        'activity1Step',
        'deliveryWorkflowActivity1Step',
      ]);

      final completedAtValue = _readFirst(data, const [
        'activity1CompletedAt',
        'deliveryWorkflowActivity1CompletedAt',
      ]);

      DateTime? completedAt;
      if (completedAtValue is Timestamp) {
        completedAt = completedAtValue.toDate();
      }

      if (!mounted) return;
      setState(() {
        _activity1Completed = completed;
        _activity1Step = step.clamp(0, _activity1Steps.length - 1);
        _activity1CompletedAt = completedAt;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  dynamic _readFirst(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key)) return data[key];
    }
    return null;
  }

  bool _readBool(Map<String, dynamic> data, List<String> keys) {
    final raw = _readFirst(data, keys);
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      final v = raw.trim().toLowerCase();
      return v == 'true' || v == '1' || v == 'yes';
    }
    return false;
  }

  int _readInt(Map<String, dynamic> data, List<String> keys) {
    final raw = _readFirst(data, keys);
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw.trim()) ?? 0;
    return 0;
  }

  Future<void> _saveStep(int step) async {
    try {
      await _academyResultRef.set({
        'scope': 'driver',
        'dspUid': widget.dspUid.trim(),
        'driverTransporterId': widget.driverTransporterId.trim().toUpperCase(),
        'testId': 'amazon_delivery',
        'testTitle': 'Amazon Delivery',
        'activity1Step': step,
        'activity1Completed': false,
        'updatedAt': FieldValue.serverTimestamp(),
        if (step == 0) 'activity1StartedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _completeActivity1() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(_academyResultRef);
        final data = snap.data() ?? const <String, dynamic>{};
        final attempts = (data['attempts'] as num?)?.toInt() ?? 0;

        tx.set(_academyResultRef, {
          'scope': 'driver',
          'dspUid': widget.dspUid.trim(),
          'driverTransporterId': widget.driverTransporterId
              .trim()
              .toUpperCase(),
          'testId': 'amazon_delivery',
          'testTitle': _firstNonEmpty([
            (data['title_en'] ?? '').toString(),
            (data['title'] ?? '').toString(),
            'Amazon Delivery',
          ]),
          'lastScore': 100,
          'lastTotal': 100,
          'lastPercent': 100,
          'passPercent': 100,
          'lastPassed': true,
          'passedEver': true,
          'attempts': attempts + 1,
          'lastAttemptAt': FieldValue.serverTimestamp(),
          'lastPassedAt': FieldValue.serverTimestamp(),
          if (data['firstPassedAt'] == null)
            'firstPassedAt': FieldValue.serverTimestamp(),
          'activity1Step': _activity1Steps.length - 1,
          'activity1Completed': true,
          'activity1CompletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          if (!snap.exists) 'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      if (!mounted) return;
      setState(() {
        _activity1Completed = true;
        _activity1CompletedAt = DateTime.now();
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _restartActivity1() async {
    if (_saving) return;

    setState(() {
      _activity1Completed = false;
      _activity1Step = 0;
      _view = _AmazonDeliveryView.player;
    });

    await _academyResultRef.set({
      'activity1Step': 0,
      'activity1Completed': false,
      'activity1StartedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _firstNonEmpty(List<String> values) {
    for (final raw in values) {
      final value = raw.trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  void _goToNextStep() {
    if (_activity1Completed || _saving) return;

    final isLast = _activity1Step >= _activity1Steps.length - 1;
    if (isLast) {
      _completeActivity1();
      return;
    }

    final next = _activity1Step + 1;
    setState(() => _activity1Step = next);
    _saveStep(next);
  }

  void _handleStepTargetTap(_HotspotTarget tapped) {
    if (_activity1Completed || _saving) return;

    final step =
        _activity1Steps[_activity1Step.clamp(0, _activity1Steps.length - 1)];
    if (step.target != tapped) return;

    _goToNextStep();
  }

  String _statusLabel(AppLocalizations t) {
    if (_activity1Completed) return t.t('delivery_training_status_completed');
    if (_activity1Step > 0) return t.t('delivery_training_status_in_progress');
    return t.t('delivery_training_status_not_started');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: _kBg,
      child: _view == _AmazonDeliveryView.module
          ? _buildModuleView(context, t)
          : _buildActivityView(context, t),
    );
  }

  Widget _buildModuleView(BuildContext context, AppLocalizations t) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _RoundIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: widget.onBack,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.t('delivery_training_module_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDDE3E7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFFE9F2FE),
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          color: _kBlue,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.t(_activities.first.titleKey),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: _kText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.t(_activities.first.subtitleKey),
                              style: const TextStyle(
                                color: _kMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _StatusPill(
                                  label: _statusLabel(t),
                                  color: _activity1Completed
                                      ? const Color(0xFF22A06B)
                                      : const Color(0xFF6B7280),
                                  bg: _activity1Completed
                                      ? const Color(0xFFE9F8F1)
                                      : const Color(0xFFF3F4F6),
                                ),
                                _StatusPill(
                                  label: t.tf('delivery_training_step_of_total', {
                                    'current':
                                        '${_activity1Completed ? _activity1Steps.length : (_activity1Step + 1)}',
                                    'total': '${_activity1Steps.length}',
                                  }),
                                  color: const Color(0xFF1E4E8C),
                                  bg: const Color(0xFFEAF2FF),
                                ),
                                _StatusPill(
                                  label:
                                      '${_activities.first.durationMinutes} min',
                                  color: const Color(0xFF7C4D00),
                                  bg: const Color(0xFFFFF3E0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_activity1CompletedAt != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      t.tf('delivery_training_last_completed', {
                        'date': _formatDate(_activity1CompletedAt!),
                      }),
                      style: const TextStyle(
                        color: _kMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_activity1Completed)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _view = _AmazonDeliveryView.player;
                              });
                            },
                            icon: const Icon(Icons.visibility_outlined),
                            label: Text(t.t('delivery_training_review')),
                          ),
                        ),
                      if (_activity1Completed) const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _activity1Completed
                              ? _restartActivity1
                              : () {
                                  setState(() {
                                    _view = _AmazonDeliveryView.player;
                                  });
                                },
                          icon: Icon(
                            _activity1Completed
                                ? Icons.restart_alt_rounded
                                : (_activity1Step > 0
                                      ? Icons.play_circle_outline_rounded
                                      : Icons.play_arrow_rounded),
                          ),
                          label: Text(
                            _activity1Completed
                                ? t.t('delivery_training_restart_activity')
                                : (_activity1Step > 0
                                      ? t.t('delivery_training_resume')
                                      : t.t('delivery_training_start_now')),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPrimary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ..._activities.skip(1).map((activity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDDE3E7)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.school_outlined,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.t(activity.titleKey),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _kText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.t(activity.subtitleKey),
                              style: const TextStyle(
                                fontSize: 12,
                                color: _kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusPill(
                        label: t.t('coming_soon'),
                        color: const Color(0xFF6B7280),
                        bg: const Color(0xFFF3F4F6),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityView(BuildContext context, AppLocalizations t) {
    final step =
        _activity1Steps[_activity1Step.clamp(0, _activity1Steps.length - 1)];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          children: [
            Row(
              children: [
                _RoundIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () {
                    setState(() => _view = _AmazonDeliveryView.module);
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.t('driver_academy_delivery_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                    ),
                  ),
                ),
                Text(
                  t.tf('delivery_training_step_of_total', {
                    'current':
                        '${_activity1Completed ? _activity1Steps.length : (_activity1Step + 1)}',
                    'total': '${_activity1Steps.length}',
                  }),
                  style: const TextStyle(
                    color: _kMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: t.t('delivery_training_restart_tooltip'),
                  onPressed: _saving ? null : _restartActivity1,
                  icon: const Icon(Icons.restart_alt_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: _activity1Completed
                    ? 1
                    : ((_activity1Step + 1) / _activity1Steps.length),
                minHeight: 8,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (step.target == null && !_saving && !_activity1Completed)
                    ? _goToNextStep
                    : null,
                child: _AmazonMockPhone(
                  frameAsset: null,
                  frameTapArea: null,
                  frameImageSize: null,
                  frameHint: '',
                  screen: step.screen,
                  activeTarget: step.target,
                  onTargetTap: _handleStepTargetTap,
                  showTutorialOverlay: false,
                  tutorialTitle: '',
                  tutorialBody: '',
                  onTutorialNext: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yy = (date.year % 100).toString().padLeft(2, '0');
    return '$dd.$mm.$yy';
  }
}

class _AmazonMockPhone extends StatelessWidget {
  final String? frameAsset;
  final Rect? frameTapArea;
  final Size? frameImageSize;
  final String frameHint;
  final _MockScreen screen;
  final _HotspotTarget? activeTarget;
  final ValueChanged<_HotspotTarget> onTargetTap;
  final bool showTutorialOverlay;
  final String tutorialTitle;
  final String tutorialBody;
  final VoidCallback onTutorialNext;

  const _AmazonMockPhone({
    this.frameAsset,
    this.frameTapArea,
    this.frameImageSize,
    this.frameHint = '',
    required this.screen,
    required this.activeTarget,
    required this.onTargetTap,
    required this.showTutorialOverlay,
    required this.tutorialTitle,
    required this.tutorialBody,
    required this.onTutorialNext,
  });

  @override
  Widget build(BuildContext context) {
    if (frameAsset != null && frameAsset!.isNotEmpty) {
      return _buildScreenshotMode();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDDE3E7), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Column(
              children: [
                if (screen != _MockScreen.welcome &&
                    screen != _MockScreen.typeOfDeliveries &&
                    screen != _MockScreen.doorToDoor &&
                    screen != _MockScreen.lockers &&
                    screen != _MockScreen.counters &&
                    screen != _MockScreen.otrSupplies &&
                    screen != _MockScreen.otpBadge &&
                    screen != _MockScreen.otpBadgeVisual &&
                    screen != _MockScreen.weatherBags &&
                    screen != _MockScreen.readyToGo &&
                    screen != _MockScreen.customerArrivalContact &&
                    screen != _MockScreen.customerFeedback &&
                    screen != _MockScreen.concessions &&
                    screen != _MockScreen.deliveryAppUsage &&
                    screen != _MockScreen.deliveryAppOverview &&
                    screen != _MockScreen.transportationMethod &&
                    screen != _MockScreen.verifyIdentity &&
                    screen != _MockScreen.deliveryAppOverviewMaps &&
                    screen != _MockScreen.offlineMapsPrompt &&
                    screen != _MockScreen.settingsPrompt &&
                    screen != _MockScreen.offlineMapsSettingsPrompt &&
                    screen != _MockScreen.offlineMapsDownloadPrompt &&
                    screen != _MockScreen.offlineMapsDownloadedPrompt &&
                    screen != _MockScreen.offlineMapsConnectivityPrompt &&
                    screen != _MockScreen.overviewIntroPrompt &&
                    screen != _MockScreen.overviewTabsPrompt &&
                    screen != _MockScreen.overviewItineraryTapPrompt &&
                    screen != _MockScreen.itineraryOverviewPrompt &&
                    screen != _MockScreen.itineraryDeliveryTypePrompt &&
                    screen != _MockScreen.itineraryMapTapPrompt &&
                    screen != _MockScreen.itineraryMapLocationsPrompt &&
                    screen != _MockScreen.itinerarySummaryTapPrompt &&
                    screen != _MockScreen.itinerarySummaryOverviewPrompt)
                  _topBar(context),
                if (screen != _MockScreen.welcome &&
                    screen != _MockScreen.typeOfDeliveries &&
                    screen != _MockScreen.doorToDoor &&
                    screen != _MockScreen.lockers &&
                    screen != _MockScreen.counters &&
                    screen != _MockScreen.otrSupplies &&
                    screen != _MockScreen.otpBadge &&
                    screen != _MockScreen.otpBadgeVisual &&
                    screen != _MockScreen.weatherBags &&
                    screen != _MockScreen.readyToGo &&
                    screen != _MockScreen.customerArrivalContact &&
                    screen != _MockScreen.customerFeedback &&
                    screen != _MockScreen.concessions &&
                    screen != _MockScreen.deliveryAppUsage &&
                    screen != _MockScreen.deliveryAppOverview &&
                    screen != _MockScreen.transportationMethod &&
                    screen != _MockScreen.verifyIdentity &&
                    screen != _MockScreen.deliveryAppOverviewMaps &&
                    screen != _MockScreen.offlineMapsPrompt &&
                    screen != _MockScreen.settingsPrompt &&
                    screen != _MockScreen.offlineMapsSettingsPrompt &&
                    screen != _MockScreen.offlineMapsDownloadPrompt &&
                    screen != _MockScreen.offlineMapsDownloadedPrompt &&
                    screen != _MockScreen.offlineMapsConnectivityPrompt &&
                    screen != _MockScreen.overviewIntroPrompt &&
                    screen != _MockScreen.overviewTabsPrompt &&
                    screen != _MockScreen.overviewItineraryTapPrompt &&
                    screen != _MockScreen.itineraryOverviewPrompt &&
                    screen != _MockScreen.itineraryDeliveryTypePrompt &&
                    screen != _MockScreen.itineraryMapTapPrompt &&
                    screen != _MockScreen.itineraryMapLocationsPrompt &&
                    screen != _MockScreen.itinerarySummaryTapPrompt &&
                    screen != _MockScreen.itinerarySummaryOverviewPrompt)
                  _tabBar(),
                Expanded(child: _screenBody(context)),
              ],
            ),
            if (showTutorialOverlay)
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.55)),
              ),
            if (showTutorialOverlay)
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: _tutorialCard(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotMode() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDDE3E7), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fullRect = Offset.zero & constraints.biggest;
            final imageRect = _fittedRect(
              imageSize: frameImageSize ?? const Size(1024, 1800),
              outputRect: fullRect,
            );
            final hintRect = frameTapArea == null
                ? null
                : Rect.fromLTWH(
                    imageRect.left + frameTapArea!.left * imageRect.width,
                    imageRect.top + frameTapArea!.top * imageRect.height,
                    frameTapArea!.width * imageRect.width,
                    frameTapArea!.height * imageRect.height,
                  ).intersect(imageRect);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (_isValidFrameTap(details.localPosition, imageRect)) {
                  onTargetTap(_HotspotTarget.coachContinue);
                }
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(frameAsset!, fit: BoxFit.contain),
                  ),
                  if (hintRect != null)
                    Positioned.fromRect(
                      rect: hintRect,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF3B82F6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: 0.35),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (hintRect != null)
                    Positioned(
                      left: hintRect.left,
                      top: hintRect.top - 24,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Click here',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (frameHint.isNotEmpty)
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.58),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            frameHint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Rect _fittedRect({required Size imageSize, required Rect outputRect}) {
    final fitted = applyBoxFit(BoxFit.contain, imageSize, outputRect.size);
    return Alignment.center.inscribe(fitted.destination, outputRect);
  }

  bool _isValidFrameTap(Offset position, Rect imageRect) {
    if (!imageRect.contains(position)) return false;
    if (frameTapArea == null) return false;

    final nx = (position.dx - imageRect.left) / imageRect.width;
    final ny = (position.dy - imageRect.top) / imageRect.height;
    return frameTapArea!.contains(Offset(nx, ny));
  }

  Widget _tutorialCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -22,
          left: 0,
          right: 0,
          child: const Center(
            child: Icon(
              Icons.arrow_drop_up_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tutorialTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _kText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tutorialBody,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onTutorialNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: _kBlue,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _topBar(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF7CA8C4),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Row(
        children: [
          _hotspot(
            _HotspotTarget.menu,
            IconButton(
              onPressed: () => onTargetTap(_HotspotTarget.menu),
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _titleForScreen(t, screen),
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ),
          _hotspot(
            _HotspotTarget.help,
            IconButton(
              onPressed: () => onTargetTap(_HotspotTarget.help),
              icon: const Icon(
                Icons.help_outline_rounded,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    if (screen == _MockScreen.menu ||
        screen == _MockScreen.settings ||
        screen == _MockScreen.welcome) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color(0xFFE7EEF6),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: _tabPill(
              icon: Icons.format_list_bulleted_rounded,
              target: _HotspotTarget.tabItinerary,
              active: screen == _MockScreen.itinerary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _tabPill(
              icon: Icons.map_outlined,
              target: _HotspotTarget.tabMap,
              active: screen == _MockScreen.map,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _tabPill(
              icon: Icons.speed_rounded,
              target: _HotspotTarget.tabSummary,
              active: screen == _MockScreen.summary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabPill({
    required IconData icon,
    required _HotspotTarget target,
    required bool active,
  }) {
    return _hotspot(
      target,
      InkWell(
        onTap: () => onTargetTap(target),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1788C3) : const Color(0xFFD7E0EA),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            icon,
            color: active ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _screenBody(BuildContext context) {
    switch (screen) {
      case _MockScreen.welcome:
        return _welcomeScreen(context);
      case _MockScreen.typeOfDeliveries:
        return _typeOfDeliveriesScreen(context);
      case _MockScreen.doorToDoor:
        return _doorToDoorScreen(context);
      case _MockScreen.lockers:
        return _lockersScreen(context);
      case _MockScreen.counters:
        return _countersScreen(context);
      case _MockScreen.otrSupplies:
        return _otrSuppliesScreen(context);
      case _MockScreen.otpBadge:
        return _otpBadgeScreen(context);
      case _MockScreen.otpBadgeVisual:
        return _otpBadgeVisualScreen(context);
      case _MockScreen.weatherBags:
        return _weatherBagsScreen(context);
      case _MockScreen.readyToGo:
        return _readyToGoScreen(context);
      case _MockScreen.customerArrivalContact:
        return _customerArrivalContactScreen(context);
      case _MockScreen.customerFeedback:
        return _customerFeedbackScreen(context);
      case _MockScreen.concessions:
        return _concessionsScreen(context);
      case _MockScreen.deliveryAppUsage:
        return _deliveryAppUsageScreen(context);
      case _MockScreen.deliveryAppOverview:
        return _deliveryAppOverviewScreen(context);
      case _MockScreen.transportationMethod:
        return _transportationMethodScreen(context);
      case _MockScreen.verifyIdentity:
        return _verifyIdentityScreen(context);
      case _MockScreen.deliveryAppOverviewMaps:
        return _deliveryAppOverviewMapsScreen(context);
      case _MockScreen.offlineMapsPrompt:
        return _offlineMapsPromptScreen(context);
      case _MockScreen.settingsPrompt:
        return _settingsPromptScreen(context);
      case _MockScreen.offlineMapsSettingsPrompt:
        return _offlineMapsSettingsPromptScreen(context);
      case _MockScreen.offlineMapsDownloadPrompt:
        return _offlineMapsDownloadPromptScreen(context);
      case _MockScreen.offlineMapsDownloadedPrompt:
        return _offlineMapsDownloadedPromptScreen(context);
      case _MockScreen.offlineMapsConnectivityPrompt:
        return _offlineMapsConnectivityPromptScreen(context);
      case _MockScreen.overviewIntroPrompt:
        return _overviewIntroPromptScreen(context);
      case _MockScreen.overviewTabsPrompt:
        return _overviewTabsPromptScreen(context);
      case _MockScreen.overviewItineraryTapPrompt:
        return _overviewItineraryTapPromptScreen(context);
      case _MockScreen.itineraryOverviewPrompt:
        return _itineraryOverviewPromptScreen(context);
      case _MockScreen.itineraryDeliveryTypePrompt:
        return _itineraryDeliveryTypePromptScreen(context);
      case _MockScreen.itineraryMapTapPrompt:
        return _itineraryMapTapPromptScreen(context);
      case _MockScreen.itineraryMapLocationsPrompt:
        return _itineraryMapLocationsPromptScreen(context);
      case _MockScreen.itinerarySummaryTapPrompt:
        return _itinerarySummaryTapPromptScreen(context);
      case _MockScreen.itinerarySummaryOverviewPrompt:
        return _itinerarySummaryOverviewPromptScreen(context);
      case _MockScreen.menu:
        return _menuScreen();
      case _MockScreen.settings:
        return _settingsScreen();
      case _MockScreen.overview:
        return _overviewScreen();
      case _MockScreen.itinerary:
        return _itineraryScreen();
      case _MockScreen.map:
        return _mapScreen();
      case _MockScreen.summary:
        return _summaryScreen();
      case _MockScreen.stopDetails:
        return _stopDetailsScreen();
    }
  }

  Widget _welcomeScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.close,
              color: const Color(0xFF6E66FB).withValues(alpha: 0.9),
              size: 24,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 258,
                  height: 258,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9E3EE),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 116,
                          decoration: const BoxDecoration(
                            color: Color(0xFFA8C6E7),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(129),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 24,
                        child: Container(
                          width: 84,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4E92D1),
                            borderRadius: BorderRadius.all(Radius.circular(42)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 56,
                        bottom: 15,
                        child: Container(
                          width: 96,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5DA0DF),
                            borderRadius: BorderRadius.all(Radius.circular(48)),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 18,
                        bottom: 22,
                        child: Container(
                          width: 90,
                          height: 66,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4E92D1),
                            borderRadius: BorderRadius.all(Radius.circular(44)),
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.rocket_launch_rounded,
                          size: 88,
                          color: Color(0xFF6B7A89),
                        ),
                      ),
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 66,
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          size: 34,
                          color: Color(0xFFF46A27),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _hotspot(
                  _HotspotTarget.coachContinue,
                  SizedBox(
                    width: 240,
                    height: 56,
                    child: FilledButton(
                      onPressed: () =>
                          onTargetTap(_HotspotTarget.coachContinue),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2F4573),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        t.t('delivery_training_launch_button'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeOfDeliveriesScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _deliveryTypeCardScreen(
      context,
      imageAsset: 'assets/da_academy/activity1/005.png',
      title: t.t('delivery_training_welcome_title'),
      body: null,
    );
  }

  Widget _doorToDoorScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _deliveryTypeCardScreen(
      context,
      imageAsset: 'assets/da_academy/activity1/006.png',
      title: t.t('delivery_training_door_to_door_title'),
      body: t.t('delivery_training_door_to_door_body'),
    );
  }

  Widget _lockersScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _deliveryTypeCardScreen(
      context,
      imageAsset: 'assets/da_academy/activity1/007.png',
      title: t.t('delivery_training_lockers_title'),
      body: t.t('delivery_training_lockers_body'),
    );
  }

  Widget _countersScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _deliveryTypeCardScreen(
      context,
      imageAsset: 'assets/da_academy/activity1/008.png',
      title: t.t('delivery_training_counters_title'),
      body: t.t('delivery_training_counters_body'),
    );
  }

  Widget _otrSuppliesScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFE3E3E3),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF202225),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Text(
                t.t('delivery_training_otr_header'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.t('delivery_training_otr_body_1'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2B2F36),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      t.t('delivery_training_otr_body_2'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2B2F36),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 86),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: _hotspot(
                _HotspotTarget.coachContinue,
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => onTargetTap(_HotspotTarget.coachContinue),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1788C3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryTypeCardScreen(
    BuildContext context, {
    required String imageAsset,
    required String title,
    required String? body,
  }) {
    return Container(
      color: const Color(0xFFE3E3E3),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 248,
                width: double.infinity,
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 50 * 0.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  height: 1.15,
                ),
              ),
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  body,
                  style: const TextStyle(
                    fontSize: 21 * 0.8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF273549),
                    height: 1.26,
                  ),
                ),
              ),
            ],
            const Spacer(),
            _hotspot(
              _HotspotTarget.coachContinue,
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => onTargetTap(_HotspotTarget.coachContinue),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1788C3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 34),
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  Widget _otpBadgeScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _buildOtpSupportScreen(
      bodyText: t.t('delivery_training_otp_badge_body'),
    );
  }

  Widget _otpBadgeVisualScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _buildOtpSupportScreen(
      bodyText: t.t('delivery_training_otp_badge_help_body'),
    );
  }

  Widget _weatherBagsScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _buildWeatherBagsSupportScreen(
      bodyText: t.t('delivery_training_weather_bags_body'),
    );
  }

  Widget _readyToGoScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFE3E3E3),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF202225),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Text(
                t.t('delivery_training_otr_header'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.t('delivery_training_ready_to_go_body'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2B2F36),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text(
                      t.t('delivery_training_ready_to_go_footer'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2B2F36),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 320),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: _hotspot(
                _HotspotTarget.coachContinue,
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => onTargetTap(_HotspotTarget.coachContinue),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1788C3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerArrivalContactScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFE3E3E3),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFB8D2DD), width: 3),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFDDB494), Color(0xFFCCA28A)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 28,
                    top: 80,
                    child: Container(
                      width: 82,
                      height: 126,
                      decoration: BoxDecoration(
                        color: const Color(0xFF45071D),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 28,
                    top: 80,
                    child: Container(
                      width: 82,
                      height: 126,
                      decoration: BoxDecoration(
                        color: const Color(0xFF45071D),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 92,
                    right: 92,
                    top: 56,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: const BoxDecoration(
                        color: Color(0xFF43A1E0),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 36,
                    top: 130,
                    child: Icon(
                      Icons.location_on,
                      size: 130,
                      color: const Color(0xFFF21A1A).withValues(alpha: 0.98),
                    ),
                  ),
                  Positioned(
                    left: 170,
                    top: 44,
                    child: Container(
                      width: 76,
                      height: 134,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF1F2937),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF4A53A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mail_outline_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 118,
                    top: 184,
                    child: Container(
                      width: 190,
                      height: 74,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D4E6C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 42,
                    right: 42,
                    top: 246,
                    child: Container(
                      width: 276,
                      height: 276,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF2F5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 94,
                    top: 318,
                    child: Container(
                      width: 102,
                      height: 122,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFB195),
                        borderRadius: BorderRadius.all(Radius.circular(48)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 86,
                    top: 388,
                    child: Transform.rotate(
                      angle: -0.42,
                      child: Container(
                        width: 24,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 18,
                      color: const Color(0xFF0E8AB7),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -6),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _OtpBodyText(
                      text: t.t('delivery_training_customer_arrival_body'),
                      emphasisWords: const [
                        'call or text the Customer',
                        'notify them of your arrival',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _hotspot(
                      _HotspotTarget.coachContinue,
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () =>
                              onTargetTap(_HotspotTarget.coachContinue),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1788C3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerFeedbackScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFE3E3E3),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE1C8B1), width: 3),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFC8D6C2), Color(0xFFF0EAD7)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 24,
                    child: Container(
                      width: 120,
                      height: 148,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9FB094),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 28,
                    child: Container(
                      width: 110,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFE8D5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 128,
                    top: 22,
                    child: Container(
                      width: 190,
                      height: 168,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 160,
                    top: 76,
                    child: Container(
                      width: 130,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4EA6D8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.star, color: Color(0xFFFACC15), size: 20),
                          Icon(Icons.star, color: Color(0xFFFACC15), size: 20),
                          Icon(Icons.star, color: Color(0xFFFACC15), size: 20),
                          Icon(Icons.star, color: Color(0xFFFACC15), size: 20),
                          Icon(Icons.star, color: Color(0xFFFACC15), size: 20),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 164,
                    top: 184,
                    child: Container(
                      width: 22,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 64,
                    top: 218,
                    child: Container(
                      width: 288,
                      height: 288,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAE3D4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 124,
                    top: 308,
                    child: Container(
                      width: 170,
                      height: 160,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1B196),
                        borderRadius: BorderRadius.all(Radius.circular(90)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 136,
                    top: 334,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7A7981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 138,
                    top: 334,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7A7981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 150,
                    top: 396,
                    child: Container(
                      width: 130,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9CA3AF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 124,
                    right: 124,
                    bottom: 0,
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9A5B21),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -6),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _OtpBodyText(
                      text: t.t('delivery_training_customer_feedback_body'),
                      emphasisWords: const [
                        'survey',
                        'evaluate their experience',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _hotspot(
                      _HotspotTarget.coachContinue,
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () =>
                              onTargetTap(_HotspotTarget.coachContinue),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1788C3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _concessionsScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFE3E3E3),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 390,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: const Color(0xFFA7A1A1)),
                    ),
                    ...List.generate(
                      8,
                      (i) => Positioned(
                        left: 0,
                        right: 0,
                        top: 18 + (i * 42),
                        child: Container(
                          height: 2,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 80,
                      top: 20,
                      child: Container(
                        width: 214,
                        height: 330,
                        decoration: BoxDecoration(
                          color: const Color(0xFF262734),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFF1F5F9),
                            width: 10,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 96,
                      top: 68,
                      child: Container(
                        width: 182,
                        height: 236,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F404D),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 6,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 168,
                      top: 184,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3F6273),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 26,
                      top: 112,
                      child: SizedBox(
                        width: 120,
                        child: Transform.rotate(
                          angle: -0.22,
                          child: const _ConcessionsPersonFigure(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 44,
                      top: 26,
                      child: Container(
                        width: 220,
                        height: 148,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 18,
                              top: 48,
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5722),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.sentiment_dissatisfied_rounded,
                                  color: Colors.black,
                                  size: 34,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 36,
                              top: 30,
                              child: Icon(
                                Icons.paid_rounded,
                                color: Colors.green.shade700,
                                size: 44,
                              ),
                            ),
                            Positioned(
                              left: 88,
                              top: 92,
                              child: Icon(
                                Icons.south_rounded,
                                color: const Color(0xFFFF6B4A),
                                size: 52,
                              ),
                            ),
                            Positioned(
                              left: 112,
                              top: 94,
                              child: Container(
                                width: 52,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1A374),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              bottom: 18,
                              child: Container(
                                width: 182,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4EA6D8),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Color(0xFFEF4444),
                                      size: 20,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Color(0xFF2C7EA7),
                                      size: 20,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Color(0xFF2C7EA7),
                                      size: 20,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Color(0xFF2C7EA7),
                                      size: 20,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Color(0xFF2C7EA7),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 126,
                      bottom: 18,
                      child: Container(
                        width: 86,
                        height: 84,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFFF4B2D),
                            width: 4,
                          ),
                        ),
                        child: const Icon(
                          Icons.question_mark_rounded,
                          color: Color(0xFFFF2D20),
                          size: 64,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.t('delivery_training_concessions_title'),
                style: const TextStyle(
                  fontSize: 50 * 0.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: _OtpBodyText(
                text: t.t('delivery_training_concessions_body'),
                emphasisWords: const ['refund', 'concession'],
              ),
            ),
            const Spacer(),
            _hotspot(
              _HotspotTarget.coachContinue,
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => onTargetTap(_HotspotTarget.coachContinue),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1788C3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 34),
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  Widget _deliveryAppUsageScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFE3E3E3),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                height: 390,
                width: double.infinity,
                child: _DeliveryAppUsageIllustration(),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.t('delivery_training_delivery_app_usage_title'),
                style: const TextStyle(
                  fontSize: 50 * 0.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: _OtpBodyText(
                text: t.t('delivery_training_delivery_app_usage_body'),
                emphasisWords: const ['Delivery App'],
              ),
            ),
            const Spacer(),
            _hotspot(
              _HotspotTarget.coachContinue,
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => onTargetTap(_HotspotTarget.coachContinue),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1788C3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 34),
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  Widget _deliveryAppOverviewScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFE3E3E3),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF202225),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Text(
                t.t('delivery_training_delivery_app_overview_header'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: _OtpBodyText(
                  text: t.t('delivery_training_delivery_app_overview_body'),
                  emphasisWords: const ['Delivery App', 'never uninstall it'],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: _hotspot(
                _HotspotTarget.coachContinue,
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => onTargetTap(_HotspotTarget.coachContinue),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1788C3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transportationMethodScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF6F6F6F),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            color: const Color(0xFF607683),
            child: Text(
              t.t('delivery_training_transportation_method_header'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
            color: const Color(0xFF6D6D6D),
            child: Text(
              t.t('delivery_training_transportation_method_question'),
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w900,
                fontSize: 24 * 0.8,
                height: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      color: const Color(0xFFF6F7F8),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        children: [
                          _transportOptionRow(
                            t.t('delivery_training_transportation_method_walk'),
                          ),
                          _transportOptionRow(
                            t.t(
                              'delivery_training_transportation_method_drive',
                            ),
                          ),
                          _transportOptionRow(
                            t.t('delivery_training_transportation_method_bike'),
                          ),
                          _transportOptionRow(
                            t.t(
                              'delivery_training_transportation_method_motorcycle',
                            ),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Container(color: const Color(0xFF6F6F6F))),
                  ],
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -28,
                        left: 0,
                        right: 0,
                        child: const Center(
                          child: Icon(
                            Icons.arrow_drop_up_rounded,
                            color: Colors.white,
                            size: 68,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.t(
                                'delivery_training_transportation_method_card_title',
                              ),
                              style: const TextStyle(
                                color: Color(0xFF1F2937),
                                fontWeight: FontWeight.w900,
                                fontSize: 26 * 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.t(
                                'delivery_training_transportation_method_card_body',
                              ),
                              style: const TextStyle(
                                color: Color(0xFF1F2937),
                                fontWeight: FontWeight.w500,
                                fontSize: 20 * 0.8,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _hotspot(
                              _HotspotTarget.coachContinue,
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton(
                                  onPressed: () =>
                                      onTargetTap(_HotspotTarget.coachContinue),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF1788C3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 34,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifyIdentityScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFECEFF1),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            color: const Color(0xFF607683),
            child: Text(
              t.t('delivery_training_verify_identity_header'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: const Color(0xFF6E6E6E),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _OtpBodyText(
                        text: t.t(
                          'delivery_training_verify_identity_card_body',
                        ),
                        emphasisWords: const ['take a selfie'],
                      ),
                      const SizedBox(height: 12),
                      _hotspot(
                        _HotspotTarget.coachContinue,
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: () =>
                                onTargetTap(_HotspotTarget.coachContinue),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1788C3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -30,
                  child: const Center(
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.white,
                      size: 74,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF6F7F8),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.t(
                              'delivery_training_verify_identity_instructions_title',
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 24 * 0.7,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.t(
                              'delivery_training_verify_identity_instructions_body',
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 19 * 0.7,
                              fontWeight: FontWeight.w500,
                              height: 1.28,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t.t('delivery_training_verify_identity_tips_title'),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 24 * 0.7,
                            ),
                          ),
                          const SizedBox(height: 2),
                          ...[
                            'delivery_training_verify_identity_tip_1',
                            'delivery_training_verify_identity_tip_2',
                            'delivery_training_verify_identity_tip_3',
                            'delivery_training_verify_identity_tip_4',
                            'delivery_training_verify_identity_tip_5',
                            'delivery_training_verify_identity_tip_6',
                          ].map(
                            (key) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '• ${t.t(key)}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18 * 0.7,
                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: const Color(0xFF6E6E6E),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D3A4A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            t.t('delivery_training_verify_identity_take_photo'),
                            style: const TextStyle(
                              color: Color(0xFF73808A),
                              fontWeight: FontWeight.w700,
                              fontSize: 23 * 0.7,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryAppOverviewMapsScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFE3E3E3),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF202225),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Text(
                t.t('delivery_training_delivery_app_overview_header'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: _OtpBodyText(
                  text: t.t(
                    'delivery_training_delivery_app_overview_maps_body',
                  ),
                  emphasisWords: const ['download maps'],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: _hotspot(
                _HotspotTarget.coachContinue,
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => onTargetTap(_HotspotTarget.coachContinue),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1788C3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _offlineMapsPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF6F6F6F),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                _hotspot(
                  _HotspotTarget.menu,
                  InkWell(
                    onTap: () => onTargetTap(_HotspotTarget.menu),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFAEDCFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: Color(0xFF1F2937),
                        size: 46,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.t('delivery_training_offline_maps_prompt_title'),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 32 * 0.7,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF111827),
                  size: 36,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF111827),
                  size: 44,
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF808489),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF686D75),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.format_list_bulleted_rounded,
                      color: Color(0xFF111827),
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF686D75),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      color: Color(0xFF111827),
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF686D75),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.speed_rounded,
                      color: Color(0xFF111827),
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF767676),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _GridPainter()),
                        ),
                        ...List.generate(
                          7,
                          (i) => Positioned(
                            left: 40 + (i * 48).toDouble(),
                            top: 56 + (i * 76).toDouble(),
                            child: Container(
                              width: 180,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC4C7CB,
                                ).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 120,
                          top: 88,
                          child: _mapPin('1', const Color(0xFF1C6A19)),
                        ),
                        Positioned(
                          left: 136,
                          top: 176,
                          child: _mapPin('2', const Color(0xFF111827)),
                        ),
                        Positioned(
                          left: 170,
                          top: 256,
                          child: _mapPin('3', const Color(0xFF111827)),
                        ),
                        Positioned(
                          right: 18,
                          top: 282,
                          child: Icon(
                            Icons.settings_rounded,
                            color: const Color(0xFF111827),
                            size: 58,
                          ),
                        ),
                        Positioned(
                          right: 18,
                          top: 404,
                          child: Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.near_me_rounded,
                              color: Color(0xFF111827),
                              size: 42,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _OtpBodyText(
                      text: t.t('delivery_training_offline_maps_prompt_body'),
                      emphasisWords: const ['Main Menu', 'Tap on it!'],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF5E6166),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 220,
                      color: const Color(0xFF607683),
                      child: Stack(
                        children: [
                          const Positioned(
                            left: 24,
                            top: 22,
                            child: Icon(
                              Icons.close_rounded,
                              size: 56,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 16,
                            child: Center(
                              child: Container(
                                width: 128,
                                height: 128,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8A8E93),
                                  shape: BoxShape.circle,
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 40,
                                      top: 20,
                                      child: Container(
                                        width: 46,
                                        height: 46,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF241716),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 28,
                                      top: 38,
                                      child: Container(
                                        width: 72,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF866A51),
                                          borderRadius: BorderRadius.circular(
                                            42,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 26,
                                      bottom: 18,
                                      child: Container(
                                        width: 78,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF151D25),
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _settingsPromptRow(
                      t.t('delivery_training_settings_prompt_current_stop'),
                      bg: const Color(0xFF7A7D82),
                    ),
                    _settingsPromptRow(
                      t.t('delivery_training_settings_prompt_feedback'),
                      bg: const Color(0xFF6E7176),
                    ),
                    InkWell(
                      onTap: () => onTargetTap(_HotspotTarget.settingsItem),
                      child: _settingsPromptRow(
                        t.t('delivery_training_settings_prompt_settings'),
                        bg: const Color(0xFFF7F8F9),
                        textColor: const Color(0xFF1E293B),
                      ),
                    ),
                    _settingsPromptRow(
                      t.t('delivery_training_settings_prompt_breaks'),
                      bg: const Color(0xFF6E7176),
                    ),
                    Container(height: 152, color: const Color(0xFF686B70)),
                    _settingsPromptBottomRow(
                      t.t('delivery_training_settings_prompt_driver_support'),
                      icon: Icons.support_agent_rounded,
                      iconColor: const Color(0xFF045B7A),
                    ),
                    _settingsPromptBottomRow(
                      t.t('delivery_training_settings_prompt_emergency_help'),
                      icon: Icons.health_and_safety_rounded,
                      iconColor: const Color(0xFF8A1F31),
                    ),
                  ],
                ),
              ),
              Container(width: 74, color: const Color(0xFF4D4F53)),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 250,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _OtpBodyText(
                    text: t.t('delivery_training_settings_prompt_body'),
                    emphasisWords: const ['Settings', 'Tap on it!'],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -30,
                  child: const Center(
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.white,
                      size: 74,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offlineMapsSettingsPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF6E7176),
      child: Column(
        children: [
          Container(
            height: 106,
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const Spacer(),
                Text(
                  t.t('delivery_training_offline_maps_settings_header'),
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                    fontSize: 26 * 0.8,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 52),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    _settingsListRow(
                      t.t('delivery_training_offline_maps_settings_personal'),
                    ),
                    _settingsListRow(
                      t.t('delivery_training_offline_maps_settings_phone'),
                    ),
                    _settingsListRow(
                      t.t('delivery_training_offline_maps_settings_legal'),
                    ),
                    InkWell(
                      onTap: () => onTargetTap(_HotspotTarget.offlineMapsItem),
                      child: _settingsListRow(
                        t.t('delivery_training_offline_maps_settings_offline'),
                        bg: const Color(0xFFF7F8F9),
                        textColor: Colors.black,
                        chevronColor: const Color(0xFFD1D5DB),
                      ),
                    ),
                    _settingsListRow(
                      t.t('delivery_training_offline_maps_settings_version'),
                    ),
                    _settingsListRow(
                      t.t('delivery_training_offline_maps_settings_device'),
                    ),
                    const Spacer(),
                    Container(
                      height: 86,
                      width: double.infinity,
                      color: const Color(0xFF0D3A4A),
                      alignment: Alignment.center,
                      child: Text(
                        t.t('delivery_training_offline_maps_settings_sign_out'),
                        style: const TextStyle(
                          color: Color(0xFF77818A),
                          fontSize: 26 * 0.8,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 70,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 100,
                        padding: const EdgeInsets.fromLTRB(34, 26, 34, 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Color(0xFF273549),
                                fontSize: 58 * 0.32,
                                fontWeight: FontWeight.w500,
                                height: 1.24,
                              ),
                              children: [
                                TextSpan(
                                  text: t.t(
                                    'delivery_training_offline_maps_settings_prompt_prefix',
                                  ),
                                ),
                                TextSpan(
                                  text: t.t(
                                    'delivery_training_offline_maps_settings_prompt_target',
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text: t.t(
                                    'delivery_training_offline_maps_settings_prompt_suffix',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -30,
                        child: const Center(
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.white,
                            size: 74,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offlineMapsDownloadPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF6E7176),
      child: Column(
        children: [
          Container(
            height: 106,
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const Spacer(),
                Text(
                  t.t('delivery_training_offline_maps_download_header'),
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                    fontSize: 26 * 0.8,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 52),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 84,
                      width: double.infinity,
                      color: const Color(0xFF6E7176),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        t.t('delivery_training_offline_maps_download_settings'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24 * 0.7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: const Color(0xFFF7F8F9),
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.t(
                                    'delivery_training_offline_maps_allow_title',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 26 * 0.7,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Container(
                                width: 122,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1D5DB),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF9FAFB),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t.t('delivery_training_offline_maps_allow_body'),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20 * 0.7,
                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 80,
                      width: double.infinity,
                      color: const Color(0xFF6E7176),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        t.t('delivery_training_offline_maps_downloaded_title'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24 * 0.7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _settingsListRow(
                      t.t('delivery_training_offline_maps_downloaded_item'),
                    ),
                    Container(
                      height: 56,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6E7176),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF64676C),
                            width: 1,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        '165.9 MB',
                        style: TextStyle(
                          color: Color(0xFF3D4248),
                          fontSize: 20 * 0.7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 86,
                      width: double.infinity,
                      color: const Color(0xFF0D3A4A),
                      alignment: Alignment.center,
                      child: Text(
                        t.t('delivery_training_offline_maps_settings_sign_out'),
                        style: const TextStyle(
                          color: Color(0xFF77818A),
                          fontSize: 26 * 0.8,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  top: 390,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -30,
                        left: 0,
                        right: 0,
                        child: const Center(
                          child: Icon(
                            Icons.arrow_drop_up_rounded,
                            color: Colors.white,
                            size: 78,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _OtpBodyText(
                              text: t.t(
                                'delivery_training_offline_maps_download_prompt_body',
                              ),
                              emphasisWords: const [
                                'offline maps',
                                '"Download over cellular network"',
                              ],
                            ),
                            const SizedBox(height: 14),
                            _hotspot(
                              _HotspotTarget.coachContinue,
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton(
                                  onPressed: () =>
                                      onTargetTap(_HotspotTarget.coachContinue),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF1788C3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 34,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offlineMapsDownloadedPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF6E7176),
      child: Column(
        children: [
          Container(
            height: 106,
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const Spacer(),
                Text(
                  t.t('delivery_training_offline_maps_download_header'),
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                    fontSize: 26 * 0.8,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 52),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 84,
                      width: double.infinity,
                      color: const Color(0xFF6E7176),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        t.t('delivery_training_offline_maps_download_settings'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24 * 0.7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF6E7176),
                      padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.t(
                                    'delivery_training_offline_maps_allow_title',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 26 * 0.7,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Container(
                                width: 122,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF777B81),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF90949A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t.t('delivery_training_offline_maps_allow_body'),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20 * 0.7,
                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: const Color(0xFFF7F8F9),
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                t.t(
                                  'delivery_training_offline_maps_downloaded_title',
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24 * 0.7,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF111827),
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'i',
                                    style: TextStyle(
                                      color: Color(0xFF111827),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 26 * 0.7,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFD1D5DB),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.t(
                                        'delivery_training_offline_maps_downloaded_code',
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 22 * 0.7,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t.t(
                                        'delivery_training_offline_maps_downloaded_size',
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 22 * 0.7,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.black,
                                size: 48,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 84,
                      width: double.infinity,
                      color: const Color(0xFF6E7176),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        t.t('delivery_training_offline_maps_other_maps'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24 * 0.7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(child: Container(color: const Color(0xFF6E7176))),
                    Container(
                      height: 86,
                      width: double.infinity,
                      color: const Color(0xFF0D3A4A),
                      alignment: Alignment.center,
                      child: Text(
                        t.t('delivery_training_offline_maps_settings_sign_out'),
                        style: const TextStyle(
                          color: Color(0xFF77818A),
                          fontSize: 26 * 0.8,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  top: 420,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -30,
                        left: 0,
                        right: 0,
                        child: const Center(
                          child: Icon(
                            Icons.arrow_drop_up_rounded,
                            color: Colors.white,
                            size: 78,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _OtpBodyText(
                              text: t.t(
                                'delivery_training_offline_maps_downloaded_prompt_body',
                              ),
                              emphasisWords: const ['already downloaded'],
                            ),
                            const SizedBox(height: 14),
                            _hotspot(
                              _HotspotTarget.coachContinue,
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton(
                                  onPressed: () =>
                                      onTargetTap(_HotspotTarget.coachContinue),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF1788C3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 34,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offlineMapsConnectivityPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF6E7176),
      child: Column(
        children: [
          Container(
            height: 106,
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const Spacer(),
                Text(
                  t.t('delivery_training_offline_maps_download_header'),
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w900,
                    fontSize: 26 * 0.8,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 52),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: 82,
                      width: double.infinity,
                      color: const Color(0xFF6E7176),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        t.t('delivery_training_offline_maps_download_settings'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24 * 0.7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF6E7176),
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.t(
                                    'delivery_training_offline_maps_allow_title',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 26 * 0.7,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Container(
                                width: 122,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF777B81),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF90949A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t.t('delivery_training_offline_maps_allow_body'),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20 * 0.7,
                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: const Color(0xFFF7F8F9),
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                t.t(
                                  'delivery_training_offline_maps_downloaded_title',
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24 * 0.7,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF111827),
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'i',
                                    style: TextStyle(
                                      color: Color(0xFF111827),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 26 * 0.7,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFD1D5DB),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.t(
                                        'delivery_training_offline_maps_downloaded_code',
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 22 * 0.7,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t.t(
                                        'delivery_training_offline_maps_downloaded_size',
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 22 * 0.7,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.black,
                                size: 48,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF7F8F9),
                        child: Column(
                          children: [
                            Container(
                              height: 66,
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                              ),
                              child: Text(
                                t.t(
                                  'delivery_training_offline_maps_other_maps',
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24 * 0.7,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFD1D5DB),
                            ),
                            _offlineMapOtherRow(
                              code: t.t(
                                'delivery_training_offline_maps_other_code_1',
                              ),
                              size: t.t(
                                'delivery_training_offline_maps_other_size_1',
                              ),
                            ),
                            _offlineMapOtherRow(
                              code: t.t(
                                'delivery_training_offline_maps_other_code_2',
                              ),
                              size: t.t(
                                'delivery_training_offline_maps_other_size_2',
                              ),
                            ),
                            _offlineMapOtherRow(
                              code: t.t(
                                'delivery_training_offline_maps_other_code_3',
                              ),
                              size: t.t(
                                'delivery_training_offline_maps_other_size_3',
                              ),
                              showDivider: false,
                            ),
                            Expanded(
                              child: Container(color: const Color(0xFF6E7176)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 86,
                      width: double.infinity,
                      color: const Color(0xFF0D3A4A),
                      alignment: Alignment.center,
                      child: Text(
                        t.t('delivery_training_offline_maps_settings_sign_out'),
                        style: const TextStyle(
                          color: Color(0xFF77818A),
                          fontSize: 26 * 0.8,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 592,
                  child: Container(color: Colors.black.withValues(alpha: 0.34)),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  top: 0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _OtpBodyText(
                              text: t.t(
                                'delivery_training_offline_maps_connectivity_prompt_body',
                              ),
                              emphasisWords: const ['poor connectivity'],
                            ),
                            const SizedBox(height: 14),
                            _hotspot(
                              _HotspotTarget.coachContinue,
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton(
                                  onPressed: () =>
                                      onTargetTap(_HotspotTarget.coachContinue),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF1788C3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 34,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -36,
                        child: const Center(
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.white,
                            size: 88,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewIntroPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF70757B),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.t('delivery_training_screen_title_overview'),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 32 * 0.7,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF111827),
                  size: 36,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF111827),
                  size: 44,
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF808489),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF686D75),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.format_list_bulleted_rounded,
                      color: Color(0xFF111827),
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF686D75),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      color: Color(0xFF111827),
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF686D75),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.speed_rounded,
                      color: Color(0xFF111827),
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF787A7A),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _GridPainter()),
                        ),
                        ...List.generate(
                          8,
                          (i) => Positioned(
                            left: 26 + (i * 42).toDouble(),
                            top: 44 + (i * 76).toDouble(),
                            child: Container(
                              width: 186,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC4C7CB,
                                ).withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 110,
                          top: 112,
                          child: _mapPin('1', const Color(0xFF1C6A19)),
                        ),
                        Positioned(
                          left: 130,
                          top: 198,
                          child: _mapPin('2', const Color(0xFF111827)),
                        ),
                        Positioned(
                          left: 162,
                          top: 282,
                          child: _mapPin('3', const Color(0xFF111827)),
                        ),
                        Positioned(
                          right: 16,
                          top: 332,
                          child: Icon(
                            Icons.settings_rounded,
                            color: const Color(0xFF111827),
                            size: 62,
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 474,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.near_me_rounded,
                              color: Color(0xFF111827),
                              size: 44,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      border: const Border(
                        top: BorderSide(color: Color(0xFFD3D8DE), width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFD2D9E1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Deliver 2 packages',
                                      style: TextStyle(
                                        color: Color(0xFF4B5563),
                                        fontSize: 20 * 0.7,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          color: Color(0xFF6B7280),
                                          size: 20,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '09:00 - 11:00',
                                          style: TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 18 * 0.7,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF8AA1B8),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  color: Color(0xFF8AA1B8),
                                  size: 34,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF8AA1B8),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.vpn_key_rounded,
                                  color: Color(0xFF8AA1B8),
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 72,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBFD3E2),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Text(
                                  'Start travel',
                                  style: TextStyle(
                                    color: Color(0xFFF8F8F8),
                                    fontSize: 24 * 0.7,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 88,
                              height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFFBFD3E2),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.open_in_new_rounded,
                                size: 46,
                                color: Color(0xFFE7EDF3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.34)),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 78,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: _OtpBodyText(
                      text: t.t('delivery_training_overview_intro_prompt_body'),
                      emphasisWords: const [
                        'Overview',
                        'deliver',
                        'troubleshoot',
                        'Let’s take a look!',
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewTabsPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF70757B),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.t('delivery_training_screen_title_overview'),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 32 * 0.7,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF111827),
                  size: 36,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF111827),
                  size: 44,
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF6E7176),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Container(
              height: 98,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(48),
              ),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFBEC9D5),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.format_list_bulleted_rounded,
                        color: Color(0xFF273549),
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFBEC9D5),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        color: Color(0xFF273549),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFBEC9D5),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.speed_rounded,
                        color: Color(0xFF273549),
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF787A7A),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _GridPainter()),
                        ),
                        ...List.generate(
                          8,
                          (i) => Positioned(
                            left: 26 + (i * 42).toDouble(),
                            top: 44 + (i * 76).toDouble(),
                            child: Container(
                              width: 186,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC4C7CB,
                                ).withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 110,
                          top: 112,
                          child: _mapPin('1', const Color(0xFF1C6A19)),
                        ),
                        Positioned(
                          left: 130,
                          top: 198,
                          child: _mapPin('2', const Color(0xFF111827)),
                        ),
                        Positioned(
                          left: 162,
                          top: 282,
                          child: _mapPin('3', const Color(0xFF111827)),
                        ),
                        Positioned(
                          right: 16,
                          top: 332,
                          child: Icon(
                            Icons.settings_rounded,
                            color: const Color(0xFF111827),
                            size: 62,
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 474,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.near_me_rounded,
                              color: Color(0xFF111827),
                              size: 44,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      border: const Border(
                        top: BorderSide(color: Color(0xFFD3D8DE), width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFD2D9E1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Deliver 2 packages',
                                      style: TextStyle(
                                        color: Color(0xFF1F2937),
                                        fontSize: 20 * 0.7,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          color: Color(0xFF045B7A),
                                          size: 20,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '09:00 - 11:00',
                                          style: TextStyle(
                                            color: Color(0xFF374151),
                                            fontSize: 18 * 0.7,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF045B7A),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  color: Color(0xFF045B7A),
                                  size: 34,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF045B7A),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.vpn_key_rounded,
                                  color: Color(0xFF045B7A),
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 72,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D3A4A),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Text(
                                  'Start travel',
                                  style: TextStyle(
                                    color: Color(0xFF77818A),
                                    fontSize: 24 * 0.7,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 88,
                              height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D3A4A),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.open_in_new_rounded,
                                size: 46,
                                color: Color(0xFF77818A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.34)),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  top: 172,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -48,
                        left: 0,
                        right: 0,
                        child: const Center(
                          child: Icon(
                            Icons.arrow_drop_up_rounded,
                            color: Colors.white,
                            size: 116,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _OtpBodyText(
                              text: t.t(
                                'delivery_training_overview_tabs_prompt',
                              ),
                              emphasisWords: const ['itinerary'],
                            ),
                            const SizedBox(height: 14),
                            _hotspot(
                              _HotspotTarget.coachContinue,
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton(
                                  onPressed: () =>
                                      onTargetTap(_HotspotTarget.coachContinue),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF1788C3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 34,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewItineraryTapPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF70757B),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.t('delivery_training_screen_title_overview'),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 32 * 0.7,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF111827),
                  size: 36,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF111827),
                  size: 44,
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF6E7176),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: SizedBox(
              height: 98,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => onTargetTap(_HotspotTarget.tabItinerary),
                    borderRadius: BorderRadius.circular(48),
                    child: Container(
                      width: 320,
                      height: 98,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(48),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFBEC9D5),
                          borderRadius: BorderRadius.circular(34),
                        ),
                        child: const Icon(
                          Icons.format_list_bulleted_rounded,
                          color: Color(0xFF273549),
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      height: 78,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E646D),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        color: Color(0xFF111827),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 78,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E646D),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.speed_rounded,
                        color: Color(0xFF111827),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF787A7A),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _GridPainter()),
                        ),
                        ...List.generate(
                          8,
                          (i) => Positioned(
                            left: 26 + (i * 42).toDouble(),
                            top: 44 + (i * 76).toDouble(),
                            child: Container(
                              width: 186,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC4C7CB,
                                ).withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 110,
                          top: 112,
                          child: _mapPin('1', const Color(0xFF1C6A19)),
                        ),
                        Positioned(
                          left: 130,
                          top: 198,
                          child: _mapPin('2', const Color(0xFF111827)),
                        ),
                        Positioned(
                          left: 162,
                          top: 282,
                          child: _mapPin('3', const Color(0xFF111827)),
                        ),
                        Positioned(
                          right: 16,
                          top: 332,
                          child: Icon(
                            Icons.settings_rounded,
                            color: const Color(0xFF111827),
                            size: 62,
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 474,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.near_me_rounded,
                              color: Color(0xFF111827),
                              size: 44,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      border: const Border(
                        top: BorderSide(color: Color(0xFFD3D8DE), width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFD2D9E1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Deliver 2 packages',
                                      style: TextStyle(
                                        color: Color(0xFF1F2937),
                                        fontSize: 20 * 0.7,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          color: Color(0xFF045B7A),
                                          size: 20,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '09:00 - 11:00',
                                          style: TextStyle(
                                            color: Color(0xFF374151),
                                            fontSize: 18 * 0.7,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF045B7A),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  color: Color(0xFF045B7A),
                                  size: 34,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF045B7A),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.vpn_key_rounded,
                                  color: Color(0xFF045B7A),
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 72,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D3A4A),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Text(
                                  'Start travel',
                                  style: TextStyle(
                                    color: Color(0xFF77818A),
                                    fontSize: 24 * 0.7,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 88,
                              height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D3A4A),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.open_in_new_rounded,
                                size: 46,
                                color: Color(0xFF77818A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.34)),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  top: 170,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -46,
                        left: 82,
                        child: const Icon(
                          Icons.arrow_drop_up_rounded,
                          color: Colors.white,
                          size: 116,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _OtpBodyText(
                          text: t.t(
                            'delivery_training_overview_itinerary_tap_prompt',
                          ),
                          emphasisWords: const ['Itinerary List', 'Tap on it!'],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itineraryOverviewPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF70757B),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.t('delivery_training_screen_title_itinerary'),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 32 * 0.7,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF111827),
                  size: 36,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF111827),
                  size: 44,
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF6E7176),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: SizedBox(
              height: 98,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 98,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(48),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B769D),
                          borderRadius: BorderRadius.circular(34),
                        ),
                        child: const Icon(
                          Icons.format_list_bulleted_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 78,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E646D),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        color: Color(0xFF111827),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 78,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E646D),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.speed_rounded,
                        color: Color(0xFF111827),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF818181),
                    child: Stack(
                      children: [
                        const Positioned(
                          left: 70,
                          top: 210,
                          bottom: 76,
                          child: VerticalDivider(
                            color: Color(0xFFA2A6AA),
                            width: 1,
                            thickness: 1.2,
                          ),
                        ),
                        _itineraryPromptRow(
                          index: '1',
                          top: 34,
                          markerColor: const Color(0xFF1E5F1B),
                          title: t.t(
                            'delivery_training_itinerary_prompt_current_stop',
                          ),
                          address: '7 Bethany Stream, BT60 3QU\nMillerhaven',
                          titleColor: const Color(0xFF1E5F1B),
                        ),
                        _itineraryPromptRow(
                          index: '2',
                          top: 210,
                          markerColor: const Color(0xFF111827),
                          title: t.t(
                            'delivery_training_itinerary_prompt_by_end_day',
                          ),
                          address: '6 Megan Glens, BT60 3QU\nMillerhaven',
                          extra: Container(
                            margin: const EdgeInsets.only(top: 18),
                            height: 52,
                            width: 240,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D3136),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.vpn_key_rounded,
                                  color: Color(0xFF7D8186),
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  t.t(
                                    'delivery_training_itinerary_prompt_access',
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF7D8186),
                                    fontSize: 20 * 0.7,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _itineraryPromptRow(
                          index: '3',
                          top: 420,
                          markerColor: const Color(0xFF111827),
                          title: t.t(
                            'delivery_training_itinerary_prompt_by_end_day',
                          ),
                          address: '245 Stevens Crescent, B63 4JQ\nMillerhaven',
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.34)),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 34,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _OtpBodyText(
                          text: t.t(
                            'delivery_training_itinerary_overview_prompt',
                          ),
                          emphasisWords: const ['list of delivery locations'],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: () =>
                                onTargetTap(_HotspotTarget.coachContinue),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1788C3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 34,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itineraryDeliveryTypePromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF70757B),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.t('delivery_training_screen_title_itinerary_list_lower'),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 32 * 0.7,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF111827),
                  size: 36,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF111827),
                  size: 44,
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: const Color(0xFF818181)),
                    ),
                    const Positioned(
                      left: 70,
                      top: 124,
                      bottom: 36,
                      child: VerticalDivider(
                        color: Color(0xFFA2A6AA),
                        width: 1,
                        thickness: 1.2,
                      ),
                    ),
                    _itineraryPromptRow(
                      index: '1',
                      top: h * 0.06,
                      markerColor: const Color(0xFF1E5F1B),
                      title: t.t(
                        'delivery_training_itinerary_prompt_current_stop',
                      ),
                      address: '7 Bethany Stream, BT60 3QU\nMillerhaven',
                      titleColor: const Color(0xFF1E5F1B),
                    ),
                    _itineraryPromptRow(
                      index: '2',
                      top: h * 0.245,
                      markerColor: const Color(0xFF111827),
                      title: t.t(
                        'delivery_training_itinerary_prompt_by_end_day',
                      ),
                      address: '6 Megan Glens, BT60 3QU\nMillerhaven',
                      extra: _deliveryTypeBadge(
                        text: t.t('delivery_training_itinerary_prompt_access'),
                        icon: Icons.vpn_key_rounded,
                      ),
                    ),
                    _itineraryPromptRow(
                      index: '3',
                      top: h * 0.44,
                      markerColor: const Color(0xFF111827),
                      title: t.t(
                        'delivery_training_itinerary_prompt_by_end_day',
                      ),
                      address: '245 Stevens Crescent, B63 4JQ\nMillerhaven',
                      extra: _deliveryTypeBadge(
                        text: t.t(
                          'delivery_training_itinerary_prompt_otp_delivery',
                        ),
                      ),
                    ),
                    _itineraryPromptRow(
                      index: '4',
                      top: h * 0.67,
                      markerColor: const Color(0xFF111827),
                      title: t.t(
                        'delivery_training_itinerary_prompt_by_end_day',
                      ),
                      address: '7 Bethany Stream, BT60 3QU\nMillerhaven',
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 18,
                      child: Container(
                        height: 78,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D3A4A),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.t(
                                  'delivery_training_itinerary_prompt_resume_stop1',
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF77818A),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24 * 0.7,
                                ),
                              ),
                            ),
                            Container(
                              width: 68,
                              height: 68,
                              decoration: const BoxDecoration(
                                color: Color(0xFF95A2AE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 46,
                                color: Color(0xFF0D3A4A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.34),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      top: 14,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: -36,
                            child: const Center(
                              child: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Colors.white,
                                size: 110,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _OtpBodyText(
                                  text: t.t(
                                    'delivery_training_itinerary_delivery_type_prompt',
                                  ),
                                  emphasisWords: const ['delivery type'],
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: FilledButton(
                                    onPressed: () => onTargetTap(
                                      _HotspotTarget.coachContinue,
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF1788C3),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 34,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _itineraryMapTapPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF70757B),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.t('delivery_training_screen_title_itinerary_list_lower'),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 32 * 0.7,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF111827),
                  size: 36,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF111827),
                  size: 44,
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF6E7176),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: SizedBox(
              height: 98,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 78,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D4962),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.format_list_bulleted_rounded,
                        color: Color(0xFF97A3AF),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => onTargetTap(_HotspotTarget.tabMap),
                      borderRadius: BorderRadius.circular(48),
                      child: Container(
                        height: 98,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(48),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFBEC9D5),
                            borderRadius: BorderRadius.circular(34),
                          ),
                          child: const Icon(
                            Icons.map_outlined,
                            color: Color(0xFF273549),
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 78,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E646D),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.speed_rounded,
                        color: Color(0xFF111827),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Container(color: const Color(0xFF818181)),
                    ),
                    const Positioned(
                      left: 70,
                      top: 124,
                      bottom: 36,
                      child: VerticalDivider(
                        color: Color(0xFFA2A6AA),
                        width: 1,
                        thickness: 1.2,
                      ),
                    ),
                    _itineraryPromptRow(
                      index: '1',
                      top: h * 0.06,
                      markerColor: const Color(0xFF1E5F1B),
                      title: t.t(
                        'delivery_training_itinerary_prompt_current_stop',
                      ),
                      address: '7 Bethany Stream, BT60 3QU\nMillerhaven',
                      titleColor: const Color(0xFF1E5F1B),
                    ),
                    _itineraryPromptRow(
                      index: '2',
                      top: h * 0.245,
                      markerColor: const Color(0xFF111827),
                      title: t.t(
                        'delivery_training_itinerary_prompt_by_end_day',
                      ),
                      address: '6 Megan Glens, BT60 3QU\nMillerhaven',
                      extra: _deliveryTypeBadge(
                        text: t.t('delivery_training_itinerary_prompt_access'),
                        icon: Icons.vpn_key_rounded,
                      ),
                    ),
                    _itineraryPromptRow(
                      index: '3',
                      top: h * 0.44,
                      markerColor: const Color(0xFF111827),
                      title: t.t(
                        'delivery_training_itinerary_prompt_by_end_day',
                      ),
                      address: '245 Stevens Crescent, B63 4JQ\nMillerhaven',
                      extra: _deliveryTypeBadge(
                        text: t.t(
                          'delivery_training_itinerary_prompt_otp_delivery',
                        ),
                      ),
                    ),
                    _itineraryPromptRow(
                      index: '4',
                      top: h * 0.67,
                      markerColor: const Color(0xFF111827),
                      title: t.t(
                        'delivery_training_itinerary_prompt_by_end_day',
                      ),
                      address: '7 Bethany Stream, BT60 3QU\nMillerhaven',
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 18,
                      child: Container(
                        height: 78,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D3A4A),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.t(
                                  'delivery_training_itinerary_prompt_resume_stop1',
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF77818A),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24 * 0.7,
                                ),
                              ),
                            ),
                            Container(
                              width: 68,
                              height: 68,
                              decoration: const BoxDecoration(
                                color: Color(0xFF95A2AE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 46,
                                color: Color(0xFF0D3A4A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.34),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      top: 170,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -46,
                            left: 0,
                            right: 0,
                            child: const Align(
                              alignment: Alignment(0.08, 0),
                              child: Icon(
                                Icons.arrow_drop_up_rounded,
                                color: Colors.white,
                                size: 116,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _OtpBodyText(
                              text: t.t(
                                'delivery_training_itinerary_map_tap_prompt',
                              ),
                              emphasisWords: const [
                                'Itinerary Map',
                                'Tap on it!',
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _itineraryMapLocationsPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF70757B),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.t('delivery_training_screen_title_map'),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 32 * 0.7,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF111827),
                  size: 36,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF111827),
                  size: 44,
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF6E7176),
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: SizedBox(
              height: 82,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E646D),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.format_list_bulleted_rounded,
                        color: Color(0xFF111827),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(48),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B769D),
                          borderRadius: BorderRadius.circular(34),
                        ),
                        child: const Icon(
                          Icons.map_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E646D),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.speed_rounded,
                        color: Color(0xFF111827),
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF6E6E6E),
                    child: Stack(
                      children: [
                        ...List.generate(
                          20,
                          (i) => Positioned(
                            left: -100 + (i * 44).toDouble(),
                            top: 16 + ((i % 7) * 88).toDouble(),
                            child: Transform.rotate(
                              angle: (i % 3 == 0) ? 0.45 : -0.35,
                              child: Container(
                                width: 300,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7B7F84),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ...List.generate(
                          10,
                          (i) => Positioned(
                            left: 44 + (i * 78).toDouble() % 620,
                            top: 130 + ((i * 87) % 860).toDouble(),
                            child: Container(
                              width: 88,
                              height: 52,
                              decoration: BoxDecoration(
                                color: (i.isEven)
                                    ? const Color(
                                        0xFF546E7A,
                                      ).withValues(alpha: 0.8)
                                    : const Color(
                                        0xFF65705F,
                                      ).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        _mapPromptPin(
                          label: '1',
                          left: 220,
                          top: 96,
                          color: const Color(0xFF2F8A1F),
                        ),
                        _mapPromptPin(
                          label: '2',
                          left: 244,
                          top: 246,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '3',
                          left: 380,
                          top: 252,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '4',
                          left: 516,
                          top: 146,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '5',
                          left: 620,
                          top: 72,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '6',
                          left: 466,
                          top: 254,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '7',
                          left: 670,
                          top: 168,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '8',
                          left: 500,
                          top: 324,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '9',
                          left: 620,
                          top: 286,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '10',
                          left: 424,
                          top: 386,
                          color: const Color(0xFF1E232B),
                        ),
                        Positioned(
                          right: 16,
                          top: 484,
                          child: Icon(
                            Icons.settings_rounded,
                            color: const Color(0xFF111827),
                            size: 62,
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 640,
                          child: Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.near_me_rounded,
                              color: Color(0xFF111827),
                              size: 48,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.30)),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _OtpBodyText(
                          text: t.t(
                            'delivery_training_itinerary_map_locations_prompt',
                          ),
                          emphasisWords: const ['delivery locations'],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: () =>
                                onTargetTap(_HotspotTarget.coachContinue),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1788C3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 34,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itinerarySummaryTapPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF70757B),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.t('delivery_training_screen_title_itinerary_map_lower'),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 32 * 0.7,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF111827),
                  size: 36,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF111827),
                  size: 44,
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF6E7176),
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: SizedBox(
              height: 82,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E646D),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.format_list_bulleted_rounded,
                        color: Color(0xFF111827),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 82,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B769D),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        color: Color(0xFF97A3AF),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => onTargetTap(_HotspotTarget.tabSummary),
                      borderRadius: BorderRadius.circular(48),
                      child: Container(
                        height: 82,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(48),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFBEC9D5),
                            borderRadius: BorderRadius.circular(34),
                          ),
                          child: const Icon(
                            Icons.speed_rounded,
                            color: Color(0xFF273549),
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF6E6E6E),
                    child: Stack(
                      children: [
                        ...List.generate(
                          20,
                          (i) => Positioned(
                            left: -100 + (i * 44).toDouble(),
                            top: 16 + ((i % 7) * 88).toDouble(),
                            child: Transform.rotate(
                              angle: (i % 3 == 0) ? 0.45 : -0.35,
                              child: Container(
                                width: 300,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7B7F84),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ...List.generate(
                          10,
                          (i) => Positioned(
                            left: 44 + (i * 78).toDouble() % 620,
                            top: 130 + ((i * 87) % 860).toDouble(),
                            child: Container(
                              width: 88,
                              height: 52,
                              decoration: BoxDecoration(
                                color: (i.isEven)
                                    ? const Color(
                                        0xFF546E7A,
                                      ).withValues(alpha: 0.8)
                                    : const Color(
                                        0xFF65705F,
                                      ).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        _mapPromptPin(
                          label: '1',
                          left: 220,
                          top: 96,
                          color: const Color(0xFF2F8A1F),
                        ),
                        _mapPromptPin(
                          label: '2',
                          left: 244,
                          top: 246,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '3',
                          left: 380,
                          top: 252,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '4',
                          left: 516,
                          top: 146,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '5',
                          left: 620,
                          top: 72,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '6',
                          left: 466,
                          top: 254,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '7',
                          left: 670,
                          top: 168,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '8',
                          left: 500,
                          top: 324,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '9',
                          left: 620,
                          top: 286,
                          color: const Color(0xFF1E232B),
                        ),
                        _mapPromptPin(
                          label: '10',
                          left: 424,
                          top: 386,
                          color: const Color(0xFF1E232B),
                        ),
                        Positioned(
                          right: 16,
                          top: 484,
                          child: Icon(
                            Icons.settings_rounded,
                            color: const Color(0xFF111827),
                            size: 62,
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 640,
                          child: Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.near_me_rounded,
                              color: Color(0xFF111827),
                              size: 48,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 18,
                          child: Container(
                            height: 78,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D3A4A),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t.t(
                                      'delivery_training_itinerary_prompt_resume_stop1',
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF77818A),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24 * 0.7,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF95A2AE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 46,
                                    color: Color(0xFF0D3A4A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.34)),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  top: 132,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -46,
                        left: 0,
                        right: 0,
                        child: const Align(
                          alignment: Alignment(0.62, 0),
                          child: Icon(
                            Icons.arrow_drop_up_rounded,
                            color: Colors.white,
                            size: 116,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _OtpBodyText(
                          text: t.t(
                            'delivery_training_itinerary_summary_tap_prompt',
                          ),
                          emphasisWords: const ['Summary', 'Tap on it!'],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itinerarySummaryOverviewPromptScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF70757B),
      child: Column(
        children: [
          Container(
            color: const Color(0xFF607683),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF111827),
                  size: 52,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.t('delivery_training_screen_title_summary'),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 32 * 0.7,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF111827),
                  size: 36,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF111827),
                  size: 44,
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF6E7176),
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: SizedBox(
              height: 82,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E646D),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.format_list_bulleted_rounded,
                        color: Color(0xFF111827),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E646D),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        color: Color(0xFF111827),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(48),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B769D),
                          borderRadius: BorderRadius.circular(34),
                        ),
                        child: const Icon(
                          Icons.speed_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Container(
                        color: const Color(0xFFF4F6F8),
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.t('delivery_training_summary_work_remaining'),
                              style: const TextStyle(
                                fontSize: 54 * 0.7,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _summaryPromptMetric(
                              t.t('delivery_training_summary_stops_count'),
                              0.52,
                            ),
                            const SizedBox(height: 18),
                            _summaryPromptMetric(
                              t.t('delivery_training_summary_locations_count'),
                              0.82,
                            ),
                            const SizedBox(height: 18),
                            _summaryPromptMetric(
                              t.t('delivery_training_summary_packages_count'),
                              1.0,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 22,
                        color: const Color(0xFF666A6D),
                        child: const Divider(
                          color: Color(0xFF7A7D80),
                          height: 22,
                          thickness: 1.2,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: const Color(0xFF6E7176),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 18,
                                right: 18,
                                top: 14,
                                child: Text(
                                  t.t('delivery_training_summary_stops_header'),
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 30 * 0.7,
                                  ),
                                ),
                              ),
                              ...List.generate(
                                4,
                                (i) => Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 78 + (i * 86).toDouble(),
                                  child: Container(
                                    height: 86,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF71757A),
                                      border: Border(
                                        top: BorderSide(
                                          color: Color(0xFF8B8F94),
                                          width: 1,
                                        ),
                                        bottom: BorderSide(
                                          color: Color(0xFF666A6D),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 18,
                                right: 18,
                                bottom: 16,
                                child: Container(
                                  height: 78,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D3A4A),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.22,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          t.t(
                                            'delivery_training_itinerary_prompt_resume_stop1',
                                          ),
                                          style: const TextStyle(
                                            color: Color(0xFF77818A),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 24 * 0.7,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 68,
                                        height: 68,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF95A2AE),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 46,
                                          color: Color(0xFF0D3A4A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.34)),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  top: 344,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -46,
                        left: 0,
                        right: 0,
                        child: const Align(
                          alignment: Alignment(0.00, 0),
                          child: Icon(
                            Icons.arrow_drop_up_rounded,
                            color: Colors.white,
                            size: 116,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _OtpBodyText(
                              text: t.t(
                                'delivery_training_itinerary_summary_overview_prompt',
                              ),
                              emphasisWords: const ['remaining packages'],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton(
                                onPressed: () =>
                                    onTargetTap(_HotspotTarget.coachContinue),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1788C3),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 34,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryPromptMetric(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 28 * 0.7,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFD5DAE3),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1788C3),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapPromptPin({
    required String label,
    required double left,
    required double top,
    required Color color,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 6),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.785398,
            child: Transform.translate(
              offset: const Offset(0, -2),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Colors.white, width: 4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryTypeBadge({required String text, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF666A70),
          borderRadius: BorderRadius.circular(32),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFFE5E7EB), size: 24),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontSize: 20 * 0.7,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itineraryPromptRow({
    required String index,
    required double top,
    required Color markerColor,
    required String title,
    required String address,
    Color titleColor = const Color(0xFF111827),
    Widget? extra,
  }) {
    return Positioned(
      left: 24,
      right: 16,
      top: top,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mapPin(index, markerColor),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 24 * 0.7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 22 * 0.7,
                      height: 1.3,
                    ),
                  ),
                  if (extra != null) ...[extra, const SizedBox(height: 16)],
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFF6F7276),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _offlineMapOtherRow({
    required String code,
    required String size,
    bool showDivider = true,
  }) {
    return Container(
      height: 78,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: Color(0xFFD1D5DB), width: 1),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22 * 0.7,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  size,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 22 * 0.7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.file_download_outlined,
            color: Color(0xFF273549),
            size: 42,
          ),
        ],
      ),
    );
  }

  Widget _settingsListRow(
    String title, {
    Color bg = const Color(0xFF6E7176),
    Color textColor = const Color(0xFF111827),
    Color chevronColor = const Color(0xFF5A5D62),
  }) {
    return Container(
      height: 72,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: bg,
        border: const Border(
          bottom: BorderSide(color: Color(0xFF64676C), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 22 * 0.7,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: chevronColor, size: 48),
        ],
      ),
    );
  }

  Widget _settingsPromptRow(
    String title, {
    required Color bg,
    Color textColor = const Color(0xFF111827),
  }) {
    return Container(
      height: 70,
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 22 * 0.7,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _settingsPromptBottomRow(
    String title, {
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      height: 74,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF6E7176),
        border: Border(top: BorderSide(color: Color(0xFF5F6267), width: 1.5)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Icon(icon, color: iconColor, size: 42),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 22 * 0.7,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapPin(String label, Color color) {
    return Container(
      width: 62,
      height: 74,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(31),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(3)),
            ),
            transform: Matrix4.rotationZ(0.785),
          ),
        ],
      ),
    );
  }

  Widget _transportOptionRow(String label, {bool showDivider = true}) {
    return Column(
      children: [
        SizedBox(
          height: 82,
          child: Row(
            children: [
              const SizedBox(width: 12),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7B8388), width: 5),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 24 * 0.7,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFD9DDDF)),
      ],
    );
  }

  Widget _buildOtpSupportScreen({required String bodyText}) {
    return Container(
      color: const Color(0xFF262626),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 332,
            child: Container(
              color: const Color(0xFF2B2B2B),
              child: Stack(
                children: [
                  Positioned(
                    right: 14,
                    top: 8,
                    child: Transform.rotate(
                      angle: -0.55,
                      child: Container(
                        width: 124,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1E38),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 92,
                    right: 92,
                    top: 88,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF092348),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF0D2D59),
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 120,
                    top: 24,
                    child: Container(
                      width: 262,
                      height: 126,
                      decoration: const BoxDecoration(
                        color: Color(0x6695C7FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 146,
                    top: 56,
                    child: Transform.rotate(
                      angle: 0.35,
                      child: Container(
                        width: 170,
                        height: 92,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF60A5FA),
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: List.generate(
                              14,
                              (_) => Container(
                                width: 26,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 206,
            bottom: 8,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -22,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    children: [
                      Container(
                        height: 330,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _OtpNumberBadge(number: '1'),
                                _OtpNumberBadge(number: '2'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _OtpPersonFigure(left: true),
                                    _OtpPersonFigure(left: false),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _OtpBodyText(text: bodyText),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _hotspot(
                        _HotspotTarget.coachContinue,
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: () =>
                                onTargetTap(_HotspotTarget.coachContinue),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1788C3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherBagsSupportScreen({required String bodyText}) {
    return Container(
      color: const Color(0xFF262626),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 332,
            child: Container(
              color: const Color(0xFF2B2B2B),
              child: Stack(
                children: [
                  Positioned(
                    right: 14,
                    top: 8,
                    child: Transform.rotate(
                      angle: -0.55,
                      child: Container(
                        width: 124,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1E38),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 92,
                    right: 92,
                    top: 88,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF092348),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF0D2D59),
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 120,
                    top: 24,
                    child: Container(
                      width: 262,
                      height: 126,
                      decoration: const BoxDecoration(
                        color: Color(0x5595C7FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 146,
                    top: 76,
                    child: Transform.rotate(
                      angle: -0.44,
                      child: Container(
                        width: 188,
                        height: 76,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FF),
                          borderRadius: BorderRadius.circular(46),
                          border: Border.all(
                            color: const Color(0xFF60A5FA),
                            width: 4,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            5,
                            (_) => Container(
                              width: 20,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 206,
            bottom: 8,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -22,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    children: [
                      Container(
                        height: 330,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const _WeatherBagsIllustration(),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _OtpBodyText(
                            text: bodyText,
                            emphasisWords: const ['weather bags'],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _hotspot(
                        _HotspotTarget.coachContinue,
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: () =>
                                onTargetTap(_HotspotTarget.coachContinue),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1788C3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuScreen() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _menuRow('Dashboard'),
          _hotspot(
            _HotspotTarget.settingsItem,
            _menuRow(
              'Settings',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF6B7280),
              ),
              onTap: () => onTargetTap(_HotspotTarget.settingsItem),
            ),
          ),
          _menuRow('Breaks'),
          _menuRow('Driver Support'),
          _menuRow('Emergency Help'),
        ],
      ),
    );
  }

  Widget _settingsScreen() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _menuRow('Personal Information'),
          _menuRow('Phone Number'),
          _hotspot(
            _HotspotTarget.offlineMapsItem,
            _menuRow(
              'Offline Maps',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF6B7280),
              ),
              onTap: () => onTargetTap(_HotspotTarget.offlineMapsItem),
            ),
          ),
          _menuRow('Version Info'),
          _menuRow('Sign out'),
        ],
      ),
    );
  }

  Widget _overviewScreen() {
    return Container(
      color: const Color(0xFFF8FBFE),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE8EEF3), Color(0xFFDCE7F1)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                ...List.generate(8, (i) {
                  final left = 36.0 + (i * 28) % 220;
                  final top = 30.0 + (i * 37) % 220;
                  return Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: i == 0 ? 28 : 22,
                      height: i == 0 ? 28 : 22,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? const Color(0xFF1B8A3F)
                            : const Color(0xFF1F2937),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          _stopCard(),
        ],
      ),
    );
  }

  Widget _itineraryScreen() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 120),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDDE3E7)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: index == 0
                      ? const Color(0xFF1B8A3F)
                      : const Color(0xFF1F2937),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Delivery address and timing window',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _mapScreen() {
    return Container(
      color: const Color(0xFFEFF4F8),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _GridPainter())),
                ...List.generate(10, (i) {
                  final left = 28.0 + (i * 23) % 250;
                  final top = 26.0 + (i * 31) % 250;
                  return Positioned(
                    left: left,
                    top: top,
                    child: Icon(
                      Icons.location_on,
                      size: i == 0 ? 30 : 24,
                      color: i == 0
                          ? const Color(0xFF1B8A3F)
                          : const Color(0xFF1F2937),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _summaryScreen() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Work remaining',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _kText,
            ),
          ),
          const SizedBox(height: 14),
          _bar('Stops', 0.55),
          const SizedBox(height: 12),
          _bar('Locations', 0.78),
          const SizedBox(height: 12),
          _bar('Packages', 1.0),
          const Spacer(),
          _stopCard(),
        ],
      ),
    );
  }

  Widget _stopDetailsScreen() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
        children: [
          _stopCard(),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDE3E7)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes',
                  style: TextStyle(fontWeight: FontWeight.w800, color: _kText),
                ),
                SizedBox(height: 8),
                Text('• Be aware of a dog at this location'),
                SizedBox(height: 4),
                Text('• Signature required'),
                SizedBox(height: 4),
                Text('• Deliver to: leave package at front door'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stopCard() {
    return _hotspot(
      _HotspotTarget.stopCard,
      Container(
        margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDE3E7)),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deliver 2 packages',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: _kText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '09:00 - 11:00',
                    style: TextStyle(
                      color: _kMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _hotspot(
              _HotspotTarget.notes,
              IconButton(
                onPressed: () => onTargetTap(_HotspotTarget.notes),
                icon: const Icon(Icons.description_outlined),
              ),
            ),
            _hotspot(
              _HotspotTarget.key,
              IconButton(
                onPressed: () => onTargetTap(_HotspotTarget.key),
                icon: const Icon(Icons.key_outlined),
              ),
            ),
            _hotspot(
              _HotspotTarget.externalNav,
              IconButton(
                onPressed: () => onTargetTap(_HotspotTarget.externalNav),
                icon: const Icon(Icons.open_in_new_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, color: _kText),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(_kBlue),
          ),
        ),
      ],
    );
  }

  Widget _menuRow(String title, {Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFDDE3E7))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: _kText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _hotspot(_HotspotTarget target, Widget child) {
    final active = activeTarget == target;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: active
            ? Border.all(color: const Color(0xFF3B82F6), width: 2)
            : null,
        boxShadow: active
            ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  String _titleForScreen(AppLocalizations t, _MockScreen screen) {
    switch (screen) {
      case _MockScreen.welcome:
        return t.t('delivery_training_screen_title_overview');
      case _MockScreen.typeOfDeliveries:
        return t.t('delivery_training_screen_title_type_of_deliveries');
      case _MockScreen.doorToDoor:
        return t.t('delivery_training_screen_title_door_to_door');
      case _MockScreen.lockers:
        return t.t('delivery_training_screen_title_lockers');
      case _MockScreen.counters:
        return t.t('delivery_training_screen_title_counters');
      case _MockScreen.otrSupplies:
        return t.t('delivery_training_screen_title_otr_supplies');
      case _MockScreen.otpBadge:
        return t.t('delivery_training_screen_title_otp_badge');
      case _MockScreen.otpBadgeVisual:
        return t.t('delivery_training_screen_title_otp_badge');
      case _MockScreen.weatherBags:
        return t.t('delivery_training_screen_title_weather_bags');
      case _MockScreen.readyToGo:
        return t.t('delivery_training_screen_title_ready_to_go');
      case _MockScreen.customerArrivalContact:
        return t.t('delivery_training_screen_title_customer_arrival');
      case _MockScreen.customerFeedback:
        return t.t('delivery_training_screen_title_customer_feedback');
      case _MockScreen.concessions:
        return t.t('delivery_training_screen_title_concessions');
      case _MockScreen.deliveryAppUsage:
        return t.t('delivery_training_screen_title_delivery_app_usage');
      case _MockScreen.deliveryAppOverview:
        return t.t('delivery_training_screen_title_delivery_app_overview');
      case _MockScreen.transportationMethod:
        return t.t('delivery_training_screen_title_transportation_method');
      case _MockScreen.verifyIdentity:
        return t.t('delivery_training_screen_title_verify_identity');
      case _MockScreen.deliveryAppOverviewMaps:
        return t.t('delivery_training_screen_title_delivery_app_overview');
      case _MockScreen.offlineMapsPrompt:
        return t.t('delivery_training_screen_title_overview');
      case _MockScreen.settingsPrompt:
        return t.t('delivery_training_screen_title_menu');
      case _MockScreen.offlineMapsSettingsPrompt:
        return t.t('delivery_training_screen_title_settings');
      case _MockScreen.offlineMapsDownloadPrompt:
        return t.t('delivery_training_screen_title_offline_maps');
      case _MockScreen.offlineMapsDownloadedPrompt:
        return t.t('delivery_training_screen_title_offline_maps');
      case _MockScreen.offlineMapsConnectivityPrompt:
        return t.t('delivery_training_screen_title_offline_maps');
      case _MockScreen.overviewIntroPrompt:
        return t.t('delivery_training_screen_title_overview');
      case _MockScreen.overviewTabsPrompt:
        return t.t('delivery_training_screen_title_overview');
      case _MockScreen.overviewItineraryTapPrompt:
        return t.t('delivery_training_screen_title_overview');
      case _MockScreen.itineraryOverviewPrompt:
        return t.t('delivery_training_screen_title_itinerary');
      case _MockScreen.itineraryDeliveryTypePrompt:
        return t.t('delivery_training_screen_title_itinerary');
      case _MockScreen.itineraryMapTapPrompt:
        return t.t('delivery_training_screen_title_itinerary');
      case _MockScreen.itineraryMapLocationsPrompt:
        return t.t('delivery_training_screen_title_map');
      case _MockScreen.itinerarySummaryTapPrompt:
        return t.t('delivery_training_screen_title_map');
      case _MockScreen.itinerarySummaryOverviewPrompt:
        return t.t('delivery_training_screen_title_summary');
      case _MockScreen.menu:
        return t.t('delivery_training_screen_title_menu');
      case _MockScreen.settings:
        return t.t('delivery_training_screen_title_settings');
      case _MockScreen.overview:
        return t.t('delivery_training_screen_title_overview');
      case _MockScreen.itinerary:
        return t.t('delivery_training_screen_title_itinerary');
      case _MockScreen.map:
        return t.t('delivery_training_screen_title_map');
      case _MockScreen.summary:
        return t.t('delivery_training_screen_title_summary');
      case _MockScreen.stopDetails:
        return t.t('delivery_training_screen_title_stop_details');
    }
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9D6E4)
      ..strokeWidth = 1;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDDE3E7), width: 1),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1F2937)),
        ),
      ),
    );
  }
}

class _OtpNumberBadge extends StatelessWidget {
  final String number;

  const _OtpNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: Color(0xFF6B6C70),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _OtpPersonFigure extends StatelessWidget {
  final bool left;

  const _OtpPersonFigure({required this.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 8,
            left: left ? 58 : 20,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF0EA5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                left ? Icons.badge_outlined : Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          if (!left)
            Positioned(
              top: -4,
              left: 34,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HELP!',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 56,
            left: left ? 18 : 28,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFF8D59A),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 84,
            left: left ? 14 : 24,
            child: Container(
              width: 42,
              height: 64,
              decoration: BoxDecoration(
                color: left ? const Color(0xFFF4B53F) : const Color(0xFFF6B74A),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Positioned(
            top: 145,
            left: left ? 12 : 22,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 66,
                  decoration: BoxDecoration(
                    color: left
                        ? const Color(0xFF1D4E89)
                        : const Color(0xFF4EB7ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 16,
                  height: 66,
                  decoration: BoxDecoration(
                    color: left
                        ? const Color(0xFF0B5D96)
                        : const Color(0xFF0E5F96),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConcessionsPersonFigure extends StatelessWidget {
  const _ConcessionsPersonFigure();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 210,
      child: Stack(
        children: [
          Positioned(
            right: 28,
            top: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFEFB195),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 30,
            top: 22,
            child: Container(
              width: 66,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF9A5B21),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 70,
            child: Transform.rotate(
              angle: 0.18,
              child: Container(
                width: 24,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFE37A47),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            left: 88,
            top: 66,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 18,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFFE37A47),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            left: 54,
            top: 90,
            child: Container(
              width: 24,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFF6E6B70),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            left: 82,
            top: 90,
            child: Container(
              width: 24,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFF888588),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryAppUsageIllustration extends StatelessWidget {
  const _DeliveryAppUsageIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE3E3E3),
      child: Stack(
        children: [
          Positioned(
            left: 32,
            right: 32,
            top: 22,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _DeliveryAppUsageBubble(
                  child: Icon(
                    Icons.sentiment_dissatisfied_rounded,
                    color: Color(0xFF111827),
                    size: 36,
                  ),
                ),
                _DeliveryAppUsageBubble(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.inventory_2_rounded, color: Color(0xFFC48E5A)),
                      Icon(
                        Icons.close_rounded,
                        color: Color(0xFFEF4444),
                        size: 38,
                      ),
                    ],
                  ),
                ),
                _DeliveryAppUsageBubble(
                  child: Icon(
                    Icons.currency_exchange_rounded,
                    color: Color(0xFF111827),
                    size: 38,
                  ),
                ),
                _DeliveryAppUsageBubble(
                  child: Icon(
                    Icons.sentiment_satisfied_alt_rounded,
                    color: Color(0xFFFACC15),
                    size: 34,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 54,
            top: 132,
            child: Container(
              width: 156,
              height: 228,
              decoration: BoxDecoration(
                color: const Color(0xFFF01717),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Positioned(
            right: 54,
            top: 132,
            child: Container(
              width: 156,
              height: 228,
              decoration: BoxDecoration(
                color: const Color(0xFF7BBC22),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          const Positioned(
            left: 50,
            bottom: 8,
            child: _DeliveryAppUsagePerson(
              happy: false,
              holdingPackage: false,
              leaningRight: false,
            ),
          ),
          const Positioned(
            right: 50,
            bottom: 8,
            child: _DeliveryAppUsagePerson(
              happy: true,
              holdingPackage: true,
              leaningRight: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryAppUsageBubble extends StatelessWidget {
  final Widget child;

  const _DeliveryAppUsageBubble({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF111827), width: 2),
            ),
            child: Center(child: child),
          ),
          const Icon(
            Icons.arrow_drop_down_rounded,
            size: 28,
            color: Color(0xFF111827),
          ),
        ],
      ),
    );
  }
}

class _DeliveryAppUsagePerson extends StatelessWidget {
  final bool happy;
  final bool holdingPackage;
  final bool leaningRight;

  const _DeliveryAppUsagePerson({
    required this.happy,
    required this.holdingPackage,
    required this.leaningRight,
  });

  @override
  Widget build(BuildContext context) {
    final shirt = const Color(0xFF8D4A1A);
    final pants = const Color(0xFF76757B);
    final skin = const Color(0xFFEAB193);
    return SizedBox(
      width: 174,
      height: 292,
      child: Transform.rotate(
        angle: leaningRight ? -0.14 : 0,
        child: Stack(
          children: [
            Positioned(
              left: 66,
              top: 8,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: skin, shape: BoxShape.circle),
                child: Icon(
                  happy
                      ? Icons.sentiment_satisfied_alt_rounded
                      : Icons.sentiment_neutral_rounded,
                  size: 20,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
            Positioned(
              left: 44,
              top: 38,
              child: Container(
                width: 84,
                height: 80,
                decoration: BoxDecoration(
                  color: shirt,
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            Positioned(
              left: holdingPackage ? 80 : 18,
              top: 56,
              child: Transform.rotate(
                angle: holdingPackage ? 0.05 : -0.35,
                child: Container(
                  width: 24,
                  height: 86,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE17B47),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            Positioned(
              left: holdingPackage ? 28 : 114,
              top: 56,
              child: Transform.rotate(
                angle: holdingPackage ? -0.55 : 0.42,
                child: Container(
                  width: 24,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE17B47),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            if (holdingPackage)
              Positioned(
                left: 10,
                top: 72,
                child: Container(
                  width: 86,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC99768),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            Positioned(
              left: 56,
              top: 112,
              child: Container(
                width: 30,
                height: 146,
                decoration: BoxDecoration(
                  color: pants,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Positioned(
              left: 92,
              top: 112,
              child: Container(
                width: 30,
                height: 146,
                decoration: BoxDecoration(
                  color: const Color(0xFF838189),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Positioned(
              left: 52,
              bottom: 0,
              child: Container(
                width: 38,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF8F181B),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Positioned(
              left: 94,
              bottom: 0,
              child: Container(
                width: 38,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF8F181B),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBodyText extends StatelessWidget {
  final String text;
  final List<String> emphasisWords;

  const _OtpBodyText({
    required this.text,
    this.emphasisWords = const ['QR code', 'OTP badge'],
  });

  @override
  Widget build(BuildContext context) {
    final full = text.trim();
    final emphasis = emphasisWords;

    final spans = <TextSpan>[];
    var cursor = 0;

    while (cursor < full.length) {
      var nextHit = -1;
      String? hitWord;
      for (final word in emphasis) {
        final idx = full.indexOf(word, cursor);
        if (idx != -1 && (nextHit == -1 || idx < nextHit)) {
          nextHit = idx;
          hitWord = word;
        }
      }

      if (nextHit == -1 || hitWord == null) {
        spans.add(TextSpan(text: full.substring(cursor)));
        break;
      }

      if (nextHit > cursor) {
        spans.add(TextSpan(text: full.substring(cursor, nextHit)));
      }

      spans.add(
        TextSpan(
          text: hitWord,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      );
      cursor = nextHit + hitWord.length;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 60 * 0.32,
          fontWeight: FontWeight.w500,
          color: Color(0xFF273549),
          height: 1.24,
        ),
        children: spans,
      ),
    );
  }
}

class _WeatherBagsIllustration extends StatelessWidget {
  const _WeatherBagsIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _OtpNumberBadge(number: '1'),
            _OtpNumberBadge(number: '2'),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        left: 18,
                        bottom: 0,
                        child: Container(
                          width: 118,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFFBFD5E3),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 16,
                        child: Container(
                          width: 92,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC58A27),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        bottom: 72,
                        child: Container(
                          width: 76,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFFFFF,
                            ).withValues(alpha: 0.58),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 40,
                        bottom: 84,
                        child: Container(
                          width: 52,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        right: 8,
                        top: 0,
                        child: Row(
                          children: List.generate(
                            3,
                            (_) => Container(
                              margin: const EdgeInsets.only(left: 2),
                              width: 46,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFFA3C6D9),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 26,
                        bottom: 14,
                        child: Container(
                          width: 86,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC49C59),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 0,
                        child: Container(
                          width: 120,
                          height: 84,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFFFFF,
                            ).withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _AmazonDeliveryView { module, player }

enum _MockScreen {
  welcome,
  typeOfDeliveries,
  doorToDoor,
  lockers,
  counters,
  otrSupplies,
  otpBadge,
  otpBadgeVisual,
  weatherBags,
  readyToGo,
  customerArrivalContact,
  customerFeedback,
  concessions,
  deliveryAppUsage,
  deliveryAppOverview,
  transportationMethod,
  verifyIdentity,
  deliveryAppOverviewMaps,
  offlineMapsPrompt,
  settingsPrompt,
  offlineMapsSettingsPrompt,
  offlineMapsDownloadPrompt,
  offlineMapsDownloadedPrompt,
  offlineMapsConnectivityPrompt,
  overviewIntroPrompt,
  overviewTabsPrompt,
  overviewItineraryTapPrompt,
  itineraryOverviewPrompt,
  itineraryDeliveryTypePrompt,
  itineraryMapTapPrompt,
  itineraryMapLocationsPrompt,
  itinerarySummaryTapPrompt,
  itinerarySummaryOverviewPrompt,
  menu,
  settings,
  overview,
  itinerary,
  map,
  summary,
  stopDetails,
}

enum _HotspotTarget {
  coachContinue,
  menu,
  settingsItem,
  offlineMapsItem,
  tabItinerary,
  tabMap,
  tabSummary,
  stopCard,
  notes,
  key,
  externalNav,
  help,
}

class _CoachStep {
  final String instructionKey;
  final _MockScreen screen;
  final _HotspotTarget? target;

  const _CoachStep({
    required this.instructionKey,
    required this.screen,
    this.target,
  });
}

class _ActivityMeta {
  final String id;
  final String titleKey;
  final String subtitleKey;
  final int durationMinutes;
  final bool required;

  const _ActivityMeta({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.durationMinutes,
    this.required = false,
  });
}
