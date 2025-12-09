import 'package:flutter/material.dart';

/// Dawoodi Bohra Misri Hijri Calendar Implementation
/// Based on the tabular Islamic calendar used by the Fatimi Imams
class MisriHijriDate {
  final int year;
  final int month;
  final int day;

  // Arabic numerals for display (Hindi-Arabic numerals)
  static const List<String> arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  
  // Hijri month names (full formal names)
  static const List<String> monthNames = [
    'Moharramul Haraam',
    'Safarul Muzaffar',
    'Rabi al-Awwal',
    'Rabi al-Aakhar',
    'Jumada al-Ula',
    'Jumada al-Ukhra',
    'Rajabul Asab',
    'Shabanul Karim',
    'Ramadanul Moazzam',
    'Shawwalul Mukarram',
    'Zilqadatil Haraam',
    'Zilhijjatil Haraam',
  ];

  // Short month names (proper format)
  static const List<String> shortMonthNames = [
    'Moharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Aakhar',
    'Jumada al-Ula',
    'Jumada al-Ukhra',
    'Rajab',
    'Shaban',
    'Ramadan',
    'Shawwal',
    'Zilqadah',
    'Zilhijjah',
  ];

  // Arabic month names
  static const List<String> arabicMonthNames = [
    'محرم الحرام',
    'صفر المظفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب الأصب',
    'شعبان الكريم',
    'رمضان المعظم',
    'شوال المكرم',
    'ذو القعدة الحرام',
    'ذو الحجة الحرام',
  ];

  // Day names in English
  static const List<String> dayNames = [
    'Ahad', 'Ithnain', 'Thulatha', 'Arbia', 'Khamis', 'Jumoa', 'Sabt'
  ];

  // Arabic day names
  static const List<String> arabicDayNames = [
    'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'
  ];

  MisriHijriDate(this.year, this.month, this.day);

  // Known reference point: Dec 7, 2025 = 17 Jumada al-Ukhra 1447 (UPDATED FOR 2025)
  static final DateTime _referenceGregorian = DateTime(2025, 12, 7);
  static const int _referenceYear = 1447;
  static const int _referenceMonth = 6; // Jumada al-Ukhra
  static const int _referenceDay = 17;

  /// Convert a Gregorian date to Misri Hijri date
  factory MisriHijriDate.fromGregorian(DateTime date) {
    // Reference: Dec 7, 2025 = 17 Jumada al-Ukhra 1447
    final inputDate = DateTime(date.year, date.month, date.day);
    final refDate = DateTime(2025, 12, 7);
    
    int daysDiff = inputDate.difference(refDate).inDays;
    int hijriDay = 17 + daysDiff;
    int hijriMonth = 6;
    int hijriYear = 1447;
    
    print('=== HIJRI DEBUG ===');
    print('Input: $inputDate, Ref: $refDate, DaysDiff: $daysDiff');
    print('Initial: day=$hijriDay, month=$hijriMonth, year=$hijriYear');
    
    // Handle forward movement (positive days)
    while (hijriDay > daysInMonth(hijriYear, hijriMonth)) {
      print('Forward: day=$hijriDay > ${daysInMonth(hijriYear, hijriMonth)} (month $hijriMonth)');
      hijriDay -= daysInMonth(hijriYear, hijriMonth);
      hijriMonth++;
      if (hijriMonth > 12) {
        hijriMonth = 1;
        hijriYear++;
      }
    }
    
    // Handle backward movement (negative days)
    while (hijriDay < 1) {
      hijriMonth--;
      if (hijriMonth < 1) {
        hijriMonth = 12;
        hijriYear--;
      }
      hijriDay += daysInMonth(hijriYear, hijriMonth);
    }
    
    print('Final: day=$hijriDay, month=$hijriMonth, year=$hijriYear');
    print('===================');
    
    return MisriHijriDate(hijriYear, hijriMonth, hijriDay);
  }

  /// Get today's Misri Hijri date
  factory MisriHijriDate.now() {
    print('MisriHijriDate.now() called with DateTime.now() = ${DateTime.now()}');
    return MisriHijriDate.fromGregorian(DateTime.now());
  }

  /// Convert to Gregorian DateTime
  DateTime toGregorian() {
    // Calculate days difference from reference Hijri date to this date
    int daysDiff = 0;
    
    // Calculate days from reference date
    int y = _referenceYear;
    int m = _referenceMonth;
    int d = _referenceDay;
    
    // If this date is after reference
    if (year > y || (year == y && month > m) || (year == y && month == m && day > d)) {
      while (y < year || m < month || d < day) {
        d++;
        daysDiff++;
        if (d > daysInMonth(y, m)) {
          d = 1;
          m++;
          if (m > 12) {
            m = 1;
            y++;
          }
        }
      }
    } else {
      // If this date is before reference
      while (y > year || m > month || d > day) {
        d--;
        daysDiff--;
        if (d < 1) {
          m--;
          if (m < 1) {
            m = 12;
            y--;
          }
          d = daysInMonth(y, m);
        }
      }
    }
    
    return _referenceGregorian.add(Duration(days: daysDiff));
  }

  /// Check if this is a kabisa (leap) year
  /// In the 30-year cycle, years 2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29 are kabisa
  static bool isKabisaYear(int year) {
    int yearInCycle = year % 30;
    return [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29].contains(yearInCycle);
  }

  /// Get days in a specific month
  /// Odd months have 30 days, even months have 29 days
  /// Exception: Zilhijjah (month 12) has 30 days in kabisa years
  static int daysInMonth(int year, int month) {
    if (month == 12 && isKabisaYear(year)) {
      return 30;
    }
    return month.isOdd ? 30 : 29;
  }

