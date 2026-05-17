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
    return OutreachPerson(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 'New',
      lastFollowedUp: DateTime.parse(json['lastFollowedUp'] ?? DateTime.now().toIso8601String()),
      prayerRequestsCount: json['prayerRequestsCount'] ?? 0,
      followUpRate: (json['followUpRate'] as num?)?.toDouble() ?? 0.0,
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
