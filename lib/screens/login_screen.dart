import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../providers/app_state_provider.dart';
import '../widgets/ui_components.dart';
import 'diagnostics_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getUserFriendlyErrorMessage(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (lowerError.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    } else if (lowerError.contains('user-not-found')) {
      return 'No account found with this email. Please sign up first.';
    } else if (lowerError.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (lowerError.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (lowerError.contains('network-request-failed')) {
      return 'Network error. Please check your connection and try again.';
    } else if (lowerError.contains('invalid-credential')) {
      return 'Invalid login credentials. Please check your email and password.';
    } else {
      return 'Login failed. Please try again or contact support if the problem persists.';
    }
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = _getUserFriendlyErrorMessage(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.statusError,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppTheme.textPrimary,
              onPressed: _signInWithEmail,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithGoogle();

      if (result != null && mounted) {
        // Load user profile from auth
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.loadUserFromAuth();

        // Navigate after auth is complete
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // User cancelled Google sign-in
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final err = e.toString();
      final lower = err.toLowerCase();

      // Special handling for DEVELOPER_ERROR / broker errors
      if (lower.contains('developer_error') ||
          lower.contains('unknown calling package') ||
          lower.contains('developer error')) {
        // Show dialog with Diagnostics and Help actions
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Google Sign-in Error'),
            content: const Text(
              'Native Google sign-in failed due to OAuth configuration (missing/incorrect SHA fingerprints or OAuth client). Use Diagnostics to inspect your app or open Help for step-by-step instructions.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DiagnosticsScreen(),
                    ),
                  );
                },
                child: const Text('Diagnostics'),
              ),
              TextButton(
                onPressed: () {
                  launchUrlString(
                    'https://github.com/pawarshreyas425-max/SmartCart#configure-firebase',
                  );
                },
                child: const Text('Help'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
        return;
      }

      final errorMessage = _getUserFriendlyErrorMessage(err);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.statusError,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScreenFade(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Logo/Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🛒', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue shopping',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'your.email@example.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/forgot-password');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign In Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signInWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.textPrimary,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppTheme.darkBorder),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppTheme.darkBorder),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Sign In Button
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: Image.network(
                        'https://developers.google.com/identity/images/g-logo.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.darkBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppTheme.textTertiary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/signup');
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
