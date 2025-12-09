import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/theme.dart';
import '../../services/csv_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/admin_background.dart';
import '../../utils/helpers.dart';

class UploadCSVScreen extends StatefulWidget {
  const UploadCSVScreen({super.key});

  @override
  State<UploadCSVScreen> createState() => _UploadCSVScreenState();
}

class _UploadCSVScreenState extends State<UploadCSVScreen> {
  final CSVService _csvService = CSVService();
  PlatformFile? _selectedFile;
  CSVImportResult? _importResult;
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    try {
      final file = await _csvService.pickCSVFile();
      if (file != null) {
        setState(() {
          _selectedFile = file;
          _importResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to pick file', isError: true);
      }
    }
  }

  Future<void> _processFile() async {
    if (_selectedFile == null) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _csvService.processCSV(_selectedFile!);
      setState(() {
        _importResult = result;
        _isProcessing = false;
      });

      if (mounted) {
        if (result.failedCount == 0) {
          Helpers.showSnackBar(
            context,
            'Successfully imported ${result.successCount} users',
          );
        } else {
          Helpers.showSnackBar(
            context,
            'Imported ${result.successCount} users, ${result.failedCount} failed',
            isError: true,
          );
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Upload CSV',
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AdminBackground(
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: _isProcessing,
            message: 'Processing CSV...',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions Card
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.darkBrown.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Iconsax.info_circle,
                                color: AppColors.darkBrown,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'CSV Format',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your CSV file must have the following columns:',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildColumnItem('its_number', '8-digit ITS number'),
                        _buildColumnItem('full_name', 'Full name of member'),
                        _buildColumnItem('mobile', '10-digit mobile number'),
                        _buildColumnItem('mohallah', 'Mohallah name (must exist)'),
                      ],
                    ),
                  ),
                
                  const SizedBox(height: 24),
                
                  // File Selection Area
                  InkWell(
                    onTap: _pickFile,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedFile != null
                              ? AppColors.success
                              : AppColors.paleGold,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFile != null
                                ? Iconsax.document_text
                                : Iconsax.document_upload,
                            size: 48,
                            color: _selectedFile != null
                                ? AppColors.success
                                : AppColors.lightBrown,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFile?.name ?? 'Tap to select CSV file',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _selectedFile != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_selectedFile != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                
                  const SizedBox(height: 24),
                
                  // Process Button
                  if (_selectedFile != null)
                    CustomButton(
                      text: 'Process CSV',
                      onPressed: _processFile,
                      icon: Iconsax.document_download,
                    ),
                
                  // Import Results
                  if (_importResult != null) ...[
                    const SizedBox(height: 24),
                    _buildResultsCard(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumnItem(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.darkBrown,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: ' - \$description',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    final result = _importResult!;
    
    return Card(
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
              'Import Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildResultItem(
                    'Total',
                    '${result.totalRows}',
                    AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: _buildResultItem(
                    'Success',
                    '${result.successCount}',
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildResultItem(
                    'Failed',
                    '${result.failedCount}',
                    AppColors.error,
                  ),
                ),
              ],
            ),
            
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Errors',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: result.errors.length,
                  itemBuilder: (context, index) {
                    final error = result.errors[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Row ${error.rowNumber}: ${error.itsNumber}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            error.error,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}