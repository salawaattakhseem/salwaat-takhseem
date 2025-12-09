import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/date_header_widget.dart';
import '../../utils/helpers.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final _databaseService = DatabaseService();
  Map<String, int> _attendanceCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();
    
    if (authProvider.currentUser != null) {
      await bookingProvider.loadUserBookings(authProvider.currentUser!.its);
      
      // Fetch attendance counts for user's booking dates
      if (bookingProvider.userBookings.isNotEmpty) {
        final mohallah = authProvider.currentUser!.mohallah;
        final dates = bookingProvider.userBookings.map((b) => b.date).toList();
        _attendanceCounts = await _databaseService.getAttendanceForDates(mohallah, dates);
        if (mounted) setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: DashboardAppBar(
        title: 'Salaam, ${user.fullName.split(' ').first}',
        subtitle: user.mohallah,
        onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image - full screen
          Image.asset(
            'img/Fatemi_Design.png',
            fit: BoxFit.cover,
          ),
          // Light blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          // Content
          LoadingOverlay(
            isLoading: bookingProvider.isLoading,
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.darkBrown,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Date Header - Gregorian and Hijri
                const DateHeaderWidget(),
                
                const SizedBox(height: 20),
                
                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        icon: Iconsax.calendar_add,
                        title: 'Book Slot',
                        subtitle: 'Select date',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.calendar),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        icon: Iconsax.ticket,
                        title: 'My Bookings',
                        subtitle: '${bookingProvider.userBookings.length} active',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.myBooking),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Contact Us Button
                InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.contactUs),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.darkBrown,
                          AppColors.mediumBrown,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBrown.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Iconsax.headphone, size: 20, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Need Help? Contact Us',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Iconsax.arrow_right_3, size: 18, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 28),
                
                // Upcoming Bookings Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (bookingProvider.userBookings.isNotEmpty)
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.myBooking),
                        child: const Text('View All'),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                if (bookingProvider.userBookings.isEmpty)
                  _buildEmptyState()
                else
                  ...bookingProvider.userBookings.take(3).map(
                    (booking) => BookingCard(
                      booking: booking,
                      showDeleteButton: false,
                      expectedAttendance: _attendanceCounts[booking.date],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.darkBrown.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightBrown.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.darkBrown, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: AppColors.softBeige,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Iconsax.calendar,
                size: 48,
                color: AppColors.textLight.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No bookings yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap "Book Slot" to make your first booking',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}