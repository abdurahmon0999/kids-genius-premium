import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'core/widgets/connectivity_wrapper.dart';
import 'core/services/kids_providers.dart';
import 'core/models/kids_models.dart';
import 'core/services/voice_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/security_provider.dart';
import 'core/services/notification_service.dart';

import 'features/auth/auth_screen.dart';
import 'features/child_dashboard/child_dashboard_screen.dart';
import 'features/parent_dashboard/parent_dashboard_screen.dart';
import 'features/learning_path/learning_path_screen.dart';
import 'features/mini_games/mini_games_screen.dart';
import 'features/shop/shop_screen.dart';
import 'features/pet_system/pet_system_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/admin_dashboard/admin_dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/security/security_screen.dart';
import 'features/info/info_screen.dart';
import 'features/contact/contact_screen.dart';
import 'features/blog/blog_screen.dart';
import 'features/news/news_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  try {
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
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  await StorageService.init();
  await VoiceService.init();
  await NotificationService.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('uz'),
      child: const ProviderScope(child: KidsGeniusApp()),
    ),
  );
}

class KidsGeniusApp extends ConsumerWidget {
  const KidsGeniusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'Kids Genius',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const ConnectivityWrapper(child: RootNavigationWrapper()),
    );
  }
}

class RootNavigationWrapper extends ConsumerStatefulWidget {
  const RootNavigationWrapper({super.key});

  @override
  ConsumerState<RootNavigationWrapper> createState() => _RootNavigationWrapperState();
}

class _RootNavigationWrapperState extends ConsumerState<RootNavigationWrapper> {
  bool _isCheckingAuth = true;
  bool _isFirstLaunch = true;
  Stream<User?>? _authStateStream;

  @override
  void initState() {
    super.initState();
    _authStateStream = FirebaseAuth.instance.authStateChanges();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
      _isCheckingAuth = false;
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    final profile = await StorageService.fetchFromCloud(uid);
    if (profile != null) {
      ref.read(userProfileProvider.notifier).setUser(profile);
    }
  }

  final List<Widget> _screens = [
    const ChildDashboardScreen(),  // 0
    const LearningPathScreen(),    // 1
    const MiniGamesScreen(),       // 2
    const PetSystemScreen(),       // 3
    const ShopScreen(),            // 4
    const NewsScreen(),            // 5 (New)
    const BlogScreen(),            // 6 (New)
    const InfoScreen(),            // 7 (New)
    const ContactScreen(),         // 8 (New)
    const ProfileScreen(),         // 9
    const ParentDashboardScreen(), // 10
    const AdminDashboardScreen(),  // 11
    const SettingsScreen(),        // 12
    const LeaderboardScreen(),     // 13
  ];

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    if (_isCheckingAuth) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_isFirstLaunch) return OnboardingScreen(onFinished: () => setState(() => _isFirstLaunch = false));

    return StreamBuilder<User?>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          // Force security lock on logout
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(securityProvider.notifier).forceLock();
          });
          return AuthScreen(onLoginSuccess: () {});
        }

        // Only load if current profile UID is different or empty
        final currentProfile = ref.read(userProfileProvider);
        if (currentProfile.uid != user.uid) {
          _loadUserProfile(user.uid);
        }

        if (securityState.isAppLocked) return const SecurityScreen();

        final selectedTab = ref.watch(selectedTabProvider);
        final userProfile = ref.watch(userProfileProvider);
        final isDark = ref.watch(isDarkModeProvider);
        final isPageLoading = ref.watch(isPageLoadingProvider);
        final navigateTo = ref.read(navigationHelperProvider);

        return Scaffold(
          appBar: AppBar(
            title: Text('app_name'.tr(), style: TextStyle(fontFamily: 'Baloo2', color: isDark ? Colors.white : AppColors.primary)),
            actions: [
              IconButton(icon: const Icon(CupertinoIcons.info_circle), onPressed: () => navigateTo(7)),
              IconButton(icon: const Icon(CupertinoIcons.gear_alt_fill), onPressed: () => navigateTo(12)),
              IconButton(icon: const Icon(CupertinoIcons.person_crop_circle), onPressed: () => navigateTo(9)),
            ],
          ),
          body: Stack(
            children: [
              _screens[selectedTab.clamp(0, _screens.length - 1)],
              if (isPageLoading) _buildLoadingOverlay(isDark),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(ref, userProfile),
        );
      },
    );
  }

  Widget _buildLoadingOverlay(bool isDark) {
    return Container(
      color: isDark ? Colors.black54 : Colors.white70,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 6),
            const SizedBox(height: 20),
            Text(
              'loading'.tr(),
              style: AppTypography.heading3(color: isDark ? Colors.white : AppColors.primary),
            ).animate().fadeIn().scale(),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildBottomNav(WidgetRef ref, UserProfileModel user) {
    List<int> tabs = [0, 1, 2, 3, 4];
    if (user.role == UserRole.parent) tabs.add(10);
    if (user.role == UserRole.admin) tabs.add(11);

    return Container(
      height: 70,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.map((index) => _buildNavItem(index, ref)).toList(),
      ),
    );
  }

  Widget _buildNavItem(int index, WidgetRef ref) {
    final selected = ref.watch(selectedTabProvider) == index;
    final icons = {
      0: CupertinoIcons.house_fill,
      1: CupertinoIcons.map_fill,
      2: CupertinoIcons.gamecontroller_fill,
      3: CupertinoIcons.heart_fill,
      4: CupertinoIcons.bag_fill,
      10: CupertinoIcons.chart_bar_square_fill,
      11: CupertinoIcons.shield_fill,
    };

    return IconButton(
      icon: Icon(icons[index], color: selected ? AppColors.accent : Colors.white70),
      onPressed: () => ref.read(navigationHelperProvider)(index),
    );
  }
}
