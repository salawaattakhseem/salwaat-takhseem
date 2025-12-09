import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/mohallah_provider.dart';
import '../../services/booking_service.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../utils/misri_hijri_date.dart';

class BookForMemberScreen extends StatefulWidget {
  const BookForMemberScreen({super.key});

  @override
  State<BookForMemberScreen> createState() => _BookForMemberScreenState();
}

class _BookForMemberScreenState extends State<BookForMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itsController = TextEditingController();
  final _itemController = TextEditingController();
  final _databaseService = DatabaseService();
  final _bookingService = BookingService();
  
  DateTime? _selectedDate;
  String? _memberName;
  bool _isSearchingMember = false;
  bool _isMemberValid = false;
  bool _isSubmitting = false;
  
  // Availability state
  int _bookingsOnDate = 0;
  int _bookingLimit = 0;
  bool _isCheckingAvailability = false;
  String? _availabilityStatus;
  
  // Partner management
  bool _addPartners = false;
  int _partnerCount = 1;
  final List<TextEditingController> _partnerControllers = [];
  final List<String?> _validatedPartnerNames = [];
  final List<bool> _isValidatingPartner = [];

  @override
  void initState() {
    super.initState();
    _initPartnerControllers();
  }

  void _initPartnerControllers() {
    for (int i = 0; i < 4; i++) {
      _partnerControllers.add(TextEditingController());
      _validatedPartnerNames.add(null);
      _isValidatingPartner.add(false);
    }
  }

  @override
  void dispose() {
    _itsController.dispose();
    _itemController.dispose();
    for (var controller in _partnerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _searchMember() async {
    final its = _itsController.text.trim();
    if (its.length != 8) {
      setState(() {
        _memberName = null;
        _isMemberValid = false;
      });
      return;
    }

    setState(() {
      _isSearchingMember = true;
    });

    try {
      final mohallahProvider = context.read<MohallahProvider>();
      final user = await _databaseService.getUser(its);
      
      if (user != null && user.mohallah == mohallahProvider.selectedMohallah?.name) {
        setState(() {
          _memberName = user.fullName;
          _isMemberValid = true;
        });
      } else if (user != null) {
        setState(() {
          _memberName = 'Member belongs to different Mohallah';
          _isMemberValid = false;
        });
      } else {
        setState(() {
          _memberName = 'Member not found';
          _isMemberValid = false;
        });
      }
    } catch (e) {
      setState(() {
        _memberName = 'Error searching member';
        _isMemberValid = false;
      });
    } finally {
      setState(() {
        _isSearchingMember = false;
      });
    }
  }

  Future<void> _validatePartnerIts(int index, String partnerIts) async {
    if (partnerIts.isEmpty || partnerIts.length != 8) {
      setState(() {
        _validatedPartnerNames[index] = null;
      });
      return;
    }

    final mohallahProvider = context.read<MohallahProvider>();
    setState(() => _isValidatingPartner[index] = true);

    final result = await _bookingService.validatePartnerIts(
      partnerIts,
      mohallahProvider.selectedMohallah!.name,
    );

    setState(() {
      _isValidatingPartner[index] = false;
      if (result?['success'] == true) {
        _validatedPartnerNames[index] = result!['name'];
      } else {
        _validatedPartnerNames[index] = null;
      }
    });
  }

  List<String> _getPartnerItsList() {
    if (!_addPartners) return [];
    return _partnerControllers
        .take(_partnerCount)
        .map((c) => c.text.trim())
        .where((its) => its.isNotEmpty)
        .toList();
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
        _availabilityStatus = null;
      });
      await _checkAvailability();
    }
  }

  Future<void> _checkAvailability() async {
    if (_selectedDate == null) return;
    
    final mohallahProvider = context.read<MohallahProvider>();
    final mohallah = mohallahProvider.selectedMohallah;
    if (mohallah == null) return;

    setState(() {
      _isCheckingAvailability = true;
    });

    try {
      final dateString = Helpers.formatDateAPI(_selectedDate!);
      final bookings = await _databaseService.getBookingsByDateAndMohallah(
        dateString,
        mohallah.name,
      );
      
      setState(() {
        _bookingsOnDate = bookings.length;
        _bookingLimit = mohallah.bookingLimit;
        
        if (_bookingsOnDate >= _bookingLimit) {
          _availabilityStatus = 'Full';
        } else if (_bookingsOnDate > 0) {
          _availabilityStatus = 'Partial';
        } else {
          _availabilityStatus = 'Available';
        }
      });
    } catch (e) {
      setState(() {
        _availabilityStatus = 'Error';
      });
    } finally {
      setState(() {
        _isCheckingAvailability = false;
      });
    }
  }

  Color _getAvailabilityColor() {
    switch (_availabilityStatus) {
      case 'Available':
        return AppColors.available;
      case 'Partial':
        return AppColors.partiallyFilled;
      case 'Full':
        return AppColors.fullyBooked;
      default:
        return AppColors.textLight;
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate() || !_isMemberValid || _selectedDate == null) {
      if (_selectedDate == null) {
        Helpers.showSnackBar(context, 'Please select a date', isError: true);
      }
      if (!_isMemberValid) {
        Helpers.showSnackBar(context, 'Please enter a valid member ITS', isError: true);
      }
      return;
    }

    // Check if date is fully booked
    if (_availabilityStatus == 'Full') {
      Helpers.showSnackBar(context, 'This date is fully booked. Please select another date.', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final mohallahProvider = context.read<MohallahProvider>();
      final dateString = Helpers.formatDateAPI(_selectedDate!);
      final partnerItsList = _getPartnerItsList();
      
      final result = await _bookingService.createBooking(
        its: _itsController.text.trim(),
        mohallah: mohallahProvider.selectedMohallah!.name,
        date: dateString,
        item: _itemController.text.trim(),
        partnerItsList: partnerItsList,
      );

      if (mounted) {
        Helpers.showSnackBar(
          context,
          result.message,
          isError: !result.success,
        );

        if (result.success) {
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mohallahProvider = context.watch<MohallahProvider>();
    final mohallah = mohallahProvider.selectedMohallah;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Book for Member'),
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
          LoadingOverlay(
            isLoading: _isSubmitting,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mohallah Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightBrown.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.building,
                            color: AppColors.darkBrown,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Booking for: ${mohallah?.name ?? "Unknown"}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Member ITS Field
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Member Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Member ITS Number',
                              hint: 'Enter 8-digit ITS number',
                              controller: _itsController,
                              keyboardType: TextInputType.number,
                              validator: Validators.validateITS,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8),
                              ],
                              onChanged: (value) {
                                if (value.length == 8) {
                                  _searchMember();
                                } else {
                                  setState(() {
                                    _memberName = null;
                                    _isMemberValid = false;
                                  });
                                }
                              },
                              suffixIcon: _isSearchingMember
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.darkBrown,
                                      ),
                                    )
                                  : _isMemberValid
                                      ? const Icon(Icons.check_circle, color: Colors.green)
                                      : null,
                            ),
                            if (_memberName != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _isMemberValid
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isMemberValid ? Iconsax.user : Iconsax.warning_2,
                                      size: 18,
                                      color: _isMemberValid ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _memberName!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _isMemberValid ? Colors.green[700] : Colors.red[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date Selection
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking Date',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                    const Spacer(),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      color: AppColors.textLight,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_selectedDate != null) ...[
                              const SizedBox(height: 12),
                              // Misri Hijri Date - using selected date
                              Text(
                                'Misri: ${MisriHijriDate.fromGregorian(_selectedDate!).format()}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Availability Status
                              if (_isCheckingAvailability)
                                const Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.darkBrown,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Checking availability...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                )
                              else if (_availabilityStatus != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _getAvailabilityColor().withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _getAvailabilityColor().withOpacity(0.5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _availabilityStatus == 'Full'
                                            ? Iconsax.close_circle
                                            : _availabilityStatus == 'Partial'
                                                ? Iconsax.warning_2
                                                : Iconsax.tick_circle,
                                        size: 18,
                                        color: _getAvailabilityColor(),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$_availabilityStatus ($_bookingsOnDate / $_bookingLimit booked)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: _getAvailabilityColor(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Item Field
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking Item',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Item',
                              hint: 'Enter item for salwaat (e.g., Sugar, Apple)',
                              controller: _itemController,
                              validator: Validators.validateItemName,
                              textCapitalization: TextCapitalization.words,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Group Booking Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.people,
                                  color: AppColors.darkBrown,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Group Booking',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: _addPartners,
                                  onChanged: (value) {
                                    setState(() {
                                      _addPartners = value;
                                      if (!value) {
                                        // Clear partner fields when disabled
                                        for (var controller in _partnerControllers) {
                                          controller.clear();
                                        }
                                        for (int i = 0; i < _validatedPartnerNames.length; i++) {
                                          _validatedPartnerNames[i] = null;
                                        }
                                        _partnerCount = 1;
                                      }
                                    });
                                  },
                                  activeColor: AppColors.darkBrown,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add partners to give salwaat together (max ${AppConstants.maxPartners})',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (_addPartners) ...[
                              const SizedBox(height: 16),
                              // Partner count selector
                              Row(
                                children: [
                                  const Text(
                                    'Number of partners:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.paleGold),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove, size: 18),
                                          onPressed: _partnerCount > 1
                                              ? () => setState(() => _partnerCount--)
                                              : null,
                                          color: AppColors.darkBrown,
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 36,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text(
                                            '$_partnerCount',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 18),
                                          onPressed: _partnerCount < AppConstants.maxPartners
                                              ? () => setState(() => _partnerCount++)
                                              : null,
                                          color: AppColors.darkBrown,
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 36,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Partner ITS fields
                              ...List.generate(_partnerCount, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextField(
                                        label: 'Partner ${index + 1} ITS',
                                        hint: 'Enter 8-digit ITS',
                                        controller: _partnerControllers[index],
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(8),
                                        ],
                                        onChanged: (value) {
                                          if (value.length == 8) {
                                            _validatePartnerIts(index, value);
                                          } else {
                                            setState(() {
                                              _validatedPartnerNames[index] = null;
                                            });
                                          }
                                        },
                                        suffixIcon: _isValidatingPartner[index]
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.darkBrown,
                                                ),
                                              )
                                            : _validatedPartnerNames[index] != null
                                                ? const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                    size: 20,
                                                  )
                                                : _partnerControllers[index].text.length == 8
                                                    ? const Icon(
                                                        Icons.error,
                                                        color: Colors.red,
                                                        size: 20,
                                                      )
                                                    : null,
                                      ),
                                      if (_validatedPartnerNames[index] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4, left: 4),
                                          child: Text(
                                            _validatedPartnerNames[index]!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    CustomButton(
                      text: _availabilityStatus == 'Full' 
                          ? 'Date Fully Booked' 
                          : _addPartners 
                              ? 'Create Group Booking'
                              : 'Create Booking',
                      icon: _addPartners ? Iconsax.people : Iconsax.calendar_add,
                      onPressed: _isMemberValid && _selectedDate != null && _availabilityStatus != 'Full'
                          ? _submitBooking
                          : null,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
