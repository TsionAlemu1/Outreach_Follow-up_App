import 'package:flutter/material.dart';
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: person.isFollowedUp ? TextDecoration.lineThrough : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person.followUpNotes,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${person.id}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    person.isFollowedUp ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: person.isFollowedUp ? Colors.green : null,
                  ),
                  tooltip: person.isFollowedUp ? 'Mark not followed up' : 'Mark as followed up',
                  onPressed: onToggle,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
