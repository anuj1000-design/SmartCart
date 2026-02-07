import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../widgets/ui_components.dart';
import '../services/auth_service.dart';
import 'report_bug_screen.dart';
import 'feedback_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
      ),
      body: ScreenFade(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              "Preferences",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _SettingTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              subtitle: "Use dark theme",
              value: appState.isDarkMode,
              onChanged: (val) => appState.toggleTheme(val),
            ),
            const SizedBox(height: 16),
            _SettingTile(
              icon: Icons.notifications_outlined,
              title: "Push Notifications",
              subtitle: "Receive order updates and offers",
              value: appState.notificationsEnabled,
              onChanged: (val) => appState.toggleNotifications(val),
            ),
            const SizedBox(height: 32),
            const Text(
              "Support",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoTile(
              icon: Icons.account_balance_wallet_outlined,
              title: "Budget Settings",
              value: "Manage",
              onTap: () {
                Navigator.pushNamed(context, '/budget-settings');
              },
            ),
            _InfoTile(
              icon: Icons.feedback_outlined,
              title: "Send Feedback",
              value: "Help",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const FeedbackScreen()),
                );
              },
            ),
            _InfoTile(
              icon: Icons.bug_report_outlined,
              title: "Report Bug",
              value: "Report",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const ReportBugScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _InfoTile(
              icon: Icons.info_outline,
              title: "App Version",
              value: "1.0.0",
            ),
            _InfoTile(
              icon: Icons.policy_outlined,
              title: "Privacy Policy",
              value: "View",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const PrivacyPolicyScreen()),
                );
              },
            ),
            _InfoTile(
              icon: Icons.description_outlined,
              title: "Terms of Service",
              value: "View",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const TermsOfServiceScreen()),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              "Developer",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onLongPress: () async {
                // Reset cart
                appState.clearCart();
                
                // Reset stock (if stored locally)
                // appState.resetStock(); // Add if needed
                
                // Clear preferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Database reset complete')),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.statusWarning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.statusWarning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.statusWarning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: AppTheme.statusWarning,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Reset Database (Long Press)",
                        style: TextStyle(
                          color: AppTheme.statusWarning,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppTheme.statusWarning,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Account",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.statusError.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.statusError.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.statusError.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: AppTheme.statusError,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.statusError,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppTheme.statusError,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: null,
              onLongPress: () async {
                // Reset cart
                Provider.of<AppStateProvider>(context, listen: false).clearCart();

                // Reset stock (if stored locally)
                await Provider.of<AppStateProvider>(context, listen: false).resetStock();

                // Clear preferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Database reset complete')),
                  );
                }
              },
              child: const Text('Developer Reset (Long Press)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha((0.05 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withAlpha((0.1 * 255).toInt()),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha((0.2 * 255).toInt()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.6 * 255).toInt(),
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.iconTheme.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: theme.dividerColor),
          ],
        ),
      ),
    );
  }
}
