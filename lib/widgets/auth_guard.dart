import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_screen.dart';
import '../theme/app_theme.dart';

/// Widget that requires authentication to access its child
/// Automatically redirects to login if user is not authenticated
class AuthGuard extends StatelessWidget {
  final Widget child;
  final String? message;

  const AuthGuard({
    super.key,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppTheme.darkBg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppTheme.primary,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // User is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          return child;
        }

        // User is not authenticated - redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        });

        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'Authentication Required',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Redirecting to login...',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Helper function to check if user is authenticated
bool isUserAuthenticated() {
  return FirebaseAuth.instance.currentUser != null;
}

/// Helper function to get current user
User? getCurrentUser() {
  return FirebaseAuth.instance.currentUser;
}

/// Helper function to require authentication, throws if not authenticated
User requireAuth() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('Authentication required. Please sign in.');
  }
  return user;
}
