import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../config/theme.dart';
import '../models/booking_model.dart';
import '../utils/helpers.dart';
import '../utils/misri_hijri_date.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onDelete;
  final bool showUserInfo;
  final bool showDeleteButton;
  final int? expectedAttendance;

  const BookingCard({
    super.key,
    required this.booking,
    this.onDelete,
    this.showUserInfo = false,
    this.showDeleteButton = true,
    this.expectedAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = booking.isCompleted;
    
    return Opacity(
      opacity: isCompleted ? 0.7 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Status badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? AppColors.success.withOpacity(0.15) 
                      : AppColors.darkBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.success : AppColors.darkBrown,
                  ),
                ),
              ),
            ),
            Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightBrown.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.calendar_1,
                    color: AppColors.darkBrown,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Helpers.formatDateDisplay(booking.dateTime),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Misri: ${MisriHijriDate.fromGregorian(booking.dateTime).format()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      // Group booking indicator
                      if (booking.hasPartners) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.darkBrown.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkBrown.withOpacity(0.25),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.people,
                                size: 14,
                                color: AppColors.darkBrown,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Group (${booking.partnerCount + 1})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkBrown,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Show partner names if available, otherwise show masked ITS
                        if (booking.partnerNames.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'With: ${booking.partnerNames.join(", ")}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else if (booking.partnerItsList.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'With: ${booking.partnerItsList.map((its) => "****${its.substring(its.length - 4)}").join(", ")}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                      // Expected attendance indicator
                      if (expectedAttendance != null && expectedAttendance! > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.available.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.available.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.chart_21,
                                size: 14,
                                color: AppColors.available,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$expectedAttendance expected',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.available,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showDeleteButton && onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Iconsax.trash,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
            if (showUserInfo && booking.userName != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.lightBrown,
                    child: Text(
                      Helpers.getInitials(booking.userName!),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.userName!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (booking.userMobile != null)
                          Text(
                            booking.userMobile!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softBeige,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      Helpers.maskITS(booking.its),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
            ),
          ],
        ),
      ),
    );
  }
}