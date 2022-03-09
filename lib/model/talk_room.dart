import 'package:flutterchatapp/model/user.dart';

class TalkRoomData {
  String roomId;
  User talkUser;
  String lastMessage;

  TalkRoomData(
      {required this.roomId,
      required this.talkUser,
      required this.lastMessage});
}
