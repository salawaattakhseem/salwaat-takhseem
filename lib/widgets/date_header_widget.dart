import 'package:flutter/material.dart';
import '../utils/misri_hijri_date.dart';

/// Date Header Widget showing both Gregorian and Hijri dates
/// Like the Mumineen Calendar website header
class DateHeaderWidget extends StatelessWidget {
  const DateHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hijriDate = MisriHijriDate.now();
    
    // Weekday names
    const weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[now.weekday % 7].toUpperCase();
    final gregorianMonth = months[now.month - 1];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade100,
            Colors.amber.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Gregorian date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weekday,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${now.day.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  height: 1,
                ),
              ),
              Text(
                '$gregorianMonth ${now.year}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          
          // Right side - Hijri date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hijriDate.dayArabic,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hijriDate.arabicMonthName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '${hijriDate.yearArabic} هـ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
