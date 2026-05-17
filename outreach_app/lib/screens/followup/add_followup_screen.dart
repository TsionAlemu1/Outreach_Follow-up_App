import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/followup_reminder.dart';
import '../../providers/outreach_provider.dart';

class AddFollowupScreen extends StatefulWidget {
  const AddFollowupScreen({super.key});

  @override
  State<AddFollowupScreen> createState() => _AddFollowupScreenState();
}

class _AddFollowupScreenState extends State<AddFollowupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedPerson;
  String? _selectedType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedStatus = 'Scheduled';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  final List<String> _followupTypes = [
    'Bible Study',
    'Prayer Meeting',
    'Coffee Chat & Share',
    'Fellowship Group',
    'One-on-One Catchup'
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        final hour = picked.hour > 12 ? picked.hour - 12 : (picked.hour == 0 ? 12 : picked.hour);
        final ampm = picked.hour >= 12 ? 'PM' : 'AM';
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = "$hour:$minute $ampm";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Add Follow-up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<OutreachProvider>(
        builder: (context, provider, child) {
          final contacts = provider.people;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Select Person
                  _buildSectionHeader(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.primary,
                    label: 'Select Person',
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      hintText: 'Choose a contact...',
                    ),
                    value: _selectedPerson,
                    validator: (val) => val == null ? 'Please select a contact' : null,
                    items: contacts.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.name,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedPerson = val;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // 2. Follow-up Type
                  _buildSectionHeader(
                    icon: Icons.local_offer_outlined,
                    iconColor: AppColors.orange,
                    label: 'Follow-up Type',
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      hintText: 'Select type...',
                    ),
                    value: _selectedType,
                    validator: (val) => val == null ? 'Please select a type' : null,
                    items: _followupTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedType = val;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // 3. Date Selection
                  _buildSectionHeader(
                    icon: Icons.calendar_month_outlined,
                    iconColor: AppColors.green,
                    label: 'Date',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: const InputDecoration(
                      hintText: 'mm/dd/yyyy',
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please select a date' : null,
                  ),

                  const SizedBox(height: 24),

                  // 4. Time Selection
                  _buildSectionHeader(
                    icon: Icons.access_time,
                    iconColor: Colors.deepPurple,
                    label: 'Time',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    onTap: () => _selectTime(context),
                    decoration: const InputDecoration(
                      hintText: '--:-- --',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please select a time' : null,
                  ),

                  const SizedBox(height: 24),

                  // 5. Status dropdown
                  _buildSectionHeader(
                    icon: Icons.flag_outlined,
                    iconColor: AppColors.darkBlue,
                    label: 'Status',
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(),
                    value: _selectedStatus,
                    items: ['Scheduled', 'Overdue', 'Done'].map((st) {
                      return DropdownMenuItem<String>(
                        value: st,
                        child: Text(st),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // 6. Notes
                  _buildSectionHeader(
                    icon: Icons.description_outlined,
                    iconColor: AppColors.orange,
                    label: 'Notes',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Add any relevant notes or discussion topics...',
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save Follow-up Action
                  ElevatedButton(
                    onPressed: () => _saveFollowup(provider),
                    child: const Text('Save Follow-up'),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _saveFollowup(OutreachProvider provider) {
    if (_formKey.currentState!.validate()) {
      // Assemble selected DateTime
      final date = _selectedDate ?? DateTime.now();
      final time = _selectedTime ?? const TimeOfDay(hour: 12, minute: 0);
      final finalDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Determine priority based on follow-up type
      FollowUpPriority priority = FollowUpPriority.medium;
      if (_selectedType == 'Bible Study') {
        priority = FollowUpPriority.high;
      } else if (_selectedType == 'Coffee Chat & Share') {
        priority = FollowUpPriority.low;
      }

      provider.addReminder(
        _selectedType!,
        _selectedPerson!,
        finalDateTime,
        priority,
        _notesController.text.trim(),
      );

      // In case we marked overdue or completed manually
      if (_selectedStatus != 'Scheduled') {
        final lastReminder = provider.reminders.first;
        final updated = lastReminder.copyWith(status: _selectedStatus);
        provider.reminders[0] = updated;
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Follow-up schedule created successfully!')),
      );
    }
  }
}
