class OutreachPerson {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String status; // 'Active', 'Discipleship', 'New', 'Inactive'
  final DateTime lastFollowedUp;
  final int prayerRequestsCount;
  final double followUpRate; // percentage

  OutreachPerson({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.lastFollowedUp,
    required this.prayerRequestsCount,
    required this.followUpRate,
  });

  factory OutreachPerson.fromJson(Map<String, dynamic> json) {
    final int parsedId = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0;
    
    String parsedName = json['name']?.toString() ?? '';
    if (parsedName.isEmpty && json.containsKey('title')) {
      final words = (json['title']?.toString() ?? '').split(' ');
      if (words.isNotEmpty) {
        parsedName = words.map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').take(2).join(' ');
      }
    }
    if (parsedName.isEmpty) parsedName = 'Outreach Contact $parsedId';

    final String parsedEmail = json['email']?.toString() ?? '${parsedName.toLowerCase().replaceAll(' ', '.')}@university.edu';
    final String parsedPhone = json['phone']?.toString() ?? '+1 (555) ${100 + (parsedId % 900)}-${2000 + (parsedId % 7000)}';
    
    String parsedStatus = json['status']?.toString() ?? 'New Contact';
    if (json['status'] == null) {
      final statuses = ['New Contact', 'Active', 'Prayer', 'Active Discipleship'];
      parsedStatus = statuses[parsedId % statuses.length];
    }

    DateTime parsedDate = DateTime.now();
    if (json['lastFollowedUp'] != null) {
      parsedDate = DateTime.tryParse(json['lastFollowedUp'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now().subtract(Duration(days: parsedId % 15));
    }

    int prayerCount = 0;
    if (json['prayerRequestsCount'] is int) {
      prayerCount = json['prayerRequestsCount'];
    } else if (json['prayerRequestsCount'] != null) {
      prayerCount = int.tryParse(json['prayerRequestsCount'].toString()) ?? 0;
    } else {
      prayerCount = parsedId % 5;
    }

    double rate = 0.0;
    if (json['followUpRate'] is num) {
      rate = (json['followUpRate'] as num).toDouble();
    } else if (json['followUpRate'] != null) {
      rate = double.tryParse(json['followUpRate'].toString()) ?? 0.0;
    } else {
      rate = 60.0 + (parsedId % 40);
    }

    return OutreachPerson(
      id: parsedId,
      name: parsedName,
      email: parsedEmail,
      phone: parsedPhone,
      status: parsedStatus,
      lastFollowedUp: parsedDate,
      prayerRequestsCount: prayerCount,
      followUpRate: rate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'lastFollowedUp': lastFollowedUp.toIso8601String(),
      'prayerRequestsCount': prayerRequestsCount,
      'followUpRate': followUpRate,
    };
  }

  OutreachPerson copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? status,
    DateTime? lastFollowedUp,
    int? prayerRequestsCount,
    double? followUpRate,
  }) {
    return OutreachPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      lastFollowedUp: lastFollowedUp ?? this.lastFollowedUp,
      prayerRequestsCount: prayerRequestsCount ?? this.prayerRequestsCount,
      followUpRate: followUpRate ?? this.followUpRate,
    );
  }
}
