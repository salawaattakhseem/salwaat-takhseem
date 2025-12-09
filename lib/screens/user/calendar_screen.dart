import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/mohallah_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/mohallah_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/misri_calendar_widget.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/misri_hijri_date.dart';
import '../../utils/date_utils.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late MisriHijriDate _focusedMonth;
  MisriHijriDate? _selectedDay;
  bool _isLoading = true;
  bool _bookingWindowOpen = true;
  String _bookingWindowMessage = '';
  MohallahModel? _mohallah;
  
  // Dynamic event dates from mohallah settings
  DateTime? _eventStartDate;
  DateTime? _eventEndDate;

  @override
  void initState() {
    super.initState();
    // Default to current month, will update after loading mohallah
    _focusedMonth = MisriHijriDate.now();
    _loadMohallahAndAvailability();
  }

  Future<void> _loadMohallahAndAvailability() async {
    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final mohallahProvider = context.read<MohallahProvider>();
    
    if (authProvider.currentUser != null) {
      // Load mohallah details to get booking window settings
      final mohallah = await mohallahProvider.getMohallahByName(
        authProvider.currentUser!.mohallah,
      );
      
      if (mohallah != null) {
        _mohallah = mohallah;
        _bookingWindowOpen = mohallah.isBookingWindowOpen;
        _bookingWindowMessage = mohallah.bookingWindowStatus;
        
        // Use dynamic event dates if set, otherwise fall back to defaults
        _eventStartDate = mohallah.eventStartDate ?? AppDateUtils.eventStartDate;
        _eventEndDate = mohallah.eventEndDate ?? AppDateUtils.eventEndDate;
        
        // Set focused month to event start date
        if (_eventStartDate != null) {
          _focusedMonth = MisriHijriDate.fromGregorian(_eventStartDate!);
        }
        
        // Load availability for the event date range
        await bookingProvider.loadAvailability(
          _eventStartDate!,
          _eventEndDate!,
          authProvider.currentUser!.mohallah,
        );
      } else {
        // Fallback to hardcoded dates
        _eventStartDate = AppDateUtils.eventStartDate;
        _eventEndDate = AppDateUtils.eventEndDate;
        _focusedMonth = AppDateUtils.eventStartHijri;
        
        await bookingProvider.loadAvailability(
          _eventStartDate!,
          _eventEndDate!,
          authProvider.currentUser!.mohallah,
        );
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onDaySelected(MisriHijriDate selectedDay) {
    // First check if booking window is open
    if (!_bookingWindowOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_bookingWindowMessage),
          backgroundColor: AppColors.fullyBooked,
        ),
      );
      return;
    }

    setState(() {
      _selectedDay = selectedDay;
    });

    Navigator.pushNamed(
      context,
      AppRoutes.booking,
      arguments: {'date': selectedDay.toGregorian()},
    );
  }

  void _onPageChanged(MisriHijriDate focusedMonth) {
    setState(() {
      _focusedMonth = focusedMonth;
    });
  }

  bool _isDateEnabled(MisriHijriDate date) {
    final gregorianDate = date.toGregorian();
    
    // Check if within dynamic event date range
    if (_eventStartDate != null && gregorianDate.isBefore(_eventStartDate!)) {
      return false;
    }
    if (_eventEndDate != null && gregorianDate.isAfter(_eventEndDate!)) {
      return false;
    }
    
    // Don't allow past dates
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (gregorianDate.isBefore(todayOnly)) {
      return false;
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Select Date'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('img/Fatemi_Design.png', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(color: Colors.white.withOpacity(0.75)),
          ),
          LoadingOverlay(
            isLoading: bookingProvider.isLoading || _isLoading,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Booking Window Status Banner
                  if (!_bookingWindowOpen && !_isLoading)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.fullyBooked.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.fullyBooked.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.lock_1, color: AppColors.fullyBooked),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Booking Not Available',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.fullyBooked,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _bookingWindowMessage,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Event Date Range Info
                  if (_eventStartDate != null && _eventEndDate != null && !_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.softBeige,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.calendar_tick, size: 16, color: AppColors.darkBrown),
                            const SizedBox(width: 8),
                            Text(
                              'Event: ${_formatDate(_eventStartDate!)} - ${_formatDate(_eventEndDate!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  MisriHijriCalendar(
                    focusedMonth: _focusedMonth,
                    selectedDay: _selectedDay,
                    availability: bookingProvider.availability,
                    onDaySelected: _onDaySelected,
                    onPageChanged: _onPageChanged,
                    enabledDayPredicate: _isDateEnabled,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const MisriCalendarLegend(),
                  
                  const SizedBox(height: 24),
                  
                  // Instructions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      elevation: 0,
                      color: AppColors.softBeige,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              _bookingWindowOpen ? Icons.info_outline : Iconsax.warning_2,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _bookingWindowOpen 
                                    ? 'Tap on an available date to book your slot'
                                    : 'Please wait for booking to open',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
