import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_screen.dart';
import '../theme/app_theme.dart';

/// Widget that checks if user is suspended
/// Automatically signs out and redirects to login if user is suspended
class SuspensionGuard extends StatelessWidget {
  final Widget child;

  const SuspensionGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return child; // Let AuthGuard handle this
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Show loading while checking suspension status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppTheme.darkBg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    color: AppTheme.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Checking account status...',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        // Check if user document exists and is suspended
        if (snapshot.hasData && snapshot.data != null) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final isSuspended = userData?['isSuspended'] ?? false;

          if (isSuspended) {
            // User is suspended - sign out and redirect
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your account has been suspended. Please contact support.'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5),
                  ),
                );
              }
            });

            return Scaffold(
              backgroundColor: AppTheme.darkBg,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.block,
                      size: 80,
                      color: Colors.red,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Account Suspended',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Your account has been suspended by an administrator.\n\nPlease contact support for assistance.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Signing out...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }

        // User is not suspended - show child
        return child;
      },
    );
  }
}
