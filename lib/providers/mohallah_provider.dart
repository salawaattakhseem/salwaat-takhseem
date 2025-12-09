import 'package:flutter/foundation.dart';
import '../models/mohallah_model.dart';
import '../services/database_service.dart';

class MohallahProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<MohallahModel> _mohallahs = [];
  MohallahModel? _selectedMohallah;
  bool _isLoading = false;
  String? _errorMessage;

  List<MohallahModel> get mohallahs => _mohallahs;
  MohallahModel? get selectedMohallah => _selectedMohallah;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all mohallahs
  Future<void> loadMohallahs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _mohallahs = await _databaseService.getAllMohallahs();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load mohallahs';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get mohallah by name
  Future<MohallahModel?> getMohallahByName(String name) async {
    return await _databaseService.getMohallahByName(name);
  }

  // Get mohallah for subadmin
  Future<void> loadMohallahForSubAdmin(String subadminIts) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedMohallah = await _databaseService.getMohallahBySubAdmin(subadminIts);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load mohallah';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create mohallah
  Future<bool> createMohallah({
    required String name,
    required int bookingLimit,
    String? subadminIts,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if mohallah already exists
      if (await _databaseService.mohallahExists(name)) {
        _errorMessage = 'Mohallah already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final mohallah = MohallahModel(
        id: '',
        name: name,
        bookingLimit: bookingLimit,
        subadminIts: subadminIts,
        createdAt: DateTime.now(),
      );

      await _databaseService.createMohallah(mohallah);
      await loadMohallahs();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create mohallah';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update mohallah
  Future<bool> updateMohallah(
    String id,
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateMohallah(id, data);
      await loadMohallahs();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update mohallah';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete mohallah
  Future<bool> deleteMohallah(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteMohallah(id);
      await loadMohallahs();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete mohallah';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectMohallah(MohallahModel mohallah) {
    _selectedMohallah = mohallah;
    notifyListeners();
  }

  // Update booking settings (for SubAdmin)
  Future<bool> updateBookingSettings({
    required String mohallahId,
    required bool bookingEnabled,
    DateTime? bookingStartDate,
    DateTime? bookingEndDate,
    DateTime? eventStartDate,
    DateTime? eventEndDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = <String, dynamic>{
        'booking_enabled': bookingEnabled,
        'booking_start_date': bookingStartDate?.toIso8601String(),
        'booking_end_date': bookingEndDate?.toIso8601String(),
        'event_start_date': eventStartDate?.toIso8601String(),
        'event_end_date': eventEndDate?.toIso8601String(),
      };

      await _databaseService.updateMohallah(mohallahId, data);
      
      // Reload the selected mohallah to get updated settings
      if (_selectedMohallah != null && _selectedMohallah!.id == mohallahId) {
        _selectedMohallah = _selectedMohallah!.copyWith(
          bookingEnabled: bookingEnabled,
          bookingStartDate: bookingStartDate,
          bookingEndDate: bookingEndDate,
          eventStartDate: eventStartDate,
          eventEndDate: eventEndDate,
        );
      }
      
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update booking settings';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}