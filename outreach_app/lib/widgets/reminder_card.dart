import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/followup_reminder.dart';

class ReminderCard extends StatelessWidget {
  final FollowUpReminder reminder;
  final VoidCallback? onViewDetails;
  final VoidCallback? onToggleStatus;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onViewDetails,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Determine priority chip colors
    Color chipBgColor;
    Color chipTextColor;
    String priorityText;

    switch (reminder.priority) {
      case FollowUpPriority.low:
        chipBgColor = AppColors.lowPriorityBg;
        chipTextColor = AppColors.lowPriorityText;
        priorityText = 'low priority';
        break;
      case FollowUpPriority.medium:
        chipBgColor = AppColors.mediumPriorityBg;
        chipTextColor = AppColors.mediumPriorityText;
        priorityText = 'medium priority';
        break;
      case FollowUpPriority.high:
        chipBgColor = AppColors.highPriorityBg;
        chipTextColor = AppColors.highPriorityText;
        priorityText = 'high priority';
        break;
    }

    // Determine left indicator strip color based on status
    Color indicatorColor;
    if (reminder.status == 'Overdue') {
      indicatorColor = AppColors.red;
    } else if (reminder.status == 'Done') {
      indicatorColor = AppColors.green;
    } else {
      // Scheduled
      final daysDiff = reminder.dateTime.difference(DateTime.now()).inDays;
      if (daysDiff <= 7) {
        indicatorColor = AppColors.orange;
      } else {
        indicatorColor = AppColors.primary;
      }
    }

    // Icon based on title/type
    IconData typeIcon;
    Color iconBgColor = AppColors.primary;

    if (reminder.title.toLowerCase().contains('bible') || reminder.title.toLowerCase().contains('study')) {
      typeIcon = Icons.menu_book_rounded;
      iconBgColor = AppColors.primary;
    } else if (reminder.title.toLowerCase().contains('prayer') || reminder.title.toLowerCase().contains('meet')) {
      typeIcon = Icons.volunteer_activism_rounded;
      iconBgColor = AppColors.orange;
    } else if (reminder.title.toLowerCase().contains('coffee') || reminder.title.toLowerCase().contains('chat')) {
      typeIcon = Icons.coffee_rounded;
      iconBgColor = AppColors.green;
    } else {
      typeIcon = Icons.chat_bubble_rounded;
      iconBgColor = AppColors.darkBlue;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored Left Strip Indicator
              Container(
                width: 5,
                color: indicatorColor,
              ),
              const SizedBox(width: 16),
              
              // Card Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // circular icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconBgColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              typeIcon,
                              color: iconBgColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Title
                          Expanded(
                            child: Text(
                              '${reminder.title} - ${reminder.personName}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Date Info
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(reminder.dateTime),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Time Info
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: AppColors.orange),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(reminder.dateTime),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Priority Chip & Details Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: chipBgColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              priorityText,
                              style: TextStyle(
                                color: chipTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: onViewDetails,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDate = DateTime(dt.year, dt.month, dt.day);

    final diff = reminderDate.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    
    // Weekday
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (diff > 1 && diff < 7) {
      return weekdays[dt.weekday - 1];
    }

    return '${dt.month}/${dt.day}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $ampm';
  }
}
