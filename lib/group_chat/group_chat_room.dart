
import 'dart:io';
import 'package:chatapp/chat_final/constants/firestore_constants.dart';
import 'package:chatapp/service/fcm_services.dart';
import 'package:chatapp/styles/app_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../chat_final/constants/color_constants.dart';
import 'full_photo_page.dart';
import '../chat_final/widgets/loading_view.dart';
import '../network/network-list.dart';
import '../service/local_notification.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName,groupAvatar;
  final int groupLength;
  final List ids;

  GroupChatRoom({required this.groupName, required this.ids,required this.groupChatId,required this.groupAvatar,required this.groupLength, Key? key})
      : super(key: key);

  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController _message = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "SendBy": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
    FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }
  final ScrollController listScrollController = ScrollController();
  int _limit = 20;
  int _limitIncrement = 20;
  List<QueryDocumentSnapshot> listMessage = [];

  @override
  void initState() {
    super.initState();
    FCMServices.fcmGetTokenandSubscribe('chat');
    fcmListen();
    listScrollController.addListener(_scrollListener);
    getGroupDetails();
  }

  List membersList = [];
  Future getGroupDetails() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupChatId)
        .get()
        .then((chatMap) {
      membersList = chatMap['members'];
      isLoading = false;
      setState(() {});
    });
  }

  _scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) == _auth.currentUser!.uid) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) !=  _auth.currentUser!.uid) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLoading = false;

  fcmListen() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      if(_auth.currentUser!.uid.toString() != event.data["userid"].toString() ) {
        // widget.ids.forEach((i) {
        //   if (widget.ids[i]["id"].toString() == event.data["id"].toString()) {
        //     LocalNotificationsService.instance.showChatNotification(
        //         title: '${event.notification!.title}',
        //         body: '${event.notification!.body}');
        //   }
        //   else{
        //     print("Err");
        //   }
        // });
        if(widget.ids.contains(event.data["id"].toString())){
          LocalNotificationsService.instance.showChatNotification(
                   title: '${event.notification!.title}',
                     body: '${event.notification!.body}');
        }
      }
      FirebaseMessaging.onMessageOpenedApp.listen((message) {

      });

    });

  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
      FCMServices.sendFCM('chat', widget.groupChatId,"new message", _auth.currentUser!.displayName, _message.text.toString());
      _message.clear();
    }
    else{
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: ColorConstants.greyColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsX.appRedColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.groupAvatar),
              radius: 20,
            ),
            const SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groupName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                  Text(
                  "${membersList.length} Participants",
                  style:const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NetworkList(
                     groupName: widget.groupName,
                     groupAvatar:widget.groupAvatar,
                     groupId: widget.groupChatId,
                  ),
                ),
              ),
              icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Input content
              buildInput(),
            ],
          ),
          // Loading
          buildLoading()
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? LoadingView() : SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: ColorsX.appRedColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: TextField(
              onSubmitted: (value) {
                onSendMessage();
              },
              style:const TextStyle(color: ColorConstants.primaryColor, fontSize: 15),
              controller: _message,
              decoration:const InputDecoration.collapsed(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: ColorConstants.greyColor),
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(),
                color: ColorsX.appRedColor
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)), color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: widget.groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('groups')
            .doc(widget.groupChatId)
            .collection('chats')
            .orderBy('time', descending: true)
            .limit(_limit)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            listMessage = snapshot.data!.docs;
            if (listMessage.isNotEmpty) {
              return ListView.builder(
                padding:const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  Map<String, dynamic> chatMap =
                  snapshot.data!.docs[index].data()
                  as Map<String, dynamic>;
                  return  messageTile(chatMap);
                },
                itemCount: snapshot.data?.docs.length,
                reverse: true,
                controller: listScrollController,
              );
            } else {
              return const Center(child: Text("No message here yet..."));
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorsX.appRedColor,
              ),
            );
          }
        },
      )
          :const Center(
        child: CircularProgressIndicator(
          color: ColorsX.appRedColor,
        ),
      ),
    );
  }

  Widget messageTile(Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          width: MediaQuery.of(context).size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                decoration: BoxDecoration(color: Color(0xFFFAF0E7), borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight:  Radius.circular(8),bottomLeft:  Radius.circular(8))),

              child: Column(
                children: [
                  Text(
                    chatMap['sendBy'],
                    style: TextStyle(color: ColorConstants.primaryColor,fontSize: 14,),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 200,
                  ),
                  Text(
                    chatMap['message'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              )),
        );
      }
      else if (chatMap['type'] == "img") {
        return Container(
          width: MediaQuery.of(context).size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
           // height: size.height / 2,
            child:Container(
              child: OutlinedButton(
                child: Material(
                  child: Image.network(
                    chatMap['message'],
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return  Container(
                        decoration:const BoxDecoration(
                          color: ColorConstants.greyColor2,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        width: 200,
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: ColorConstants.themeColor,
                            value: loadingProgress.expectedTotalBytes != null &&
                                loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return Material(
                        child: Image.asset(
                          'assets/images/chat_images/img_not_available.jpeg',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        clipBehavior: Clip.hardEdge,
                      );
                    },
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  clipBehavior: Clip.hardEdge,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullPhotoPage(
                        url: chatMap['message'],
                      ),
                    ),
                  );
                },
                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
              ),

            )


          ),
        );
      }
      else if (chatMap['type'] == "notify") {
        return Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
      else {
        return SizedBox();
      }
    });
  }
}