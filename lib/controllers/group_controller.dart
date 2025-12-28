import 'dart:math';
import '../services/database_service.dart';
import '../models/group.dart';
import '../models/group_member.dart';
import '../models/user.dart';

class GroupController {

  Future<void> createGroup(String nom, int createurId) async {
    String code = _generateUniqueCode();

    Group newGroup = Group(
      id: 0,
      name: nom,
      code: code,
      createdAt: DateTime.now(),
      ownerId: createurId,
    );

    await DatabaseService().createGroupWithMember(newGroup, createurId);
  }

  Future<void> joinGroup(String code, int userId) async {
    Group? group = await DatabaseService().getGroupByCode(code);

    if (group == null) {
      throw Exception("Code not linked to any group");
    }

    GroupMember membre = GroupMember(
      groupId: group.id,
      userId: userId,
      joinedAt: DateTime.now(),
    );

    await DatabaseService().insertMember(membre);
  }

  Future<void> leaveGroup(int groupId, int userId) async {
    await DatabaseService().removeMember(groupId, userId);
  }

  Future<void> deleteGroup(int groupId, int userId) async {
    Group group = await DatabaseService().getGroupById(groupId);

    if (group.ownerId != userId) {
      throw Exception("Only the owner can delete the group");
    }

    await DatabaseService().deleteGroup(groupId);
  }

  Future<String> getGroupCode(int groupId) async {
    Group group = await DatabaseService().getGroupById(groupId);
    return group.code;
  }

  String _generateUniqueCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<List<Group>> getMyGroups(int userId) async {
    return await DatabaseService().getUserGroups(userId);
  }




  Future<List<User>> getMembers(int groupId) async {
    return await DatabaseService().getGroupMembers(groupId);
  }

  Future<void> modifyGroupName(int groupId, String newName, int userId) async {
    Group group = await DatabaseService().getGroupById(groupId);

    if (group.ownerId != userId) {
      throw Exception("Action denied: You are not the group owner.");
    }

    await DatabaseService().updateGroupName(groupId, newName);
  }

}