  /// Get total days in a Hijri year
  static int daysInYear(int year) {
    return isKabisaYear(year) ? 355 : 354;
  }

  /// Convert number to Arabic numeral string
  static String toArabicNumeral(int number) {
    String result = '';
    String numStr = number.toString();
    for (int i = 0; i < numStr.length; i++) {
      int digit = int.parse(numStr[i]);
      result += arabicNumerals[digit];
    }
    return result;
  }

  /// Get month name
  String get monthName => monthNames[month - 1];
  String get shortMonthName => shortMonthNames[month - 1];
  String get arabicMonthName => arabicMonthNames[month - 1];

  /// Get day in Arabic numerals
  String get dayArabic => toArabicNumeral(day);
  String get yearArabic => toArabicNumeral(year);

  /// Get day of week (0 = Sunday, 6 = Saturday)
  int get weekday {
    // Use Gregorian conversion to get accurate weekday
    final gregorian = toGregorian();
    // DateTime.weekday: 1=Monday, 7=Sunday, we need 0=Sunday, 6=Saturday
    return gregorian.weekday == 7 ? 0 : gregorian.weekday;
  }

  String get dayName => dayNames[weekday];
  String get arabicDayName => arabicDayNames[weekday];

  /// Format as "Day Month Year"
  String format() => '$day $shortMonthName $year H';
  String formatArabic() => '${toArabicNumeral(day)} $arabicMonthName ${toArabicNumeral(year)}';
  String formatFull() => '$day $monthName $year H';

  // ===== Internal Calendar Calculations =====

  /// Epoch: Julian day of 1 Moharram 1 AH (July 19, 622 CE Julian)
  static const int hijriEpoch = 1948440;

  /// Convert Gregorian date to Julian Day Number
  static int _gregorianToJulian(int year, int month, int day) {
    int a = ((14 - month) / 12).floor();
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    return day + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() 
           - (y / 100).floor() + (y / 400).floor() - 32045;
  }

  /// Convert Julian Day Number to Gregorian date
  static DateTime _julianToGregorian(int jd) {
    int a = jd + 32044;
    int b = ((4 * a + 3) / 146097).floor();
    int c = a - ((146097 * b) / 4).floor();
    int d = ((4 * c + 3) / 1461).floor();
    int e = c - ((1461 * d) / 4).floor();
    int m = ((5 * e + 2) / 153).floor();
    
    int day = e - ((153 * m + 2) / 5).floor() + 1;
    int month = m + 3 - 12 * (m / 10).floor();
    int year = 100 * b + d - 4800 + (m / 10).floor();
    
    return DateTime(year, month, day);
  }

  /// Convert Julian Day Number to Misri Hijri date
  static MisriHijriDate _julianToHijri(int jd) {
    int l = jd - hijriEpoch + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = (((10985 - l) / 5316).floor()) * ((((50 * l) / 17719).floor())) +
            (((l / 5670).floor())) * ((((43 * l) / 15238).floor()));
    l = l - (((30 - j) / 15).floor()) * ((((17719 * j) / 50).floor())) -
        (((j / 16).floor())) * ((((15238 * j) / 43).floor())) + 29;
    int month = ((24 * l) / 709).floor();
    int day = l - ((709 * month) / 24).floor();
    int year = 30 * n + j - 30;
    
    return MisriHijriDate(year, month, day);
  }

  /// Convert Misri Hijri date to Julian Day Number
  static int _hijriToJulian(int year, int month, int day) {
    return day + 
           ((29 * month + 6) / 11).ceil() +
           29 * (month - 1) +
           (year - 1) * 354 +
           ((3 + 11 * year) / 30).floor() +
           hijriEpoch - 1;
  }

  /// Get first day of the month
  static MisriHijriDate firstDayOfMonth(int year, int month) {
    return MisriHijriDate(year, month, 1);
  }

  /// Get last day of the month
  static MisriHijriDate lastDayOfMonth(int year, int month) {
    return MisriHijriDate(year, month, daysInMonth(year, month));
  }

  /// Add days to this date
  MisriHijriDate addDays(int days) {
    int newYear = year;
    int newMonth = month;
    int newDay = day + days;
    
    if (days >= 0) {
      // Adding days - move forward
      while (newDay > daysInMonth(newYear, newMonth)) {
        newDay -= daysInMonth(newYear, newMonth);
        newMonth++;
        if (newMonth > 12) {
          newMonth = 1;
          newYear++;
        }
      }
    } else {
      // Subtracting days - move backward
      while (newDay < 1) {
        newMonth--;
        if (newMonth < 1) {
          newMonth = 12;
          newYear--;
        }
        newDay += daysInMonth(newYear, newMonth);
      }
    }
    
    return MisriHijriDate(newYear, newMonth, newDay);
  }

  /// Add months to this date
  MisriHijriDate addMonths(int months) {
    int newMonth = month + months;
    int newYear = year;
    
    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }
    
    int maxDay = daysInMonth(newYear, newMonth);
    int newDay = day > maxDay ? maxDay : day;
    
    return MisriHijriDate(newYear, newMonth, newDay);
  }

  /// Check if this date is before another date
  bool isBefore(MisriHijriDate other) {
    if (year != other.year) return year < other.year;
    if (month != other.month) return month < other.month;
    return day < other.day;
  }

  /// Check if this date is after another date
  bool isAfter(MisriHijriDate other) {
    if (year != other.year) return year > other.year;
    if (month != other.month) return month > other.month;
    return day > other.day;
  }

  /// Check if this date is the same as another date
  bool isSameDay(MisriHijriDate other) {
    return year == other.year && month == other.month && day == other.day;
  }

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) {
    if (other is MisriHijriDate) {
      return year == other.year && month == other.month && day == other.day;
    }
    return false;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;
}
