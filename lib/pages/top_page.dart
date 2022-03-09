import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterchatapp/model/talk_room.dart';
import 'package:flutterchatapp/model/user.dart';
import 'package:flutterchatapp/pages/settings_profile.dart';
import 'package:flutterchatapp/pages/talk_room.dart';
import 'package:flutterchatapp/utils/firebase.dart';

import '../utils/shared_prefs.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<TalkRoomData> talkUserList = [];
  User myProf = User(
      name: 'ななしさん',
      uid: 'uid',
      imagePath:
          'http://kumiho.sakura.ne.jp/twegg/gen_egg.cgi?r=59&g=148&b=217');
  String myUid = SharedPrefs.getUid();

  Future<void> createRooms() async {
    String myUid = SharedPrefs.getUid();
    talkUserList = await Firestore.getRooms(myUid);
  }

  Future<void> myProfFuture() async {
    String myUid = SharedPrefs.getUid();
    myProf = await Firestore.getProfile(myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: StreamBuilder<Object>(
              stream: Firestore.myProfSnapshot(myUid),
              builder: (context, snapshot) {
                return FutureBuilder(
                    future: myProfFuture(),
                    builder: (context, snapshot) {
                      return Center(
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(myProf.imagePath),
                                radius: 20,
                              ),
                            ),
                            Text(
                              myProf.name,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      );
                    });
              }),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingProfilePage()));
              },
              icon: Icon(Icons.settings),
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: Firestore.roomSnapshot,
            builder: (context, snapshot) {
              return FutureBuilder(
                  future: createRooms(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ListView.builder(
                          itemCount: talkUserList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TalkRoom(talkUserList[index])));
                              },
                              child: Container(
                                height: 70,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            talkUserList[index]
                                                .talkUser
                                                .imagePath),
                                        radius: 30,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          talkUserList[index].talkUser.name,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          talkUserList[index].lastMessage,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  });
            }));
  }
}
