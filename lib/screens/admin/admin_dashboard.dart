import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mohallah_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/admin_background.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final mohallahProvider = context.read<MohallahProvider>();
    final userProvider = context.read<UserProvider>();
    final bookingProvider = context.read<BookingProvider>();

    await Future.wait([
      mohallahProvider.loadMohallahs(),
      userProvider.loadAllUsers(),
      bookingProvider.loadAllBookings(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final mohallahProvider = context.watch<MohallahProvider>();
    final userProvider = context.watch<UserProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    
    final user = authProvider.currentUser;
    final isLoading = mohallahProvider.isLoading || 
                      userProvider.isLoading || 
                      bookingProvider.isLoading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: DashboardAppBar(
        title: 'Admin Dashboard',
        subtitle: 'Salam, ${user?.fullName.split(' ').first ?? "Admin"}',
        onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
        transparent: true,
      ),
      body: AdminBackground(
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: isLoading,
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.darkBrown,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid with glass effect
                    Row(
                      children: [
                        Expanded(
                          child: GlassStatCard(
                            icon: Iconsax.building,
                            title: 'Mohallahs',
                            value: '${mohallahProvider.mohallahs.length}',
                            color: AppColors.darkBrown,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassStatCard(
                            icon: Iconsax.people,
                            title: 'Users',
                            value: '${userProvider.users.length}',
                            color: AppColors.mediumBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GlassStatCard(
                            icon: Iconsax.calendar_tick,
                            title: 'Bookings',
                            value: '${bookingProvider.bookings.length}',
                            color: AppColors.lightBrown,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassStatCard(
                            icon: Iconsax.user_tick,
                            title: 'Sub Admins',
                            value: '${userProvider.users.where((u) => u.isSubAdmin).length}',
                            color: AppColors.warmBrown,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Quick Actions Header
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Glass Action Tiles
                    GlassActionTile(
                      icon: Iconsax.document_upload,
                      title: 'Upload CSV',
                      subtitle: 'Bulk import users from CSV file',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.uploadCSV),
                    ),
                    
                    GlassActionTile(
                      icon: Iconsax.building_4,
                      title: 'Manage Mohallahs',
                      subtitle: 'Create and manage Mohallahs',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.manageMohallahs),
                    ),
                    
                    GlassActionTile(
                      icon: Iconsax.user_edit,
                      title: 'Manage Members',
                      subtitle: 'View and manage all users',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.manageMembers),
                    ),
                    
                    GlassActionTile(
                      icon: Iconsax.calendar_1,
                      title: 'All Bookings',
                      subtitle: 'View and manage all bookings',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.allBookings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}