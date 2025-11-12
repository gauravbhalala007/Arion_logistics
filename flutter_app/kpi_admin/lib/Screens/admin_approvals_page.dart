import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/app_shell.dart';
import '../widgets/app_side_menu.dart';
import '../services/admin_approvals.dart';

class AdminApprovalsPage extends StatelessWidget {
  const AdminApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      menuWidth: 280,
      sideMenu: const AppSideMenu(width: 280, active: AppNav.adminApprovals),
      title: const Text('USER APPROVALS'),
      body: Container(
        color: const Color(0xFFF6F7F5),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: AdminApprovalsService.pendingUsersStream(),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // NEW: show errors so “missing index” etc. are visible
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error loading pending users:\n${snap.error}',
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
              return const Center(child: Text('No pending users.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final d = docs[i];
                final data = d.data();
                final name =
                    '${(data['firstName'] ?? '').toString()} ${(data['lastName'] ?? '').toString()}'
                        .trim();
                final email = (data['email'] ?? '').toString();
                final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

                return Card(
                  child: ListTile(
                    title: Text(
                      name.isEmpty ? '(no name)' : name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '$email${createdAt != null ? ' • ${createdAt.toLocal()}' : ''}',
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => AdminApprovalsService.deleteUserDoc(d.id),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                        ),
                        FilledButton.icon(
                          onPressed: () => AdminApprovalsService.approve(d.id),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Approve'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
