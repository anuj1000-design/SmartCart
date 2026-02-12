import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/barcode_scanner_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/store_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/spending_analytics_screen.dart';
import 'screens/budget_settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/report_bug_screen.dart';
import 'screens/loyalty_program_screen.dart';
import 'screens/analytics_dashboard_screen.dart';
import 'screens/multiple_addresses_screen.dart';
import 'screens/inventory_management_screen.dart';
import 'screens/support_tickets_screen.dart';
import 'providers/app_state_provider.dart';
import 'services/analytics_service.dart';
import 'services/push_notification_service.dart';
import 'utils/shake_detector.dart';
import 'widgets/suspension_guard.dart';

// Global navigator key for app-wide navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Slide transition for navigation
Route _createSlideTransition(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

// ---------------------------------------------------------------------------
// 🚀 MAIN APP
// ---------------------------------------------------------------------------

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      // Initialize Firebase using generated options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Set Firebase Auth language code
      FirebaseAuth.instance.setLanguageCode('en');

      // Enable Crashlytics
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      // Configure Firestore settings for consistent data sync across platforms
      final firestore = FirebaseFirestore.instance;

      // Enable offline persistence for mobile/desktop (not available on web)
      try {
        if (!kIsWeb) {
          await firestore.disableNetwork();
          await firestore.enableNetwork();
        }
      } catch (e) {
        debugPrint('Network sync error: $e');
      }

      // Set cache size to 100MB for better performance
      firestore.settings = const Settings(
        cacheSizeBytes: 100 * 1024 * 1024, // 100MB cache
        persistenceEnabled: !kIsWeb, // Only for mobile
      );

      // Initialize analytics and crash monitoring
      await AnalyticsService().initialize();

      // Initialize push notifications
      await PushNotificationService().initialize();
    } catch (e) {
      debugPrint('Initialization error: $e');
    }

    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    runApp(const SmartCartApp());
  }, (error, stack) {
    // Catch any uncaught errors in the zone
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class SmartCartApp extends StatefulWidget {
  const SmartCartApp({super.key});

  @override
  State<SmartCartApp> createState() => _SmartCartAppState();
}

class _SmartCartAppState extends State<SmartCartApp> {
  bool _onboardingCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    setState(() {
      _onboardingCompleted = completed;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          backgroundColor: AppTheme.darkBg,
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
        ),
      );
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return ChangeNotifierProvider(
      create: (_) {
        final appState = AppStateProvider();
        appState.loadThemePreference();
        appState.loadProductsFromFirestore();
        appState.loadAddressesFromFirestore();
        appState.loadProfileFromFirestore();
        appState.loadPaymentMethodsFromFirestore();
        appState.loadOrdersFromFirestore();

        return appState;
      },
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'SmartCart',
            debugShowCheckedModeBanner: false,
            theme: appState.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            builder: (context, child) {
              return ShakeListener(
                onShake: () {
                  // Simply push the screen. The debounce in ShakeListener prevents spamming.
                  // Checking route name here is unreliable without a RouteObserver.
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(builder: (_) => const ReportBugScreen()),
                  );
                },
                child: child!,
              );
            },
            home: _onboardingCompleted
            ? StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  // If stream is still waiting and we have no data, show loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // But check if user is already cached locally
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      // User exists locally, go to home immediately
                      return const RoleBasedHome();
                    }
                    // Still waiting and no local user, show loading
                    return Scaffold(
                      backgroundColor: AppTheme.darkBg,
                      body: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      ),
                    );
                  }

                  // Stream completed
                  if (snapshot.hasData) {
                    return const RoleBasedHome();
                  }

                  // No user
                  return const LoginScreen();
                },
              )
            : const OnboardingScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const RoleBasedHome(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/store': (context) => const StoreScreen(),
          '/analytics': (context) => const SpendingAnalyticsScreen(),
          '/budget-settings': (context) => const BudgetSettingsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/loyalty-program': (context) => const LoyaltyProgramScreen(),
          '/analytics-dashboard': (context) => const AnalyticsDashboardScreen(),
          '/multiple-addresses': (context) => const MultipleAddressesScreen(),
          '/inventory-management': (context) => const InventoryManagementScreen(),
          '/support-tickets': (context) => const SupportTicketsScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return _createSlideTransition(const LoginScreen(), settings);
            case '/signup':
              return _createSlideTransition(const SignUpScreen(), settings);
            case '/forgot-password':
              return _createSlideTransition(
                const ForgotPasswordScreen(),
                settings,
              );
            case '/home':
              return _createSlideTransition(const RoleBasedHome(), settings);
            case '/onboarding':
              return _createSlideTransition(const OnboardingScreen(), settings);
            case '/store':
              return _createSlideTransition(const StoreScreen(), settings);
            case '/analytics':
              return _createSlideTransition(
                const SpendingAnalyticsScreen(),
                settings,
              );
            case '/budget-settings':
              return _createSlideTransition(
                const BudgetSettingsScreen(),
                settings,
              );
            case '/notifications':
              return _createSlideTransition(
                const NotificationsScreen(),
                settings,
              );
            case '/loyalty-program':
              return _createSlideTransition(
                const LoyaltyProgramScreen(),
                settings,
              );
            case '/analytics-dashboard':
              return _createSlideTransition(
                const AnalyticsDashboardScreen(),
                settings,
              );
            case '/multiple-addresses':
              return _createSlideTransition(
                const MultipleAddressesScreen(),
                settings,
              );
            case '/inventory-management':
              return _createSlideTransition(
                const InventoryManagementScreen(),
                settings,
              );
            case '/support-tickets':
              return _createSlideTransition(
                const SupportTicketsScreen(),
                settings,
              );
            default:
              return null;
          }
        },
        );
        },
      ),
    );
  }
}

