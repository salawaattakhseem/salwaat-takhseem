import '../main.dart';
import '../config/constants.dart';
import '../models/booking_model.dart';
import '../models/mohallah_model.dart';
import 'database_service.dart';

class BookingResult {
  final bool success;
  final String message;
  final BookingModel? booking;

  BookingResult({
    required this.success,
    required this.message,
    this.booking,
  });
}

class BookingService {
  final DatabaseService _databaseService = DatabaseService();

  // Validate partner ITS - must be from same mohallah
  Future<Map<String, dynamic>?> validatePartnerIts(String partnerIts, String userMohallah) async {
    try {
      final response = await supabase
          .from(AppConstants.usersTable)
          .select('its, full_name, mohallah')
          .eq('its', partnerIts)
          .maybeSingle();
      
      if (response == null) {
        return {'error': 'Partner ITS $partnerIts not found in the system'};
      }
      
      if (response['mohallah'] != userMohallah) {
        return {'error': 'Partner $partnerIts must be from the same Mohallah'};
      }
      
      return {'success': true, 'name': response['full_name'], 'its': partnerIts};
    } catch (e) {
      return {'error': 'Failed to validate partner ITS'};
    }
  }

  // Validate multiple partners
  Future<Map<String, dynamic>> validatePartnerItsList(
    List<String> partnerItsList,
    String userMohallah,
    String userIts,
    String date,
  ) async {
    List<String> validatedNames = [];
    print('DEBUG: validatePartnerItsList - partners: $partnerItsList');
    
    for (int i = 0; i < partnerItsList.length; i++) {
      final partnerIts = partnerItsList[i];
      print('DEBUG: Validating partner ${i+1}: $partnerIts');
      
      if (partnerIts.trim().isEmpty) {
        print('DEBUG: Partner $partnerIts is empty, skipping');
        continue;
      }
      
      // Check if partner is same as user
      if (partnerIts == userIts) {
        print('DEBUG: Partner $partnerIts is same as user');
        return {'error': 'You cannot add yourself as a partner'};
      }
      
      // Check for duplicates
      if (partnerItsList.where((p) => p == partnerIts).length > 1) {
        print('DEBUG: Partner $partnerIts is duplicate');
        return {'error': 'Duplicate partner ITS: $partnerIts'};
      }
      
      // Check if partner already booked this date
      final partnerHasBooked = await _databaseService.hasUserBookedDate(partnerIts, date);
      if (partnerHasBooked) {
        print('DEBUG: Partner $partnerIts already booked');
        return {'error': 'Partner $partnerIts has already booked a slot for this date'};
      }
      
      // Validate partner is from same mohallah
      final validation = await validatePartnerIts(partnerIts, userMohallah);
      print('DEBUG: Partner $partnerIts validation result: $validation');
      if (validation?['error'] != null) {
        return {'error': validation!['error']};
      }
      
      validatedNames.add(validation!['name']);
    }
    
    print('DEBUG: All partners validated successfully: $validatedNames');
    return {'success': true, 'names': validatedNames};
  }

  // Create booking with atomic check
  Future<BookingResult> createBooking({
    required String its,
    required String mohallah,
    required String date,
    required String item,
    List<String>? partnerItsList,
  }) async {
    try {
      final cleanPartnerList = partnerItsList
          ?.where((p) => p.trim().isNotEmpty)
          .toList() ?? [];
      
      // Validate all partners if provided
      if (cleanPartnerList.isNotEmpty) {
        if (cleanPartnerList.length > AppConstants.maxPartners) {
          return BookingResult(
            success: false,
            message: 'Maximum ${AppConstants.maxPartners} partners allowed',
          );
        }
        
        final validation = await validatePartnerItsList(
          cleanPartnerList,
          mohallah,
          its,
          date,
        );
        
        if (validation['error'] != null) {
          return BookingResult(
            success: false,
            message: validation['error'],
          );
        }
      }
      
      // Check if user already booked this date
      final hasBooked = await _databaseService.hasUserBookedDate(its, date);
      if (hasBooked) {
        return BookingResult(
          success: false,
          message: 'You have already booked a slot for this date',
        );
      }

      // Get mohallah booking limit
      final mohallahData = await _databaseService.getMohallahByName(mohallah);
      if (mohallahData == null) {
        return BookingResult(
          success: false,
          message: 'Mohallah not found',
        );
      }

      // Create booking with fallback method
      return await _createBookingFallback(its, mohallah, date, item, cleanPartnerList);
    } catch (e) {
      return BookingResult(
        success: false,
        message: 'Failed to create booking: ${e.toString()}',
      );
    }
  }

