import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'co_button.dart';

/// Operative Tasks — recurring shift-bound to-dos for the admin team only.
/// Stored under `users/{adminUid}/operative_tasks/{taskId}`; drivers have no
/// read access (covered by the admin blanket rule, no dedicated rules entry).
///
/// Recurrence is expressed through occurrence keys inside `doneKeys`:
/// daily → `d-2026-07-20`, weekly → `w-2026-W30`, monthly → `m-2026-07`.
/// When the period rolls over the key changes, so the task automatically
/// appears unchecked again.
class OperativeTask {
  final String id;
  final String title;
  final String description;
  final String shift; // 'early' | 'middle' | 'late'
  final String recurrence; // 'none' | 'weekly' | 'monthly' ('daily' legacy)
  final int weekday; // 1 (Mon) .. 7 (Sun); only meaningful for 'weekly'
  final String time; // 'HH:mm' or '' when no time was set

  /// Optionally tagged dispatchers: `[{'uid': ..., 'name': ...}, ...]`.
  final List<Map<String, String>> dispatchers;
  final List<String> doneKeys;
  final DateTime createdAt;

  const OperativeTask({
    required this.id,
    required this.title,
    required this.description,
    required this.shift,
    required this.recurrence,
    required this.weekday,
    required this.time,
    required this.dispatchers,
    required this.doneKeys,
    required this.createdAt,
  });

  List<String> get dispatcherNames => dispatchers
      .map((d) => (d['name'] ?? '').trim())
      .where((n) => n.isNotEmpty)
      .toList(growable: false);

