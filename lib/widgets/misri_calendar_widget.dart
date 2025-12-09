import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/misri_hijri_date.dart';
import '../services/booking_service.dart';

/// Custom Hijri Calendar Widget for Dawoodi Bohra (Misri Calendar)
class MisriHijriCalendar extends StatefulWidget {
  final MisriHijriDate focusedMonth;
  final MisriHijriDate? selectedDay;
  final Map<String, DateAvailability> availability;
  final Function(MisriHijriDate) onDaySelected;
  final Function(MisriHijriDate) onPageChanged;
  final bool Function(MisriHijriDate)? enabledDayPredicate;

  const MisriHijriCalendar({
    super.key,
    required this.focusedMonth,
    this.selectedDay,
    required this.availability,
    required this.onDaySelected,
    required this.onPageChanged,
    this.enabledDayPredicate,
  });

  @override
  State<MisriHijriCalendar> createState() => _MisriHijriCalendarState();
}

class _MisriHijriCalendarState extends State<MisriHijriCalendar> {
  late MisriHijriDate _currentMonth;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.focusedMonth;
    _pageController = PageController(initialPage: 1000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = _currentMonth.addMonths(-1);
    });
    widget.onPageChanged(_currentMonth);
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = _currentMonth.addMonths(1);
    });
    widget.onPageChanged(_currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Year
            _buildYearHeader(),
            const SizedBox(height: 8),
            // Month Navigation
            _buildMonthHeader(),
            const SizedBox(height: 16),
            // Day Names Row
            _buildDayNamesRow(),
            const SizedBox(height: 8),
            // Calendar Grid
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildYearHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkBrown,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${_currentMonth.year}H',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            MisriHijriDate.toArabicNumeral(_currentMonth.year),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Arial',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.darkBrown, size: 30),
          onPressed: _goToPreviousMonth,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                _currentMonth.monthName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBrown,
                ),
              ),
              Text(
                _currentMonth.arabicMonthName,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.darkBrown, size: 30),
          onPressed: _goToNextMonth,
        ),
      ],
    );
  }

  Widget _buildDayNamesRow() {
    const dayAbbr = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: dayAbbr.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: day == 'Fri' ? AppColors.darkBrown : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    // Get first day of the month
    final firstDay = MisriHijriDate.firstDayOfMonth(_currentMonth.year, _currentMonth.month);
    final daysInMonth = MisriHijriDate.daysInMonth(_currentMonth.year, _currentMonth.month);
    
    // Get weekday of first day (0 = Sunday)
    final startWeekday = firstDay.weekday;
    
    // Calculate total cells needed (leading empty + days)
    final totalCells = ((startWeekday + daysInMonth) / 7).ceil() * 7;
    
    List<Widget> rows = [];
    List<Widget> currentRow = [];
    
    for (int i = 0; i < totalCells; i++) {
      if (i < startWeekday || i >= startWeekday + daysInMonth) {
        // Empty cell
        currentRow.add(const Expanded(child: SizedBox(height: 48)));
      } else {
        // Day cell
        int day = i - startWeekday + 1;
        final hijriDate = MisriHijriDate(_currentMonth.year, _currentMonth.month, day);
        currentRow.add(Expanded(child: _buildDayCell(hijriDate)));
      }
      
      if (currentRow.length == 7) {
        rows.add(Row(children: currentRow));
        currentRow = [];
      }
    }
    
    return Column(children: rows);
  }

  Widget _buildDayCell(MisriHijriDate date) {
    final today = MisriHijriDate.now();
    final isToday = date.isSameDay(today);
    final isSelected = widget.selectedDay != null && date.isSameDay(widget.selectedDay!);
    final isPast = date.isBefore(today);
    
    // Check if day is enabled
    bool isEnabled = true;
    if (widget.enabledDayPredicate != null) {
      isEnabled = widget.enabledDayPredicate!(date);
    }
    isEnabled = isEnabled && !isPast;
    
    // Get availability status using GREGORIAN date string (matches booking service keys)
    final gregorian = date.toGregorian();
    final dateStr = '${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(2, '0')}';
    final avail = widget.availability[dateStr];
    
    Color bgColor = Colors.transparent;
    Color textColor = AppColors.textPrimary;
    
    if (!isEnabled) {
      textColor = AppColors.textLight;
    } else if (isSelected) {
      bgColor = AppColors.darkBrown;
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = AppColors.lightBrown.withOpacity(0.3);
      textColor = AppColors.darkBrown;
    } else if (avail != null) {
      switch (avail.status) {
        case AvailabilityStatus.available:
          bgColor = AppColors.available.withOpacity(0.2);
          break;
        case AvailabilityStatus.partial:
          bgColor = AppColors.partiallyFilled.withOpacity(0.2);
          break;
        case AvailabilityStatus.full:
          bgColor = AppColors.fullyBooked.withOpacity(0.2);
          textColor = AppColors.textLight;
          break;
        case AvailabilityStatus.notAvailable:
          bgColor = AppColors.notAvailable.withOpacity(0.1);
          textColor = AppColors.textLight;
          break;
      }
    } else if (isEnabled) {
      // For enabled dates with no booking data, show as Available (green)
      bgColor = AppColors.available.withOpacity(0.2);
    }
    
    return GestureDetector(
      onTap: isEnabled ? () => widget.onDaySelected(date) : null,
      child: Container(
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected 
              ? Border.all(color: AppColors.darkBrown, width: 2)
              : null,
          boxShadow: isEnabled && bgColor != Colors.transparent
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            date.dayArabic,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Calendar Legend Widget
class MisriCalendarLegend extends StatelessWidget {
  const MisriCalendarLegend({super.key});

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
