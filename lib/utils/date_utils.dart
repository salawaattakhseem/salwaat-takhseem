import 'package:hijri/hijri_calendar.dart';
import '../config/constants.dart';
import 'misri_hijri_date.dart';

class AppDateUtils {
  // Hijri month names
  static const List<String> hijriMonthNames = [
    'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Shaban',
    'Ramadan', 'Shawwal', 'Dhul Qadah', 'Dhul Hijjah'
  ];

  // Convert Gregorian date to Hijri
  static HijriCalendar toHijri(DateTime date) {
    return HijriCalendar.fromDate(date);
  }

  // Get Hijri date display string
  static String getHijriDateDisplay(DateTime date) {
    final hijri = toHijri(date);
    return '${hijri.hDay} ${hijriMonthNames[hijri.hMonth - 1]} ${hijri.hYear}';
  }

  // Get short Hijri date display
  static String getShortHijriDate(DateTime date) {
    final hijri = toHijri(date);
    return '${hijri.hDay} ${hijriMonthNames[hijri.hMonth - 1].split(' ').first}';
  }

  // Get Hijri month and year for calendar header
  static String getHijriMonthYear(DateTime date) {
    final hijri = toHijri(date);
    return '${hijriMonthNames[hijri.hMonth - 1]} ${hijri.hYear} AH';
  }

  // Get event start Hijri date
  static MisriHijriDate get eventStartHijri => MisriHijriDate(
    AppConstants.eventHijriYear,
    AppConstants.eventHijriMonth,
    AppConstants.eventHijriStartDay,
  );

  // Get event end Hijri date
  static MisriHijriDate get eventEndHijri => MisriHijriDate(
    AppConstants.eventHijriYear,
    AppConstants.eventHijriMonth,
    AppConstants.eventHijriEndDay,
  );

  // Get event start date (Gregorian)
  static DateTime get eventStartDate => eventStartHijri.toGregorian();

  // Get event end date (Gregorian)
  static DateTime get eventEndDate => eventEndHijri.toGregorian();

  // Get focusedDay clamped to valid range
  static DateTime getClampedFocusedDay() {
    final now = DateTime.now();
    if (now.isBefore(eventStartDate)) {
      return eventStartDate;
    } else if (now.isAfter(eventEndDate)) {
      return eventEndDate;
    }
    return now;
  }

  // Check if Hijri date is within event period (Rajab ul Asab only)
  static bool isHijriWithinEventPeriod(MisriHijriDate date) {
    return date.year == AppConstants.eventHijriYear &&
           date.month == AppConstants.eventHijriMonth &&
           date.day >= AppConstants.eventHijriStartDay &&
           date.day <= AppConstants.eventHijriEndDay;
  }

  // Check if date is within event period (Gregorian)
  static bool isWithinEventPeriod(DateTime date) {
    final hijri = MisriHijriDate.fromGregorian(date);
    return isHijriWithinEventPeriod(hijri);
  }

  // Check if Hijri date is NOT in Rajab ul Asab (for display purposes)
  static bool isNotBookingMonth(MisriHijriDate date) {
    return date.month != AppConstants.eventHijriMonth ||
           date.year != AppConstants.eventHijriYear;
  }

  // Check if date is in the past
  static bool isPastDate(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isBefore(todayOnly);
  }

  // Check if Hijri date is in the past
  static bool isHijriPastDate(MisriHijriDate date) {
    final today = MisriHijriDate.now();
    return date.isBefore(today);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  // Format date as string (YYYY-MM-DD)
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Parse date string to DateTime
  static DateTime parseDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  // Get list of all dates in event period
  static List<DateTime> getEventDates() {
    final dates = <DateTime>[];
    DateTime current = eventStartDate;
    
    while (!current.isAfter(eventEndDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }

  // Get day name
  static String getDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  // Get full day name
  static String getFullDayName(DateTime date) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday - 1];
  }

  // Get month name
  static String getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Get short month name
  static String getShortMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Get formatted date display
  static String getFormattedDisplay(DateTime date) {
    return '${getDayName(date)}, ${date.day} ${getShortMonthName(date.month)} ${date.year}';
  }
}