import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../providers/mohallah_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../utils/helpers.dart';

class BookingSettingsScreen extends StatefulWidget {
  const BookingSettingsScreen({super.key});

  @override
  State<BookingSettingsScreen> createState() => _BookingSettingsScreenState();
}

class _BookingSettingsScreenState extends State<BookingSettingsScreen> {
  bool _bookingEnabled = true;
  DateTime? _bookingStartDate;
  DateTime? _bookingEndDate;
  DateTime? _eventStartDate;
  DateTime? _eventEndDate;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final mohallahProvider = context.read<MohallahProvider>();
    final mohallah = mohallahProvider.selectedMohallah;
    if (mohallah != null) {
      setState(() {
        _bookingEnabled = mohallah.bookingEnabled;
        _bookingStartDate = mohallah.bookingStartDate;
        _bookingEndDate = mohallah.bookingEndDate;
        _eventStartDate = mohallah.eventStartDate;
        _eventEndDate = mohallah.eventEndDate;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _getInitialDate(field) ?? now;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkBrown,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _hasChanges = true;
        switch (field) {
          case 'bookingStart':
            _bookingStartDate = picked;
            break;
          case 'bookingEnd':
            _bookingEndDate = picked;
            break;
          case 'eventStart':
            _eventStartDate = picked;
            break;
          case 'eventEnd':
            _eventEndDate = picked;
            break;
        }
      });
    }
  }

  DateTime? _getInitialDate(String field) {
    switch (field) {
      case 'bookingStart':
        return _bookingStartDate;
      case 'bookingEnd':
        return _bookingEndDate;
      case 'eventStart':
        return _eventStartDate;
      case 'eventEnd':
        return _eventEndDate;
      default:
        return null;
    }
  }

  Future<void> _saveSettings() async {
    final mohallahProvider = context.read<MohallahProvider>();
    final mohallah = mohallahProvider.selectedMohallah;
    
    if (mohallah == null) return;

    // Validate date ranges
    if (_bookingStartDate != null && _bookingEndDate != null) {
      if (_bookingStartDate!.isAfter(_bookingEndDate!)) {
        Helpers.showSnackBar(context, 'Booking start date must be before end date', isError: true);
        return;
      }
    }

    if (_eventStartDate != null && _eventEndDate != null) {
      if (_eventStartDate!.isAfter(_eventEndDate!)) {
        Helpers.showSnackBar(context, 'Event start date must be before end date', isError: true);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final success = await mohallahProvider.updateBookingSettings(
        mohallahId: mohallah.id,
        bookingEnabled: _bookingEnabled,
        bookingStartDate: _bookingStartDate,
        bookingEndDate: _bookingEndDate,
        eventStartDate: _eventStartDate,
        eventEndDate: _eventEndDate,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          _hasChanges = false;
          Helpers.showSnackBar(context, 'Booking settings saved successfully');
        } else {
          Helpers.showSnackBar(context, 'Failed to save settings', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mohallahProvider = context.watch<MohallahProvider>();
    final mohallah = mohallahProvider.selectedMohallah;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Booking Settings'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('img/Fatemi_Design.png', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(color: Colors.white.withOpacity(0.85)),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightBrown.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Iconsax.setting_2, color: AppColors.darkBrown),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mohallah?.name ?? 'Mohallah',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Configure booking window for your members',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Master Switch
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: SwitchListTile(
                    title: const Text(
                      'Enable Booking',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _bookingEnabled ? 'Members can book slots' : 'Booking is disabled',
                      style: TextStyle(
                        color: _bookingEnabled ? AppColors.available : AppColors.fullyBooked,
                      ),
                    ),
                    value: _bookingEnabled,
                    activeColor: AppColors.darkBrown,
                    onChanged: (value) {
                      setState(() {
                        _bookingEnabled = value;
                        _hasChanges = true;
                      });
                    },
                    secondary: Icon(
                      _bookingEnabled ? Iconsax.tick_circle : Iconsax.close_circle,
                      color: _bookingEnabled ? AppColors.available : AppColors.fullyBooked,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Booking Window Section
                const Text(
                  'Booking Window',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Set when members can START booking',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDateCard(
                        title: 'Booking Opens',
                        date: _bookingStartDate,
                        onTap: () => _selectDate(context, 'bookingStart'),
                        onClear: () {
                          setState(() {
                            _bookingStartDate = null;
                            _hasChanges = true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateCard(
                        title: 'Booking Closes',
                        date: _bookingEndDate,
                        onTap: () => _selectDate(context, 'bookingEnd'),
                        onClear: () {
                          setState(() {
                            _bookingEndDate = null;
                            _hasChanges = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Event Date Range Section
                const Text(
                  'Event Date Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Set which dates members can book FOR',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDateCard(
                        title: 'Event Starts',
                        date: _eventStartDate,
                        onTap: () => _selectDate(context, 'eventStart'),
                        onClear: () {
                          setState(() {
                            _eventStartDate = null;
                            _hasChanges = true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateCard(
                        title: 'Event Ends',
                        date: _eventEndDate,
                        onTap: () => _selectDate(context, 'eventEnd'),
                        onClear: () {
                          setState(() {
                            _eventEndDate = null;
                            _hasChanges = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Save Button
                CustomButton(
                  text: 'Save Settings',
                  onPressed: _hasChanges ? _saveSettings : null,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 16),

                // Info Card
                Card(
                  elevation: 1,
                  color: AppColors.softBeige,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Iconsax.info_circle, color: AppColors.darkBrown, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Leave dates empty to remove restrictions. If booking window is not set, members can book anytime.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (date != null)
                    GestureDetector(
                      onTap: onClear,
                      child: const Icon(
                        Iconsax.close_circle,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Iconsax.calendar_1,
                    size: 18,
                    color: date != null ? AppColors.darkBrown : AppColors.textLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Not set',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: date != null ? AppColors.textPrimary : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
