import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../providers/mohallah_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/helpers.dart';

class MohallahBookingsScreen extends StatefulWidget {
  const MohallahBookingsScreen({super.key});

  @override
  State<MohallahBookingsScreen> createState() => _MohallahBookingsScreenState();
}

class _MohallahBookingsScreenState extends State<MohallahBookingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final mohallahProvider = context.read<MohallahProvider>();
    final bookingProvider = context.read<BookingProvider>();

    if (mohallahProvider.selectedMohallah != null) {
      await bookingProvider.loadBookingsByMohallah(
        mohallahProvider.selectedMohallah!.name,
      );
    }
  }

  Future<void> _handleDeleteBooking(String bookingId) async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Delete Booking',
      message: 'Are you sure you want to delete this booking?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirm) return;

    final bookingProvider = context.read<BookingProvider>();
    final result = await bookingProvider.deleteBookingAdmin(bookingId);

    if (mounted) {
      Helpers.showSnackBar(
        context,
        result.message,
        isError: !result.success,
      );
      
      if (result.success) {
        _loadBookings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    
    // Sort bookings: upcoming first (ascending), then past (descending)
    final now = DateTime.now();
    final sortedBookings = List.of(bookingProvider.bookings);
    sortedBookings.sort((a, b) {
      final aDate = a.dateTime;
      final bDate = b.dateTime;
      final aIsUpcoming = aDate.isAfter(now.subtract(const Duration(days: 1)));
      final bIsUpcoming = bDate.isAfter(now.subtract(const Duration(days: 1)));
      
      if (aIsUpcoming && !bIsUpcoming) return -1;
      if (!aIsUpcoming && bIsUpcoming) return 1;
      if (aIsUpcoming && bIsUpcoming) return aDate.compareTo(bDate); // Ascending
      return bDate.compareTo(aDate); // Past: descending
    });

    return Scaffold(
      appBar: const CustomAppBar(title: 'Mohallah Bookings'),
      backgroundColor: AppColors.creamBackground,
      body: LoadingOverlay(
        isLoading: bookingProvider.isLoading,
        child: RefreshIndicator(
          onRefresh: _loadBookings,
          color: AppColors.darkBrown,
          child: sortedBookings.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: sortedBookings.length,
                  itemBuilder: (context, index) {
                    final booking = sortedBookings[index];
                    return BookingCard(
                      booking: booking,
                      showUserInfo: true,
                      onDelete: () => _handleDeleteBooking(booking.id),
                    );
                  },
                ),
        ),
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
                'Bookings from your Mohallah will appear here',
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