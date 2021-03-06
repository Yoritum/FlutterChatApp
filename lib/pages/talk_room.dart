import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterchatapp/model/message.dart';
import 'package:flutterchatapp/model/talk_room.dart';
import 'package:flutterchatapp/utils/firebase.dart';
import 'package:intl/intl.dart' as intl;

class TalkRoom extends StatefulWidget {
  final TalkRoomData room;
  TalkRoom(this.room);
  @override
  _TalkRoomState createState() => _TalkRoomState();
}

class _TalkRoomState extends State<TalkRoom> {
  List<Message> messageList = [];
  TextEditingController controller = TextEditingController();

  Future<void> getMessages() async {
    messageList = await Firestore.getMessages(widget.room.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: Text(widget.room.talkUser.name),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.messageSnapshot(widget.room.roomId),
                builder: (context, snapshot) {
                  return FutureBuilder(
                    future: getMessages(),
                    builder: (context, snapshot) {
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: RangeMaintainingScrollPhysics(),
                          reverse: true,
                          itemCount: messageList.length,
                          itemBuilder: (context, index) {
                            Message _message = messageList[index];
                            DateTime sendTime = _message.sendTime.toDate();
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: 10,
                                  right: 10,
                                  left: 10,
                                  bottom: index == 0 ? 10 : 0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                textDirection: messageList[index].isMe
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                children: [
                                  Container(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                          color: messageList[index].isMe
                                              ? Colors.green
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(18)),
                                      child: Text(messageList[index].message)),
                                  Text(
                                      intl.DateFormat('yy/MM/dd_HH:mm')
                                          .format(sendTime),
                                      style: TextStyle(
                                        fontSize: 10,
                                      )),
                                ],
                              ),
                            );
                          });
                    },
                  );
                }),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 60,
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                  )),
                  IconButton(
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        await Firestore.sendMessage(
                            widget.room.roomId, controller.text);
                        controller.clear();
                      }
                    },
                    icon: Icon(Icons.send),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
