import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/bouncy_button.dart';
import '../../core/models/kids_models.dart';
import '../../core/services/kids_providers.dart';
import '../../core/services/voice_service.dart';
import '../../core/services/storage_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  UserRole _selectedRole = UserRole.kid;
  final TextEditingController _nameController = TextEditingController(text: 'Leo Explorer');
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _isPhoneLoginMode = false;
  bool _otpSent = false;
  String? _verificationId;
  bool _isLoading = false;
  ConfirmationResult? _webConfirmationResult;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? "442697787118-83m13ohkll2980cdec3158u6fh63ptp3.apps.googleusercontent.com" : null,
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          var profile = await StorageService.fetchFromCloud(firebaseUser.uid);
          if (profile == null) {
            profile = UserProfileModel(
              uid: firebaseUser.uid,
              name: googleUser.displayName ?? 'Hero',
              role: _selectedRole,
              coins: 300, // Extra bonus for Google users!
              xp: 0,
              level: 1,
              streakDays: 1,
              activeAvatarHat: '👑',
              activeAvatarOutfit: '🚀',
              activePetName: 'New Friend',
              activePetEmoji: '🥚',
              profilePic: googleUser.photoUrl ?? '🦁',
              isPremium: false,
            );
            await StorageService.syncToCloud(profile);
          }
          
          ref.read(userProfileProvider.notifier).setUser(profile);
          VoiceService.speak("Google orqali xush kelibsiz!");
          widget.onLoginSuccess();
        }
      }
    } catch (e) {
      _showError("Google login failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loginAsGuest() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        // Check if profile exists, if not create one
        var profile = await StorageService.fetchFromCloud(firebaseUser.uid);
        if (profile == null) {
          profile = UserProfileModel(
            uid: firebaseUser.uid,
            name: 'Guest Hero',
            role: _selectedRole,
            coins: 100,
            xp: 0,
            level: 1,
            streakDays: 1,
            activeAvatarHat: '👑',
            activeAvatarOutfit: '🚀',
            activePetName: 'New Friend',
            activePetEmoji: '🥚',
            profilePic: '🦁',
            isPremium: false,
          );
          await StorageService.syncToCloud(profile);
        }
        
        // IMPORTANT: Set the loaded profile to the global provider!
        ref.read(userProfileProvider.notifier).setUser(profile);
        VoiceService.speak("Xush kelibsiz! Kids Genius-ga marhamat!");
        widget.onLoginSuccess();
      }
    } catch (e) {
      _showError("Guest login failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sendOtp() async {
    String phoneNumber = _phoneController.text.trim().replaceAll(' ', '');
    if (phoneNumber.isEmpty) {
      _showError("Telefon raqamini kiriting");
      return;
    }

    // Auto-prepend +998 if missing
    if (!phoneNumber.startsWith('+')) {
      if (phoneNumber.startsWith('998')) {
        phoneNumber = '+$phoneNumber';
      } else {
        phoneNumber = '+998$phoneNumber';
      }
    }

    setState(() => _isLoading = true);
    
    try {
      if (kIsWeb) {
        // Fallback for Web if region is blocked but test number is used
        try {
          final confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(phoneNumber);
          setState(() {
            _otpSent = true;
            _verificationId = confirmationResult.verificationId;
            _webConfirmationResult = confirmationResult;
            _isLoading = false;
          });
        } catch (webError) {
          // If it's a known test number, we can manually force the OTP screen
          if (phoneNumber.contains('904401823')) {
             setState(() {
              _otpSent = true;
              _isLoading = false;
            });
            VoiceService.speak("Test rejimi: Kodni kiriting (123456)");
          } else {
            rethrow;
          }
        }
        VoiceService.speak("Tasdiqlash kodi yuborildi");
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
            _onAuthSuccess();
          },
          verificationFailed: (FirebaseAuthException e) {
            _showError(e.message ?? "Xatolik yuz berdi");
            setState(() => _isLoading = false);
          },
          codeSent: (String vid, int? resendToken) {
            setState(() {
              _otpSent = true;
              _verificationId = vid;
              _isLoading = false;
            });
            VoiceService.speak("Tasdiqlash kodi yuborildi");
          },
          codeAutoRetrievalTimeout: (String vid) {
            _verificationId = vid;
          },
        );
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('operation-not-allowed')) {
        _showError("SMS yuborish ruxsat etilmagan. Iltimos, Firebase-da 'Test raqam' qo'shing yoki 'Mehmon' bo'lib kiring.");
      } else {
        _showError("Xatolik: $e");
      }
      setState(() => _isLoading = false);
    }
  }

  void _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      _showError("Kodni kiriting");
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        if (_webConfirmationResult != null) {
          await _webConfirmationResult!.confirm(_otpController.text);
        } else if (_phoneController.text.contains('904401823') && _otpController.text == '123456') {
          // Manually pass for test number if Firebase rejected the request but logic matches
        } else {
          throw Exception("Verification failed");
        }
      } else {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: _otpController.text,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      _onAuthSuccess();
    } catch (e) {
      _showError("Kod noto'g'ri yoki amal qilish muddati tugagan");
      setState(() => _isLoading = false);
    }
  }

  void _onAuthSuccess() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      var profile = await StorageService.fetchFromCloud(firebaseUser.uid);
      if (profile == null) {
        // Create new profile if not exists
        profile = UserProfileModel(
          uid: firebaseUser.uid,
          name: 'Hero ${firebaseUser.phoneNumber?.substring(firebaseUser.phoneNumber!.length - 4) ?? "User"}',
          role: _selectedRole,
          coins: 200,
          xp: 0,
          level: 1,
          streakDays: 1,
          activeAvatarHat: '👑',
          activeAvatarOutfit: '🚀',
          activePetName: 'New Friend',
          activePetEmoji: '🥚',
          profilePic: '🦁',
          isPremium: false,
        );
        await StorageService.syncToCloud(profile);
      }
      
      // IMPORTANT: Update the global provider with the loaded profile!
      ref.read(userProfileProvider.notifier).setUser(profile);
      widget.onLoginSuccess();
      VoiceService.speakSuccess();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.bgDark, AppColors.cardDark]
                : [AppColors.primary.withOpacity(0.15), AppColors.bgLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 32),
                  
                  if (!_isPhoneLoginMode) _buildMainAuthCard(isDark)
                  else _buildPhoneAuthCard(isDark),
                  
                  if (_isLoading) 
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.heroGradient),
          child: const Center(child: Text('🦁', style: TextStyle(fontSize: 44))),
        ).animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 12),
        Text('Kids Genius', style: AppTypography.heading2(color: isDark ? Colors.white : AppColors.primary)),
      ],
    );
  }

  Widget _buildMainAuthCard(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Select Profile', style: AppTypography.heading3(color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildRoleTile(UserRole.kid, 'Kid 🚀', CupertinoIcons.person_fill),
              const SizedBox(width: 8),
              _buildRoleTile(UserRole.parent, 'Parent 🛡️', CupertinoIcons.person_2_fill),
              const SizedBox(width: 8),
              _buildRoleTile(UserRole.admin, 'Admin 👑', CupertinoIcons.shield_fill),
            ],
          ),
          const SizedBox(height: 24),
          BouncyButton(
            text: 'Enter as Guest 🌟',
            onTap: _loginAsGuest,
            gradientStart: AppColors.success,
            gradientEnd: Colors.green,
          ),
          const SizedBox(height: 12),
          BouncyButton(
            text: 'Continue with Google 🌐',
            onTap: _loginWithGoogle,
            gradientStart: Colors.white,
            gradientEnd: Colors.grey.shade200,
            textColor: Colors.black87,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _isPhoneLoginMode = true),
            child: Text('Login with Phone Number 📱', style: TextStyle(color: isDark ? Colors.white70 : AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneAuthCard(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _isPhoneLoginMode = false)),
              Text('Phone Login', style: AppTypography.heading3(color: isDark ? Colors.white : Colors.black)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _otpSent ? _otpController : _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: _otpSent ? 'Enter SMS Code' : 'Phone Number (+998...)',
              prefixIcon: Icon(_otpSent ? CupertinoIcons.lock_shield : CupertinoIcons.phone_fill),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          BouncyButton(
            text: _otpSent ? 'Verify & Enter ✨' : 'Send Code 📩',
            onTap: _otpSent ? _verifyOtp : _sendOtp,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTile(UserRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white12,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.accent : Colors.white24),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 20),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
