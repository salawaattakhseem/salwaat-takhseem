class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://hqrwnnblovqbduasazai.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxcndubmJsb3ZxYmR1YXNhemFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ5NTM4NDcsImV4cCI6MjA4MDUyOTg0N30.XY8gm9aghdni_ytP-pSmlIfNeNCf1JnzCK_-u9QHn8I';
  
  // App Configuration
  static const String appName = 'Salwaat Takhseem';
  static const String emailDomain = '@swt.com';
  
  // Event Configuration - Hijri Calendar
  // Bookings only allowed in Rajab ul Asab (Month 7) of 1447H
  static const int eventHijriYear = 1447;
  static const int eventHijriMonth = 7; // Rajab ul Asab
  static const int eventHijriStartDay = 1;
  static const int eventHijriEndDay = 30; // Rajab has 30 days (odd month)
  
  // Partner Configuration
  static const int maxPartners = 4; // Maximum partners allowed per booking
  
  // Booking Limits per Mohallah per day
  static const int defaultBookingLimit = 2;
  static const int maxBookingLimit = 3;
  
  // Table Names
  static const String usersTable = 'users';
  static const String mohallahsTable = 'mohallahs';
  static const String bookingsTable = 'bookings';
  static const String attendanceTable = 'attendance_counts';
  
  // Storage Buckets
  static const String csvBucket = 'csv-uploads';
  
  // Edge Function Names
  static const String processCSVFunction = 'process-csv';
  static const String createBookingFunction = 'create-booking';
  static const String deleteBookingFunction = 'delete-booking';
}

class UserRoles {
  static const String admin = 'admin';
  static const String subadmin = 'subadmin';
  static const String user = 'user';
}