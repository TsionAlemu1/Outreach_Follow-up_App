import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/outreach_provider.dart';
import '../../widgets/outreach_card.dart';
import 'person_detail_screen.dart';

class OutreachScreen extends StatefulWidget {
  const OutreachScreen({super.key});

  @override
  State<OutreachScreen> createState() => _OutreachScreenState();
}

class _OutreachScreenState extends State<OutreachScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Outreach Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => _showAddContactSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Header
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 4),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search contacts...',
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Status Filter Badges (Horizontal scroll)
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: ['All', 'New Contact', 'Active', 'Prayer', 'Discipleship'].map((status) {
                      final bool isSelected = _selectedFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = status;
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.15),
                          selectedColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide.none,
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Main Contacts List
          Expanded(
            child: Consumer<OutreachProvider>(
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
                          const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.red),
                          const SizedBox(height: 12),
                          const Text(
                            'Failed to Load Contacts',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
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

                // Filter the contacts in memory
                final filteredList = provider.people.where((person) {
                  final matchesSearch = person.name.toLowerCase().contains(_searchQuery) ||
                      person.phone.contains(_searchQuery) ||
                      person.email.toLowerCase().contains(_searchQuery);
                  
                  bool matchesStatus = false;
                  if (_selectedFilter == 'All') {
                    matchesStatus = true;
                  } else if (_selectedFilter == 'New Contact') {
                    matchesStatus = person.status.toLowerCase() == 'new contact' || person.status.toLowerCase() == 'new';
                  } else if (_selectedFilter == 'Active') {
                    matchesStatus = person.status.toLowerCase() == 'active';
                  } else if (_selectedFilter == 'Prayer') {
                    matchesStatus = person.status.toLowerCase() == 'prayer';
                  } else if (_selectedFilter == 'Discipleship') {
                    matchesStatus = person.status.toLowerCase() == 'active discipleship' || person.status.toLowerCase() == 'discipleship';
                  }
                  
                  return matchesSearch && matchesStatus;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textLight.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'No contacts match your selection',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add a new campus contact by clicking the top button.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final person = filteredList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonDetailScreen(personId: person.id),
                          ),
                        );
                      },
                      child: OutreachCard(
                        person: person,
                        onToggle: () async {
                          // Cycles status
                          String newStatus = 'Active';
                          if (person.status == 'New') newStatus = 'Active';
                          if (person.status == 'Active') newStatus = 'Discipleship';
                          if (person.status == 'Discipleship') newStatus = 'Inactive';
                          if (person.status == 'Inactive') newStatus = 'New';
                          
                          try {
                            await provider.toggleContactStatus(person.id, newStatus);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Updated ${person.name} status to $newStatus!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to update status on server. Rolled back.')),
                            );
                          }
                        },
                        onDelete: () => _confirmDelete(context, provider, person.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showAddContactSheet(context),
      ),
    );
  }

  void _confirmDelete(BuildContext context, OutreachProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Contact'),
        content: const Text('Are you sure you want to remove this contact from your outreach tracker?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Remove', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
            onPressed: () async {
              try {
                await provider.deleteContact(id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact removed from fellowship records')),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete failed: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddContactSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String phone = '';
    String status = 'New';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Outreach Contact',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Name Field
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
                    onSaved: (val) => name = val!.trim(),
                  ),
                  const SizedBox(height: 12),

                  // Phone Field
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    onSaved: (val) => phone = val?.trim() ?? '',
                  ),
                  const SizedBox(height: 12),

                  // Email Field
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email Address',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    onSaved: (val) => email = val?.trim() ?? '',
                  ),
                  const SizedBox(height: 12),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: ['New', 'Active', 'Discipleship', 'Inactive']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) status = val;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        
                        // Show custom progress loading placeholder
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        try {
                          await context.read<OutreachProvider>().addContact(name, email, phone, status);
                          Navigator.pop(context); // Pop loading dialog
                          Navigator.pop(context); // Pop bottom sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contact added successfully!')),
                          );
                        } catch (e) {
                          Navigator.pop(context); // Pop loading dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save contact on API: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Add Contact'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
