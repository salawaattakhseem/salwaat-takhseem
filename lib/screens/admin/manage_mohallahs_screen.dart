import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme.dart';
import '../../models/mohallah_model.dart';
import '../../providers/mohallah_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/mohallah_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/admin_background.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';

class ManageMohallahsScreen extends StatefulWidget {
  const ManageMohallahsScreen({super.key});

  @override
  State<ManageMohallahsScreen> createState() => _ManageMohallahsScreenState();
}

class _ManageMohallahsScreenState extends State<ManageMohallahsScreen> {
  @override
  void initState() {
    super.initState();
    _loadMohallahs();
  }

  Future<void> _loadMohallahs() async {
    await context.read<MohallahProvider>().loadMohallahs();
  }

  void _showAddEditDialog([MohallahModel? mohallah]) {
    final isEdit = mohallah != null;
    final nameController = TextEditingController(text: mohallah?.name ?? '');
    final limitController = TextEditingController(
      text: mohallah?.bookingLimit.toString() ?? '2',
    );
    final subadminController = TextEditingController(
      text: mohallah?.subadminIts ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Mohallah' : 'Add Mohallah'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Mohallah Name',
                  hint: 'Enter mohallah name',
                  controller: nameController,
                  validator: Validators.validateMohallahName,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Daily Booking Limit',
                  hint: 'Enter limit (1-10)',
                  controller: limitController,
                  keyboardType: TextInputType.number,
                  validator: Validators.validateBookingLimit,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Sub Admin ITS (Optional)',
                  hint: 'Enter sub admin ITS',
                  controller: subadminController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final mohallahProvider = context.read<MohallahProvider>();
              bool success;

              if (isEdit) {
                success = await mohallahProvider.updateMohallah(
                  mohallah!.id,
                  {
                    'name': nameController.text.trim(),
                    'booking_limit': int.parse(limitController.text),
                    'subadmin_its': subadminController.text.isEmpty
                        ? null
                        : subadminController.text.trim(),
                  },
                );
              } else {
                success = await mohallahProvider.createMohallah(
                  name: nameController.text.trim(),
                  bookingLimit: int.parse(limitController.text),
                  subadminIts: subadminController.text.isEmpty
                      ? null
                      : subadminController.text.trim(),
                );
              }

              if (context.mounted) {
                Navigator.pop(context);
                Helpers.showSnackBar(
                  context,
                  success
                      ? '${isEdit ? 'Updated' : 'Created'} successfully'
                      : mohallahProvider.errorMessage ?? 'Operation failed',
                  isError: !success,
                );
              }
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(MohallahModel mohallah) async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Delete Mohallah',
      message: 'Are you sure you want to delete "${mohallah.name}"?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirm) return;

    final mohallahProvider = context.read<MohallahProvider>();
    final success = await mohallahProvider.deleteMohallah(mohallah.id);

    if (mounted) {
      Helpers.showSnackBar(
        context,
        success ? 'Mohallah deleted' : 'Failed to delete',
        isError: !success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mohallahProvider = context.watch<MohallahProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Manage Mohallahs',
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.darkBrown,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: AdminBackground(
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: mohallahProvider.isLoading,
            child: RefreshIndicator(
              onRefresh: _loadMohallahs,
              color: AppColors.darkBrown,
              child: mohallahProvider.mohallahs.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: mohallahProvider.mohallahs.length,
                      itemBuilder: (context, index) {
                        final mohallah = mohallahProvider.mohallahs[index];
                        return MohallahCard(
                          mohallah: mohallah,
                          onEdit: () => _showAddEditDialog(mohallah),
                          onDelete: () => _handleDelete(mohallah),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.building,
                size: 64,
                color: AppColors.textLight.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Mohallahs Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap + to add your first Mohallah',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}