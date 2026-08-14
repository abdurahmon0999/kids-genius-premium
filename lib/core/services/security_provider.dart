import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class SecurityState {
  final bool isPinSet;
  final bool isBiometricsEnabled;
  final bool isAppLocked;

  SecurityState({
    this.isPinSet = false,
    this.isBiometricsEnabled = false,
    this.isAppLocked = true,
  });

  SecurityState copyWith({
    bool? isPinSet,
    bool? isBiometricsEnabled,
    bool? isAppLocked,
  }) {
    return SecurityState(
      isPinSet: isPinSet ?? this.isPinSet,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      isAppLocked: isAppLocked ?? this.isAppLocked,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  static const String _pinKey = 'auth_pin_code';
  static const String _bioKey = 'auth_bio_enabled';
  final LocalAuthentication _auth = LocalAuthentication();

  SecurityNotifier() : super(SecurityState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(_pinKey);
    final bio = prefs.getBool(_bioKey) ?? false;
    
    state = state.copyWith(
      isPinSet: pin != null && pin.isNotEmpty,
      isBiometricsEnabled: bio,
      isAppLocked: pin != null && pin.isNotEmpty, // Lock if PIN is set
    );
  }

  void forceLock() {
    if (state.isPinSet) {
      state = state.copyWith(isAppLocked: true);
    }
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    state = state.copyWith(isPinSet: true, isAppLocked: false);
  }

  Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.remove(_bioKey);
    state = state.copyWith(isPinSet: false, isBiometricsEnabled: false, isAppLocked: false);
  }

  Future<bool> verifyPin(String enteredPin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_pinKey);
    if (savedPin == enteredPin) {
      state = state.copyWith(isAppLocked: false);
      return true;
    }
    return false;
  }

  Future<void> toggleBiometrics(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bioKey, enabled);
    state = state.copyWith(isBiometricsEnabled: enabled);
  }

  Future<bool> authenticateBiometrically() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (canAuthenticate && state.isBiometricsEnabled) {
        final bool didAuthenticate = await _auth.authenticate(
          localizedReason: 'Please authenticate to unlock Kids Genius',
          options: const AuthenticationOptions(stickyAuth: true),
        );
        if (didAuthenticate) {
          state = state.copyWith(isAppLocked: false);
        }
        return didAuthenticate;
      }
    } catch (e) {
      print("Biometric Auth Error: $e");
    }
    return false;
  }

  void lockApp() {
    if (state.isPinSet) {
      state = state.copyWith(isAppLocked: true);
    }
  }

  void resetLock() {
    state = state.copyWith(isAppLocked: state.isPinSet);
  }
}

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier();
});
