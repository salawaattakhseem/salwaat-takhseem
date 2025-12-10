import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/member_card.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/admin_background.dart';
import '../../utils/helpers.dart';

class ManageMembersScreen extends StatefulWidget {
  const ManageMembersScreen({super.key});

  @override
  State<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    await context.read<UserProvider>().loadAllUsers();
  }

  List<dynamic> _getFilteredUsers(List<dynamic> users) {
    var filtered = users;
    
    // Filter by role
    if (_selectedRole != 'all') {
      filtered = filtered.where((u) => u.role == _selectedRole).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((u) {
        return u.fullName.toLowerCase().contains(query) ||
            u.its.contains(query) ||
            u.mobile.contains(query) ||
            u.mohallah.toLowerCase().contains(query);
      }).toList();
    }
    
    return filtered;
  }

  Future<void> _handleDeleteUser(String its) async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Delete User',
      message: 'Are you sure you want to delete this user?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirm) return;

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.deleteUser(its);

    if (mounted) {
      Helpers.showSnackBar(
        context,
        success ? 'User deleted' : 'Failed to delete user',
        isError: !success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final filteredUsers = _getFilteredUsers(userProvider.users);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Manage Members',
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AdminBackground(
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: userProvider.isLoading,
            child: Column(
              children: [
                // Search and Filter with glass effect
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search members...',
                              prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textLight),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Iconsax.close_circle),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.5),
                            ),
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('All', 'all'),
                                _buildFilterChip('Users', 'user'),
                                _buildFilterChip('Sub Admins', 'subadmin'),
                                _buildFilterChip('Admins', 'admin'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Results count
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredUsers.length} member${filteredUsers.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Members List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadMembers,
                    color: AppColors.darkBrown,
                    child: filteredUsers.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return MemberCard(
                                user: user,
                                showRole: true,
                                showDeleteButton: user.role != 'admin',
                                onDelete: user.role != 'admin'
                                    ? () => _handleDeleteUser(user.its)
                                    : null,
                              );
                            },
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedRole == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedRole = value);
        },
        backgroundColor: AppColors.softBeige,
        selectedColor: AppColors.darkBrown,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: AppColors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.people,
            size: 64,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No members found',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}