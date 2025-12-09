import '../main.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import '../models/mohallah_model.dart';
import '../models/booking_model.dart';
import '../models/attendance_model.dart';

class DatabaseService {
  // ============ USER OPERATIONS ============
  
  Future<UserModel?> getUser(String its) async {
    try {
      final response = await supabase
          .from(AppConstants.usersTable)
          .select()
          .eq('its', its)
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await supabase
          .from(AppConstants.usersTable)
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getUsersByMohallah(String mohallah) async {
    try {
      print('DEBUG: getUsersByMohallah - mohallah: "$mohallah"');
      final response = await supabase
          .from(AppConstants.usersTable)
          .select()
          .eq('mohallah', mohallah)
          .eq('role', UserRoles.user)
          .order('full_name');
      final users = (response as List).map((e) => UserModel.fromJson(e)).toList();
      print('DEBUG: getUsersByMohallah - found ${users.length} users');
      return users;
    } catch (e) {
      print('DEBUG: getUsersByMohallah ERROR - $e');
      return [];
    }
  }

  Future<void> createUser(UserModel user) async {
    await supabase.from(AppConstants.usersTable).insert(user.toJson());
  }

  Future<void> updateUser(String its, Map<String, dynamic> data) async {
    await supabase
        .from(AppConstants.usersTable)
        .update(data)
        .eq('its', its);
  }

  Future<void> deleteUser(String its) async {
    await supabase
        .from(AppConstants.usersTable)
        .delete()
        .eq('its', its);
  }

  Future<bool> userExists(String its) async {
    try {
      final response = await supabase
          .from(AppConstants.usersTable)
          .select('its')
          .eq('its', its)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // ============ MOHALLAH OPERATIONS ============

  Future<List<MohallahModel>> getAllMohallahs() async {
    try {
      final response = await supabase
          .from(AppConstants.mohallahsTable)
          .select()
          .order('name');
      return (response as List).map((e) => MohallahModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<MohallahModel?> getMohallah(String id) async {
    try {
      final response = await supabase
          .from(AppConstants.mohallahsTable)
          .select()
          .eq('id', id)
          .single();
      return MohallahModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<MohallahModel?> getMohallahByName(String name) async {
    try {
      final response = await supabase
          .from(AppConstants.mohallahsTable)
          .select()
          .eq('name', name)
          .single();
      return MohallahModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<MohallahModel?> getMohallahBySubAdmin(String subadminIts) async {
    try {
      print('DEBUG: getMohallahBySubAdmin - subadminIts: "$subadminIts"');
      final response = await supabase
          .from(AppConstants.mohallahsTable)
          .select()
          .eq('subadmin_its', subadminIts)
          .single();
      print('DEBUG: getMohallahBySubAdmin - found: ${response['name']}');
      return MohallahModel.fromJson(response);
    } catch (e) {
      print('DEBUG: getMohallahBySubAdmin ERROR - $e');
      return null;
    }
  }

  Future<void> createMohallah(MohallahModel mohallah) async {
    await supabase
        .from(AppConstants.mohallahsTable)
        .insert(mohallah.toInsertJson());
  }

  Future<void> updateMohallah(String id, Map<String, dynamic> data) async {
    await supabase
        .from(AppConstants.mohallahsTable)
        .update(data)
        .eq('id', id);
  }

  Future<void> deleteMohallah(String id) async {
    await supabase
        .from(AppConstants.mohallahsTable)
        .delete()
        .eq('id', id);
  }

  Future<bool> mohallahExists(String name) async {
    try {
      final response = await supabase
          .from(AppConstants.mohallahsTable)
          .select('id')
          .eq('name', name)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // ============ BOOKING OPERATIONS ============

  Future<List<BookingModel>> getAllBookings() async {
    try {
      // Use relationship hint to resolve ambiguous foreign key
      final response = await supabase
          .from(AppConstants.bookingsTable)
          .select('*, users!bookings_its_fkey(full_name, mobile)')
          .order('date')
          .order('created_at');
      return (response as List).map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      print('DEBUG: getAllBookings ERROR - $e');
      return [];
    }
  }

  Future<List<BookingModel>> getBookingsByMohallah(String mohallah) async {
    try {
      final cleanMohallah = mohallah.trim();
      // Use relationship hint to resolve ambiguous foreign key
      final response = await supabase
          .from(AppConstants.bookingsTable)
          .select('*, users!bookings_its_fkey(full_name, mobile)')
          .ilike('mohallah', cleanMohallah)
          .order('date')
          .order('created_at');
      final bookings = (response as List).map((e) => BookingModel.fromJson(e)).toList();
      print('DEBUG: getBookingsByMohallah - mohallah: "$cleanMohallah", count: ${bookings.length}');
      return bookings;
    } catch (e) {
      print('DEBUG: getBookingsByMohallah ERROR - $e');
      return [];
    }
  }

  Future<List<BookingModel>> getBookingsByUser(String its) async {
    try {
      // Get bookings where user is the primary booker OR is listed as a partner
      final response = await supabase
          .from(AppConstants.bookingsTable)
          .select()
          .or('its.eq.$its,partner_its.ilike.%$its%')
          .order('date');
      print('DEBUG: getBookingsByUser - its: $its, count: ${(response as List).length}');
      
      // Parse bookings first
      List<BookingModel> bookings = (response as List).map((e) => BookingModel.fromJson(e)).toList();
      
      // Collect all ITS numbers we need to look up (primary bookers + all partners)
      Set<String> allItsToLookup = {};
      for (var booking in bookings) {
        allItsToLookup.add(booking.its); // Primary booker
        allItsToLookup.addAll(booking.partnerItsList); // Partners
      }
      
      // Fetch names for all ITS numbers at once
      Map<String, String> itsToName = {};
      if (allItsToLookup.isNotEmpty) {
        try {
          final usersResponse = await supabase
              .from(AppConstants.usersTable)
              .select('its, full_name')
              .inFilter('its', allItsToLookup.toList());
          for (var user in (usersResponse as List)) {
            itsToName[user['its']] = user['full_name'];
          }
        } catch (e) {
          print('DEBUG: getBookingsByUser - Error fetching names: $e');
        }
      }
      
      // Update each booking with group member names (excluding the requesting user)
      List<BookingModel> result = [];
      for (var booking in bookings) {
        // Collect all group members (primary booker + partners)
        List<String> allGroupMembers = [booking.its, ...booking.partnerItsList];
        
        // Get names of all OTHER members (exclude the requesting user)
        List<String> otherMemberNames = [];
        for (var memberIts in allGroupMembers) {
          if (memberIts != its && itsToName.containsKey(memberIts)) {
            otherMemberNames.add(itsToName[memberIts]!);
          }
        }
        
        result.add(booking.copyWith(
          partnerNames: otherMemberNames,
          userName: itsToName[booking.its], // Also set primary booker name
        ));
      }
      
      return result;
    } catch (e) {
      print('DEBUG: getBookingsByUser ERROR - $e');
      return [];
    }
  }

  Future<List<BookingModel>> getBookingsByDate(String date) async {
    try {
      // Use relationship hint to resolve ambiguous foreign key
      final response = await supabase
          .from(AppConstants.bookingsTable)
          .select('*, users!bookings_its_fkey(full_name, mobile)')
          .eq('date', date)
          .order('created_at');
      return (response as List).map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<BookingModel>> getBookingsByDateAndMohallah(
      String date, String mohallah) async {
    try {
      final cleanMohallah = mohallah.trim();
      // Use relationship hint to resolve ambiguous foreign key
      final response = await supabase
          .from(AppConstants.bookingsTable)
          .select('*, users!bookings_its_fkey(full_name, mobile)')
          .eq('date', date)
          .ilike('mohallah', cleanMohallah)
          .order('created_at');
      return (response as List).map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> getBookingCountForDate(String date, String mohallah) async {
    try {
      // Use ilike for case-insensitive matching and trim
      final cleanMohallah = mohallah.trim();
      final response = await supabase
          .from(AppConstants.bookingsTable)
          .select('id')
          .eq('date', date)
          .ilike('mohallah', cleanMohallah);
      final count = (response as List).length;
      // Debug print to trace the issue
      print('DEBUG: getBookingCountForDate - date: "$date", mohallah: "$cleanMohallah", count: $count');
      return count;
    } catch (e) {
      print('DEBUG: getBookingCountForDate ERROR - $e');
      return 0;
    }
  }

  Future<void> deleteBooking(String id) async {
    await supabase
        .from(AppConstants.bookingsTable)
        .delete()
        .eq('id', id);
  }

  Future<bool> hasUserBookedDate(String its, String date) async {
    try {
      final response = await supabase
          .from(AppConstants.bookingsTable)
          .select('id')
          .eq('its', its)
          .eq('date', date)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Get booking statistics
  Future<Map<String, int>> getBookingStats() async {
    try {
      final bookings = await getAllBookings();
      final Map<String, int> stats = {};
      
      for (var booking in bookings) {
        stats[booking.date] = (stats[booking.date] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      return {};
    }
  }

  // Get booking counts by date for a mohallah (simple query without user join)
  Future<Map<String, int>> getBookingCountsByMohallah(String mohallah) async {
    try {
      final cleanMohallah = mohallah.trim();
      
      // Simple query - just get id and date, no user join needed for counting
      final response = await supabase
          .from(AppConstants.bookingsTable)
          .select('id, date')
          .ilike('mohallah', cleanMohallah);
      
      final bookingsList = response as List;
      
      final Map<String, int> counts = {};
      for (var booking in bookingsList) {
        final date = booking['date'] as String;
        counts[date] = (counts[date] ?? 0) + 1;
      }
      
      return counts;
    } catch (e) {
      print('DEBUG: getBookingCountsByMohallah ERROR - $e');
      return {};
    }
  }

  // ============ ATTENDANCE OPERATIONS ============

  // Get attendance count for a specific date and mohallah
  Future<AttendanceModel?> getAttendance(String mohallah, String date) async {
    try {
      final response = await supabase
          .from(AppConstants.attendanceTable)
          .select()
          .eq('mohallah', mohallah)
          .eq('date', date)
          .maybeSingle();
      return response != null ? AttendanceModel.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  // Get all attendance counts for a mohallah
  Future<List<AttendanceModel>> getAttendanceByMohallah(String mohallah) async {
    try {
      final response = await supabase
          .from(AppConstants.attendanceTable)
          .select()
          .eq('mohallah', mohallah)
          .order('date', ascending: true);
      return (response as List).map((e) => AttendanceModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // Create or update attendance count (upsert)
  Future<bool> upsertAttendance(String mohallah, String date, int expectedCount, {String? note}) async {
    try {
      await supabase
          .from(AppConstants.attendanceTable)
          .upsert({
            'mohallah': mohallah,
            'date': date,
            'expected_count': expectedCount,
            'note': note,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'mohallah,date');
      return true;
    } catch (e) {
      print('DEBUG: upsertAttendance ERROR - $e');
      return false;
    }
  }

  // Delete attendance count
  Future<bool> deleteAttendance(String mohallah, String date) async {
    try {
      await supabase
          .from(AppConstants.attendanceTable)
          .delete()
          .eq('mohallah', mohallah)
          .eq('date', date);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get attendance for user's upcoming bookings
  Future<Map<String, int>> getAttendanceForDates(String mohallah, List<String> dates) async {
    try {
      if (dates.isEmpty) return {};
      
      final response = await supabase
          .from(AppConstants.attendanceTable)
          .select('date, expected_count')
          .eq('mohallah', mohallah)
          .inFilter('date', dates);
      
      final Map<String, int> result = {};
      for (var item in (response as List)) {
        result[item['date']] = item['expected_count'] ?? 0;
      }
      return result;
    } catch (e) {
      return {};
    }
  }

  // Get user names by ITS list for partner names
  Future<Map<String, String>> getUserNamesByItsList(List<String> itsList) async {
    try {
      if (itsList.isEmpty) return {};
      
      final response = await supabase
          .from(AppConstants.usersTable)
          .select('its, full_name')
          .inFilter('its', itsList);
      
      final Map<String, String> result = {};
      for (var item in (response as List)) {
        result[item['its']] = item['full_name'] ?? '';
      }
      return result;
    } catch (e) {
      return {};
    }
  }

  // Populate partner names for a list of bookings
  Future<List<BookingModel>> populatePartnerNames(List<BookingModel> bookings) async {
    // Collect all unique partner ITS from all bookings
    final Set<String> allPartnerIts = {};
    for (var booking in bookings) {
      allPartnerIts.addAll(booking.partnerItsList);
    }
    
    if (allPartnerIts.isEmpty) return bookings;
    
    // Fetch all partner names in one query
    final names = await getUserNamesByItsList(allPartnerIts.toList());
    
    // Update bookings with partner names
    return bookings.map((booking) {
      if (booking.partnerItsList.isEmpty) return booking;
      
      final partnerNames = booking.partnerItsList
          .map((its) => names[its] ?? 'Unknown')
          .toList();
      
      return booking.copyWith(partnerNames: partnerNames);
    }).toList();
  }
}