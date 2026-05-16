import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/outreach_provider.dart';
import '../widgets/outreach_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OutreachProvider>().fetchPeople();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outreach Follow-ups'),
        centerTitle: true,
      ),
      body: Consumer<OutreachProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Fetching outreach records...');
          }

          if (provider.errorMessage != null) {
            return AppErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchPeople(),
            );
          }

          if (provider.people.isEmpty) {
            return const Center(child: Text('No outreach records found.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchPeople(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.people.length,
              itemBuilder: (context, index) {
                final person = provider.people[index];
                return OutreachCard(
                  person: person,
                  onToggle: () => provider.toggleFollowUp(person.id),
                  onDelete: () => _confirmDelete(context, provider, person.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, OutreachProvider provider, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this outreach record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      provider.removePerson(id);
    }
  }
}
