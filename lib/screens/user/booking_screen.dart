import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/booking_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/premium_widgets.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../utils/date_utils.dart';
import 'package:confetti/confetti.dart';

class BookingScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const BookingScreen({super.key, this.selectedDate});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  DateAvailability? _availability;
  bool _isLoading = false;
  bool _isBooking = false;
  
  // Partner management
  bool _addPartners = false;
  int _partnerCount = 1; // 1-4 partners allowed
  final List<TextEditingController> _partnerControllers = [];
  final List<String?> _validatedPartnerNames = [];
  final List<bool> _isValidatingPartner = [];
  
  // Confetti controller
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadAvailability();
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
    _itemController.dispose();
    _confettiController.dispose();
    for (var controller in _partnerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    if (widget.selectedDate == null) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final bookingService = BookingService();

    if (authProvider.currentUser != null) {
      final availability = await bookingService.getDateAvailability(
        AppDateUtils.formatDate(widget.selectedDate!),
        authProvider.currentUser!.mohallah,
      );

      setState(() {
        _availability = availability;
        _isLoading = false;
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

    final authProvider = context.read<AuthProvider>();
    setState(() => _isValidatingPartner[index] = true);

    final bookingService = BookingService();
    final result = await bookingService.validatePartnerIts(
      partnerIts,
      authProvider.currentUser!.mohallah,
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

  Future<void> _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.selectedDate == null) return;

    setState(() => _isBooking = true);

    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    final partnerItsList = _getPartnerItsList();

    final result = await bookingProvider.createBooking(
      its: authProvider.currentUser!.its,
      mohallah: authProvider.currentUser!.mohallah,
      date: AppDateUtils.formatDate(widget.selectedDate!),
      item: _itemController.text.trim(),
      partnerItsList: partnerItsList,
    );

    setState(() => _isBooking = false);

    if (mounted) {
      if (result.success) {
        // Show confetti celebration!
        _confettiController.play();
        
        // Show success dialog - user can enjoy the celebration
        await SuccessDialog.show(
          context,
          title: 'Booking Confirmed! 🎉',
          message: 'Your slot has been reserved successfully.',
          buttonText: 'Continue',
          onPressed: () {
            Navigator.pop(context); // Close dialog
          },
        );
        
        // Navigate back to dashboard after dialog closed
        if (mounted) {
          Navigator.pop(context); // Close booking screen
          Navigator.pop(context); // Close calendar → go to dashboard
        }
      } else {
        Helpers.showSnackBar(context, result.message, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.selectedDate;

    if (date == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Book Slot'),
        body: const Center(child: Text('No date selected')),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Book Slot'),
      body: ConfettiOverlay(
        controller: _confettiController,
        child: Stack(
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
            isLoading: _isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkBrown,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${date.day}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                AppDateUtils.getShortMonthName(date.month),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppDateUtils.getFullDayName(date),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppDateUtils.getMonthName(date.month)} ${date.year}',
                                style: const TextStyle(
                                  fontSize: 14,
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
                
                const SizedBox(height: 20),
                
                // Availability Card
                if (_availability != null)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_availability!.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getStatusIcon(_availability!.status),
                              color: _getStatusColor(_availability!.status),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _availability!.displayText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(_availability!.status),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_availability!.availableSlots} of ${_availability!.totalSlots} slots available',
                                  style: const TextStyle(
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
                
                // Item Input
                if (_availability != null && _availability!.status != AvailabilityStatus.full) ...[
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
                            'What will you be distributing?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Item Name',
                            hint: 'e.g., Food Packets, Gift Boxes',
                            controller: _itemController,
                            prefixIcon: const Icon(Iconsax.box, color: AppColors.textLight),
                            validator: Validators.validateItemName,
                            textCapitalization: TextCapitalization.words,
                          ),
                          
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          // Partners Toggle
                          Row(
                            children: [
                              Checkbox(
                                value: _addPartners,
                                onChanged: (value) {
                                  setState(() {
                                    _addPartners = value ?? false;
                                    if (!_addPartners) {
                                      for (var controller in _partnerControllers) {
                                        controller.clear();
                                      }
                                      for (int i = 0; i < _validatedPartnerNames.length; i++) {
                                        _validatedPartnerNames[i] = null;
                                      }
                                    }
                                  });
                                },
                                activeColor: AppColors.mediumBrown,
                              ),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add Partners (Optional)',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Up to 4 partners giving together as one booking',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          // Partner Count and Fields
                          if (_addPartners) ...[
                            const SizedBox(height: 16),
                            
                            // Partner count dropdown
                            Row(
                              children: [
                                const Text(
                                  'Number of Partners: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.lightBrown),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<int>(
                                    value: _partnerCount,
                                    underline: const SizedBox(),
                                    items: [1, 2, 3, 4].map((count) {
                                      return DropdownMenuItem(
                                        value: count,
                                        child: Text('$count'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _partnerCount = value ?? 1;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Dynamic Partner ITS Fields
                            for (int i = 0; i < _partnerCount; i++) ...[
                              CustomTextField(
                                label: 'Partner ${i + 1} ITS Number',
                                hint: 'Enter 8-digit ITS',
                                controller: _partnerControllers[i],
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(Iconsax.user_add, color: AppColors.textLight),
                                onChanged: (value) => _validatePartnerIts(i, value),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(8),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (_isValidatingPartner[i])
                                const Row(
                                  children: [
                                    SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 6),
                                    Text('Validating...', style: TextStyle(fontSize: 11)),
                                  ],
                                )
                              else if (_validatedPartnerNames[i] != null)
                                Row(
                                  children: [
                                    const Icon(Iconsax.tick_circle, color: AppColors.available, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '✓ ${_validatedPartnerNames[i]}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.available,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else if (_partnerControllers[i].text.length == 8)
                                const Row(
                                  children: [
                                    Icon(Iconsax.close_circle, color: AppColors.fullyBooked, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Not found or different Mohallah',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.fullyBooked,
                                      ),
                                    ),
                                  ],
                                ),
                              if (i < _partnerCount - 1) const SizedBox(height: 12),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  CustomButton(
                    text: _addPartners && _getPartnerItsList().isNotEmpty 
                        ? 'Confirm Group Booking (${1 + _getPartnerItsList().length} people)' 
                        : 'Confirm Booking',
                    onPressed: _handleBooking,
                    isLoading: _isBooking,
                    icon: Iconsax.tick_circle,
                  ),
                ],
                
                // Full message
                if (_availability != null && _availability!.status == AvailabilityStatus.full)
                  Card(
                    elevation: 0,
                    color: AppColors.fullyBooked.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            size: 48,
                            color: AppColors.fullyBooked,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'This date is fully booked',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please select another date from the calendar',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
        ],
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

  IconData _getStatusIcon(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return Iconsax.tick_circle;
      case AvailabilityStatus.partial:
        return Iconsax.warning_2;
      case AvailabilityStatus.full:
        return Iconsax.close_circle;
      case AvailabilityStatus.notAvailable:
        return Iconsax.minus_cirlce;
    }
  }
}