import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../config/constants.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isSubAdmin => _currentUser?.isSubAdmin ?? false;
  bool get isUser => _currentUser?.isUser ?? false;

  AuthProvider() {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final authUser = _authService.currentAuthUser;
      if (authUser != null) {
        final its = _authService.getCurrentUserIts();
        if (its != null) {
          _currentUser = await _authService.getUserByIts(its);
          if (_currentUser != null) {
            _status = AuthStatus.authenticated;
          } else {
            _status = AuthStatus.unauthenticated;
          }
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String itsNumber, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(itsNumber, password);
      print('DEBUG AUTH: currentUser=$_currentUser, role=${_currentUser?.role}');
      if (_currentUser != null) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'User data not found';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String itsNumber, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.createAuthUser(itsNumber, password);
      // After signup, try to sign in immediately
      return await signIn(itsNumber, password);
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> resetPassword(String itsNumber) async {
    try {
      await _authService.resetPassword(itsNumber);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      await _authService.updatePassword(newPassword);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  String getDashboardRoute() {
    if (_currentUser == null) return '/login';
    
    switch (_currentUser!.role) {
      case UserRoles.admin:
        return '/admin/dashboard';
      case UserRoles.subadmin:
        return '/subadmin/dashboard';
      default:
        return '/user/dashboard';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}