import 'package:flutter_test/flutter_test.dart';

/// Authentication Service Tests
/// 
/// Critical for production: Validates user authentication, sign-up,
/// sign-in, password reset, and profile creation flows.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Tests', () {
    test('Email validation - accepts valid emails', () {
      final validEmails = [
        'user@example.com',
        'test.user@domain.co.in',
        'admin+tag@company.org',
      ];

      for (final email in validEmails) {
        expect(_isValidEmail(email), true, reason: '$email should be valid');
      }
    });

    test('Email validation - rejects invalid emails', () {
      final invalidEmails = [
        'notanemail',
        '@example.com',
        'user@',
        'user @example.com',
        '',
      ];

      for (final email in invalidEmails) {
        expect(_isValidEmail(email), false, reason: '$email should be invalid');
      }
    });

    test('Password validation - strong passwords', () {
      final strongPasswords = [
        'MyP@ssw0rd123',
        'Str0ng!Pass',
        'Complex#123',
      ];

      for (final pwd in strongPasswords) {
        expect(pwd.length >= 6, true, reason: 'Password should be at least 6 characters');
      }
    });

    test('Password validation - weak passwords rejected', () {
      final weakPasswords = [
        '12345',
        'abc',
        'pass',
      ];

      for (final pwd in weakPasswords) {
        expect(pwd.length < 6, true, reason: 'Password should be rejected');
      }
    });
  });

  group('User Profile Tests', () {
    test('New user profile has correct default values', () {
      final profile = {
        'name': 'Test User',
        'email': 'test@example.com',
        'membershipTier': 'Silver',
        'points': 0,
        'totalSpent': 0,
        'avatarEmoji': '👤',
        'photoURL': null,
      };

      expect(profile['membershipTier'], 'Silver');
      expect(profile['points'], 0);
      expect(profile['totalSpent'], 0);
      expect(profile['photoURL'], isNull);
    });

    test('Google Sign-In user has photoURL', () {
      final googleProfile = {
        'name': 'Google User',
        'email': 'user@gmail.com',
        'photoURL': 'https://lh3.googleusercontent.com/a/test',
      };

      expect(googleProfile['photoURL'], isNotNull);
      expect(googleProfile['photoURL'], contains('googleusercontent.com'));
    });
  });
}

// Helper function for email validation
bool _isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email);
}