  factory OperativeTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return OperativeTask(
      id: doc.id,
      title: (data['title'] ?? '').toString().trim(),
      description: (data['description'] ?? '').toString().trim(),
      shift: (data['shift'] ?? 'early').toString(),
      recurrence: (data['recurrence'] ?? 'none').toString(),
      weekday: (data['weekday'] is num)
          ? (data['weekday'] as num).toInt().clamp(1, 7)
          : 1,
      time: (data['time'] ?? '').toString().trim(),
      dispatchers: (data['dispatchers'] is List)
          ? (data['dispatchers'] as List)
                .whereType<Map>()
                .map(
                  (m) => <String, String>{
                    'uid': (m['uid'] ?? '').toString(),
                    'name': (m['name'] ?? '').toString(),
                  },
                )
                .toList(growable: false)
          : const <Map<String, String>>[],
      doneKeys: (data['doneKeys'] is List)
          ? (data['doneKeys'] as List)
                .map((e) => e.toString())
                .toList(growable: false)
          : const <String>[],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  String get currentOccurrenceKey =>
      occurrenceKeyFor(recurrence, DateTime.now());

  bool get isDoneNow => doneKeys.contains(currentOccurrenceKey);
}

String occurrenceKeyFor(String recurrence, DateTime now) {
  String two(int n) => n.toString().padLeft(2, '0');
  switch (recurrence) {
    case 'weekly':
      final week = _isoWeek(now);
      return 'w-${week.$1}-W${two(week.$2)}';
    case 'monthly':
      return 'm-${now.year}-${two(now.month)}';
    case 'daily': // Mon–Sat; hidden on Sundays in the list
      return 'd-${now.year}-${two(now.month)}-${two(now.day)}';
    case 'none':
    default:
      // One-time task: the key never changes, so a check stays checked.
      return 'once';
  }
}

const List<String> weekdayShortDe = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
const List<String> weekdayShortEn = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

/// ISO-8601 week: returns (weekBasedYear, weekNumber).
/// UTC-basiert: lokale Differenzen über die Sommerzeit-Grenze sind 1h zu
/// kurz, wodurch Schreiben (mit Uhrzeit) und Archiv-Lesen (Mitternacht)
/// unterschiedliche Wochen-Keys erzeugten.
(int, int) _isoWeek(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  final thursday = day.add(Duration(days: 4 - day.weekday));
  final jan4 = DateTime.utc(thursday.year, 1, 4);
  final week1Monday = jan4.subtract(Duration(days: jan4.weekday - 1));
  final week = thursday.difference(week1Monday).inDays ~/ 7 + 1;
  return (thursday.year, week);
}

CollectionReference<Map<String, dynamic>> operativeTasksCol(String adminUid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(adminUid)
      .collection('operative_tasks');
}

String _two(int n) => n.toString().padLeft(2, '0');

String _dateNumeric(DateTime d, bool de) => de
    ? '${_two(d.day)}.${_two(d.month)}.${d.year}'
    : '${_two(d.day)}/${_two(d.month)}/${d.year}';

String _todayLabel(BuildContext context, bool de) {
  final now = DateTime.now();
  return de
      ? 'Heute · ${_dateNumeric(now, true)}'
      : 'Today · ${_dateNumeric(now, false)}';
}

/// Was a task done on [date]? Uses the same occurrence-key scheme as the
/// live card, so historical completions are read straight from [doneKeys].
bool _taskDoneOn(OperativeTask task, DateTime date) =>
    task.doneKeys.contains(occurrenceKeyFor(task.recurrence, date));

// ---------------------------------------------------------------------------
// Create-task popup
// ---------------------------------------------------------------------------

Future<void> showOperativeTaskDialog(
  BuildContext context, {
  required String adminUid,
}) async {
  final de = Localizations.localeOf(context).languageCode == 'de';
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String shift = 'early';
  String recurrence = 'none';
  int weekday = DateTime.now().weekday; // preselect today for weekly
  TimeOfDay? time;
  final selectedDispatchers = <String, String>{}; // uid -> displayName
  bool saving = false;

  // Dispatcher sub-accounts of this admin — loaded once for the tag chips.
  final dispatchersFuture = FirebaseFirestore.instance
      .collection('users')
      .doc(adminUid)
      .collection('sub_accounts')
      .get();

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          Widget choiceChip({
            required String value,
            required String groupValue,
            required String label,
            required IconData icon,
            required void Function(String) onSelect,
          }) {
            final selected = value == groupValue;
            return InkWell(
              onTap: () => onSelect(value),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF111827)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: selected ? Colors.white : const Color(0xFF4B5563),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          Widget sectionLabel(String text) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6B7280),
                letterSpacing: 0.4,
              ),
            ),
          );

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.playlist_add_check_rounded, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            de ? 'Neue Operativ-Aufgabe' : 'New operative task',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          splashRadius: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleCtrl,
                      autofocus: true,
                      maxLength: 120,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: de
                            ? 'Aufgabe, z. B. „Scanner einsammeln“'
                            : 'Task, e.g. "Collect scanners"',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      minLines: 2,
                      maxLines: 4,
                      maxLength: 500,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: de
                            ? 'Beschreibung (optional)'
                            : 'Description (optional)',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    sectionLabel(de ? 'SCHICHT' : 'SHIFT'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        choiceChip(
                          value: 'early',
                          groupValue: shift,
                          label: 'Early Shift',
                          icon: Icons.wb_twilight_rounded,
                          onSelect: (v) => setState(() => shift = v),
                        ),
                        choiceChip(
                          value: 'middle',
                          groupValue: shift,
                          label: 'Middle Shift',
                          icon: Icons.wb_sunny_rounded,
                          onSelect: (v) => setState(() => shift = v),
                        ),
                        choiceChip(
                          value: 'late',
                          groupValue: shift,
                          label: 'Late Shift',
                          icon: Icons.nights_stay_rounded,
                          onSelect: (v) => setState(() => shift = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    sectionLabel(de ? 'WIEDERHOLUNG' : 'REPEAT'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        choiceChip(
                          value: 'none',
                          groupValue: recurrence,
                          label: de ? 'Einmalig' : 'No repeat',
                          icon: Icons.looks_one_rounded,
                          onSelect: (v) => setState(() => recurrence = v),
                        ),
                        choiceChip(
                          value: 'daily',
                          groupValue: recurrence,
                          label: de ? 'Täglich (Mo–Sa)' : 'Daily (Mon–Sat)',
                          icon: Icons.today_rounded,
                          onSelect: (v) => setState(() => recurrence = v),
                        ),
                        choiceChip(
                          value: 'weekly',
                          groupValue: recurrence,
                          label: de ? 'Wöchentlich' : 'Weekly',
                          icon: Icons.date_range_rounded,
                          onSelect: (v) => setState(() => recurrence = v),
                        ),
                        choiceChip(
                          value: 'monthly',
                          groupValue: recurrence,
                          label: de ? 'Monatlich' : 'Monthly',
                          icon: Icons.calendar_month_rounded,
                          onSelect: (v) => setState(() => recurrence = v),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      alignment: Alignment.topLeft,
                      child: recurrence == 'weekly'
                          ? Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionLabel(de ? 'WOCHENTAG' : 'WEEKDAY'),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: List.generate(7, (i) {
                                      final day = i + 1;
                                      final selected = weekday == day;
                                      final label = de
                                          ? weekdayShortDe[i]
                                          : weekdayShortEn[i];
                                      return InkWell(
                                        onTap: () =>
                                            setState(() => weekday = day),
                                        borderRadius: BorderRadius.circular(9),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 150,
                                          ),
                                          curve: Curves.easeOut,
                                          width: 44,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? const Color(0xFF111827)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                            border: Border.all(
                                              color: selected
                                                  ? const Color(0xFF111827)
                                                  : const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: selected
                                                  ? Colors.white
                                                  : const Color(0xFF4B5563),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      future: dispatchersFuture,
                      builder: (context, snap) {
                        final docs = snap.data?.docs ?? const [];
                        final options = <String, String>{};
                        for (final d in docs) {
                          final data = d.data();
                          var name = (data['displayName'] ?? '')
                              .toString()
                              .trim();
                          if (name.isEmpty) {
                            // Fall back to the e-mail (readable prefix).
                            final email = (data['email'] ?? '')
                                .toString()
                                .trim();
                            name = email.contains('@')
                                ? email.split('@').first
                                : email;
                          }
                          if (name.isNotEmpty) options[d.id] = name;
                        }
                        // Section is always visible so it's clear WHY no
                        // dispatchers are selectable (loading / error / none).
                        Widget body;
                        if (snap.connectionState == ConnectionState.waiting) {
                          body = const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        } else if (snap.hasError) {
                          body = Text(
                            de
                                ? 'Dispatcher konnten nicht geladen werden: ${snap.error}'
                                : 'Could not load dispatchers: ${snap.error}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB91C1C),
                            ),
                          );
                        } else if (options.isEmpty) {
                          body = Text(
                            de
                                ? 'Keine Dispatcher-Accounts vorhanden — anlegen unter Menü → Dispatcher.'
                                : 'No dispatcher accounts yet — create them via menu → Dispatchers.',
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF9CA3AF),
                            ),
                          );
                        } else {
                          body = const SizedBox.shrink();
                        }
                        if (options.isEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 18),
                              sectionLabel(
                                de
                                    ? 'DISPATCHER TAGGEN (OPTIONAL)'
                                    : 'TAG DISPATCHERS (OPTIONAL)',
                              ),
                              body,
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 18),
                            sectionLabel(
                              de
                                  ? 'DISPATCHER TAGGEN (OPTIONAL)'
                                  : 'TAG DISPATCHERS (OPTIONAL)',
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: options.entries.map((e) {
                                final selected = selectedDispatchers
                                    .containsKey(e.key);
                                return InkWell(
                                  onTap: () => setState(() {
                                    if (selected) {
                                      selectedDispatchers.remove(e.key);
                                    } else {
                                      selectedDispatchers[e.key] = e.value;
                                    }
                                  }),
                                  borderRadius: BorderRadius.circular(10),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    curve: Curves.easeOut,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? const Color(0xFF1D7F5A)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFF1D7F5A)
                                            : const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          selected
                                              ? Icons.check_rounded
                                              : Icons.person_outline_rounded,
                                          size: 15,
                                          color: selected
                                              ? Colors.white
                                              : const Color(0xFF4B5563),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          e.value,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: selected
                                                ? Colors.white
                                                : const Color(0xFF4B5563),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    sectionLabel(de ? 'UHRZEIT (OPTIONAL)' : 'TIME (OPTIONAL)'),
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            final initial =
                                time ?? const TimeOfDay(hour: 9, minute: 0);
                            var temp = initial;
                            await showCupertinoModalPopup<void>(
                              context: ctx,
                              builder: (popupCtx) => Container(
                                height: 300,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: SafeArea(
                                  top: false,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CupertinoButton(
                                              onPressed: () =>
                                                  Navigator.of(popupCtx).pop(),
                                              child: Text(
                                                de ? 'Abbrechen' : 'Cancel',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ),
                                            CupertinoButton(
                                              onPressed: () {
                                                setState(() => time = temp);
                                                Navigator.of(popupCtx).pop();
                                              },
                                              child: Text(
                                                de ? 'Fertig' : 'Done',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1D7F5A),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.time,
                                          use24hFormat: true,
                                          initialDateTime: DateTime(
                                            2026,
                                            1,
                                            1,
                                            initial.hour,
                                            initial.minute,
                                          ),
                                          onDateTimeChanged: (dt) =>
                                              temp = TimeOfDay(
                                                hour: dt.hour,
                                                minute: dt.minute,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 15,
                                  color: Color(0xFF4B5563),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  time != null
                                      ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
                                      : (de ? 'Uhrzeit wählen' : 'Pick a time'),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (time != null)
                          IconButton(
                            onPressed: () => setState(() => time = null),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                            splashRadius: 16,
                            tooltip: de ? 'Uhrzeit entfernen' : 'Clear time',
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CoButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          label: de ? 'Abbrechen' : 'Cancel',
                          variant: CoButtonVariant.secondaryOutlined,
                        ),
                        const SizedBox(width: 10),
                        CoButton(
                          busy: saving,
                          onPressed: () async {
                            final title = titleCtrl.text.trim();
                            if (title.isEmpty || saving) return;
                            setState(() => saving = true);
                            try {
                              await operativeTasksCol(adminUid).add({
                                'title': title,
                                'description': descCtrl.text.trim(),
                                'shift': shift,
                                'recurrence': recurrence,
                                if (recurrence == 'weekly') 'weekday': weekday,
                                'time': time != null
                                    ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
                                    : '',
                                'dispatchers': selectedDispatchers.entries
                                    .map((e) => {'uid': e.key, 'name': e.value})
                                    .toList(),
                                'doneKeys': <String>[],
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                              if (dialogCtx.mounted) {
                                Navigator.of(dialogCtx).pop();
                              }
                            } catch (_) {
                              if (ctx.mounted) setState(() => saving = false);
                            }
                          },
                          icon: Icons.add_rounded,
                          label: de ? 'Aufgabe anlegen' : 'Create task',
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
    },
  );
  titleCtrl.dispose();
  descCtrl.dispose();
}

// ---------------------------------------------------------------------------
// Card (dashboard + tasksheet)
// ---------------------------------------------------------------------------

class OperativeTasksCard extends StatefulWidget {
  final String adminUid;
  const OperativeTasksCard({super.key, required this.adminUid});

  @override
  State<OperativeTasksCard> createState() => _OperativeTasksCardState();
}

class _OperativeTasksCardState extends State<OperativeTasksCard> {
  String get adminUid => widget.adminUid;

  /// Ticket „Tasks dem Sub-Account zuordnen": Ein eingeloggter
  /// Dispatcher kann die Liste auf die ihm zugewiesenen Aufgaben
  /// filtern. Fuer den Admin selbst ist der Filter ausgeblendet.
  bool _onlyMine = false;

  String? get _selfUid => FirebaseAuth.instance.currentUser?.uid;
  bool get _isSubAccount {
    final self = _selfUid;
    return self != null && self.isNotEmpty && self != adminUid;
  }

  static const _kBorder = Color(0xFFE5E7EB);
  static const _kText = Color(0xFF111827);
  static const _kMuted = Color(0xFF9CA3AF);
  static const _kSubText = Color(0xFF4B5563);
  static const _kGreen = Color(0xFF1D7F5A);

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded, size: 22, color: _kGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      de ? 'Operativ Tasks' : 'Operative tasks',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _kText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _todayLabel(context, de),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _kMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    showOperativeArchiveDialog(context, adminUid: adminUid),
                icon: const Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: _kSubText,
                ),
                tooltip: de ? 'Archiv' : 'Archive',
                splashRadius: 20,
              ),
              const SizedBox(width: 4),
              CoButton(
                onPressed: () =>
                    showOperativeTaskDialog(context, adminUid: adminUid),
                icon: Icons.add_rounded,
                label: de ? 'Neue Aufgabe' : 'New task',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: _kBorder),
          if (_isSubAccount)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  label: Text(
                    de ? 'Nur meine Aufgaben' : 'My tasks only',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  selected: _onlyMine,
                  onSelected: (v) => setState(() => _onlyMine = v),
                  avatar: Icon(
                    Icons.person_outline_rounded,
                    size: 15,
                    color: _onlyMine ? _kGreen : _kMuted,
                  ),
                  showCheckmark: false,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: operativeTasksCol(
                adminUid,
              ).orderBy('createdAt', descending: false).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    !snap.hasData) {
                  return const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final isSunday = DateTime.now().weekday == DateTime.sunday;
                final selfUid = _selfUid ?? '';
                final tasks = (snap.data?.docs ?? const [])
                    .map(OperativeTask.fromDoc)
                    .where((t) => t.title.isNotEmpty)
                    // Daily means Mon–Sat — keep Sundays free of them.
                    .where((t) => !(isSunday && t.recurrence == 'daily'))
                    // „Nur meine": auf die dem Sub-Account zugewiesenen
                    // Aufgaben eingrenzen (uid im dispatchers-Array).
                    .where((t) =>
                        !_onlyMine ||
                        t.dispatchers
                            .any((d) => (d['uid'] ?? '') == selfUid))
                    .toList();
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.task_alt_rounded,
                          size: 30,
                          color: _kMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          de
                              ? 'Noch keine Operativ-Aufgaben'
                              : 'No operative tasks yet',
                          style: const TextStyle(
                            fontSize: 13,
                            color: _kMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return _GroupedTaskList(tasks: tasks, adminUid: adminUid);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupedTaskList extends StatelessWidget {
  final List<OperativeTask> tasks;
  final String adminUid;
  const _GroupedTaskList({required this.tasks, required this.adminUid});

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    const shifts = ['early', 'middle', 'late'];
    const shiftLabels = {
      'early': 'Early Shift',
      'middle': 'Middle Shift',
      'late': 'Late Shift',
    };
    const shiftIcons = {
      'early': Icons.wb_twilight_rounded,
      'middle': Icons.wb_sunny_rounded,
      'late': Icons.nights_stay_rounded,
    };

    final children = <Widget>[];
    for (final shift in shifts) {
      final group = tasks.where((t) => t.shift == shift).toList()
        // Timed tasks first (by time), untimed ones keep creation order.
        ..sort((a, b) {
          if (a.time.isEmpty && b.time.isEmpty) {
            return a.createdAt.compareTo(b.createdAt);
          }
          if (a.time.isEmpty) return 1;
          if (b.time.isEmpty) return -1;
          return a.time.compareTo(b.time);
        });
      if (group.isEmpty) continue;
      final doneCount = group.where((t) => t.isDoneNow).length;
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Row(
            children: [
              Icon(
                shiftIcons[shift],
                size: 15,
                color: _OperativeTasksCardState._kSubText,
              ),
              const SizedBox(width: 6),
              Text(
                shiftLabels[shift]!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _OperativeTasksCardState._kSubText,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$doneCount/${group.length}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _OperativeTasksCardState._kMuted,
                ),
              ),
            ],
          ),
        ),
      );
      for (var i = 0; i < group.length; i++) {
        children.add(
          _TaskRow(
            task: group[i],
            adminUid: adminUid,
            de: de,
            background: i.isEven ? const Color(0xFFF6F7F9) : Colors.white,
          ),
        );
      }
    }

    return ListView(padding: EdgeInsets.zero, children: children);
  }
}

class _TaskRow extends StatelessWidget {
  final OperativeTask task;
  final String adminUid;
  final bool de;
  final Color background;
  const _TaskRow({
    required this.task,
    required this.adminUid,
    required this.de,
    required this.background,
  });

  String get _recurrenceLabel {
    switch (task.recurrence) {
      case 'weekly':
        final day = (de ? weekdayShortDe : weekdayShortEn)[task.weekday - 1];
        return de ? 'Wöchentl. · $day' : 'Weekly · $day';
      case 'monthly':
        return de ? 'Monatlich' : 'Monthly';
      case 'daily':
        return de ? 'Täglich · Mo–Sa' : 'Daily · Mon–Sat';
      default:
        return de ? 'Einmalig' : 'One-time';
    }
  }

  Future<void> _toggle([BuildContext? context]) async {
    final key = task.currentOccurrenceKey;
    try {
      await operativeTasksCol(adminUid).doc(task.id).update({
        'doneKeys': task.isDoneNow
            ? FieldValue.arrayRemove([key])
            : FieldValue.arrayUnion([key]),
      });
    } catch (e) {
      // Surface write failures instead of silently losing the check —
      // this is why completions could appear "not saved".
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${de ? 'Konnte nicht speichern' : 'Could not save'}: $e',
            ),
          ),
        );
      }
    }
  }

  /// Detail popup: full task info + done-toggle button.
  Future<void> _showDetail(BuildContext context) async {
    const shiftLabels = {
      'early': 'Early Shift',
      'middle': 'Middle Shift',
      'late': 'Late Shift',
    };
    final done = task.isDoneNow;

    Widget badge(String text, {IconData? icon, Color? bg, Color? fg}) {
      final fgColor = fg ?? _OperativeTasksCardState._kSubText;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: bg ?? const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: fgColor),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: fgColor,
              ),
            ),
          ],
        ),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.checklist_rounded,
                      size: 20,
                      color: Color(0xFF1D7F5A),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _OperativeTasksCardState._kText,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      splashRadius: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    badge(
                      shiftLabels[task.shift] ?? task.shift,
                      icon: Icons.badge_outlined,
                    ),
                    badge(
                      _recurrenceLabel,
                      icon: task.recurrence == 'none'
                          ? Icons.looks_one_rounded
                          : Icons.repeat_rounded,
                    ),
                    if (task.time.isNotEmpty)
                      badge(
                        task.time,
                        icon: Icons.schedule_rounded,
                        bg: const Color(0xFFEFF6FF),
                        fg: const Color(0xFF1D4ED8),
                      ),
                    ...task.dispatcherNames.map(
                      (n) => badge(
                        n,
                        icon: Icons.person_outline_rounded,
                        bg: const Color(0xFFECFDF5),
                        fg: const Color(0xFF1D7F5A),
                      ),
                    ),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      task.description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: _OperativeTasksCardState._kSubText,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final deleted = await _delete(dialogCtx);
                        if (deleted && dialogCtx.mounted) {
                          Navigator.of(dialogCtx).pop();
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Color(0xFFB91C1C),
                      ),
                      splashRadius: 18,
                      tooltip: de ? 'Aufgabe löschen' : 'Delete task',
                    ),
                    const Spacer(),
                    CoButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      label: de ? 'Schließen' : 'Close',
                      variant: CoButtonVariant.secondaryOutlined,
                    ),
                    const SizedBox(width: 10),
                    CoButton(
                      onPressed: () async {
                        await _toggle(dialogCtx);
                        if (dialogCtx.mounted) {
                          Navigator.of(dialogCtx).pop();
                        }
                      },
                      icon: done ? Icons.undo_rounded : Icons.check_rounded,
                      label: done
                          ? (de ? 'Als offen markieren' : 'Mark as open')
                          : (de ? 'Erledigen' : 'Mark done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns true when the task was actually deleted.
  Future<bool> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(de ? 'Aufgabe löschen?' : 'Delete task?'),
        content: Text(task.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              de ? 'Löschen' : 'Delete',
              style: const TextStyle(color: Color(0xFFB91C1C)),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await operativeTasksCol(adminUid).doc(task.id).delete();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final done = task.isDoneNow;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => _showDetail(context),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _toggle(context),
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: done ? const Color(0xFF1D7F5A) : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: done
                            ? const Color(0xFF1D7F5A)
                            : const Color(0xFFD1D5DB),
                        width: 1.5,
                      ),
                    ),
                    child: done
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: done
                              ? _OperativeTasksCardState._kMuted
                              : _OperativeTasksCardState._kText,
                          decoration: done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (task.description.isNotEmpty)
                        Text(
                          task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: _OperativeTasksCardState._kMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (task.dispatcherNames.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 11,
                          color: Color(0xFF1D7F5A),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          task.dispatcherNames.length == 1
                              ? task.dispatcherNames.first
                              : '${task.dispatcherNames.first} +${task.dispatcherNames.length - 1}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D7F5A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (task.time.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: Color(0xFF1D4ED8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          task.time,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (task.recurrence == 'daily' ||
                          task.recurrence == 'weekly' ||
                          task.recurrence == 'monthly') ...[
                        const Icon(
                          Icons.repeat_rounded,
                          size: 11,
                          color: _OperativeTasksCardState._kSubText,
                        ),
                        const SizedBox(width: 3),
                      ],
                      Text(
                        _recurrenceLabel,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _OperativeTasksCardState._kSubText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Archive — read-only view of past days
// ---------------------------------------------------------------------------

/// Opens a read-only archive: pick a past day and see which operative
/// tasks were checked off that day. Nothing here can be edited (feedback
/// ticket "archive for daily tasks, no option to change previous days").
Future<void> showOperativeArchiveDialog(
  BuildContext context, {
  required String adminUid,
}) async {
  final de = Localizations.localeOf(context).languageCode == 'de';
  final today = DateTime.now();
  var selected = DateTime(today.year, today.month, today.day);

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460, maxHeight: 620),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 20,
                          color: Color(0xFF1D7F5A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            de ? 'Archiv' : 'Archive',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          splashRadius: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Day picker row.
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => setState(() {
                            selected = selected.subtract(
                              const Duration(days: 1),
                            );
                          }),
                          icon: const Icon(Icons.chevron_left_rounded),
                          splashRadius: 18,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: selected,
                                firstDate: DateTime(today.year - 2),
                                lastDate: today,
                              );
                              if (picked != null) {
                                setState(
                                  () => selected = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                _dateNumeric(selected, de),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              selected.isBefore(
                                DateTime(today.year, today.month, today.day),
                              )
                              ? () => setState(() {
                                  selected = selected.add(
                                    const Duration(days: 1),
                                  );
                                })
                              : null,
                          icon: const Icon(Icons.chevron_right_rounded),
                          splashRadius: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 4),
                    Flexible(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: operativeTasksCol(
                          adminUid,
                        ).orderBy('createdAt', descending: false).snapshots(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting &&
                              !snap.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          final endOfDay = DateTime(
                            selected.year,
                            selected.month,
                            selected.day,
                            23,
                            59,
                            59,
                          );
                          final isSunday = selected.weekday == DateTime.sunday;
                          final tasks = (snap.data?.docs ?? const [])
                              .map(OperativeTask.fromDoc)
                              .where((t) => t.title.isNotEmpty)
                              // Existed on that day…
                              .where((t) => !t.createdAt.isAfter(endOfDay))
                              // …and daily tasks don't apply on Sundays.
                              .where(
                                (t) => !(isSunday && t.recurrence == 'daily'),
                              )
                              .toList();
                          if (tasks.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  de
                                      ? 'Keine Aufgaben für diesen Tag'
                                      : 'No tasks for this day',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }
                          const shifts = ['early', 'middle', 'late'];
                          const shiftLabels = {
                            'early': 'Early Shift',
                            'middle': 'Middle Shift',
                            'late': 'Late Shift',
                          };
                          final children = <Widget>[];
                          for (final shift in shifts) {
                            final group = tasks
                                .where((t) => t.shift == shift)
                                .toList();
                            if (group.isEmpty) continue;
                            final doneCount = group
                                .where((t) => _taskDoneOn(t, selected))
                                .length;
                            children.add(
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 4,
                                ),
                                child: Text(
                                  '${shiftLabels[shift]}  ·  $doneCount/${group.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF4B5563),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            );
                            for (final t in group) {
                              final done = _taskDoneOn(t, selected);
                              children.add(
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        done
                                            ? Icons.check_box_rounded
                                            : Icons
                                                  .check_box_outline_blank_rounded,
                                        size: 18,
                                        color: done
                                            ? const Color(0xFF1D7F5A)
                                            : const Color(0xFFB0B7C0),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          t.title,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: done
                                                ? const Color(0xFF9CA3AF)
                                                : const Color(0xFF111827),
                                            decoration: done
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }
                          return ListView(
                            padding: EdgeInsets.zero,
                            children: children,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
