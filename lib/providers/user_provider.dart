import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../config/constants.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all users
  Future<void> loadAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _databaseService.getAllUsers();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load users';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load users by mohallah
  Future<void> loadUsersByMohallah(String mohallah) async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _databaseService.getUsersByMohallah(mohallah);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load users';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create user
  Future<bool> createUser({
    required String its,
    required String fullName,
    required String mobile,
    required String mohallah,
    String role = UserRoles.user,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user already exists
      if (await _databaseService.userExists(its)) {
        _errorMessage = 'ITS number already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get last 4 digits and add prefix for 6-char minimum
      final passwordLast4 = its.substring(its.length - 4);
      final password = 'sw$passwordLast4';
      print('DEBUG: Creating user - ITS: $its, Password: $password, Length: ${password.length}');

      // Create auth user
      await _authService.createAuthUser(its, password);

      // Create user in database
      final user = UserModel(
        its: its,
        fullName: fullName,
        mobile: mobile,
        mohallah: mohallah,
        role: role,
        passwordLast4: passwordLast4,
        createdAt: DateTime.now(),
      );

      await _databaseService.createUser(user);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create user: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(String its, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateUser(its, data);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String its) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteUser(its);
      _users.removeWhere((u) => u.its == its);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Search users
  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return _users;
    
    final lowerQuery = query.toLowerCase();
    return _users.where((user) {
      return user.fullName.toLowerCase().contains(lowerQuery) ||
          user.its.contains(lowerQuery) ||
          user.mobile.contains(lowerQuery);
    }).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}