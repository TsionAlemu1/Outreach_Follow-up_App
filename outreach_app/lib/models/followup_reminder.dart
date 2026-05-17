enum FollowUpPriority {
  low,
  medium,
  high
}

class FollowUpReminder {
  final int id;
  final String title; // 'Bible Study', 'Prayer Meeting', etc.
  final String personName; // Contact name
  final DateTime dateTime;
  final FollowUpPriority priority;
  final String status; // 'Scheduled', 'Done', 'Overdue'
  final String notes;

  FollowUpReminder({
    required this.id,
    required this.title,
    required this.personName,
    required this.dateTime,
    required this.priority,
    required this.status,
    required this.notes,
  });

  factory FollowUpReminder.fromJson(Map<String, dynamic> json) {
    final int parsedId = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0;
    
    String parsedTitle = json['title']?.toString() ?? '';
    if (parsedTitle.isEmpty) parsedTitle = 'Bible Study';
    
    if (parsedTitle.split(' ').length > 4) {
      final words = parsedTitle.split(' ');
      parsedTitle = words.map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').take(2).join(' ') + ' Share';
    }

    final String parsedPersonName = json['personName']?.toString() ?? 'Michael Lee';
    
    DateTime parsedDate = DateTime.now();
    if (json['dateTime'] != null) {
      parsedDate = DateTime.tryParse(json['dateTime'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now().add(Duration(days: (parsedId % 10) - 2));
    }

    FollowUpPriority parsedPriority = FollowUpPriority.medium;
    if (json['priority'] != null) {
      final priStr = json['priority'].toString().toLowerCase();
      if (priStr.contains('high')) parsedPriority = FollowUpPriority.high;
      if (priStr.contains('low')) parsedPriority = FollowUpPriority.low;
    } else {
      final priorities = [FollowUpPriority.low, FollowUpPriority.medium, FollowUpPriority.high];
      parsedPriority = priorities[parsedId % priorities.length];
    }

    String parsedStatus = json['status']?.toString() ?? 'Scheduled';
    if (json['status'] == null) {
      if (parsedDate.isBefore(DateTime.now())) {
        parsedStatus = 'Overdue';
      } else {
        parsedStatus = 'Scheduled';
      }
    }

    final String parsedNotes = json['notes']?.toString() ?? json['body']?.toString() ?? '';

    return FollowUpReminder(
      id: parsedId,
      title: parsedTitle,
      personName: parsedPersonName,
      dateTime: parsedDate,
      priority: parsedPriority,
      status: parsedStatus,
      notes: parsedNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'personName': personName,
      'dateTime': dateTime.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'status': status,
      'notes': notes,
    };
  }

  FollowUpReminder copyWith({
    int? id,
    String? title,
    String? personName,
    DateTime? dateTime,
    FollowUpPriority? priority,
    String? status,
    String? notes,
  }) {
    return FollowUpReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      personName: personName ?? this.personName,
      dateTime: dateTime ?? this.dateTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
