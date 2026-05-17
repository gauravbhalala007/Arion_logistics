// lib/widgets/maintenance_banner.dart
//
// Sticky-Banner, der bei aktivem Wartungsmodus oben in allen Shells
// (Admin/Dispatcher/Driver) eingeblendet wird.

import 'package:flutter/material.dart';

import '../services/maintenance_flag_service.dart';

class MaintenanceBanner extends StatelessWidget {
  const MaintenanceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MaintenanceState>(
      stream: MaintenanceFlagService.watch(),
      builder: (context, snapshot) {
        final state = snapshot.data ?? MaintenanceState.off;
        if (!state.isActive) return const SizedBox.shrink();

        final message = state.message?.trim().isNotEmpty == true
            ? state.message!.trim()
            : 'Wartungsarbeiten — bitte aktuell keine Änderungen vornehmen.';

        return Material(
          color: const Color(0xFFFFE9B0),
          child: SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.engineering,
                    size: 18,
                    color: Color(0xFF8A5A00),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8A5A00),
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
    );
  }
}
