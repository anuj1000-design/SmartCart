import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  String _packageName = 'unknown';
  bool _isSignedIn = false;
  bool _supportsAuthenticate = false;
  String _lastError = '';

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  void initState() {
    super.initState();
    _collectInfo();
  }

  Future<void> _collectInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _packageName = info.packageName;
    } catch (e) {
      _packageName = 'error: $e';
    }

    try {
      _isSignedIn = await _googleSignIn.isSignedIn();
    } catch (e) {
      _lastError = 'isSignedIn error: $e';
    }

    // v5 api may expose supportsAuthenticate via instance
    try {
      // v5.x: assume the plugin supports lightweight/native auth methods;
      // this is a best-effort indicator rather than a guaranteed check.
      _supportsAuthenticate = true;
    } catch (_) {
      _supportsAuthenticate = false;
    }

    if (mounted) setState(() {});
  }

  Future<void> _trySignInSilently() async {
    setState(() => _lastError = '');
    try {
      final account = await _googleSignIn.signInSilently();
      setState(() {
        _isSignedIn = account != null;
      });
    } catch (e) {
      setState(() {
        _lastError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText('Package name: $_packageName'),
            const SizedBox(height: 12),
            Text('GoogleSignIn signed-in: $_isSignedIn'),
            const SizedBox(height: 12),
            Text(
              'GoogleSignIn lightweight auth supported: $_supportsAuthenticate',
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _trySignInSilently,
              child: const Text('Try signInSilently()'),
            ),
            const SizedBox(height: 12),
            Text('Last error: $_lastError'),
            const SizedBox(height: 12),
            const Text('App Information:'),
            const SizedBox(height: 6),
             Text('Package: $_packageName'),
            const SizedBox(height: 18),
            const Text('Troubleshooting:'),
            const SizedBox(height: 8),
            const Text(
              '- If sign-in fails, ensure your keystore SHA-1 is added to Firebase console.',
            ),
             const SizedBox(height: 8),
            const Text(
              '- To find your SHA-1, run `.gradlew signingReport` in the android folder.',
            ),
            const SizedBox(height: 16),
            if (kDebugMode)
              const Text(
                'Note: diagnostics are only shown in debug builds.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
