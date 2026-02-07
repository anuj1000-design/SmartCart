import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles Firestore errors and provides user-friendly messages
class FirestoreErrorHandler {
  /// Check if error is a permission denied error
  static bool isPermissionDenied(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('permission') ||
        errorString.contains('denied') ||
        errorString.contains('insufficient permissions') ||
        errorString.contains('missing or insufficient permissions');
  }

  /// Check if error is an authentication error
  static bool isAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('unauthenticated') ||
        errorString.contains('not authenticated') ||
        errorString.contains('requires authentication');
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (isPermissionDenied(error)) {
      if (FirebaseAuth.instance.currentUser == null) {
        return 'Please sign in to access this feature.';
      }
      return 'You don\'t have permission to perform this action.';
    }

    if (isAuthError(error)) {
      return 'Authentication required. Please sign in to continue.';
    }

    if (errorString.contains('network')) {
      return 'Network error. Please check your connection and try again.';
    }

    if (errorString.contains('not found') || errorString.contains('no document')) {
      return 'The requested data was not found.';
    }

    if (errorString.contains('already exists')) {
      return 'This item already exists.';
    }

    if (errorString.contains('invalid')) {
      return 'Invalid data provided. Please check your input.';
    }

    // Default message
    return 'An error occurred. Please try again.';
  }

  /// Show error snackbar with user-friendly message
  static void showError(BuildContext context, dynamic error) {
    final message = getUserFriendlyMessage(error);
    
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Handle error and redirect to login if needed
  static void handleErrorWithRedirect(BuildContext context, dynamic error) {
    if (isAuthError(error) || 
        (isPermissionDenied(error) && FirebaseAuth.instance.currentUser == null)) {
      // Redirect to login
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    showError(context, error);
  }

  /// Wrap async operation with error handling
  static Future<T?> handleAsync<T>({
    required Future<T> Function() operation,
    required BuildContext context,
    String? loadingMessage,
    String? successMessage,
    bool redirectOnAuth = false,
  }) async {
    try {
      final result = await operation();
      
      if (successMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    successMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      return result;
    } catch (e) {
      if (context.mounted) {
        if (redirectOnAuth) {
          handleErrorWithRedirect(context, e);
        } else {
          showError(context, e);
        }
      }
      return null;
    }
  }
}