  // Fallback booking method (without RPC)
  Future<BookingResult> _createBookingFallback(
    String its,
    String mohallah,
    String date,
    String item,
    List<String> partnerItsList,
  ) async {
    try {
      // Get mohallah booking limit
      final mohallahData = await _databaseService.getMohallahByName(mohallah);
      if (mohallahData == null) {
        return BookingResult(
          success: false,
          message: 'Mohallah not found',
        );
      }

      // Check current booking count
      final currentCount = await _databaseService.getBookingCountForDate(date, mohallah);
      final limit = mohallahData.bookingLimit;
      print('DEBUG: createBooking - currentCount: $currentCount, limit: $limit');
      if (currentCount >= limit) {
        print('DEBUG: BLOCKING - slot is full!');
        return BookingResult(
          success: false,
          message: 'This slot is fully booked (${currentCount}/${limit})',
        );
      }

      // Build booking data with optional partner_its (comma-separated)
      final bookingData = <String, dynamic>{
        'its': its,
        'mohallah': mohallah,
        'date': date,
        'item': item,
      };
      
      if (partnerItsList.isNotEmpty) {
        bookingData['partner_its'] = partnerItsList.join(',');
      }

      // Create booking
      final response = await supabase
          .from(AppConstants.bookingsTable)
          .insert(bookingData)
          .select()
          .single();

      final partnerCount = partnerItsList.length;
      String message;
      if (partnerCount == 0) {
        message = 'Booking confirmed successfully!';
      } else if (partnerCount == 1) {
        message = 'Group booking confirmed! You and your partner are giving together.';
      } else {
        message = 'Group booking confirmed! You and $partnerCount partners are giving together.';
      }
      
      return BookingResult(
        success: true,
        message: message,
        booking: BookingModel.fromJson(response),
      );
    } catch (e) {
      return BookingResult(
        success: false,
        message: 'Failed to create booking: ${e.toString()}',
      );
    }
  }

  // Delete booking
  Future<BookingResult> deleteBooking(String bookingId) async {
    try {
      await _databaseService.deleteBooking(bookingId);
      return BookingResult(
        success: true,
        message: 'Booking cancelled successfully',
      );
    } catch (e) {
      return BookingResult(
        success: false,
        message: 'Failed to cancel booking',
      );
    }
  }

  // Get availability for a date
  Future<DateAvailability> getDateAvailability(
    String date,
    String mohallah,
  ) async {
    try {
      final mohallahData = await _databaseService.getMohallahByName(mohallah);
      if (mohallahData == null) {
        return DateAvailability(
          date: date,
          totalSlots: 0,
          bookedSlots: 0,
          status: AvailabilityStatus.notAvailable,
        );
      }

      final bookedCount = await _databaseService.getBookingCountForDate(date, mohallah);
      final limit = mohallahData.bookingLimit;

      AvailabilityStatus status;
      if (bookedCount >= limit) {
        status = AvailabilityStatus.full;
      } else if (bookedCount > 0) {
        status = AvailabilityStatus.partial;
      } else {
        status = AvailabilityStatus.available;
      }

      return DateAvailability(
        date: date,
        totalSlots: limit,
        bookedSlots: bookedCount,
        status: status,
      );
    } catch (e) {
      return DateAvailability(
        date: date,
        totalSlots: 0,
        bookedSlots: 0,
        status: AvailabilityStatus.notAvailable,
      );
    }
  }

  // Get availability for date range
  Future<Map<String, DateAvailability>> getAvailabilityForRange(
    DateTime start,
    DateTime end,
    String mohallah,
  ) async {
    final Map<String, DateAvailability> availability = {};
    
    final mohallahData = await _databaseService.getMohallahByName(mohallah);
    if (mohallahData == null) {
      print('DEBUG: getAvailabilityForRange - mohallah not found: "$mohallah"');
      return availability;
    }

    final bookingCounts = await _databaseService.getBookingCountsByMohallah(mohallah);
    final limit = mohallahData.bookingLimit;
    
    print('DEBUG: getAvailabilityForRange - mohallah: "$mohallah", limit: $limit, bookingCounts: $bookingCounts');

    DateTime current = start;
    while (!current.isAfter(end)) {
      final dateStr = _formatDate(current);
      final bookedCount = bookingCounts[dateStr] ?? 0;

      AvailabilityStatus status;
      if (bookedCount >= limit) {
        status = AvailabilityStatus.full;
      } else if (bookedCount > 0) {
        status = AvailabilityStatus.partial;
      } else {
        status = AvailabilityStatus.available;
      }

      availability[dateStr] = DateAvailability(
        date: dateStr,
        totalSlots: limit,
        bookedSlots: bookedCount,
        status: status,
      );

      current = current.add(const Duration(days: 1));
    }

    return availability;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

enum AvailabilityStatus {
  available,
  partial,
  full,
  notAvailable,
}

class DateAvailability {
  final String date;
  final int totalSlots;
  final int bookedSlots;
  final AvailabilityStatus status;

  DateAvailability({
    required this.date,
    required this.totalSlots,
    required this.bookedSlots,
    required this.status,
  });

  int get availableSlots => totalSlots - bookedSlots;
  
  String get displayText {
    switch (status) {
      case AvailabilityStatus.available:
        return 'Available';
      case AvailabilityStatus.partial:
        return '$bookedSlots/\$totalSlots booked';
      case AvailabilityStatus.full:
        return 'FULL';
      case AvailabilityStatus.notAvailable:
        return 'N/A';
    }
  }
}