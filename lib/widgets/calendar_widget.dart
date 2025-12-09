import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';
import '../config/theme.dart';
import '../services/booking_service.dart';
import '../utils/date_utils.dart';

class BookingCalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<String, DateAvailability> availability;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const BookingCalendarWidget({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.availability,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: AppDateUtils.eventStartDate,
          lastDay: AppDateUtils.eventEndDate,
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            headerPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          calendarBuilders: CalendarBuilders(
            // Custom header showing both Gregorian and Hijri dates
            headerTitleBuilder: (context, day) {
              final hijri = HijriCalendar.fromDate(day);
              return Column(
                children: [
                  Text(
                    '${AppDateUtils.getMonthName(day.month)} ${day.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppDateUtils.getHijriMonthYear(day),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              );
            },
            defaultBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, false);
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, false, isToday: true);
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, true);
            },
            disabledBuilder: (context, day, focusedDay) {
              return _buildDisabledCell(day);
            },
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: const TextStyle(
              color: AppColors.textPrimary,
            ),
            weekendTextStyle: const TextStyle(
              color: AppColors.textPrimary,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.darkBrown,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.lightBrown.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: AppColors.darkBrown,
              fontWeight: FontWeight.w600,
            ),
            markerDecoration: const BoxDecoration(
              color: AppColors.darkBrown,
              shape: BoxShape.circle,
            ),
          ),
          enabledDayPredicate: (day) {
            return AppDateUtils.isWithinEventPeriod(day) &&
                !AppDateUtils.isPastDate(day);
          },
          onDaySelected: onDaySelected,
          onPageChanged: onPageChanged,
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isSelected, {bool isToday = false}) {
    final dateStr = AppDateUtils.formatDate(day);
    final avail = availability[dateStr];
    
    Color bgColor;
    Color textColor;
    
    if (isSelected) {
      bgColor = AppColors.darkBrown;
      textColor = AppColors.white;
    } else if (avail != null) {
      switch (avail.status) {
        case AvailabilityStatus.available:
          bgColor = AppColors.available.withOpacity(0.3);
          textColor = AppColors.textPrimary;
          break;
        case AvailabilityStatus.partial:
          bgColor = AppColors.partiallyFilled.withOpacity(0.3);
          textColor = AppColors.textPrimary;
          break;
        case AvailabilityStatus.full:
          bgColor = AppColors.fullyBooked.withOpacity(0.3);
          textColor = AppColors.textPrimary;
          break;
        case AvailabilityStatus.notAvailable:
          bgColor = AppColors.notAvailable.withOpacity(0.3);
          textColor = AppColors.textLight;
          break;
      }
    } else {
      bgColor = isToday ? AppColors.lightBrown.withOpacity(0.3) : Colors.transparent;
      textColor = AppColors.textPrimary;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(color: AppColors.darkBrown, width: 1.5)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (avail != null && !isSelected)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getStatusColor(avail.status),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledCell(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.notAvailable.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: const TextStyle(
            color: AppColors.textLight,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return AppColors.available;
      case AvailabilityStatus.partial:
        return AppColors.partiallyFilled;
      case AvailabilityStatus.full:
        return AppColors.fullyBooked;
      case AvailabilityStatus.notAvailable:
        return AppColors.notAvailable;
    }
  }
}

// Legend Widget
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Available', AppColors.available),
          _buildLegendItem('Partial', AppColors.partiallyFilled),
          _buildLegendItem('Full', AppColors.fullyBooked),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}