class MohallahModel {
  final String id;
  final String name;
  final int bookingLimit;
  final String? subadminIts;
  final DateTime createdAt;
  
  // Booking Window Settings
  final DateTime? bookingStartDate;  // When users can START booking
  final DateTime? bookingEndDate;    // Last date for booking
  final DateTime? eventStartDate;    // First date users can book FOR
  final DateTime? eventEndDate;      // Last date users can book FOR
  final bool bookingEnabled;         // Master switch to enable/disable booking

  MohallahModel({
    required this.id,
    required this.name,
    required this.bookingLimit,
    this.subadminIts,
    required this.createdAt,
    this.bookingStartDate,
    this.bookingEndDate,
    this.eventStartDate,
    this.eventEndDate,
    this.bookingEnabled = true,
  });

  factory MohallahModel.fromJson(Map<String, dynamic> json) {
    return MohallahModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      bookingLimit: json['booking_limit'] ?? 2,
      subadminIts: json['subadmin_its'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      bookingStartDate: json['booking_start_date'] != null 
          ? DateTime.parse(json['booking_start_date']) 
          : null,
      bookingEndDate: json['booking_end_date'] != null 
          ? DateTime.parse(json['booking_end_date']) 
          : null,
      eventStartDate: json['event_start_date'] != null 
          ? DateTime.parse(json['event_start_date']) 
          : null,
      eventEndDate: json['event_end_date'] != null 
          ? DateTime.parse(json['event_end_date']) 
          : null,
      bookingEnabled: json['booking_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'booking_limit': bookingLimit,
      'subadmin_its': subadminIts,
      'created_at': createdAt.toIso8601String(),
      'booking_start_date': bookingStartDate?.toIso8601String(),
      'booking_end_date': bookingEndDate?.toIso8601String(),
      'event_start_date': eventStartDate?.toIso8601String(),
      'event_end_date': eventEndDate?.toIso8601String(),
      'booking_enabled': bookingEnabled,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'booking_limit': bookingLimit,
      'subadmin_its': subadminIts,
      'booking_start_date': bookingStartDate?.toIso8601String(),
      'booking_end_date': bookingEndDate?.toIso8601String(),
      'event_start_date': eventStartDate?.toIso8601String(),
      'event_end_date': eventEndDate?.toIso8601String(),
      'booking_enabled': bookingEnabled,
    };
  }

  MohallahModel copyWith({
    String? id,
    String? name,
    int? bookingLimit,
    String? subadminIts,
    DateTime? createdAt,
    DateTime? bookingStartDate,
    DateTime? bookingEndDate,
    DateTime? eventStartDate,
    DateTime? eventEndDate,
    bool? bookingEnabled,
  }) {
    return MohallahModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bookingLimit: bookingLimit ?? this.bookingLimit,
      subadminIts: subadminIts ?? this.subadminIts,
      createdAt: createdAt ?? this.createdAt,
      bookingStartDate: bookingStartDate ?? this.bookingStartDate,
      bookingEndDate: bookingEndDate ?? this.bookingEndDate,
      eventStartDate: eventStartDate ?? this.eventStartDate,
      eventEndDate: eventEndDate ?? this.eventEndDate,
      bookingEnabled: bookingEnabled ?? this.bookingEnabled,
    );
  }

  // Helper methods for booking window logic
  bool get isBookingWindowOpen {
    if (!bookingEnabled) return false;
    
    final now = DateTime.now();
    
    // Check if we're within the booking window
    if (bookingStartDate != null && now.isBefore(bookingStartDate!)) {
      return false; // Booking hasn't started yet
    }
    if (bookingEndDate != null && now.isAfter(bookingEndDate!)) {
      return false; // Booking window has closed
    }
    
    return true;
  }

  String get bookingWindowStatus {
    if (!bookingEnabled) {
      return 'Booking is currently disabled';
    }
    
    final now = DateTime.now();
    
    if (bookingStartDate != null && now.isBefore(bookingStartDate!)) {
      return 'Booking opens on ${_formatDate(bookingStartDate!)}';
    }
    
    if (bookingEndDate != null && now.isAfter(bookingEndDate!)) {
      return 'Booking window has closed';
    }
    
    if (bookingEndDate != null) {
      return 'Booking open until ${_formatDate(bookingEndDate!)}';
    }
    
    return 'Booking is open';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool isDateAvailableForBooking(DateTime date) {
    if (!bookingEnabled) return false;
    
    // Check if the date falls within the allowed event date range
    if (eventStartDate != null && date.isBefore(eventStartDate!)) {
      return false;
    }
    if (eventEndDate != null && date.isAfter(eventEndDate!)) {
      return false;
    }
    
    return true;
  }
}