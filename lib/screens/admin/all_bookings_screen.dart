import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/mohallah_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/admin_background.dart';
import '../../utils/helpers.dart';

class AllBookingsScreen extends StatefulWidget {
  const AllBookingsScreen({super.key});

  @override
  State<AllBookingsScreen> createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends State<AllBookingsScreen> {
  String _selectedMohallah = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final bookingProvider = context.read<BookingProvider>();
    final mohallahProvider = context.read<MohallahProvider>();
    
    await Future.wait([
      bookingProvider.loadAllBookings(),
      mohallahProvider.loadMohallahs(),
    ]);
  }

  List<dynamic> _getFilteredBookings(List<dynamic> bookings) {
    List<dynamic> filtered;
    if (_selectedMohallah == 'all') {
      filtered = List.of(bookings);
    } else {
      filtered = bookings.where((b) => b.mohallah == _selectedMohallah).toList();
    }
    
    // Sort: upcoming first (ascending), then past (descending)
    final now = DateTime.now();
    filtered.sort((a, b) {
      final aDate = a.dateTime as DateTime;
      final bDate = b.dateTime as DateTime;
      final aIsUpcoming = aDate.isAfter(now.subtract(const Duration(days: 1)));
      final bIsUpcoming = bDate.isAfter(now.subtract(const Duration(days: 1)));
      
      if (aIsUpcoming && !bIsUpcoming) return -1;
      if (!aIsUpcoming && bIsUpcoming) return 1;
      if (aIsUpcoming && bIsUpcoming) return aDate.compareTo(bDate); // Upcoming: ascending
      return bDate.compareTo(aDate); // Past: descending
    });
    
    return filtered;
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
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final mohallahProvider = context.watch<MohallahProvider>();
    final filteredBookings = _getFilteredBookings(bookingProvider.bookings);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'All Bookings',
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AdminBackground(
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: bookingProvider.isLoading,
            child: Column(
              children: [
                // Filter with glass effect
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'all'),
                            ...mohallahProvider.mohallahs.map(
                              (m) => _buildFilterChip(m.name, m.name),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Count
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredBookings.length} booking${filteredBookings.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bookings List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppColors.darkBrown,
                    child: filteredBookings.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              final booking = filteredBookings[index];
                              return BookingCard(
                                booking: booking,
                                showUserInfo: true,
                                onDelete: () => _handleDeleteBooking(booking.id),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedMohallah == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedMohallah = value);
        },
        backgroundColor: AppColors.softBeige,
        selectedColor: AppColors.darkBrown,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: AppColors.white,
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
                'No Bookings Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedMohallah == 'all'
                    ? 'No bookings have been made yet'
                    : 'No bookings for selected Mohallah',
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