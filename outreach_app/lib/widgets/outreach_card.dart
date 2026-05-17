import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/outreach_person.dart';

class OutreachCard extends StatelessWidget {
  final OutreachPerson person;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const OutreachCard({
    super.key,
    required this.person,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Status Badge colors
    Color statusBgColor;
    Color statusTextColor;
    
    switch (person.status.toLowerCase()) {
      case 'active':
        statusBgColor = const Color(0xFFEFF6FF); // Light blue
        statusTextColor = const Color(0xFF2563EB); // Royal blue
        break;
      case 'active discipleship':
      case 'discipleship':
        statusBgColor = const Color(0xFFECFDF5); // Light emerald green
        statusTextColor = const Color(0xFF059669); // Emerald text
        break;
      case 'new contact':
      case 'new':
        statusBgColor = const Color(0xFFFFF7ED); // Orange background
        statusTextColor = AppColors.orange;
        break;
      case 'prayer':
        statusBgColor = const Color(0xFFFDF2F8); // Pink background
        statusTextColor = const Color(0xFFDB2777); // Pink/magenta text
        break;
      default:
        statusBgColor = AppColors.border;
        statusTextColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Name & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    person.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    person.status,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Detail Rows (Phone & Email)
            if (person.phone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16, color: AppColors.iconColor),
                    const SizedBox(width: 8),
                    Text(
                      person.phone,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (person.email.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline_rounded, size: 16, color: AppColors.iconColor),
                    const SizedBox(width: 8),
                    Text(
                      person.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            const Divider(color: AppColors.border, height: 24),
            
            // Follow-up Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Follow-up Rate',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${person.followUpRate.toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: person.followUpRate / 100,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Last followed up & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last active: ${_formatLastFollowedUp(person.lastFollowedUp)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: AppColors.green),
                      tooltip: 'Mark followed up',
                      onPressed: onToggle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
                      tooltip: 'Remove',
                      onPressed: onDelete,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastFollowedUp(DateTime dt) {
    final diff = DateTime.now().difference(dt).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 30) return '${(diff / 7).floor()} weeks ago';
    return '${(diff / 30).floor()} months ago';
  }
}
