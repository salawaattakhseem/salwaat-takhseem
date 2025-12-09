import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_app_bar.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      Helpers.showSnackBar(context, 'Passwords do not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updatePassword(_newPasswordController.text);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Helpers.showSnackBar(context, 'Password changed successfully');
      Navigator.pop(context);
    } else if (mounted) {
      Helpers.showSnackBar(
        context,
        authProvider.errorMessage ?? 'Failed to change password',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Change Password'),
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.lightBrown.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.key,
                      size: 40,
                      color: AppColors.darkBrown,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'Create New Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                const Text(
                  'Your new password must be different from previously used passwords.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
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
                          label: 'New Password',
                          hint: 'Enter new password',
                          controller: _newPasswordController,
                          obscureText: true,
                          prefixIcon: const Icon(Iconsax.lock, color: AppColors.textLight),
                          validator: Validators.validatePassword,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        CustomTextField(
                          label: 'Confirm Password',
                          hint: 'Confirm new password',
                          controller: _confirmPasswordController,
                          obscureText: true,
                          prefixIcon: const Icon(Iconsax.lock_1, color: AppColors.textLight),
                          validator: (value) {
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return Validators.validatePassword(value);
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        CustomButton(
                          text: 'Change Password',
                          onPressed: _handleChangePassword,
                          isLoading: _isLoading,
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
    );
  }
}