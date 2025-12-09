class AttendanceModel {
  final String id;
  final String mohallah;
  final String date;
  final int expectedCount;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceModel({
    required this.id,
    required this.mohallah,
    required this.date,
    required this.expectedCount,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      mohallah: json['mohallah'] ?? '',
      date: json['date'] ?? '',
      expectedCount: json['expected_count'] ?? 0,
      note: json['note'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mohallah': mohallah,
      'date': date,
      'expected_count': expectedCount,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'mohallah': mohallah,
      'date': date,
      'expected_count': expectedCount,
      'note': note,
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? mohallah,
    String? date,
    int? expectedCount,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      mohallah: mohallah ?? this.mohallah,
      date: date ?? this.date,
      expectedCount: expectedCount ?? this.expectedCount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
