import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/outreach_person.dart';
import '../../providers/outreach_provider.dart';

class PersonDetailScreen extends StatefulWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  // Local cache of added prayer requests for this session
  final List<String> _sessionPrayerRequests = [
    'Strength and wisdom for the upcoming midterms.',
    'Praying for family health concerns back home.',
  ];

  void _simulateInteraction(BuildContext context, String type, String details, OutreachProvider provider, OutreachPerson person) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(ctx)) {
            Navigator.pop(ctx);
            // Log interaction: update last followed up to now
            provider.logInteraction(person.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$type interaction logged with ${person.name}!')),
            );
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 24),
              Text(
                'Simulating $type...',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                details,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showAddPrayerDialog(BuildContext context, OutreachProvider provider, OutreachPerson person) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Prayer Request', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: textController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Type prayer request details...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final txt = textController.text.trim();
                if (txt.isNotEmpty) {
                  setState(() {
                    _sessionPrayerRequests.insert(0, txt);
                  });
                  // Increment count statefully via provider async/PATCH method
                  provider.addPrayerRequest(person.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Prayer request added successfully!')),
                  );
                }
              },
              child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showEditContactDialog(BuildContext context, OutreachProvider provider, OutreachPerson person) {
    final nameController = TextEditingController(text: person.name);
    final emailController = TextEditingController(text: person.email);
    final phoneController = TextEditingController(text: person.phone);
    String selectedStatus = person.status;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.edit_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Edit Contact Info', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: ['New Contact', 'Active', 'Prayer', 'Active Discipleship'].contains(selectedStatus) 
                            ? selectedStatus 
                            : 'New Contact',
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.label_outline_rounded),
                        ),
                        items: ['New Contact', 'Active', 'Prayer', 'Active Discipleship'].map((st) {
                          return DropdownMenuItem<String>(
                            value: st,
                            child: Text(st),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            selectedStatus = val;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.pop(ctx);
                      
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        // Use PATCH to update name/phone partially
                        await provider.patchContact(person.id, {
                          'name': nameController.text.trim(),
                          'phone': phoneController.text.trim(),
                        });
                        
                        // Then use PUT to completely update remaining fields
                        final updatedPerson = person.copyWith(
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          email: emailController.text.trim(),
                          status: selectedStatus,
                        );
                        await provider.updateContact(updatedPerson);

                        if (context.mounted) {
                          Navigator.pop(context); // Dismiss loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contact details successfully updated!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context); // Dismiss loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error updating contact: $e')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OutreachProvider>(
      builder: (context, provider, child) {
        // Find matching contact in provider
        final personIdx = provider.people.indexWhere((p) => p.id == widget.personId);
        if (personIdx == -1) {
          return Scaffold(
            appBar: AppBar(backgroundColor: AppColors.primary, title: const Text('Contact Details')),
            body: const Center(child: Text('Contact not found')),
          );
        }

        final person = provider.people[personIdx];
        
        // Find related scheduled reminders
        final relatedReminders = provider.reminders
            .where((r) => r.personName.toLowerCase() == person.name.toLowerCase())
            .toList();



        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: const Text('Contact Profile'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: () => _showEditContactDialog(context, provider, person),
                tooltip: 'Edit Contact Details',
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Curved Profile Header
                Container(
                  width: double.infinity,
                  color: AppColors.primary,
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 4),
                  child: Column(
                    children: [
                      // Avatar Badge
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            person.name.isNotEmpty ? person.name.substring(0, 1).toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        person.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          person.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Interactive Quick Actions Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.phone_rounded,
                        label: 'Call Now',
                        color: AppColors.primary,
                        onTap: () => _simulateInteraction(
                          context,
                          'Voice Call',
                          'Dialing ${person.phone}...',
                          provider,
                          person,
                        ),
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.sms_rounded,
                        label: 'Send SMS',
                        color: AppColors.orange,
                        onTap: () => _simulateInteraction(
                          context,
                          'SMS Message',
                          'Sending SMS to ${person.phone}...',
                          provider,
                          person,
                        ),
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.favorite_rounded,
                        label: 'Add Prayer',
                        color: AppColors.red,
                        onTap: () => _showAddPrayerDialog(context, provider, person),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Contact Details Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Details',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.phone_iphone_rounded, 'Phone Number', person.phone.isNotEmpty ? person.phone : 'Not provided'),
                      _buildDetailRow(Icons.mail_outline_rounded, 'Email Address', person.email.isNotEmpty ? person.email : 'Not provided'),
                      _buildDetailRow(Icons.history_rounded, 'Last Followed Up', _formatLastFollowedUp(person.lastFollowedUp)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Follow-up Success Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Discipleship Success Rate',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${person.followUpRate.toInt()}%',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: person.followUpRate / 100,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Prayer Requests Log
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Prayer Requests (${person.prayerRequestsCount})',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddPrayerDialog(context, provider, person),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Request'),
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _sessionPrayerRequests.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('No active prayer request logs.', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                            )
                          : Column(
                              children: _sessionPrayerRequests.map((req) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.favorite_rounded, color: AppColors.red, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          req,
                                          style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Scheduled Reminders Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scheduled Follow-ups',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      relatedReminders.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'No upcoming schedules. Tap standard Floating Action Button in reminders tab to add one!',
                                style: TextStyle(color: AppColors.textLight, fontSize: 13),
                              ),
                            )
                          : Column(
                              children: relatedReminders.map((rem) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.alarm, color: AppColors.primary, size: 20),
                                    ),
                                    title: Text(rem.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    subtitle: Text(
                                      '${rem.dateTime.month}/${rem.dateTime.day} at ${rem.dateTime.hour}:${rem.dateTime.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: rem.status == 'Overdue' ? AppColors.highPriorityBg : AppColors.lowPriorityBg,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        rem.status,
                                        style: TextStyle(
                                          color: rem.status == 'Overdue' ? AppColors.highPriorityText : AppColors.lowPriorityText,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.iconColor, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
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
