import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveRuleConfirmationStats {
  final int confirmedCount;
  final int pendingCount;
  final int totalCount;
  final List<String> pendingDriverNames;

  const ActiveRuleConfirmationStats({
    required this.confirmedCount,
    required this.pendingCount,
    required this.totalCount,
    required this.pendingDriverNames,
  });
}

bool isDriverWorking(Map<String, dynamic> driverData) {
  bool? parseBoolish(dynamic raw) {
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      final v = raw.trim().toLowerCase();
      if (v == 'false' || v == '0' || v == 'off' || v == 'inactive') {
        return false;
      }
      if (v == 'true' || v == '1' || v == 'on' || v == 'active') {
        return true;
      }
    }
    return null;
  }

  final active = parseBoolish(driverData['active']);
  final working = parseBoolish(driverData['working']);
  final isWorking = parseBoolish(driverData['isWorking']);

  if (active == false || working == false || isWorking == false) {
    return false;
  }

  final status = (driverData['status'] ?? '').toString().trim().toLowerCase();
  const inactiveStatuses = <String>{
    'off',
    'inactive',
    'suspended',
    'deleted',
    'archived',
    'left',
    'terminated',
    'fired',
    'quit',
    'rejected',
  };
  if (inactiveStatuses.contains(status)) return false;
  // Also exclude soft-deleted drivers and onboarding-only ones.
  if (driverData['isDeleted'] == true ||
      driverData['deleted'] == true ||
      driverData['archived'] == true) {
    return false;
  }

  if (active == true || working == true || isWorking == true) {
    return true;
  }

  return true;
}

Future<ActiveRuleConfirmationStats> loadActiveRuleConfirmationStats({
  required String dspUid,
  required String notificationId,
  required String fallbackDriverLabel,
}) async {
  final driversSnap = await FirebaseFirestore.instance
      .collection('users')
      .doc(dspUid)
      .collection('drivers')
      .get();

  final activeDrivers = driversSnap.docs
      .where((doc) => isDriverWorking(doc.data()))
      .toList(growable: false);

  final rows = await Future.wait(
    activeDrivers.map((driverDoc) async {
      final driverData = driverDoc.data();
      final transporterId = (driverData['transporterId'] ?? driverDoc.id)
          .toString()
          .trim()
          .toUpperCase();
      final driverName = (driverData['driverName'] ??
              driverData['fullName'] ??
              transporterId)
          .toString()
          .trim();

      final notifSnap = await driverDoc.reference
          .collection('notifications')
          .doc(notificationId)
          .get();

      if (!notifSnap.exists) {
        return null;
      }

      final status = (notifSnap.data()?['status'] ?? 'unread').toString();
      return {
        'name': driverName.isEmpty ? fallbackDriverLabel : driverName,
        'status': status,
      };
    }),
  );

  final pendingNames = <String>[];
  var total = 0;
  var confirmed = 0;

  for (final row in rows) {
    if (row == null) continue;
    total += 1;
    if (row['status'] == 'confirmed') {
      confirmed += 1;
    } else {
      pendingNames.add((row['name'] ?? fallbackDriverLabel).toString());
    }
  }

  pendingNames.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  return ActiveRuleConfirmationStats(
    confirmedCount: confirmed,
    pendingCount: pendingNames.length,
    totalCount: total,
    pendingDriverNames: pendingNames,
  );
}
