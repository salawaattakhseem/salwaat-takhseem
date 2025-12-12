class BookingModel {
  final String id;
  final String its;
  final String mohallah;
  final String date;
  final String item;
  final DateTime createdAt;
  final List<String> partnerItsList; // Optional partners for group booking (up to 4)
  
  // Optional joined fields
  final String? userName;
  final String? userMobile;
  final List<String> partnerNames; // Partners' names from users table

  BookingModel({
    required this.id,
    required this.its,
    required this.mohallah,
    required this.date,
    required this.item,
    required this.createdAt,
    this.partnerItsList = const [],
    this.userName,
    this.userMobile,
    this.partnerNames = const [],
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Parse partner_its - can be comma-separated string or single value
    List<String> partnerItsList = [];
    if (json['partner_its'] != null && json['partner_its'].toString().isNotEmpty) {
      final rawPartnerIts = json['partner_its'].toString();
      partnerItsList = rawPartnerIts.split(',').where((s) => s.trim().isNotEmpty).toList();
    }
    
    return BookingModel(
      id: json['id'] ?? '',
      its: json['its'] ?? '',
      mohallah: json['mohallah'] ?? '',
      date: json['date'] ?? '',
      item: json['item'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      partnerItsList: partnerItsList,
      userName: json['users']?['full_name'],
      userMobile: json['users']?['mobile'],
      partnerNames: [], // Will be populated separately if needed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'its': its,
      'mohallah': mohallah,
      'date': date,
      'item': item,
      'created_at': createdAt.toIso8601String(),
      if (partnerItsList.isNotEmpty) 'partner_its': partnerItsList.join(','),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'its': its,
      'mohallah': mohallah,
      'date': date,
      'item': item,
      if (partnerItsList.isNotEmpty) 'partner_its': partnerItsList.join(','),
    };
  }

  bool get hasPartners => partnerItsList.isNotEmpty;
  int get partnerCount => partnerItsList.length;
  int get totalPeople => 1 + partnerCount; // Primary booker + partners

  BookingModel copyWith({
    String? id,
    String? its,
    String? mohallah,
    String? date,
    String? item,
    DateTime? createdAt,
    List<String>? partnerItsList,
    String? userName,
    String? userMobile,
    List<String>? partnerNames,
  }) {
    return BookingModel(
      id: id ?? this.id,
      its: its ?? this.its,
      mohallah: mohallah ?? this.mohallah,
      date: date ?? this.date,
      item: item ?? this.item,
      createdAt: createdAt ?? this.createdAt,
      partnerItsList: partnerItsList ?? this.partnerItsList,
      userName: userName ?? this.userName,
      userMobile: userMobile ?? this.userMobile,
      partnerNames: partnerNames ?? this.partnerNames,
    );
  }

  DateTime get dateTime => DateTime.parse(date);
  
  /// Check if booking date has passed (completed)
  bool get isCompleted {
    final now = DateTime.now();
    final bookingDate = dateTime;
    // Completed if booking date is before today
    return bookingDate.isBefore(DateTime(now.year, now.month, now.day));
  }
  
  /// Check if booking is upcoming (not yet completed)
  bool get isUpcoming => !isCompleted;
  
  /// Get status string for display
  String get statusText => isCompleted ? 'Completed' : 'Upcoming';
}