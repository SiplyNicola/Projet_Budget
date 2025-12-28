class GroupMember {
  final int groupId;
  final int userId;
  final DateTime joinedAt;

  GroupMember({
    required this.groupId,
    required this.userId,
    required this.joinedAt,
  });

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      groupId: map['group_id'],
      userId: map['user_id'],
      joinedAt: DateTime.parse(map['joined_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'group_id': groupId,
      'user_id': userId,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}