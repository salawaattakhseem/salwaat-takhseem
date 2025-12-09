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

class SubAdminDashboard extends StatefulWidget {
  const SubAdminDashboard({super.key});

  @override
  State<SubAdminDashboard> createState() => _SubAdminDashboardState();
}

class _SubAdminDashboardState extends State<SubAdminDashboard> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final mohallahProvider = context.read<MohallahProvider>();
    final userProvider = context.read<UserProvider>();
    final bookingProvider = context.read<BookingProvider>();

    if (authProvider.currentUser != null) {
      await mohallahProvider.loadMohallahForSubAdmin(authProvider.currentUser!.its);
      
      if (mohallahProvider.selectedMohallah != null) {
        await userProvider.loadUsersByMohallah(mohallahProvider.selectedMohallah!.name);
        await bookingProvider.loadBookingsByMohallah(mohallahProvider.selectedMohallah!.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final mohallahProvider = context.watch<MohallahProvider>();
    final userProvider = context.watch<UserProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    
    final user = authProvider.currentUser;
    final mohallah = mohallahProvider.selectedMohallah;

    return Scaffold(
      appBar: DashboardAppBar(
        title: 'Sub Admin Dashboard',
        subtitle: mohallah?.name ?? 'Loading...',
        onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
      ),
      backgroundColor: AppColors.creamBackground,
      body: LoadingOverlay(
        isLoading: mohallahProvider.isLoading,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.darkBrown,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Iconsax.people,
                        title: 'Members',
                        value: '${userProvider.users.length}',
                        color: AppColors.mediumBrown,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Iconsax.calendar_tick,
                        title: 'Bookings',
                        value: '${bookingProvider.bookings.length}',
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Mohallah Info Card
                if (mohallah != null)
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
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.lightBrown.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Iconsax.building,
                              color: AppColors.darkBrown,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mohallah.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Daily Booking Limit: ${mohallah.bookingLimit}',
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
                
                const SizedBox(height: 24),
                
                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildActionTile(
                  icon: Iconsax.people,
                  title: 'View Members',
                  subtitle: 'See all members in your Mohallah',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.memberList),
                ),
                
                _buildActionTile(
                  icon: Iconsax.calendar_1,
                  title: 'View Bookings',
                  subtitle: 'Manage Mohallah bookings',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.mohallahBookings),
                ),
                
                _buildActionTile(
                  icon: Iconsax.calendar_add,
                  title: 'Book for Member',
                  subtitle: 'Create booking on behalf of a member',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.bookForMember),
                ),
                
                _buildActionTile(
                  icon: Iconsax.chart_square,
                  title: 'Manage Attendance',
                  subtitle: 'Set expected attendance for dates',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.manageAttendance),
                ),
                
                _buildActionTile(
                  icon: Iconsax.setting_2,
                  title: 'Booking Settings',
                  subtitle: 'Configure booking window & availability',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.bookingSettings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightBrown.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.darkBrown),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}