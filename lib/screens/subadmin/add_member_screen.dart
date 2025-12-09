import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mohallah_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itsController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _itsController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _handleAddMember() async {
    if (!_formKey.currentState!.validate()) return;

    final mohallahProvider = context.read<MohallahProvider>();
    final userProvider = context.read<UserProvider>();

    if (mohallahProvider.selectedMohallah == null) {
      Helpers.showSnackBar(context, 'Mohallah not found', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final success = await userProvider.createUser(
      its: _itsController.text.trim(),
      fullName: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      mohallah: mohallahProvider.selectedMohallah!.name,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Helpers.showSnackBar(context, 'Member added successfully');
      Navigator.pop(context);
    } else if (mounted) {
      Helpers.showSnackBar(
        context,
        userProvider.errorMessage ?? 'Failed to add member',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mohallahProvider = context.watch<MohallahProvider>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Member'),
      backgroundColor: AppColors.creamBackground,
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mohallah Info
                Card(
                  elevation: 0,
                  color: AppColors.softBeige,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.building,
                          color: AppColors.darkBrown,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Adding to: ${mohallahProvider.selectedMohallah?.name ?? "Unknown"}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Form Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'ITS Number',
                          hint: 'Enter 8-digit ITS number',
                          controller: _itsController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Iconsax.user, color: AppColors.textLight),
                          validator: Validators.validateITS,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        CustomTextField(
                          label: 'Full Name',
                          hint: 'Enter full name',
                          controller: _nameController,
                          prefixIcon: const Icon(Iconsax.user_octagon, color: AppColors.textLight),
                          validator: Validators.validateName,
                          textCapitalization: TextCapitalization.words,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        CustomTextField(
                          label: 'Mobile Number',
                          hint: 'Enter mobile number',
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Iconsax.call, color: AppColors.textLight),
                          validator: Validators.validateMobile,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Note
                Card(
                  elevation: 0,
                  color: AppColors.softBeige,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Default password will be \"sw\" + last 4 digits of ITS (e.g. sw0026)',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                CustomButton(
                  text: 'Add Member',
                  onPressed: _handleAddMember,
                  icon: Iconsax.user_add,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}