// Dark Theme applied globally in MaterialApp

// ---------------------------------------------------------------------------
// 🎭 ROLE BASED HOME
// ---------------------------------------------------------------------------

class RoleBasedHome extends StatefulWidget {
  const RoleBasedHome({super.key});

  @override
  State<RoleBasedHome> createState() => _RoleBasedHomeState();
}

class _RoleBasedHomeState extends State<RoleBasedHome> {
  @override
  void initState() {
    super.initState();
    // Load user profile after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AppStateProvider>(
          context,
          listen: false,
        ).loadUserFromAuth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always return customer interface wrapped with suspension check
    return const SuspensionGuard(
      child: MainScaffold(),
    );
  }
}

// ---------------------------------------------------------------------------
// 📱 MAIN SCAFFOLD & NAVIGATION
// ---------------------------------------------------------------------------

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  bool _isScanning = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StoreScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load user data from Firebase Auth after the build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().loadUserFromAuth();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Clear search when switching to home screen
    if (index == 0) {
      context.read<AppStateProvider>().setSearchQuery('');
      context.read<AppStateProvider>().setSelectedCategory('All');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    return Scaffold(
      extendBody: true, // Content behind nav bar
      body: IndexedStack(index: _selectedIndex, children: _screens),

      // SCANNER BUTTON
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: _isScanning
              ? null
              : () async {
                  setState(() => _isScanning = true);
                  try {
                    // Open real camera scanner
                    // The scanner handles product lookup and cart addition
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const BarcodeScannerScreen(),
                      ),
                    );
                  } catch (e) {
                    if (mounted) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Scanning failed: $e'),
                            backgroundColor: AppTheme.statusError,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isScanning = false);
                    }
                  }
                },
          backgroundColor: _isScanning ? AppTheme.textMuted : AppTheme.primary,
          shape: const CircleBorder(),
          elevation: 12,
          child: _isScanning
              ? const CircularProgressIndicator(color: AppTheme.textPrimary)
              : const Icon(
                  Icons.qr_code_scanner,
                  color: AppTheme.textPrimary,
                  size: 30,
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: BottomAppBar(
          color: AppTheme.darkCard.withValues(alpha: 0.95),
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(Icons.home_rounded, 0, "Home"),
              _buildNavIcon(Icons.storefront_rounded, 1, "Store"),
              const SizedBox(width: 48), // Gap for scanner
              _buildNavIcon(
                Icons.shopping_bag_outlined,
                2,
                "Cart",
                badge: appState.cartCount > 0 ? "${appState.cartCount}" : null,
                subtitle: appState.cartCount > 0
                    ? "₹${(appState.cartTotal / 100).toStringAsFixed(2)}"
                    : null,
              ),
              _buildNavIcon(Icons.person_outline_rounded, 3, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(
    IconData icon,
    int index,
    String label, {
    String? badge,
    String? subtitle,
  }) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64, // increased slightly to avoid clipping on some devices
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                    color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                    fontSize: 9,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.primary.withValues(alpha: 0.7)
                            : AppTheme.textMuted.withValues(alpha: 0.7),
                        fontSize: 7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
            if (badge != null)
              Positioned(
                right: -6,
                top: -3,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppTheme.statusError,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 🏠 HOME SCREEN
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// 🛒 CART SCREEN
// ---------------------------------------------------------------------------

// ------------------- PROFILE SUBSCREENS -------------------
