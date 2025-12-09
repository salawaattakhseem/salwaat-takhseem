import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../main.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import 'auth_service.dart';

class CSVImportResult {
  final int totalRows;
  final int successCount;
  final int failedCount;
  final List<CSVRowError> errors;

  CSVImportResult({
    required this.totalRows,
    required this.successCount,
    required this.failedCount,
    required this.errors,
  });
}

class CSVRowError {
  final int rowNumber;
  final String itsNumber;
  final String error;

  CSVRowError({
    required this.rowNumber,
    required this.itsNumber,
    required this.error,
  });
}

class CSVService {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  // Pick CSV file
  Future<PlatformFile?> pickCSVFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: \$e');
    }
  }

  // Parse CSV content
  List<List<dynamic>> parseCSV(String content) {
    return const CsvToListConverter().convert(content);
  }

  // Process CSV and import users
  Future<CSVImportResult> processCSV(PlatformFile file) async {
    final List<CSVRowError> errors = [];
    int successCount = 0;

    try {
      // Read file content
      String content;
      if (file.bytes != null) {
        content = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        throw Exception('Unable to read file');
      }

      final rows = parseCSV(content);
      
      if (rows.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // Get header row
      final headers = rows.first.map((e) => e.toString().toLowerCase().trim()).toList();
      
      // Validate required columns
      final requiredColumns = ['its_number', 'full_name', 'mobile', 'mohallah'];
      for (var col in requiredColumns) {
        if (!headers.contains(col)) {
          throw Exception('Missing required column: \$col');
        }
      }

      // Get column indices
      final itsIndex = headers.indexOf('its_number');
      final nameIndex = headers.indexOf('full_name');
      final mobileIndex = headers.indexOf('mobile');
      final mohallahIndex = headers.indexOf('mohallah');
      final roleIndex = headers.indexOf('role'); // Optional role column

      // Process data rows (skip header)
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        
        if (row.length < 4) {
          errors.add(CSVRowError(
            rowNumber: i + 1,
            itsNumber: row.isNotEmpty ? row[itsIndex].toString() : 'Unknown',
            error: 'Invalid row format',
          ));
          continue;
        }

        final itsNumber = row[itsIndex].toString().trim();
        final fullName = row[nameIndex].toString().trim();
        final mobile = row[mobileIndex].toString().trim();
        final mohallah = row[mohallahIndex].toString().trim();
        
        // Get role from CSV if column exists, default to 'user'
        String role = UserRoles.user;
        if (roleIndex >= 0 && row.length > roleIndex) {
          final csvRole = row[roleIndex].toString().trim().toLowerCase();
          // Only allow 'user' role from CSV (admin/subadmin must be created manually for security)
          if (csvRole == UserRoles.user || csvRole.isEmpty) {
            role = UserRoles.user;
          } else if (csvRole == UserRoles.admin || csvRole == UserRoles.subadmin) {
            // Don't allow admin/subadmin role from CSV for security
            errors.add(CSVRowError(
              rowNumber: i + 1,
              itsNumber: itsNumber,
              error: 'Admin/SubAdmin roles cannot be assigned via CSV. Use "user" only.',
            ));
            continue;
          } else {
            errors.add(CSVRowError(
              rowNumber: i + 1,
              itsNumber: itsNumber,
              error: 'Invalid role "$csvRole". Only "user" role is allowed in CSV.',
            ));
            continue;
          }
        }

        // Validate ITS number - must be only digits and at least 4 characters
        final itsRegex = RegExp(r'^[0-9]+$');
        if (itsNumber.isEmpty || itsNumber.length < 4 || !itsRegex.hasMatch(itsNumber)) {
          errors.add(CSVRowError(
            rowNumber: i + 1,
            itsNumber: itsNumber,
            error: 'Invalid ITS number (must be digits only, min 4 digits)',
          ));
          continue;
        }

        // Check if ITS already exists
        if (await _databaseService.userExists(itsNumber)) {
          errors.add(CSVRowError(
            rowNumber: i + 1,
            itsNumber: itsNumber,
            error: 'ITS number already exists',
          ));
          continue;
        }

        // Check if mohallah exists
        if (!await _databaseService.mohallahExists(mohallah)) {
          errors.add(CSVRowError(
            rowNumber: i + 1,
            itsNumber: itsNumber,
            error: 'Mohallah "$mohallah" does not exist',
          ));
          continue;
        }

        // Get last 4 digits for password (displayed to user)
        final passwordLast4 = itsNumber.substring(itsNumber.length - 4);

        try {
          // Create user in database - auth user is created automatically by database trigger
          final user = UserModel(
            its: itsNumber,
            fullName: fullName,
            mobile: mobile,
            mohallah: mohallah,
            role: role,
            passwordLast4: passwordLast4,
            createdAt: DateTime.now(),
          );

          await _databaseService.createUser(user);
          print('CSV IMPORT: User $itsNumber created (auth user auto-created by trigger)');
          successCount++;
        } catch (e) {
          print('CSV IMPORT ERROR for $itsNumber: $e');
          errors.add(CSVRowError(
            rowNumber: i + 1,
            itsNumber: itsNumber,
            error: e.toString(),
          ));
        }
      }

      return CSVImportResult(
        totalRows: rows.length - 1, // Exclude header
        successCount: successCount,
        failedCount: errors.length,
        errors: errors,
      );
    } catch (e) {
      throw Exception('Failed to process CSV: $e');
    }
  }

  // Upload CSV to Supabase Storage (optional, for record keeping)
  Future<String?> uploadCSVToStorage(PlatformFile file) async {
    try {
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final fileName = 'imports/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      
      await supabase.storage
          .from(AppConstants.csvBucket)
          .uploadBinary(fileName, bytes);
      
      return fileName;
    } catch (e) {
      return null;
    }
  }

  // Generate sample CSV content
  String generateSampleCSV() {
    return '''its_number,full_name,mobile,mohallah,role
12345678,Fatima Bai,9876543210,Mohallah A,user
12345679,Sakina Bai,9876543211,Mohallah A,subadmin
12345680,Maryam Bai,9876543212,Mohallah B,user''';
  }
}