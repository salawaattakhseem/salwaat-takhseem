// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:iconsax/iconsax.dart';
// import '../../config/theme.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_text_field.dart';
// import '../../widgets/custom_app_bar.dart';
// import '../../utils/validators.dart';
// import '../../utils/helpers.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _itsController = TextEditingController();
//   bool _isLoading = false;
//   bool _emailSent = false;

//   @override
//   void dispose() {
//     _itsController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleResetPassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final authProvider = context.read<AuthProvider>();
//     final success = await authProvider.resetPassword(_itsController.text.trim());

//     setState(() {
//       _isLoading = false;
//       _emailSent = success;
//     });

//     if (success && mounted) {
//       Helpers.showSnackBar(
//         context,
//         'Password reset instructions sent',
//       );
//     } else if (mounted) {
//       Helpers.showSnackBar(
//         context,
//         authProvider.errorMessage ?? 'Failed to send reset email',
//         isError: true,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(title: 'Forgot Password'),
//       backgroundColor: AppColors.creamBackground,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 20),
                
//                 // Icon
//                 Center(
//                   child: Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: AppColors.lightBrown.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       _emailSent ? Iconsax.tick_circle : Iconsax.lock_1,
//                       size: 40,
//                       color: AppColors.darkBrown,
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 24),
                
//                 Text(
//                   _emailSent ? 'Check Your Email' : 'Reset Password',
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.darkBrown,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
                
//                 const SizedBox(height: 12),
                
//                 Text(
//                   _emailSent
//                       ? 'We have sent password reset instructions to your registered email.'
//                       : 'Enter your ITS number and we\'ll send you instructions to reset your password.',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textSecondary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
                
//                 const SizedBox(height: 32),
                
//                 if (!_emailSent) ...[
//                   Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         children: [
//                           CustomTextField(
//                             label: 'ITS Number',
//                             hint: 'Enter your 8-digit ITS number',
//                             controller: _itsController,
//                             keyboardType: TextInputType.number,
//                             prefixIcon: const Icon(Iconsax.user, color: AppColors.textLight),
//                             validator: Validators.validateITS,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                               LengthLimitingTextInputFormatter(8),
//                             ],
//                           ),
                          
//                           const SizedBox(height: 24),
                          
//                           CustomButton(
//                             text: 'Send Reset Link',
//                             onPressed: _handleResetPassword,
//                             isLoading: _isLoading,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ] else ...[
//                   CustomButton(
//                     text: 'Back to Login',
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }