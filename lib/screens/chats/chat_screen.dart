import 'package:flash_chat_flutter/screens/take_picture.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flash_chat_flutter/components/message_stream.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.users,
  }) : super(key: key);
  static const String id = 'chat_screen';
  final String chatId;
  final List users;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController controller;
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final title = _firestore.collection('chats').doc('title');
  String? messageText;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    controller = TextEditingController();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addUser({required users}) {
    final db = _firestore.collection('chats').doc(widget.chatId);
    return db.update({
      'users': FieldValue.arrayUnion([users])
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<String?> addNewUsers() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Add Users to Chat'),
              content: TextField(
                autofocus: true,
                decoration: InputDecoration(hintText: 'Enter User Email'),
                controller: controller,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(controller.text);
                  },
                  child: Text('SUBMIT'),
                ),
              ],
            ));
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.userPlus),
              onPressed: () async {
                final newUser = await addNewUsers();
                if (newUser == null || newUser.isEmpty) return;
                addUser(users: newUser);
              },
            ),
          )
        ],
        title: Text(''),
        backgroundColor: Colors.blueGrey,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(chatId: widget.chatId),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, TakePictureScreen.id);
                    },
                    child: Icon(
                      FontAwesomeIcons.camera,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration.copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.circleArrowUp,
                            color: Colors.blueGrey,
                          ),
                          onPressed: () {
                            messageTextController.clear();
                            _firestore.collection('messages').add({
                              'chatId': widget.chatId,
                              'text': messageText,
                              'sender': loggedInUser?.email,
                              'sent': Timestamp.now(),
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Icon(
                      FontAwesomeIcons.circlePlus,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
