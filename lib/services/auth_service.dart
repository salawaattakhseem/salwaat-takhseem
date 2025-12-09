import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../config/constants.dart';
import '../models/user_model.dart';

class AuthService {
  // Sign in with ITS number
  Future<UserModel?> signIn(String itsNumber, String password) async {
    try {
      final email = '$itsNumber${AppConstants.emailDomain}';
      // User enters last 4 digits only, we add 'sw' prefix
      final authPassword = 'sw$password';
      print('=== LOGIN ATTEMPT ===');
      print('DEBUG LOGIN: email=$email, password=$authPassword');
      
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: authPassword,
      );
      
      print('DEBUG LOGIN SUCCESS: user=${response.user?.email}');
      
      if (response.user != null) {
        final user = await getUserByIts(itsNumber);
        print('DEBUG LOGIN: User from DB=${user?.fullName}');
        return user;
      }
      print('DEBUG LOGIN: No user in response');
      return null;
    } on AuthException catch (e) {
      print('DEBUG LOGIN ERROR (Auth): ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('DEBUG LOGIN ERROR: $e');
      throw Exception('An error occurred during sign in');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Get current user
  User? get currentAuthUser => supabase.auth.currentUser;

  // Get user data from users table
  Future<UserModel?> getUserByIts(String its) async {
    try {
      final response = await supabase
          .from(AppConstants.usersTable)
          .select()
          .eq('its', its)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get current user's ITS from email
  String? getCurrentUserIts() {
    final email = currentAuthUser?.email;
    if (email != null) {
      return email.replaceAll(AppConstants.emailDomain, '');
    }
    return null;
  }

  // Reset password (send reset email)
  Future<void> resetPassword(String itsNumber) async {
    try {
      final email = '$itsNumber${AppConstants.emailDomain}';
      await supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      // Also update password_last4 in users table
      final its = getCurrentUserIts();
      if (its != null) {
        await supabase
            .from(AppConstants.usersTable)
            .update({'password_last4': newPassword})
            .eq('its', its);
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Create auth user (for admin use or self-registration)
  Future<void> createAuthUser(String itsNumber, String password) async {
    try {
      final email = '$itsNumber${AppConstants.emailDomain}';
      
      // Try regular signup first (for self-registration)
      await supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      // If regular sign-up fails (e.g. user already exists or admin-only), rethrow
      throw Exception(e.toString());
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => currentAuthUser != null;

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
}