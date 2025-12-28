class Group {
  final int id;
  final String name;
  final String code;
  final DateTime createdAt;
  final int ownerId; // Foreign key to User (1-1)

  Group({
    required this.id,
    required this.name,
    required this.code,
    required this.createdAt,
    required this.ownerId,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      createdAt: DateTime.parse(map['created_at']),
      ownerId: map['owner_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'created_at': createdAt.toIso8601String(),
      'owner_id': ownerId,
    };
  }
}