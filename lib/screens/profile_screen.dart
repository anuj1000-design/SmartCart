import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../services/auth_service.dart';
import '../widgets/ui_components.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';
import 'payment_methods_screen.dart';
import 'shipping_address_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ScreenFade(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                    backgroundImage: appState.userProfile.photoURL != null
                        ? NetworkImage(appState.userProfile.photoURL!)
                        : null,
                    child: appState.userProfile.photoURL == null
                        ? Text(
                            appState.userProfile.avatarEmoji,
                            style: const TextStyle(fontSize: 50),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => EditProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                appState.userProfile.name,
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                appState.userProfile.membershipTier,
                style: const TextStyle(color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                appState.userProfile.email,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 32),
              _buildProfileOption(context, Icons.history, "Order History", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => OrderHistoryScreen()),
                );
              }),
              _buildProfileOption(
                context,
                Icons.credit_card,
                "Payment Methods",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => PaymentMethodsScreen()),
                  );
                },
              ),
              _buildProfileOption(
                context,
                Icons.location_on_outlined,
                "Shipping Address",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => ShippingAddressScreen()),
                  );
                },
              ),
              _buildProfileOption(
                context,
                Icons.settings_outlined,
                "Settings",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Sign Out Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final authService = AuthService();
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.statusError),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppTheme.statusError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.statusError),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).iconTheme.color),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            const Spacer(),
            Icon(Icons.chevron_right, color: Theme.of(context).dividerColor),
          ],
        ),
      ),
    );
  }
}
