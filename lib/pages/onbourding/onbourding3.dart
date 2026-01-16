import 'package:flutter/material.dart';
import '../../services/local_auth.dart';
import '../../services/notification_service.dart';

class Onbourding3 extends StatelessWidget {
  const Onbourding3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Icon(
                  Icons.notifications,
                  size: 110,
                  color: Colors.amber.shade700,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Stay on Track',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  'Set gentle reminders to check in with yourself throughout the day.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await LocalAuthService.setCompletedOnboarding(true);
                        // Try to setup notifications but don't let it block navigation if it fails
                        await NotificationService.requestPermissions();
                        await NotificationService.scheduleDailyNotification();
                      } catch (e) {
                        debugPrint('Error setting up notifications: $e');
                      } finally {
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'get started',
                      style: TextStyle(
                        color: Color(0xFFBFF23B),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
