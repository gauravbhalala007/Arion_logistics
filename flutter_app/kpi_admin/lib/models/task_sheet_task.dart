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

class TaskSheetTask {
  final String id;
  final String title;
  final String description;
  final String assignedTransporterId;
  final String assignedDriverName;
  final String assignmentScope;
  final String assignmentBatchId;
  final DriverTaskStatus status;
  final bool completedConfirmed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskSheetTask({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTransporterId,
    required this.assignedDriverName,
    required this.assignmentScope,
    required this.assignmentBatchId,
    required this.status,
    required this.completedConfirmed,
    required this.createdAt,
    required this.updatedAt,
  });

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
    final statusRaw = (data['status'] ?? 'pending').toString().trim();
    final completedConfirmed = data['completedConfirmed'] == true;

    return TaskSheetTask(
      id: doc.id,
      title: title,
      description: description,
      assignedTransporterId: assignedTransporterId,
      assignedDriverName: assignedDriverName,
      assignmentScope: assignmentScope,
      assignmentBatchId: assignmentBatchId,
      status: parseDriverTaskStatus(statusRaw),
      completedConfirmed: completedConfirmed,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }
}
