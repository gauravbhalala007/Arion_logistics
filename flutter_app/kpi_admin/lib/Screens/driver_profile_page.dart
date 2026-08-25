import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/privacy_notice/privacy_notice_content.dart';
import '../data/privacy_notice/privacy_notice_texts.dart';
import '../localization/app_localizations.dart';
import '../services/vacation_pools_repository.dart';
import '../utils/vacation_pools.dart';
import '../widgets/vacation_pool_lines.dart';
import '../widgets/web_preview.dart'
    if (dart.library.html) '../widgets/web_preview_web.dart';
import 'driver_privacy_notice_page.dart';
import 'driver_profile_sections.dart';

const _kBg = Color(0xFFF3F6F7);
const _kText = Color(0xFF22252F);
const _kMuted = Color(0xFF6B7280);

class DriverProfilePage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;

  const DriverProfilePage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
  });

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  bool _weeklyScoreSummaryExpanded = false;

  // ── Urlaubs-Töpfe des DSP ───────────────────────────────────────────
  // Ohne Konfigurationsdokument bleibt es beim Ein-Topf-Bestandsverhalten.
  VacationPoolsConfig _poolsConfig = VacationPoolsConfig.disabled;

  @override
  void initState() {
    super.initState();
    _loadPools();
  }

  Future<void> _loadPools() async {
    final config = await VacationPoolsRepository.load(widget.dspUid);
    if (!mounted) return;
    setState(() => _poolsConfig = config);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final driverRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .doc(widget.driverTransporterId.toUpperCase());

    return Container(
      color: _kBg,
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: driverRef.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() ?? {};
          final onboarding = _driverProfileOnboardingMap(data['onboarding']);
          final profileImage = _driverProfileImageFromOnboarding(onboarding);
          final name = (data['driverName'] ?? '').toString().trim();
          final email = (data['email'] ?? '').toString().trim();
          final transporterId = (data['transporterId'] ?? '')
              .toString()
              .trim()
              .toUpperCase();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.t('nav_profile'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTopCard(
                  context: context,
                  driverRef: driverRef,
                  data: data,
                  onboarding: onboarding,
                  profileImage: profileImage,
                  driverName: name,
                  email: email,
                  transporterId: transporterId,
                ),
                const SizedBox(height: 16),
                if (transporterId.isNotEmpty)
                  _buildWeeklyScoreSummaryCard(
                    context: context,
                    transporterId: transporterId,
                  ),
                if (transporterId.isNotEmpty) const SizedBox(height: 16),
                // Ticket „Your driving History": alle Vorfälle dieses
                // Fahrers, gelesen aus dem Fahrer-Unterpfad (Root-
                // Sammlung ist für den Fahrer nicht listbar).
                DriverDrivingHistorySection(
                  dspUid: widget.dspUid,
                  transporterId: widget.driverTransporterId,
                ),
                const SizedBox(height: 16),
                // Ticket „Your Attendance": Überstunden je Monat,
                // Krankmeldungen, Urlaub + Resturlaub.
                DriverAttendanceSection(
                  dspUid: widget.dspUid,
                  transporterId: widget.driverTransporterId,
                  driverData: data,
                  poolsConfig: _poolsConfig,
                ),
                const SizedBox(height: 16),
                _buildDetailsCard(
                  context: context,
                  driverRef: driverRef,
                  onboarding: onboarding,
                ),
                const SizedBox(height: 16),
                _buildPrivacyNoticeCard(context: context),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Dauerhafter Zugang zur vollständigen Datenschutzinformation.
  ///
  /// Beim Login sieht der Fahrer nur die Kurzinformation im Pop-up
  /// (gestuftes Hinweismodell nach Art. 12 Abs. 1 DSGVO). Damit die
  /// vollständige Information nach der Kenntnisnahme nicht verschwindet,
  /// hängt sie hier — rein zum Nachlesen, ohne Bestätigungsteil, mit
  /// dem Datum der bereits erfolgten Kenntnisnahme.
  Widget _buildPrivacyNoticeCard({required BuildContext context}) {
    final lang = Localizations.localeOf(context).languageCode;
    String t(String key, [Map<String, String>? vars]) =>
        privacyNoticeText(lang, key, vars: vars);

    final ackRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('academy_test_results')
        .doc(kPrivacyNoticeTestId)
        .collection('drivers')
        .doc(widget.driverTransporterId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ackRef.snapshots(),
      builder: (context, snap) {
        final raw = snap.data?.data()?['acknowledgedAt'];
        final acknowledgedAt = raw is Timestamp ? raw.toDate() : null;
        final statusText = acknowledgedAt == null
            ? t('ack_not_yet')
            : t('ack_confirmed_on', {
                'date': _driverProfileFormatDate(acknowledgedAt),
              });

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => openPrivacyNoticeDetail(
              context,
              acknowledgedAt: acknowledgedAt,
              showAckStatus: true,
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEEF9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('appbar_title'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _kText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t('later_entry_sub'),
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: _kMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: acknowledgedAt == null
                                ? _kMuted
                                : const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopCard({
    required BuildContext context,
    required DocumentReference<Map<String, dynamic>> driverRef,
    required Map<String, dynamic> data,
    required Map<String, dynamic> onboarding,
    required ImageProvider? profileImage,
    required String driverName,
    required String email,
    required String transporterId,
  }) {
    final t = AppLocalizations.of(context);

    return Container(
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
          final isNarrow = constraints.maxWidth < 720;

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
                        : Image(image: profileImage, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: driverRef
                        .collection('documents')
                        .doc('driver_license_front')
                        .snapshots(),
                    builder: (context, docSnap) {
                      final docData = docSnap.data?.data() ?? const {};
                      final url = (docData['downloadUrl'] ?? '').toString();
                      final fileName = (docData['fileName'] ?? '').toString();
                      final hasUrl = url.isNotEmpty;
                      final path =
                          Uri.tryParse(url)?.path.toLowerCase() ?? '';
                      final isImage = path.endsWith('.png') ||
                          path.endsWith('.jpg') ||
                          path.endsWith('.jpeg') ||
                          path.endsWith('.webp');

                      Widget child;
                      if (!hasUrl) {
                        child = Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.badge,
                                size: 24,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                t.t('drivers_hub_driving_licence_front_preview'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
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
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Color(0xFF9CA3AF),
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
                                    ? t.t('driver_license_front')
                                    : fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
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

          final right = Column(
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
                          driverName.isEmpty ? t.t('dash_no_name') : driverName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _kText,
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
                        if (transporterId.isNotEmpty)
                          SelectableText(
                            t.tf('drivers_hub_transporter_id_line', {
                              'id': transporterId,
                            }),
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
                      _driverProfileStatusChip(data, context),
                      const SizedBox(height: 6),
                      _driverProfileExpiryChipDetailed(onboarding, context),
                    ],
                  ),
                ],
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                left,
                const SizedBox(height: 16),
                right,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              left,
              const SizedBox(width: 24),
              Expanded(child: right),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailsCard({
    required BuildContext context,
    required DocumentReference<Map<String, dynamic>> driverRef,
    required Map<String, dynamic> onboarding,
  }) {
    final t = AppLocalizations.of(context);

    final workPermitType = _driverProfileNormalizeWorkPermitType(
      onboarding['workPermitType'],
      fallbackExpiry: onboarding['residencePermitExpiry'],
    );
    final workVisaExpiryValue =
        (onboarding['workVisaExpiry'] ?? onboarding['residencePermitExpiry'])
            .toString();

    final personalSection = _DriverProfileSection(
      title: t.t('drivers_hub_section_personal_details'),
      children: [
        _driverProfileDetailRow(
          t.t('drivers_hub_field_full_name'),
          onboarding['fullName'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_name_at_birth'),
          onboarding['nameAtBirth'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_date_of_birth'),
          onboarding['dateOfBirth'],
          isDate: true,
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_phone'),
          onboarding['phone'],
        ),
      ],
    );

    final originSection = _DriverProfileSection(
      title: t.t('drivers_hub_section_origin'),
      children: [
        _driverProfileDetailRow(
          t.t('drivers_hub_field_city_of_birth'),
          onboarding['birthCity'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_state_of_birth'),
          onboarding['birthState'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_nationality_id_card'),
          onboarding['nationalityIdCard'],
        ),
      ],
    );

    final addressSection = _DriverProfileSection(
      title: t.t('drivers_hub_section_address'),
      children: [
        _driverProfileDetailRow(
          t.t('drivers_hub_field_street_address'),
          onboarding['address'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_city'),
          onboarding['city'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_postal_code'),
          onboarding['postalCode'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_country'),
          onboarding['country'],
        ),
      ],
    );

    final documentsDatesSection = _DriverProfileSection(
      title: t.t('drivers_hub_section_document_expiry_dates'),
      children: [
        _driverProfileDetailRow(
          t.t('drivers_hub_field_work_permit_type'),
          _driverProfileWorkPermitTypeLabel(
            t,
            workPermitType,
            fallbackExpiry: onboarding['residencePermitExpiry'],
          ),
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_work_start_date'),
          onboarding['workStartDate'],
          isDate: true,
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_annual_vacation_days'),
          onboarding['annualVacationDays'] ?? 20,
        ),
        _buildRemainingVacationDaysRow(driverRef: driverRef, onboarding: onboarding),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_probezeit_end'),
          (() {
            final start =
                _driverProfileDateFromDynamic(onboarding['workStartDate']);
            final end = _driverProfileProbationEndFromStart(start);
            return end == null ? '' : _driverProfileFormatDate(end);
          })(),
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_contract_expiry'),
          onboarding['contractExpiry'],
          isDate: true,
        ),
        if (workPermitType == 'working_visa')
          _driverProfileDetailRow(
            t.t('drivers_hub_field_work_visa_expiry'),
            workVisaExpiryValue,
            isDate: true,
          ),
        if (workPermitType == 'working_visa')
          _driverProfileDetailRow(
            t.t('drivers_hub_field_zusatzblatt_expiry'),
            onboarding['zusatzblattExpiry'],
            isDate: true,
          ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_id_card_passport_expiry'),
          onboarding['idDocExpiry'],
          isDate: true,
        ),
      ],
    );

    final licenseSection = _DriverProfileSection(
      title: t.t('drivers_hub_section_driving_license'),
      children: [
        _driverProfileDetailRow(
          t.t('drivers_hub_field_driving_license_number'),
          onboarding['licenseNumber'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_license_expiry_date'),
          onboarding['licenseExpiry'],
          isDate: true,
        ),
      ],
    );

    final emergencySection = _DriverProfileSection(
      title: t.t('drivers_hub_section_emergency_contact'),
      children: [
        _driverProfileDetailRow(
          t.t('drivers_hub_field_emergency_contact_name'),
          onboarding['emergencyContactName'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_emergency_contact_phone'),
          onboarding['emergencyContactPhone'],
        ),
      ],
    );

    final paymentSection = _DriverProfileSection(
      title: t.t('drivers_hub_section_payment_tax'),
      children: [
        _driverProfileDetailRow(
          t.t('drivers_hub_field_bank_iban'),
          onboarding['bankIban'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_insurance_company'),
          onboarding['insuranceCompany'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_tax_id'),
          onboarding['taxId'],
        ),
      ],
    );

    final uniformSection = _DriverProfileSection(
      title: t.t('drivers_hub_section_uniform'),
      children: [
        _driverProfileDetailRow(
          t.t('drivers_hub_field_tshirt_size'),
          onboarding['tShirtSize'],
        ),
        _driverProfileDetailRow(
          t.t('drivers_hub_field_shoe_size'),
          onboarding['shoeSize'],
        ),
      ],
    );

    final notesSection = _DriverProfileSection(
      title: t.t('drivers_hub_section_other_notes'),
      children: [
        _driverProfileDetailRow(
          t.t('drivers_hub_field_notes'),
          onboarding['notes'],
        ),
      ],
    );

    return Container(
      width: double.infinity,
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
          final isNarrow = constraints.maxWidth < 720;

          if (isNarrow) {
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
          }

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
                    emergencySection,
                    notesSection,
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
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Resturlaub im Fahrer-Profil.
  ///
  /// Nutzt seit dem Ticket „getrennte Verfallsdaten" dieselbe Formel wie
  /// der Admin (`utils/vacation_pools.dart`). Vorher rechnete diese
  /// Seite eigenständig und ignorierte insbesondere den manuellen
  /// Resturlaubs-Override — Fahrer und Admin sahen unterschiedliche
  /// Zahlen. Bei aktivierten Töpfen folgt unter der Gesamtzahl je Topf
  /// eine Zeile mit Resttagen und Verfallsdatum.
  Widget _buildRemainingVacationDaysRow({
    required DocumentReference<Map<String, dynamic>> driverRef,
    required Map<String, dynamic> onboarding,
  }) {
    final t = AppLocalizations.of(context);
    final config = _poolsConfig.forDriver(onboarding);
    final annualVacationDays =
        _driverProfileAnnualVacationDaysFromOnboarding(onboarding);
    final workStartDate = parseVacationDate(onboarding['workStartDate']);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driverRef.collection('absence_requests').snapshots(),
      builder: (context, snap) {
        String value = '...';
        VacationBalance? balance;

        if (snap.hasError) {
          value = '—';
        } else if (snap.connectionState != ConnectionState.waiting) {
          final absences = <VacationAbsence>[
            for (final doc in snap.data?.docs ??
                const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
              if (VacationAbsence.fromMap(doc.data()) case final a?) a,
          ];
          balance = computeVacationBalance(
            absences: absences,
            config: config,
            annualVacationDays: annualVacationDays,
            workStartDate: workStartDate,
            manualOverride: vacationOverrideOf(onboarding),
            manualOverrideAt: vacationOverrideAtOf(onboarding),
          );
          value = _driverProfileFormatVacationDays(balance.totalRemaining);
        }

        final row = _driverProfileDetailRow(
          t.t('drivers_hub_field_remaining_vacation_days'),
          value,
        );
        if (balance == null || !balance.pooled) return row;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            row,
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: VacationPoolLines(balance: balance),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeeklyScoreSummaryCard({
    required BuildContext context,
    required String transporterId,
  }) {
    final t = AppLocalizations.of(context);

    return Container(
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
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.dspUid)
            .collection('scores')
            .where('transporterId', isEqualTo: transporterId.toUpperCase())
            .snapshots(),
        builder: (context, snap) {
          final title = Text(
            t.t('drivers_hub_weekly_score_summary'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          );

          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 14),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          }

          final docs = [...?snap.data?.docs];
          docs.sort((a, b) {
            final ad = a.data();
            final bd = b.data();
            final aYear = (ad['year'] as num?)?.toInt() ?? -1;
            final bYear = (bd['year'] as num?)?.toInt() ?? -1;
            if (aYear != bYear) return bYear.compareTo(aYear);

            final aWeek = (ad['weekNumber'] as num?)?.toInt() ?? -1;
            final bWeek = (bd['weekNumber'] as num?)?.toInt() ?? -1;
            if (aWeek != bWeek) return bWeek.compareTo(aWeek);

            final aDate =
                (ad['reportDate'] as Timestamp?)?.millisecondsSinceEpoch ??
                (ad['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                0;
            final bDate =
                (bd['reportDate'] as Timestamp?)?.millisecondsSinceEpoch ??
                (bd['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                0;
            return bDate.compareTo(aDate);
          });

          final visible = docs.take(8).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: visible.isEmpty
                    ? null
                    : () {
                        setState(() {
                          _weeklyScoreSummaryExpanded =
                              !_weeklyScoreSummaryExpanded;
                        });
                      },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: title),
                      if (visible.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${visible.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _weeklyScoreSummaryExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF6B7280),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (visible.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    t.t('drivers_hub_no_scores_yet'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                )
              else if (_weeklyScoreSummaryExpanded)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < visible.length; i++) ...[
                        _buildWeeklyScoreSummaryRow(
                          context: context,
                          data: visible[i].data(),
                        ),
                        if (i != visible.length - 1)
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeeklyScoreSummaryRow({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) {
    final t = AppLocalizations.of(context);
    final year = (data['year'] as num?)?.toInt();
    final week = (data['weekNumber'] as num?)?.toInt();
    final bucket = _driverProfileNormalizedScoreBucket(
      raw: data['statusBucket'],
      score: ((data['comp'] as Map?)?['FinalScore'] as num?)?.toDouble(),
    );
    final label = _driverProfileScoreBucketLabel(t, bucket);
    final color = _driverProfileScoreBucketColor(bucket);

    String leftLabel;
    if (week != null && year != null) {
      leftLabel = t.tf(
        'dash_week_range',
        {'week': week.toString(), 'year': year.toString()},
      );
    } else if (week != null) {
      leftLabel = '${t.t('dash_week')} $week';
    } else {
      leftLabel = t.t('drivers_hub_not_set');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              leftLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard({
    required BuildContext context,
    required DocumentReference<Map<String, dynamic>> driverRef,
    required String driverName,
  }) {
    final t = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.t('drivers_hub_documents'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: driverRef
                .collection('documents')
                .orderBy('uploadedAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator(minHeight: 2);
              }

              final docs = snap.data?.docs ?? [];
              final docsByType = <String, Map<String, dynamic>>{
                for (final d in docs)
                  (d.data()['docType'] ?? d.id).toString(): d.data(),
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
                final name = (data['fileName'] ?? t.t('drivers_hub_not_uploaded'))
                    .toString();
                final url = (data['downloadUrl'] ?? '').toString();
                final hasUrl = url.isNotEmpty;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: !hasUrl
                        ? null
                        : () => _showDriverDocumentPreview(
                              context: context,
                              docType: docType,
                              label: _driverProfileDocLabel(context, docType),
                              url: url,
                              fileName: name,
                              driverName: driverName,
                            ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                                  _driverProfileDocLabel(context, docType),
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
                          Icon(
                            hasUrl
                                ? Icons.open_in_new_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: hasUrl
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF9CA3AF),
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
          ),
        ],
      ),
    );
  }

  Future<void> _showDriverDocumentPreview({
    required BuildContext context,
    required String docType,
    required String label,
    required String url,
    required String fileName,
    required String driverName,
  }) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    final normalizedFileName = fileName.toLowerCase();
    final isImage = normalizedFileName.endsWith('.png') ||
        normalizedFileName.endsWith('.jpg') ||
        normalizedFileName.endsWith('.jpeg') ||
        normalizedFileName.endsWith('.webp') ||
        path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp');
    final isPdf =
        normalizedFileName.endsWith('.pdf') || path.endsWith('.pdf');

    if (isImage) {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
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
                    child: kIsWeb
                        ? buildWebImagePreview(url)
                        : Image.network(url, fit: BoxFit.contain),
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
            final t = AppLocalizations.of(ctx);
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
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
                      child: FutureBuilder<Uint8List?>(
                        future: () async {
                          try {
                            final bytes = await fb.FirebaseStorage.instance
                                .refFromURL(url)
                                .getData(50 * 1024 * 1024);
                            if (bytes != null) return bytes;
                          } catch (_) {
                            // Fall through to URL fetch.
                          }
                          try {
                            final data = await NetworkAssetBundle(uri).load('');
                            return data.buffer.asUint8List();
                          } catch (_) {
                            return null;
                          }
                        }(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          if (snap.hasError || snap.data == null) {
                            return Center(
                              child: Text(
                                t.t('drivers_hub_failed_load_pdf_preview'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            );
                          }
                          return SfPdfViewer.memory(
                            snap.data!,
                            canShowPaginationDialog: false,
                            canShowScrollHead: true,
                            canShowScrollStatus: true,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final adjustedUri = Uri.parse(
                            url.contains('response-content-disposition=')
                                ? url
                                : '${url}${url.contains('?') ? '&' : '?'}response-content-disposition='
                                      '${Uri.encodeComponent('attachment; filename="${_driverProfileDownloadNameForDoc(docType: docType, url: url, fileName: fileName, driverName: driverName, context: context)}"')}',
                          );
                          if (await canLaunchUrl(adjustedUri)) {
                            await launchUrl(
                              adjustedUri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: const Icon(Icons.download_outlined, size: 16),
                        label: Text(t.t('drivers_hub_download')),
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
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
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
                    child: FutureBuilder<Uint8List?>(
                      future: () async {
                        try {
                          final bytes = await fb.FirebaseStorage.instance
                              .refFromURL(url)
                              .getData(50 * 1024 * 1024);
                          if (bytes != null) return bytes;
                        } catch (_) {
                          // Fall through to URL fetch.
                        }
                        try {
                          final data = await NetworkAssetBundle(uri).load('');
                          return data.buffer.asUint8List();
                        } catch (_) {
                          return null;
                        }
                      }(),
                      builder: (context, snap) {
                        final t = AppLocalizations.of(context);
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        if (snap.hasError || snap.data == null) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(t.t('drivers_hub_failed_load_pdf_preview')),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () async {
                                    final adjustedUri = Uri.parse(
                                      url.contains(
                                            'response-content-disposition=',
                                          )
                                          ? url
                                          : '${url}${url.contains('?') ? '&' : '?'}response-content-disposition='
                                                '${Uri.encodeComponent('attachment; filename="${_driverProfileDownloadNameForDoc(docType: docType, url: url, fileName: fileName, driverName: driverName, context: context)}"')}',
                                    );
                                    if (await canLaunchUrl(adjustedUri)) {
                                      await launchUrl(
                                        adjustedUri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  child: Text(t.t('drivers_hub_download')),
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

    final adjustedUri = Uri.parse(
      url.contains('response-content-disposition=')
          ? url
          : '${url}${url.contains('?') ? '&' : '?'}response-content-disposition='
                '${Uri.encodeComponent('attachment; filename="${_driverProfileDownloadNameForDoc(docType: docType, url: url, fileName: fileName, driverName: driverName, context: context)}"')}',
    );
    if (await canLaunchUrl(adjustedUri)) {
      await launchUrl(adjustedUri, mode: LaunchMode.externalApplication);
    }
  }
}

class _DriverProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DriverProfileSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA8A29E),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

Widget _driverProfileDetailRow(
  String label,
  dynamic value, {
  bool isDate = false,
}) {
  var text = (value ?? '').toString().trim();
  if (isDate) {
    final parsed = _driverProfileParseIsoDate(text);
    if (parsed != null) {
      text = _driverProfileFormatDate(parsed);
    }
  }
  if (text.isEmpty) text = '—';

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: SelectableText(
            text,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
        ),
      ],
    ),
  );
}

Map<String, dynamic> _driverProfileOnboardingMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    return raw.map((k, v) => MapEntry(k.toString(), v));
  }
  return const {};
}

ImageProvider? _driverProfileImageFromOnboarding(Map<String, dynamic> onboarding) {
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

String _driverProfileNormalizeWorkPermitType(
  dynamic raw, {
  dynamic fallbackExpiry,
}) {
  final value = (raw ?? '').toString().trim().toLowerCase();
  if (value.isEmpty) {
    final hasLegacyExpiry =
        (fallbackExpiry ?? '').toString().trim().isNotEmpty;
    return hasLegacyExpiry ? 'working_visa' : 'eu';
  }
  if (value == 'eu' || value == 'permit_eu_id' || value == 'eu_id') {
    return 'eu';
  }
  if (value == 'working_visa' ||
      value == 'work_visa' ||
      value == 'permit_work_visa' ||
      value == 'visa') {
    return 'working_visa';
  }
  return value;
}

String _driverProfileWorkPermitTypeLabel(
  AppLocalizations t,
  dynamic raw, {
  dynamic fallbackExpiry,
}) {
  switch (_driverProfileNormalizeWorkPermitType(
    raw,
    fallbackExpiry: fallbackExpiry,
  )) {
    case 'working_visa':
      return t.t('drivers_hub_work_permit_working_visa');
    case 'eu':
    default:
      return t.t('drivers_hub_work_permit_eu');
  }
}

Widget _driverProfileStatusChip(
  Map<String, dynamic> data,
  BuildContext context,
) {
  final t = AppLocalizations.of(context);
  final active = (data['active'] as bool?) ?? true;
  final onboardingRaw = data['onboarding'];
  final hasOnboarding = onboardingRaw is Map && onboardingRaw.isNotEmpty;

  String label;
  Color bg;
  Color fg;

  if (!hasOnboarding) {
    label = t.t('drivers_hub_status_pending');
    bg = const Color(0xFFFDE68A);
    fg = const Color(0xFF92400E);
  } else if (active) {
    label = t.t('drivers_hub_status_approved');
    bg = const Color(0xFFD1FAE5);
    fg = const Color(0xFF065F46);
  } else {
    label = t.t('drivers_hub_status_rejected');
    bg = const Color(0xFFFEE2E2);
    fg = const Color(0xFF991B1B);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
    ),
  );
}

Widget _driverProfileExpiryChipDetailed(
  Map<String, dynamic> onboarding,
  BuildContext context,
) {
  final t = AppLocalizations.of(context);
  if (onboarding.isEmpty) return const SizedBox.shrink();

  final contractDate =
      _driverProfileParseIsoDate(onboarding['contractExpiry']?.toString());
  final probationEnd = _driverProfileProbationEndFromStart(
    _driverProfileParseIsoDate(onboarding['workStartDate']?.toString()),
  );
  final workPermitType = _driverProfileNormalizeWorkPermitType(
    onboarding['workPermitType'],
    fallbackExpiry: onboarding['residencePermitExpiry'],
  );
  final workVisaDate = workPermitType == 'working_visa'
      ? _driverProfileParseIsoDate(
          (onboarding['workVisaExpiry'] ?? onboarding['residencePermitExpiry'])
              ?.toString(),
        )
      : null;
  final zusatzblattDate = workPermitType == 'working_visa'
      ? _driverProfileParseIsoDate(onboarding['zusatzblattExpiry']?.toString())
      : null;
  final licenseDate =
      _driverProfileParseIsoDate(onboarding['licenseExpiry']?.toString());
  final idDocDate =
      _driverProfileParseIsoDate(onboarding['idDocExpiry']?.toString());

  if (contractDate == null &&
      workVisaDate == null &&
      zusatzblattDate == null &&
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
  check(workVisaDate);
  check(zusatzblattDate);
  check(licenseDate);
  check(idDocDate);
  if (probationEnd != null) {
    final diff = probationEnd.difference(today).inDays;
    if (_driverProfileIsProbezeitExpiredWithinGrace(probationEnd, today)) {
      pExpired = true;
      expiredCount++;
    } else if (diff >= 0 && diff <= 30) {
      pSoon = true;
      soonCount++;
    }
  }

  if (expiredCount == 0 && soonCount == 0) {
    return const SizedBox.shrink();
  }

  late final String label;
  late final Color bg;
  late final Color fg;

  if (expiredCount > 0) {
    final onlyProbation = pExpired && expiredCount == 1 && soonCount == 0;
    label = onlyProbation
        ? t.t('drivers_hub_probezeit_expired')
        : t.tf('drivers_hub_documents_expired', {'count': '$expiredCount'});
    bg = const Color(0xFFFEE2E2);
    fg = const Color(0xFF991B1B);
  } else {
    final onlyProbation = pSoon && soonCount == 1;
    label = onlyProbation
        ? t.t('drivers_hub_probezeit_expiring_soon')
        : t.tf('drivers_hub_documents_expiring_soon', {'count': '$soonCount'});
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
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
    ),
  );
}

double _driverProfileAnnualVacationDaysFromOnboarding(
  Map<String, dynamic> onboarding,
) {
  final raw = onboarding['annualVacationDays'];
  if (raw is num && raw > 0) return raw.toDouble();
  if (raw is String) {
    final parsed = num.tryParse(raw.trim().replaceAll(',', '.'));
    if (parsed != null && parsed > 0) return parsed.toDouble();
  }
  return 20;
}

DateTime? _driverProfileDateFromDynamic(dynamic raw) {
  if (raw is Timestamp) return raw.toDate();
  if (raw is DateTime) return raw;
  return _driverProfileParseIsoDate(raw?.toString());
}

// `_driverProfileApprovedVacationDaysFromRequests` und
// `_driverProfileCompletedMonthsSince` leben jetzt in
// `utils/vacation_pools.dart` (eine Formel fuer Admin + Fahrer).

String _driverProfileFormatVacationDays(double value) {
  if (value % 1 == 0) return value.toInt().toString();
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

DateTime? _driverProfileParseIsoDate(String? value) {
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

String _driverProfileFormatDate(DateTime d) {
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  final year = d.year.toString().padLeft(4, '0');
  return '$day/$month/$year';
}

DateTime _driverProfileAddMonthsClamped(DateTime date, int months) {
  final totalMonths = (date.month - 1) + months;
  final year = date.year + (totalMonths ~/ 12);
  final month = (totalMonths % 12) + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = date.day <= lastDay ? date.day : lastDay;
  return DateTime(year, month, day);
}

DateTime? _driverProfileProbationEndFromStart(DateTime? start) {
  if (start == null) return null;
  final sixMonthsLater = _driverProfileAddMonthsClamped(start, 6);
  return sixMonthsLater.subtract(const Duration(days: 1));
}

bool _driverProfileIsProbezeitExpiredWithinGrace(
  DateTime probationEnd,
  DateTime today,
) {
  const graceDays = 7;
  final daysSinceEnd = today.difference(probationEnd).inDays;
  return daysSinceEnd >= 1 && daysSinceEnd <= graceDays;
}

String _driverProfileNormalizedScoreBucket({dynamic raw, double? score}) {
  final value = (raw ?? '').toString().trim().toUpperCase();
  if (value.isNotEmpty) {
    switch (value) {
      case 'FANTASTIC_PLUS':
      case 'FANTASTIC PLUS':
        return 'FANTASTIC_PLUS';
      case 'FANTASTIC':
        return 'FANTASTIC';
      case 'GREAT':
        return 'GREAT';
      case 'FAIR':
        return 'FAIR';
      case 'POOR':
        return 'POOR';
    }
  }

  final finalScore = score ?? 0;
  if (finalScore >= 93) return 'FANTASTIC_PLUS';
  if (finalScore >= 86) return 'FANTASTIC';
  if (finalScore >= 70) return 'GREAT';
  if (finalScore >= 50) return 'FAIR';
  return 'POOR';
}

String _driverProfileScoreBucketLabel(AppLocalizations t, String bucket) {
  switch (bucket) {
    case 'FANTASTIC_PLUS':
      return 'Fantastic Plus';
    case 'FANTASTIC':
      return 'Fantastic';
    case 'GREAT':
      return 'Great';
    case 'FAIR':
      return 'Fair';
    case 'POOR':
    default:
      return 'Poor';
  }
}

Color _driverProfileScoreBucketColor(String bucket) {
  switch (bucket) {
    case 'FANTASTIC_PLUS':
      return const Color(0xFF14B8A6);
    case 'FANTASTIC':
      return const Color(0xFF0EA5E9);
    case 'GREAT':
      return const Color(0xFFF59E0B);
    case 'FAIR':
      return const Color(0xFFFB923C);
    case 'POOR':
    default:
      return const Color(0xFFEF4444);
  }
}

String _driverProfileDocLabel(BuildContext context, String docType) {
  final t = AppLocalizations.of(context);
  switch (docType) {
    case 'resident_permit':
      return t.t('work_permit');
    case 'driver_license_front':
      return t.t('driver_license_front');
    case 'driver_license_back':
      return t.t('driver_license_back');
    case 'id_card_front':
      return t.t('id_card_front');
    case 'id_card_back':
      return t.t('id_card_back');
    case 'passport_front':
      return t.t('passport_front');
    case 'passport_back':
      return t.t('passport_back');
    case 'tax_id':
      return t.t('doc_tax_id');
    case 'insurance':
      return t.t('doc_insurance');
    case 'contract':
      return t.t('admin_home_contract');
    default:
      return docType;
  }
}

String _driverProfileDownloadNameForDoc({
  required String docType,
  required String url,
  required String fileName,
  required String driverName,
  required BuildContext context,
}) {
  String sanitize(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s*/\s*'), '_')
        .replaceAll(RegExp(r'[()]'), '')
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String fileExtension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return '';
    return name.substring(dot + 1);
  }

  var base = sanitize(_driverProfileDocLabel(context, docType));
  if (base.isEmpty) base = sanitize(docType);
  final driver = sanitize(driverName);
  if (driver.isNotEmpty) {
    base = '${base}_$driver';
  }

  var ext = fileName.isNotEmpty ? fileExtension(fileName) : '';
  if (ext.isEmpty) {
    final path = Uri.tryParse(url)?.path ?? '';
    ext = fileExtension(path.split('/').last);
  }
  return ext.isEmpty ? base : '$base.$ext';
}
