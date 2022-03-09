import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterchatapp/model/message.dart';
import 'package:flutterchatapp/model/talk_room.dart';
import 'package:flutterchatapp/model/user.dart';
import 'package:flutterchatapp/pages/talk_room.dart';
import 'package:flutterchatapp/utils/shared_prefs.dart';

class Firestore {
  static FirebaseFirestore _firestoreinstance = FirebaseFirestore.instance;
  static final userRef = _firestoreinstance.collection('user');
  static final roomRef = _firestoreinstance.collection('room');
  static final roomSnapshot = roomRef.snapshots();

  static Future<void> addUser() async {
    final newDoc = await _firestoreinstance.collection('user').add({
      'name': 'ななしさん',
      'image_path':
          'http://kumiho.sakura.ne.jp/twegg/gen_egg.cgi?r=59&g=148&b=217&dl=dl'
    });
    print('accountOK');

    print(newDoc.id);
    await SharedPrefs.setUid(newDoc.id);
    String uid = SharedPrefs.getUid();
    print(uid);

    List<String> userIds = await getUser();
    userIds.forEach((user) async {
      if (user != newDoc.id) {
        await roomRef.add({
          'joined_user_ids': [user, newDoc.id],
          'updated_time': Timestamp.now()
        });
      }
    });
    print('roomOK');
  }

  static Future<List<String>> getUser() async {
    final snapshot = await userRef.get();
    List<String> userIds = [];
    snapshot.docs.forEach((user) {
      userIds.add(user.id);
      print('kyめんとい ${user.id} ${user.data()['name']}');
    });
    return userIds;
  }

  static Future<User> getProfile(String uid) async {
    final profile = await userRef.doc(uid).get();
    User myProfile = User(
      name: profile.data()!['name'],
      uid: uid,
      imagePath: profile.data()!['image_path'],
    );
    return myProfile;
  }

  static Future<void> updateProfile(User newProfile) async {
    String myUid = SharedPrefs.getUid();
    userRef.doc(myUid).update({
      'name': newProfile.name,
      'image_path': newProfile.imagePath,
    });
  }

  static Future<List<TalkRoomData>> getRooms(String myUid) async {
    final snapshot = await roomRef.get();
    List<TalkRoomData> roomList = [];
    await Future.forEach<QueryDocumentSnapshot<Map<String, dynamic>>>(
        snapshot.docs, (doc) async {
      if (doc.data()['joined_user_ids'].contains(myUid)) {
        String yourUid = '';
        doc.data()['joined_user_ids'].forEach((id) {
          if (id != myUid) {
            yourUid = id;
            return;
          }
        });
        User yourProfile = await getProfile(yourUid);
        TalkRoomData room = TalkRoomData(
            roomId: doc.id,
            talkUser: yourProfile,
            lastMessage: doc.data()['last_message'] ?? '');
        roomList.add(room);
      }
    });
    print(roomList.length);
    return roomList;
  }

  static Future<List<Message>> getMessages(String roomId) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    List<Message> messageList = [];
    final snapshot = await messageRef.get();
    await Future.forEach<QueryDocumentSnapshot<Map<String, dynamic>>>(
        snapshot.docs, (doc) {
      bool isMe;
      String myUid = SharedPrefs.getUid();
      if (doc.data()['sender_id'] == myUid) {
        isMe = true;
      } else {
        isMe = false;
      }
      Message message = Message(
          message: doc.data()['message'],
          isMe: isMe,
          sendTime: doc.data()['send_time']);
      messageList.add(message);
    });
    messageList.sort((a, b) => b.sendTime.compareTo(a.sendTime));
    return messageList;
  }

  static Future<void> sendMessage(String roomId, String message) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    String myUid = SharedPrefs.getUid();
    await messageRef.add(
        {'message': message, 'sender_id': myUid, 'send_time': Timestamp.now()});

    roomRef.doc(roomId).update({'last_message': message});
  }

  static Stream<QuerySnapshot> messageSnapshot(String roomId) {
    return roomRef.doc(roomId).collection('message').snapshots();
  }

//ここから改変分
  static Stream<DocumentSnapshot<Map<String, dynamic>>> myProfSnapshot(
      String uid) {
    return userRef.doc(uid).snapshots();
  }
}
