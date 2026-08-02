import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/glass_card.dart';
import 'core/services/kids_providers.dart';
import 'core/models/kids_models.dart';
import 'features/auth/auth_screen.dart';
import 'features/child_dashboard/child_dashboard_screen.dart';
import 'features/parent_dashboard/parent_dashboard_screen.dart';
import 'features/learning_path/learning_path_screen.dart';
import 'features/mini_games/mini_games_screen.dart';
import 'features/shop/shop_screen.dart';
import 'features/avatar_builder/avatar_builder_screen.dart';
import 'features/pet_system/pet_system_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/achievements/achievements_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/premium/premium_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/admin_dashboard/admin_dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/voice_service.dart';
import 'core/services/storage_service.dart';

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCmRWb2iyqll-RMz969lAtpLm6jA-XpNDE",
          authDomain: "ai-cids.firebaseapp.com",
          projectId: "ai-cids",
          storageBucket: "ai-cids.firebasestorage.app",
          messagingSenderId: "301520519620",
          appId: "1:301520519620:web:6fe84e409ba0df3edc6491",
          measurementId: "G-1TJHFSZ0Q9",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase initialization skipped or failed: $e");
  }

  await StorageService.init();
  await VoiceService.init();
  runApp(const ProviderScope(child: KidsGeniusApp()));
}

class KidsGeniusApp extends ConsumerWidget {
  const KidsGeniusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'Kids Genius - Premium Learning Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const RootNavigationWrapper(),
    );
  }
}

class RootNavigationWrapper extends ConsumerStatefulWidget {
  const RootNavigationWrapper({super.key});

  @override
  ConsumerState<RootNavigationWrapper> createState() =>
      _RootNavigationWrapperState();
}

class _RootNavigationWrapperState
    extends ConsumerState<RootNavigationWrapper> {
  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _initializeAppState();
  }

  Future<void> _initializeAppState() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await StorageService.fetchFromCloud(user.uid);
      if (profile != null) {
        ref.read(userProfileProvider.notifier).setUser(profile);
        setState(() {
          _isLoggedIn = true;
        });
      }
    }
    setState(() {
      _isCheckingAuth = false;
    });
  }

  final List<Widget> _screens = [
    const ChildDashboardScreen(),   // Tab 0
    const LearningPathScreen(),     // Tab 1
    const MiniGamesScreen(),        // Tab 2
    const PetSystemScreen(),        // Tab 3
    const ShopScreen(),             // Tab 4
    const AvatarBuilderScreen(),    // Tab 5
    const LeaderboardScreen(),      // Tab 6
    const ParentDashboardScreen(),  // Tab 7
    const AchievementsScreen(),     // Tab 8
    const ProfileScreen(),          // Tab 9
    const PremiumScreen(),          // Tab 10
    const SettingsScreen(),         // Tab 11
    const AdminDashboardScreen(),   // Tab 12
  ];

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_isFirstLaunch) {
      return OnboardingScreen(
        onFinished: () => setState(() {
          _isFirstLaunch = false;
        }),
      );
    }

    if (!_isLoggedIn) {
      return AuthScreen(
        onLoginSuccess: () {
          setState(() {
            _isLoggedIn = true;
          });
        },
      );
    }

    final selectedTab = ref.watch(selectedTabProvider);
    final user = ref.watch(userProfileProvider);
    final isDark = ref.watch(isDarkModeProvider);

    // Dynamic Bottom Nav based on role
    List<Widget> navItems = [
      _buildNavItem(0, CupertinoIcons.house_fill, 'Home'),
      _buildNavItem(1, CupertinoIcons.map_fill, 'Path'),
      _buildNavItem(2, CupertinoIcons.gamecontroller_fill, 'Play'),
      _buildNavItem(3, CupertinoIcons.heart_fill, 'Pet'),
      _buildNavItem(4, CupertinoIcons.bag_fill, 'Shop'),
    ];

    if (user.role == UserRole.parent) {
      navItems.add(_buildNavItem(7, CupertinoIcons.chart_bar_square_fill, 'Report'));
    } else if (user.role == UserRole.admin) {
      navItems.add(_buildNavItem(12, CupertinoIcons.shield_fill, 'Admin'));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false, // Unified alignment
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🦁 ', style: TextStyle(fontSize: 24)),
            Text('Kids Genius',
                style: TextStyle(
                    fontFamily: 'Baloo2',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.gear_alt_fill),
            onPressed: () {
              ref.read(selectedTabProvider.notifier).state = 11; // Settings
            },
          ),
          IconButton(
            icon: Icon(user.role == UserRole.parent
                ? CupertinoIcons.person_2_fill
                : user.role == UserRole.admin 
                  ? CupertinoIcons.shield_fill
                  : CupertinoIcons.person_crop_circle),
            onPressed: () {
              ref.read(selectedTabProvider.notifier).state = 9; // Profile
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[selectedTab.clamp(0, _screens.length - 1)],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80, // Fixed height for consistency
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            borderRadius: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: navItems,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        ref.read(selectedTabProvider.notifier).state = index;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
