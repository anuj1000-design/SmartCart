import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Welcome to SmartCart',
      'description':
          'Your smart shopping companion for effortless grocery shopping.',
      'emoji': '🛒',
    },
    {
      'title': 'Scan & Shop',
      'description':
          'Simply scan barcodes to add items to your cart instantly.',
      'emoji': '📱',
    },
    {
      'title': 'Easy Checkout',
      'description':
          'Secure payments and fast delivery right to your doorstep.',
      'emoji': '💳',
    },
    {
      'title': 'Get Started',
      'description': 'Join thousands of happy shoppers. Let\'s begin!',
      'emoji': '🚀',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: _OnboardingPage(data: _onboardingData[index]),
                      );
                    },
                  );
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppTheme.primary
                      : AppTheme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                const SizedBox(width: 60),
              ElevatedButton(
                onPressed: _currentPage == _onboardingData.length - 1
                    ? _completeOnboarding
                    : () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  _currentPage == _onboardingData.length - 1
                      ? 'Get Started'
                      : 'Next',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final Map<String, String> data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(data['emoji']!, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 40),
          Text(
            data['title']!,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data['description']!,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textTertiary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
