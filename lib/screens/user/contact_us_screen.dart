import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_app_bar.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _databaseService = DatabaseService();
  String? _subAdminName;
  String? _subAdminMobile;
  bool _isLoading = true;

  // Fixed Admin contacts
  final List<Map<String, String>> _adminContacts = [
    {'name': 'Abdullah Kapadia', 'mobile': '8320021832'},
    {'name': 'Taher Bootwala', 'mobile': '9484514813'},
    {'name': 'Yusuf Gundarwala', 'mobile': '9409086874'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSubAdminDetails();
  }

  Future<void> _loadSubAdminDetails() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user != null) {
      try {
        // Get mohallah details to find subadmin ITS
        final mohallah = await _databaseService.getMohallahByName(user.mohallah);
        if (mohallah != null && mohallah.subadminIts != null) {
          // Get subadmin user details
          final subAdmin = await _databaseService.getUser(mohallah.subadminIts!);
          if (subAdmin != null) {
            setState(() {
              _subAdminName = subAdmin.fullName;
              _subAdminMobile = subAdmin.mobile;
            });
          }
        }
      } catch (e) {
        print('Error loading subadmin: $e');
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri.parse('https://wa.me/91$phoneNumber');
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp'),
            backgroundColor: AppColors.fullyBooked,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Contact Us'),
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
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          // Content
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.darkBrown))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'Need Help?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reach out to your Mohallah SubAdmin or the App Admins',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // SubAdmin Section
                      if (_subAdminName != null) ...[
                        _buildSectionHeader(
                          icon: Iconsax.building,
                          title: 'Your Mohallah SubAdmin',
                          subtitle: user?.mohallah ?? '',
                        ),
                        const SizedBox(height: 12),
                        _buildContactCard(
                          name: _subAdminName!,
                          mobile: _subAdminMobile ?? '',
                          role: 'SubAdmin',
                          roleColor: AppColors.mediumBrown,
                        ),
                        const SizedBox(height: 28),
                      ] else ...[
                        _buildSectionHeader(
                          icon: Iconsax.building,
                          title: 'Your Mohallah SubAdmin',
                          subtitle: user?.mohallah ?? '',
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Icon(Iconsax.info_circle, color: AppColors.textLight),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No SubAdmin assigned to your Mohallah yet',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                      
                      // Admin Section
                      _buildSectionHeader(
                        icon: Iconsax.shield_tick,
                        title: 'App Admins',
                        subtitle: 'For technical support & queries',
                      ),
                      const SizedBox(height: 12),
                      
                      ..._adminContacts.map((admin) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildContactCard(
                          name: admin['name']!,
                          mobile: admin['mobile']!,
                          role: 'Admin',
                          roleColor: AppColors.darkBrown,
                        ),
                      )),
                      
                      const SizedBox(height: 28),
                      
                      // Donation Section
                      _buildSectionHeader(
                        icon: Iconsax.heart,
                        title: 'Support Us',
                        subtitle: 'Help us maintain this app',
                      ),
                      const SizedBox(height: 12),
                      
                      _buildDonationCard(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.lightBrown.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.darkBrown, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required String name,
    required String mobile,
    required String role,
    required Color roleColor,
  }) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.darkBrown.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: roleColor.withOpacity(0.15),
                  child: Text(
                    name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: roleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mobile,
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
            const SizedBox(height: 12),
            // Action buttons row
            Row(
              children: [
                // Call button
                Expanded(
                  child: InkWell(
                    onTap: () => _makePhoneCall(mobile),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Iconsax.call, color: Colors.green, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Call',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // WhatsApp button
                Expanded(
                  child: InkWell(
                    onTap: () => _sendWhatsApp(mobile),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.chat, color: Color(0xFF25D366), size: 18),
                          SizedBox(width: 6),
                          Text(
                            'WhatsApp',
                            style: TextStyle(
                              color: Color(0xFF25D366),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard() {
    return Card(
      elevation: 3,
      shadowColor: AppColors.darkBrown.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.softBeige,
              AppColors.lightBrown.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.lovely,
                      color: Colors.pink,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Like this app?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your support helps us keep improving!',
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
              const SizedBox(height: 20),
              
              // Donate Button
              InkWell(
                onTap: () => _openUpiPayment(53),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Donate ₹53 via UPI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Other amounts row
              Row(
                children: [
                  Expanded(child: _buildAmountButton(21)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildAmountButton(101)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildAmountButton(251)),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Note/Remark
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lightBrown.withOpacity(0.5)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Iconsax.info_circle, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Every small contribution makes a big difference. JazakAllah Khair! 🤲',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountButton(int amount) {
    return InkWell(
      onTap: () => _openUpiPayment(amount),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.lightBrown),
        ),
        child: Center(
          child: Text(
            '₹$amount',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkBrown,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUpiPayment(int amount) async {
    const upiId = 'yusufgunderwala0@oksbi';
    const payeeName = 'Salwaat Takhseem';
    const note = 'Salwaat Takhseem App';
    
    // Encode the note for URL
    final encodedNote = Uri.encodeComponent(note);
    final encodedName = Uri.encodeComponent(payeeName);
    
    final upiUrl = 'upi://pay?pa=$upiId&pn=$encodedName&am=$amount&cu=INR&tn=$encodedNote';
    
    final Uri uri = Uri.parse(upiUrl);
    
    try {
      // Try to launch directly without checking
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open UPI app. Please make sure GPay, PhonePe, or Paytm is installed.'),
            backgroundColor: AppColors.fullyBooked,
          ),
        );
      }
    }
  }
}
