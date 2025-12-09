import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../providers/mohallah_provider.dart';
import '../../services/database_service.dart';
import '../../models/attendance_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/helpers.dart';
import '../../utils/misri_hijri_date.dart';

class ManageAttendanceScreen extends StatefulWidget {
  const ManageAttendanceScreen({super.key});

  @override
  State<ManageAttendanceScreen> createState() => _ManageAttendanceScreenState();
}

class _ManageAttendanceScreenState extends State<ManageAttendanceScreen> {
  final _databaseService = DatabaseService();
  final _countController = TextEditingController();
  final _noteController = TextEditingController();
  
  List<AttendanceModel> _attendanceList = [];
  bool _isLoading = true;
  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  @override
  void dispose() {
    _countController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendance() async {
    final mohallahProvider = context.read<MohallahProvider>();
    final mohallah = mohallahProvider.selectedMohallah;
    if (mohallah == null) return;

    setState(() => _isLoading = true);
    
    try {
      _attendanceList = await _databaseService.getAttendanceByMohallah(mohallah.name);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
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
        _selectedDate = picked;
      });
      
      // Load existing attendance for this date
      final mohallahProvider = context.read<MohallahProvider>();
      final mohallah = mohallahProvider.selectedMohallah;
      if (mohallah != null) {
        final dateString = Helpers.formatDateAPI(picked);
        final existing = await _databaseService.getAttendance(mohallah.name, dateString);
        if (existing != null) {
          _countController.text = existing.expectedCount.toString();
          _noteController.text = existing.note ?? '';
        } else {
          _countController.clear();
          _noteController.clear();
        }
      }
    }
  }

  Future<void> _saveAttendance() async {
    if (_selectedDate == null) {
      Helpers.showSnackBar(context, 'Please select a date', isError: true);
      return;
    }
    
    final countText = _countController.text.trim();
    if (countText.isEmpty) {
      Helpers.showSnackBar(context, 'Please enter expected count', isError: true);
      return;
    }
    
    final count = int.tryParse(countText);
    if (count == null || count < 0) {
      Helpers.showSnackBar(context, 'Please enter a valid number', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final mohallahProvider = context.read<MohallahProvider>();
      final mohallah = mohallahProvider.selectedMohallah;
      if (mohallah == null) return;

      final dateString = Helpers.formatDateAPI(_selectedDate!);
      final success = await _databaseService.upsertAttendance(
        mohallah.name,
        dateString,
        count,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      if (mounted) {
        if (success) {
          Helpers.showSnackBar(context, 'Attendance count saved successfully');
          _countController.clear();
          _noteController.clear();
          _selectedDate = null;
          await _loadAttendance();
        } else {
          Helpers.showSnackBar(context, 'Failed to save attendance count', isError: true);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteAttendance(AttendanceModel attendance) async {
    final confirmed = await Helpers.showConfirmationDialog(
      context,
      title: 'Delete Attendance',
      message: 'Are you sure you want to delete this attendance count?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirmed) return;

    final mohallahProvider = context.read<MohallahProvider>();
    final mohallah = mohallahProvider.selectedMohallah;
    if (mohallah == null) return;

    final success = await _databaseService.deleteAttendance(mohallah.name, attendance.date);
    if (mounted) {
      if (success) {
        Helpers.showSnackBar(context, 'Attendance count deleted');
        await _loadAttendance();
      } else {
        Helpers.showSnackBar(context, 'Failed to delete', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Manage Attendance'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'img/Fatemi_Design.png',
            fit: BoxFit.cover,
          ),
          // Light blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add/Edit Form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Set Expected Attendance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date Selection
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.paleGold),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Iconsax.calendar_1,
                                color: AppColors.darkBrown,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedDate != null
                                          ? Helpers.formatDateDisplay(_selectedDate!)
                                          : 'Select a date',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _selectedDate != null
                                            ? AppColors.textPrimary
                                            : AppColors.textLight,
                                      ),
                                    ),
                                    if (_selectedDate != null)
                                      Text(
                                        'Misri: ${MisriHijriDate.fromGregorian(_selectedDate!).format()}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.textLight,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Expected Count
                      CustomTextField(
                        label: 'Expected Attendance',
                        hint: 'Enter expected number of people',
                        controller: _countController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Note (optional)
                      CustomTextField(
                        label: 'Note (Optional)',
                        hint: 'Add any notes',
                        controller: _noteController,
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      CustomButton(
                        text: 'Save Attendance',
                        icon: Iconsax.tick_circle,
                        onPressed: _saveAttendance,
                        isLoading: _isSaving,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Existing Attendance List
                const Text(
                  'Saved Attendance Counts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppColors.darkBrown),
                    ),
                  )
                else if (_attendanceList.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'No attendance counts set yet',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _attendanceList.length,
                    itemBuilder: (context, index) {
                      final attendance = _attendanceList[index];
                      final date = DateTime.tryParse(attendance.date);
                      final isUpcoming = date != null && date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUpcoming ? AppColors.available.withOpacity(0.3) : AppColors.paleGold,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUpcoming 
                                    ? AppColors.available.withOpacity(0.1)
                                    : AppColors.paleGold.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Iconsax.people,
                                color: isUpcoming ? AppColors.available : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    date != null ? Helpers.formatDateDisplay(date) : attendance.date,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${attendance.expectedCount} people expected',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isUpcoming ? AppColors.available : AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (attendance.note != null && attendance.note!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        attendance.note!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Iconsax.trash, color: Colors.red, size: 20),
                              onPressed: () => _deleteAttendance(attendance),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
