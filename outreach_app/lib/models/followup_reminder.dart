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
    return FollowUpReminder(
      id: json['id'] as int,
      title: json['title'] as String,
      personName: json['personName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      priority: FollowUpPriority.values.firstWhere(
        (e) => e.toString().split('.').last == (json['priority'] ?? 'medium'),
        orElse: () => FollowUpPriority.medium,
      ),
      status: json['status'] ?? 'Scheduled',
      notes: json['notes'] ?? '',
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
