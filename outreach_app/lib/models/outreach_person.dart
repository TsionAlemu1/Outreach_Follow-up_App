class OutreachPerson {
  final int id;
  final String name;
  final String followUpNotes;
  final bool isFollowedUp;

  OutreachPerson({
    required this.id,
    required this.name,
    required this.followUpNotes,
    this.isFollowedUp = false,
  });

  factory OutreachPerson.fromJson(Map<String, dynamic> json) {
    return OutreachPerson(
      id: json['id'] as int,
      name: json['title'] as String,
      followUpNotes: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'body': followUpNotes,
    };
  }

  OutreachPerson copyWith({
    int? id,
    String? name,
    String? followUpNotes,
    bool? isFollowedUp,
  }) {
    return OutreachPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      followUpNotes: followUpNotes ?? this.followUpNotes,
      isFollowedUp: isFollowedUp ?? this.isFollowedUp,
    );
  }
}
