import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../database/database_service.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

/// Handles local authentication state.
class AuthProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _onboardingDone = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get onboardingDone => _onboardingDone;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    _onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
    if (_isLoggedIn) {
      final uid = prefs.getString(AppConstants.keyUserId);
      if (uid != null) _currentUser = _db.getUser(uid);
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    _onboardingDone = true;
    notifyListeners();
  }

  Future<String?> register(String name, String email, String password) async {
    // Check if email already exists
    final existing = _db.getUserByEmail(email);
    if (existing != null) return 'Email already registered';

    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      avatarColorIndex: DateTime.now().millisecond % 10,
    );
    await _db.saveUser(user);

    // Save password in settings (local-only demo)
    await _db.saveSetting('pwd_${user.id}', password);

    _currentUser = user;
    _isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserId, user.id);
    notifyListeners();
    return null; // success
  }

  Future<String?> login(String email, String password) async {
    final user = _db.getUserByEmail(email);
    if (user == null) return 'No account found with this email';

    final savedPwd = _db.getSetting('pwd_${user.id}');
    if (savedPwd != password) return 'Incorrect password';

    _currentUser = user;
    _isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserId, user.id);
    notifyListeners();
    return null;
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(name: name, phone: phone);
    await _db.saveUser(_currentUser!);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    await prefs.remove(AppConstants.keyUserId);
    notifyListeners();
  }
}
