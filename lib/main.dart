import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyApp());

class CompanyColors {
  CompanyColors._(); // this basically makes it so you can instantiate this class

  static const _blackPrimaryValue = 0xFF000000;

  static const MaterialColor black = const MaterialColor(
    _blackPrimaryValue,
    const <int, Color>{
      50: const Color(0xFFe0e0e0),
      100: const Color(0xFFb3b3b3),
      200: const Color(0xFF808080),
      300: const Color(0xFF4d4d4d),
      400: const Color(0xFF262626),
      500: const Color(_blackPrimaryValue),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anonymous',
      theme: ThemeData(
        primarySwatch: CompanyColors.black,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();

  String name = "Ester Tester";
  String cell = "3412345678";

  Future<String> changeName(BuildContext context) async {
    var myName = await createAlertDialog(context, "Inserisci il tuo yesNome");
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      if (myName != null) name = '$myName';
      user.name = '$name';
    });
    return '$myName';
  }

  Future<String> changeNumber(BuildContext context) async {
    var myNum = await createAlertDialog(context, "Inserisci il tuo yesNumero");
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      if (myNum != null) cell = '$myNum';
      //user.phonNumber = '$cell'; work in progress, devi modificare la classe user per aggiungere attributo
    });
    return '$myNum';
  }

  Future<String> createAlertDialog(BuildContext context, String str) {
    TextEditingController controller = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(str),
            content: TextField(
              controller: controller,
            ),
            actions: <Widget>[
              MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancella", style: TextStyle(color: Colors.red))),
              MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop(controller.text.toString());
                  },
                  splashColor: Colors.black,
                  child: Text("Conferma")),
            ],
          );
        });
  }

  final ChatUser user = ChatUser(
    name: "Ester Tester",
    uid: "15649655",
    containerColor: Colors.deepOrangeAccent,
    //containerColor: Colors.lightBlueAccent,
    //avatar: "https://firebasestorage.googleapis.com/v0/b/chat-cdecc.appspot.com/o/favicon.png?alt=media&token=8b2ce33c-d0ec-4c31-886e-b89d5ad916b3",
    avatar: "https://firebasestorage.googleapis.com/v0/b/chat-cdecc.appspot.com/o/test.png?alt=media&token=bcf890bf-fef6-4764-9755-d1089cd6d6c7",
  );

  final ChatUser otherUser = ChatUser(
    name: "Marianovich",
    uid: "25649655",
  );

  List<ChatMessage> messages = List<ChatMessage>();
  var m = List<ChatMessage>();

  var i = 0;

  @override
  void initState() {
    super.initState();
  }

  void systemMessage() {
    Timer(Duration(milliseconds: 300), () {
      if (i < 6) {
        setState(() {
          messages = [...messages, m[i]];
        });
        i++;
      }
      Timer(Duration(milliseconds: 300), () {
        _chatViewKey.currentState.scrollController
          ..animateTo(
            _chatViewKey.currentState.scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
      });
    });
  }

  String initials(String name)
  {
    String result = "";
    if ('$name'.split(" ") != null)
    {  
      for(int i = 0; i<'$name'.split(" ").length; i++)
      result += '$name'.split(" ")[i].split("")[0];
    }
    return result;
  }

  void onSend(ChatMessage message) {
    print(message.toJson());
    var documentReference = Firestore.instance
        .collection('messages')
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        message.toJson(),
      );
    });
     setState(() {
      messages = [...messages, message];
      print(messages.length);
    });

    if (i == 0) {
      systemMessage();
      Timer(Duration(milliseconds: 600), () {
        systemMessage();
      });
    } else {
      systemMessage();
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anonymous", style: GoogleFonts.lobster(),),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('messages').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              );
            } else {
              List<DocumentSnapshot> items = snapshot.data.documents;
              var messages =
                  items.map((i) => ChatMessage.fromJson(i.data)).toList();
              return DashChat(
                key: _chatViewKey,
                inverted: false,
                onSend: onSend,
                sendOnEnter: true,
                textInputAction: TextInputAction.send,
                user: user,
                inputDecoration:
                    InputDecoration.collapsed(hintText: "  scrivi qualcosa... (ultrayes)", border: OutlineInputBorder(borderSide: BorderSide(width: 5.0, ), borderRadius: const BorderRadius.all(Radius.circular(16.0)))),
                dateFormat: DateFormat('dd-MMM-yyyy'),
                timeFormat: DateFormat('HH:mm'),
                messages: messages,
                showUserAvatar: true,
                showAvatarForEveryMessage: false,
                scrollToBottom: true,
                onPressAvatar: (ChatUser user) {
                  print("OnPressAvatar: ${user.name}");
                  final stampaNome = SnackBar(
                    content: Text("${user.name}"),
                    action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {//qualcosa
                    },
                    ),);
                    Scaffold.of(context).showSnackBar(stampaNome);
                },
                onLongPressAvatar: (ChatUser user) {
                  //print("OnLongPressAvatar: ${user.name}");
                  final stampaNome = SnackBar(
                    content: Text("${user.name}"),
                    action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {

                    },
                    ),);
                    Scaffold.of(context).showSnackBar(stampaNome);
                },
                inputMaxLines: 5,
                messageContainerPadding: EdgeInsets.only(left: 8.0, right: 1.0),
                alwaysShowSend: true,
                inputTextStyle: GoogleFonts.nunito(fontSize: 18.0),
                inputContainerStyle: BoxDecoration(
                  //border: Border.all(width: 0.0),
                  borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(0.0),
                topRight: const Radius.circular(0.0),
                bottomLeft: const Radius.circular(0.0),
                bottomRight: const Radius.circular(0.0),
              ),
                  color: Colors.white60,
                ),
                onQuickReply: (Reply reply) {
                  setState(() {
                    messages.add(ChatMessage(
                        text: reply.value,
                        createdAt: DateTime.now(),
                        user: user));

                    messages = [...messages];
                  });

                  Timer(Duration(milliseconds: 200), () {
                    _chatViewKey.currentState.scrollController
                      ..animateTo(
                        _chatViewKey.currentState.scrollController.position
                            .maxScrollExtent,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 200),
                      );

                    if (i == 0) {
                      systemMessage();
                      Timer(Duration(milliseconds: 300), () {
                        systemMessage();
                      });
                    } else {
                      systemMessage();
                    }
                  });
                },
                onLoadEarlier: () {
                  print("carichiamo sto azz di messaggio...");
                },
                shouldShowLoadEarlier: false,
                showTraillingBeforeSend: false,
                trailing: <Widget>[
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: () async {
                      File result = await ImagePicker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                        maxHeight: 400,
                        maxWidth: 400,
                      );

                      if (result != null) {
                        final StorageReference storageRef =
                            FirebaseStorage.instance.ref().child("chat_images/"+ result.path);

                        StorageUploadTask uploadTask = storageRef.putFile(
                          result,
                          StorageMetadata(
                            contentType: 'image/png',
                          ),
                        );
                        StorageTaskSnapshot download =
                            await uploadTask.onComplete;

                        String url = await download.ref.getDownloadURL();

                        ChatMessage message =
                            ChatMessage(text: "", user: user, image: url);

                        var documentReference = Firestore.instance
                            .collection('messages')
                            .document(DateTime.now()
                                .millisecondsSinceEpoch
                                .toString());

                        Firestore.instance.runTransaction((transaction) async {
                          await transaction.set(
                            documentReference,
                            message.toJson(),
                          );
                        });
                      }
                    },
                  )
                ],
              );
            }
          }),
          drawer: Drawer(
        elevation: 16.0,
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('$name'),
              accountEmail: Text('$cell'),
              currentAccountPicture: CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.transparent,
                /*child: Text('$name'.split("")[0] +
                    '$name'.split(" ")[1].split("")[
                        0]), //it takes the first letters of the name (name and surname). it doesn't work in multiple name case. (not definitive)*/
                backgroundImage: NetworkImage("${user.avatar}"),
              ),
              otherAccountsPictures: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(initials(name), style: TextStyle(color: Colors.white)), //it takes the first letters of the name (name and surname). it doesn't work in multiple name case. (not definitive),
                )
              ],
            ),
            ListTile(
              title: new Text("cambia nome"),
              leading: new Icon(Icons.account_circle),
              onTap: () {
                changeName(this.context);
              },
            ),
            Divider(
              height: 0.1,
            ),
            ListTile(
              title: new Text("cambia numero"),
              leading: new Icon(Icons.call),
              onTap: () {
                changeNumber(this.context);
              },
            ),
            Divider(
              height: 0.1,
            ),
            /*ListTile(
              title: new Text("Promotions"),
              leading: new Icon(Icons.local_offer),
            )*/
          ],
        ),
      ),
    );
  }
}
