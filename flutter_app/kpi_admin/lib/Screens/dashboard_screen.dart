import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Color _statusColor(String? s) {
    switch (s) {
      case 'Fantastic':
        return const Color(0xFF16A34A);
      case 'Great':
        return const Color(0xFF22C55E);
      case 'Fair':
        return const Color(0xFFF59E0B);
      case 'Poor':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('drivers')
        .orderBy('currentScore', descending: true);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final docs = snap.data?.docs ?? [];

        final avg = docs.isEmpty
            ? 0.0
            : docs
                .map((d) => (d.data()['currentScore'] ?? 0.0) as num)
                .fold<num>(0, (a, b) => a + b) /
              docs.length;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  title: const Text('Total Company Score'),
                  subtitle: Text('${avg.toStringAsFixed(2)} %'),
                  trailing: const Text('Live data'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final d = docs[i].data();
                    final name = (d['driverName'] ?? '').toString();
                    final id = (d['transporterId'] ?? '').toString();
                    final score = (d['currentScore'] ?? 0.0) as num;
                    final status = (d['currentStatus'] ?? 'Unknown').toString();

                    return Card(
                      child: ListTile(
                        isThreeLine: true, // give the tile more height
                        minVerticalPadding: 10,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              _statusColor(status).withOpacity(0.15),
                          child: Text(
                            '#${i + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          name.isEmpty ? '(No Name)' : name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          id,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Wrap trailing in FittedBox so it scales & never overflows
                        trailing: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                score.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      _statusColor(status).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _statusColor(status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
