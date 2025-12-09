import 'package:flutter/material.dart';

// Common Screens
import '../screens/common/splash_screen.dart';
import '../screens/common/login_screen.dart';
import '../screens/common/forgot_password_screen.dart';
import '../screens/common/change_password_screen.dart';
import '../screens/common/profile_screen.dart';

// User Screens
import '../screens/user/user_dashboard.dart';
import '../screens/user/calendar_screen.dart';
import '../screens/user/booking_screen.dart';
import '../screens/user/my_booking_screen.dart';
import '../screens/user/contact_us_screen.dart';

// SubAdmin Screens
import '../screens/subadmin/subadmin_dashboard.dart';
import '../screens/subadmin/add_member_screen.dart';
import '../screens/subadmin/member_list_screen.dart';
import '../screens/subadmin/mohallah_bookings_screen.dart';
import '../screens/subadmin/book_for_member_screen.dart';
import '../screens/subadmin/manage_attendance_screen.dart';
import '../screens/subadmin/booking_settings_screen.dart';

// Admin Screens
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/upload_csv_screen.dart';
import '../screens/admin/manage_mohallahs_screen.dart';
import '../screens/admin/manage_members_screen.dart';
import '../screens/admin/all_bookings_screen.dart';

class AppRoutes {
  // Common Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';
  static const String profile = '/profile';
  
  // User Routes
  static const String userDashboard = '/user/dashboard';
  static const String calendar = '/user/calendar';
  static const String booking = '/user/booking';
  static const String myBooking = '/user/my-booking';
  static const String contactUs = '/user/contact-us';
  
  // SubAdmin Routes
  static const String subadminDashboard = '/subadmin/dashboard';
  static const String addMember = '/subadmin/add-member';
  static const String memberList = '/subadmin/member-list';
  static const String mohallahBookings = '/subadmin/bookings';
  static const String bookForMember = '/subadmin/book-for-member';
  static const String manageAttendance = '/subadmin/manage-attendance';
  static const String bookingSettings = '/subadmin/booking-settings';
  
  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String uploadCSV = '/admin/upload-csv';
  static const String manageMohallahs = '/admin/mohallahs';
  static const String manageMembers = '/admin/members';
  static const String allBookings = '/admin/bookings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Common Routes
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case login:
        return _buildRoute(const LoginScreen(), settings);
      // case forgotPassword:
        // return _buildRoute(const ForgotPasswordScreen(), settings);
      case changePassword:
        return _buildRoute(const ChangePasswordScreen(), settings);
      case profile:
        return _buildRoute(const ProfileScreen(), settings);
      
      // User Routes
      case userDashboard:
        return _buildRoute(const UserDashboard(), settings);
      case calendar:
        return _buildRoute(const CalendarScreen(), settings);
      case booking:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(BookingScreen(selectedDate: args?['date']), settings);
      case myBooking:
        return _buildRoute(const MyBookingScreen(), settings);
      case contactUs:
        return _buildRoute(const ContactUsScreen(), settings);
      
      // SubAdmin Routes
      case subadminDashboard:
        return _buildRoute(const SubAdminDashboard(), settings);
      case addMember:
        return _buildRoute(const AddMemberScreen(), settings);
      case memberList:
        return _buildRoute(const MemberListScreen(), settings);
      case mohallahBookings:
        return _buildRoute(const MohallahBookingsScreen(), settings);
      case bookForMember:
        return _buildRoute(const BookForMemberScreen(), settings);
      case manageAttendance:
        return _buildRoute(const ManageAttendanceScreen(), settings);
      case bookingSettings:
        return _buildRoute(const BookingSettingsScreen(), settings);
      
      // Admin Routes
      case adminDashboard:
        return _buildRoute(const AdminDashboard(), settings);
      case uploadCSV:
        return _buildRoute(const UploadCSVScreen(), settings);
      case manageMohallahs:
        return _buildRoute(const ManageMohallahsScreen(), settings);
      case manageMembers:
        return _buildRoute(const ManageMembersScreen(), settings);
      case allBookings:
        return _buildRoute(const AllBookingsScreen(), settings);
      
      default:
        return _buildRoute(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}