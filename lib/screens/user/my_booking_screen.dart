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
import '../../widgets/skeleton_widgets.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/helpers.dart';
import '../../utils/animation_utils.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> with SingleTickerProviderStateMixin {
  final _databaseService = DatabaseService();
  Map<String, int> _attendanceCounts = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    
    // Separate bookings into upcoming and completed
    final upcomingBookings = bookingProvider.userBookings
        .where((b) => b.isUpcoming)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime)); // Ascending
    
    final completedBookings = bookingProvider.userBookings
        .where((b) => b.isCompleted)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Descending (newest first)

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Bookings',
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.darkBrown,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.calendar_tick, size: 18),
                  const SizedBox(width: 6),
                  Text('Upcoming (${upcomingBookings.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.tick_circle, size: 18),
                  const SizedBox(width: 6),
                  Text('History (${completedBookings.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
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
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Tab
                RefreshIndicator(
                  onRefresh: _loadBookings,
                  color: AppColors.darkBrown,
                  child: bookingProvider.isLoading
                      ? ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: 5,
                          itemBuilder: (_, __) => const SkeletonBookingCard(),
                        )
                      : upcomingBookings.isEmpty
                          ? _buildEmptyState(isUpcoming: true)
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: upcomingBookings.length,
                              itemBuilder: (context, index) {
                                final booking = upcomingBookings[index];
                                final attendanceCount = _attendanceCounts[booking.date];
                                return StaggeredListAnimation(
                                  index: index,
                                  child: Dismissible(
                                    key: Key(booking.id),
                                    direction: DismissDirection.endToStart,
                                    // Require 60% swipe to dismiss (prevents accidental tab switch)
                                    dismissThresholds: const {
                                      DismissDirection.endToStart: 0.6,
                                    },
                                    confirmDismiss: (direction) async {
                                      // Show confirmation dialog
                                      return await Helpers.showConfirmationDialog(
                                        context,
                                        title: 'Cancel Booking?',
                                        message: 'Are you sure you want to cancel this booking?',
                                        confirmText: 'Yes, Cancel',
                                        isDestructive: true,
                                      );
                                    },
                                    onDismissed: (direction) {
                                      _handleCancelBooking(booking.id);
                                    },
                                    background: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.error,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 24),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Iconsax.trash,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: BookingCard(
                                      booking: booking,
                                      onDelete: () => _handleCancelBooking(booking.id),
                                      expectedAttendance: attendanceCount,
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                // History Tab
                RefreshIndicator(
                  onRefresh: _loadBookings,
                  color: AppColors.darkBrown,
                  child: completedBookings.isEmpty
                      ? _buildEmptyState(isUpcoming: false)
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: completedBookings.length,
                          itemBuilder: (context, index) {
                            final booking = completedBookings[index];
                            final attendanceCount = _attendanceCounts[booking.date];
                            return StaggeredListAnimation(
                              index: index,
                              child: BookingCard(
                                booking: booking,
                                showDeleteButton: false,
                                expectedAttendance: attendanceCount,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required bool isUpcoming}) {
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
                child: Icon(
                  isUpcoming ? Iconsax.calendar : Iconsax.tick_circle,
                  size: 64,
                  color: AppColors.lightBrown,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isUpcoming ? 'No Upcoming Bookings' : 'No Booking History',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isUpcoming 
                    ? 'Your upcoming bookings will appear here'
                    : 'Your completed bookings will appear here',
                style: const TextStyle(
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