import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../localization/app_localizations.dart';
import '../services/admin_approvals.dart';

class AdminApprovalsPage extends StatelessWidget {
  const AdminApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFF6F7F5),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: AdminApprovalsService.pendingUsersStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  t.tf('admin_approvals_error_loading', {
                    'error': '${snap.error}',
                  }),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final docs = snap.data?.docs ?? [];

          // Client-side sort by createdAt desc (no composite index needed)
          docs.sort((a, b) {
            final ta = (a.data()['createdAt'] as Timestamp?);
            final tb = (b.data()['createdAt'] as Timestamp?);
            final da = ta?.toDate();
            final db = tb?.toDate();
            if (da == null && db == null) return 0;
            if (da == null) return 1;
            if (db == null) return -1;
            return db.compareTo(da); // newest first
          });

          if (docs.isEmpty) {
            return Center(child: Text(t.t('admin_approvals_no_pending')));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data();
              final name =
                  '${(data['firstName'] ?? '').toString()} ${(data['lastName'] ?? '').toString()}'
                      .trim();
              final email = (data['email'] ?? '').toString();
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              final isNarrow = MediaQuery.of(context).size.width < 760;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? t.t('admin_approvals_no_name') : name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$email${createdAt != null ? ' • ${createdAt.toLocal()}' : ''}',
                      ),
                      const SizedBox(height: 10),
                      if (isNarrow) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                AdminApprovalsService.deleteUserDoc(d.id),
                            icon: const Icon(Icons.delete_outline),
                            label: Text(t.t('admin_approvals_delete')),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () =>
                                AdminApprovalsService.approve(d.id),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(t.t('admin_approvals_approve')),
                          ),
                        ),
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  AdminApprovalsService.deleteUserDoc(d.id),
                              icon: const Icon(Icons.delete_outline),
                              label: Text(t.t('admin_approvals_delete')),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: () =>
                                  AdminApprovalsService.approve(d.id),
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text(t.t('admin_approvals_approve')),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
