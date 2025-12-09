import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/helpers.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  final _databaseService = DatabaseService();
  Map<String, int> _attendanceCounts = {};

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
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

  Future<void> _handleCancelBooking(String bookingId) async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Cancel Booking',
      message: 'Are you sure you want to cancel this booking?',
      confirmText: 'Cancel Booking',
      isDestructive: true,
    );

    if (!confirm) return;

    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    final result = await bookingProvider.deleteBooking(
      bookingId,
      authProvider.currentUser!.its,
    );

    if (mounted) {
      Helpers.showSnackBar(
        context,
        result.message,
        isError: !result.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'My Bookings'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
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
              onRefresh: _loadBookings,
              color: AppColors.darkBrown,
              child: bookingProvider.userBookings.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: bookingProvider.userBookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookingProvider.userBookings[index];
                        final attendanceCount = _attendanceCounts[booking.date];
                        return BookingCard(
                          booking: booking,
                          onDelete: () => _handleCancelBooking(booking.id),
                          expectedAttendance: attendanceCount,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.lightBrown.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.calendar,
                  size: 64,
                  color: AppColors.lightBrown,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Bookings Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your booked slots will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
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