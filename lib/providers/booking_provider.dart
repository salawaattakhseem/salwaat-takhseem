import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/database_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final DatabaseService _databaseService = DatabaseService();

  List<BookingModel> _bookings = [];
  List<BookingModel> _userBookings = [];
  Map<String, DateAvailability> _availability = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get userBookings => _userBookings;
  Map<String, DateAvailability> get availability => _availability;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all bookings (for admin)
  Future<void> loadAllBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _databaseService.getAllBookings();
      // Populate partner names for group bookings
      _bookings = await _databaseService.populatePartnerNames(_bookings);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load bookings';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load bookings by mohallah (for subadmin)
  Future<void> loadBookingsByMohallah(String mohallah) async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _databaseService.getBookingsByMohallah(mohallah);
      // Populate partner names for group bookings
      _bookings = await _databaseService.populatePartnerNames(_bookings);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load bookings';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load user's bookings
  Future<void> loadUserBookings(String its) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userBookings = await _databaseService.getBookingsByUser(its);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load bookings';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load availability for a date range
  Future<void> loadAvailability(
    DateTime start,
    DateTime end,
    String mohallah,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      _availability = await _bookingService.getAvailabilityForRange(
        start,
        end,
        mohallah,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load availability';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create booking
  Future<BookingResult> createBooking({
    required String its,
    required String mohallah,
    required String date,
    required String item,
    List<String>? partnerItsList,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _bookingService.createBooking(
      its: its,
      mohallah: mohallah,
      date: date,
      item: item,
      partnerItsList: partnerItsList,
    );

    if (result.success) {
      await loadUserBookings(its);
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Delete booking
  Future<BookingResult> deleteBooking(String bookingId, String its) async {
    _isLoading = true;
    notifyListeners();

    final result = await _bookingService.deleteBooking(bookingId);

    if (result.success) {
      await loadUserBookings(its);
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Delete booking (admin/subadmin)
  Future<BookingResult> deleteBookingAdmin(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _bookingService.deleteBooking(bookingId);

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Get availability for a specific date
  DateAvailability? getAvailabilityForDate(String date) {
    return _availability[date];
  }

  // Get bookings for a specific date
  List<BookingModel> getBookingsForDate(String date) {
    return _bookings.where((b) => b.date == date).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}