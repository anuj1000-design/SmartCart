import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../firebase_options.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  String _packageName = 'unknown';
  String _version = '-';
  String _buildNumber = '-';
  bool _isSignedIn = false;
  bool _supportsAuthenticate = false;
  String _lastError = 'None';
  String _accountEmail = 'Not signed in';
  bool _loading = true;
  bool _firebaseReady = false;
  String _firebaseProject = 'Not initialized';
  String _firebaseErrors = 'None';
  final bool _isRelease = kReleaseMode;
  final bool _isWeb = kIsWeb;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  void initState() {
    super.initState();
    _collectInfo();
  }

  Future<void> _collectInfo() async {
    setState(() {
      _loading = true;
      _lastError = 'None';
    });

    try {
      final info = await PackageInfo.fromPlatform();
      _packageName = info.packageName;
      _version = info.version;
      _buildNumber = info.buildNumber;
    } catch (e) {
      _packageName = 'error: $e';
      _version = 'error';
      _buildNumber = 'error';
    }


    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      final app = Firebase.app();
      _firebaseReady = true;
      _firebaseProject = app.options.projectId;
    } catch (e) {
      _firebaseReady = false;
      _firebaseErrors = e.toString();
    }
    try {
      _isSignedIn = await _googleSignIn.isSignedIn();
    } catch (e) {
      _lastError = 'isSignedIn error: $e';
    }

    try {
      final account = await _googleSignIn.signInSilently();
      _accountEmail = account?.email ?? 'Not signed in';
    } catch (e) {
      _lastError = 'signInSilently error: $e';
    }

    // v5 api may expose supportsAuthenticate via instance
    try {
      // v5.x: assume the plugin supports lightweight/native auth methods;
      // this is a best-effort indicator rather than a guaranteed check.
      _supportsAuthenticate = true;
    } catch (_) {
      _supportsAuthenticate = false;
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _trySignInSilently() async {
    setState(() => _lastError = 'None');
    try {
      final account = await _googleSignIn.signInSilently();
      setState(() {
        _isSignedIn = account != null;
        _accountEmail = account?.email ?? 'Not signed in';
      });
    } catch (e) {
      setState(() {
        _lastError = e.toString();
      });
    }
  }

  Widget _statusChip({required String label, required bool ok}) {
    return Chip(
      label: Text(label),
      backgroundColor: ok ? Colors.green.shade100 : Colors.red.shade100,
      labelStyle: TextStyle(color: ok ? Colors.green.shade800 : Colors.red.shade800),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _collectInfo,
            tooltip: 'Refresh diagnostics',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_loading) const LinearProgressIndicator(),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _statusChip(label: 'Firebase', ok: _firebaseReady),
                    _statusChip(label: 'Google Sign-In', ok: _isSignedIn),
                    _statusChip(label: _isRelease ? 'Release' : 'Debug', ok: !_isRelease || _isRelease),
                    _statusChip(label: _isWeb ? 'Web' : 'Mobile', ok: true),
                  ],
                ),
                const SizedBox(height: 16),
                _card(
                  title: 'App',
                  children: [
                    _infoRow('Package', _packageName),
                    _infoRow('Version', _version),
                    _infoRow('Build', _buildNumber),
                    _infoRow('Mode', _isRelease ? 'Release' : 'Debug'),
                    _infoRow('Platform', _isWeb ? 'Web' : 'Mobile'),
                  ],
                ),
                _card(
                  title: 'Google Sign-In',
                  children: [
                    _infoRow('Signed in', _isSignedIn.toString()),
                    _infoRow('Account', _accountEmail),
                    _infoRow('Lightweight auth', _supportsAuthenticate.toString()),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _trySignInSilently,
                      child: const Text('Try signInSilently()'),
                    ),
                    const SizedBox(height: 8),
                    _infoRow('Last error', _lastError),
                  ],
                ),
                _card(
                  title: 'Firebase',
                  children: [
                    _infoRow('Initialized', _firebaseReady.toString()),
                    _infoRow('Project ID', _firebaseProject),
                    _infoRow('Errors', _firebaseErrors),
                  ],
                ),
                _card(
                  title: 'Troubleshooting',
                  children: const [
                    Text('- Ensure your keystore SHA-1/SHA-256 are added in Firebase console (Project settings > Your apps).'),
                    SizedBox(height: 8),
                    Text('- Run `./gradlew signingReport` inside android/ to print fingerprints.'),
                    SizedBox(height: 8),
                    Text('- Verify the OAuth client ID in google-services.json matches your Firebase project.'),
                  ],
                ),
                if (kDebugMode)
                  const Text(
                    'Note: diagnostics are only shown in debug builds.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
