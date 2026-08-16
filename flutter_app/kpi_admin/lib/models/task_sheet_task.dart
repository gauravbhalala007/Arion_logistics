import 'package:cloud_firestore/cloud_firestore.dart';

enum DriverTaskStatus { pending, inProgress, completed }

DriverTaskStatus parseDriverTaskStatus(String raw) {
  switch (raw) {
    case 'in_progress':
      return DriverTaskStatus.inProgress;
    case 'completed':
      return DriverTaskStatus.completed;
    case 'pending':
    default:
      return DriverTaskStatus.pending;
  }
}

String driverTaskStatusValue(DriverTaskStatus status) {
  switch (status) {
    case DriverTaskStatus.inProgress:
      return 'in_progress';
    case DriverTaskStatus.completed:
      return 'completed';
    case DriverTaskStatus.pending:
      return 'pending';
  }
}

String driverTaskStatusLabel(DriverTaskStatus status) {
  switch (status) {
    case DriverTaskStatus.inProgress:
      return 'In progress';
    case DriverTaskStatus.completed:
      return 'Completed';
    case DriverTaskStatus.pending:
      return 'Pending';
  }
}

DateTime _toDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.fromMillisecondsSinceEpoch(0);
}

List<String> _toStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

class TaskSheetTask {
  final String id;
  final String title;
  final String description;
  final String assignedTransporterId;
  final String assignedDriverName;
  final String assignmentScope;
  final String assignmentBatchId;
  final String taskKind;
  final List<String> feedbackOptions;
  final String feedbackText;
  final String feedbackSelectedOption;
  final DateTime? respondedAt;
  final DriverTaskStatus status;
  final bool completedConfirmed;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Language the admin originally wrote [title]/[description] in.
  final String sourceLang;

  /// Per-language translations: `{ langCode: { 'title': ..., 'description': ... } }`.
  /// Empty when auto-translation was off at creation time.
  final Map<String, Map<String, String>> translations;

  const TaskSheetTask({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTransporterId,
    required this.assignedDriverName,
    required this.assignmentScope,
    required this.assignmentBatchId,
    required this.taskKind,
    required this.feedbackOptions,
    required this.feedbackText,
    required this.feedbackSelectedOption,
    required this.respondedAt,
    required this.status,
    required this.completedConfirmed,
    required this.createdAt,
    required this.updatedAt,
    this.sourceLang = '',
    this.translations = const <String, Map<String, String>>{},
  });

  /// Title in [langCode] if a translation exists, otherwise the source text.
  String localizedTitle(String langCode) =>
      _localized('title', langCode, title);

  /// Description in [langCode] if a translation exists, otherwise the source.
  String localizedDescription(String langCode) =>
      _localized('description', langCode, description);

  String _localized(String field, String langCode, String fallback) {
    final row = translations[langCode.toLowerCase()];
    final value = (row?[field] ?? '').trim();
    return value.isNotEmpty ? value : fallback;
  }

  bool get isFeedbackText => taskKind == 'feedback_text';

  bool get isFeedbackChoice => taskKind == 'feedback_choice';

  bool get isFeedbackTask => isFeedbackText || isFeedbackChoice;

  String get feedbackResponse =>
      feedbackText.isNotEmpty ? feedbackText : feedbackSelectedOption;

  factory TaskSheetTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final title = (data['title'] ?? '').toString().trim();
    final description = (data['description'] ?? '').toString().trim();
    final assignedTransporterId = (data['assignedTransporterId'] ?? '')
        .toString()
        .trim()
        .toUpperCase();
    final assignedDriverName = (data['assignedDriverName'] ?? '')
        .toString()
        .trim();
    final assignmentScope = (data['assignmentScope'] ?? 'single').toString();
    final assignmentBatchId = (data['assignmentBatchId'] ?? '')
        .toString()
        .trim();
    final taskKind = (data['taskKind'] ?? 'standard').toString().trim();
    final feedbackOptions = _toStringList(data['feedbackOptions']);
    final feedbackText = (data['feedbackText'] ?? '').toString().trim();
    final feedbackSelectedOption = (data['feedbackSelectedOption'] ?? '')
        .toString()
        .trim();
    final statusRaw = (data['status'] ?? 'pending').toString().trim();
    final completedConfirmed = data['completedConfirmed'] == true;
    final sourceLang = (data['sourceLang'] ?? '').toString().trim();
    final translations = <String, Map<String, String>>{};
    final rawTranslations = data['translations'];
    if (rawTranslations is Map) {
      rawTranslations.forEach((key, value) {
        if (value is Map) {
          translations[key.toString().toLowerCase()] = <String, String>{
            'title': (value['title'] ?? '').toString(),
            'description': (value['description'] ?? '').toString(),
          };
        }
      });
    }

    return TaskSheetTask(
      id: doc.id,
      title: title,
      description: description,
      assignedTransporterId: assignedTransporterId,
      assignedDriverName: assignedDriverName,
      assignmentScope: assignmentScope,
      assignmentBatchId: assignmentBatchId,
      taskKind: taskKind,
      feedbackOptions: feedbackOptions,
      feedbackText: feedbackText,
      feedbackSelectedOption: feedbackSelectedOption,
      respondedAt: data['respondedAt'] is Timestamp
          ? (data['respondedAt'] as Timestamp).toDate()
          : (data['respondedAt'] is DateTime ? data['respondedAt'] as DateTime : null),
      status: parseDriverTaskStatus(statusRaw),
      completedConfirmed: completedConfirmed,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
      sourceLang: sourceLang,
      translations: translations,
    );
  }
}
