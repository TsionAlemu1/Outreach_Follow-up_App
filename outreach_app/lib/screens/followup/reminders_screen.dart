import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/outreach_provider.dart';
import '../../widgets/reminder_card.dart';
import '../../widgets/status_indicator_card.dart';
import 'add_followup_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  String _activeFilter = 'All'; // 'All', 'Week', 'Month', 'Overdue'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Reminders'),
        centerTitle: true,
      ),
      body: Consumer<OutreachProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load reminders',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          // Compute matching list
          List filteredReminders = provider.reminders;
          if (_activeFilter == 'Week') {
            final now = DateTime.now();
            final oneWeekLater = now.add(const Duration(days: 7));
            filteredReminders = provider.reminders.where(
              (r) => r.status == 'Scheduled' && r.dateTime.isAfter(now) && r.dateTime.isBefore(oneWeekLater),
            ).toList();
          } else if (_activeFilter == 'Month') {
            final now = DateTime.now();
            final oneMonthLater = now.add(const Duration(days: 30));
            filteredReminders = provider.reminders.where(
              (r) => r.status == 'Scheduled' && r.dateTime.isAfter(now) && r.dateTime.isBefore(oneMonthLater),
            ).toList();
          } else if (_activeFilter == 'Overdue') {
            filteredReminders = provider.reminders.where((r) => r.status == 'Overdue').toList();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blue Top Banner (Title & Description)
              Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming follow-up schedules',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Filter Row (StatusIndicatorCards)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      StatusIndicatorCard(
                        count: '${provider.remindersThisWeekCount}',
                        label: 'This Week',
                        themeColor: AppColors.orange,
                        isActive: _activeFilter == 'Week',
                        onTap: () => _toggleFilter('Week'),
                      ),
                      const SizedBox(width: 12),
                      StatusIndicatorCard(
                        count: '${provider.remindersThisMonthCount}',
                        label: 'This Month',
                        themeColor: AppColors.darkBlue,
                        isActive: _activeFilter == 'Month',
                        onTap: () => _toggleFilter('Month'),
                      ),
                      const SizedBox(width: 12),
                      StatusIndicatorCard(
                        count: '${provider.overdueRemindersCount}',
                        label: 'Overdue',
                        themeColor: AppColors.red,
                        isActive: _activeFilter == 'Overdue',
                        onTap: () => _toggleFilter('Overdue'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Active Filter Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getFilterTitle(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (_activeFilter != 'All')
                      TextButton(
                        onPressed: () => setState(() => _activeFilter = 'All'),
                        child: const Text('Clear Filter', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                  ],
                ),
              ),

              // Reminders List
              Expanded(
                child: filteredReminders.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.checklist_rounded, size: 56, color: AppColors.textLight.withOpacity(0.5)),
                              const SizedBox(height: 12),
                              const Text(
                                'No reminders found for this filter',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredReminders.length,
                        itemBuilder: (context, index) {
                          final reminder = filteredReminders[index];
                          return Dismissible(
                            key: Key(reminder.id.toString()),
                            background: Container(
                              color: AppColors.green,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Icon(Icons.check, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              color: AppColors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                provider.toggleReminderStatus(reminder.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Follow-up status updated!')),
                                );
                              } else {
                                provider.deleteReminder(reminder.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reminder deleted')),
                                );
                              }
                            },
                            child: ReminderCard(
                              reminder: reminder,
                              onViewDetails: () => _showReminderDetail(context, reminder),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_alert_rounded),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFollowupScreen()),
          );
        },
      ),
    );
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_activeFilter == filter) {
        _activeFilter = 'All';
      } else {
        _activeFilter = filter;
      }
    });
  }

  String _getFilterTitle() {
    switch (_activeFilter) {
      case 'Week':
        return 'Schedules This Week';
      case 'Month':
        return 'Schedules This Month';
      case 'Overdue':
        return 'Overdue Schedules';
      default:
        return 'All Scheduled Follow-ups';
    }
  }

  void _showReminderDetail(BuildContext context, reminder) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    reminder.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Contact: ${reminder.personName}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.notes_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Follow-up Discussion Topics & Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reminder.notes.isNotEmpty ? reminder.notes : 'No specific discussion topics added yet.',
                  style: const TextStyle(height: 1.4, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
