import 'package:chatapp/chat_final/constants/firestore_constants.dart';
import 'package:chatapp/group_chat/group_chat.dart';
import 'package:chatapp/styles/app_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../chat_final/constants/color_constants.dart';

class AddMembersINGroup extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;
  const AddMembersINGroup(
      {required this.name,
        required this.membersList,
        required this.groupChatId,
        Key? key})
      : super(key: key);

  @override
  _AddMembersINGroupState createState() => _AddMembersINGroupState();
}

class _AddMembersINGroupState extends State<AddMembersINGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    membersList = widget.membersList;
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection(FirestoreConstants.pathUserCollection)
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void onAddMembers() async {
    membersList.add({
      "username": userMap!['username'],
      "id": userMap!['id'],
      "email": userMap!['email'],
      "photoUrl": userMap!['photoUrl'],
      "isAdmin": false,
    });

    await _firestore.collection('groups').doc(widget.groupChatId).update({
      "members": membersList,
    });

    await _firestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(userMap!['id'])
        .collection('groups')
        .doc(widget.groupChatId)
        .set({
      "username": widget.name,
      "id": widget.groupChatId});
    Fluttertoast.showToast(msg: "Member Added");
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_)=>const GroupChatScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsX.appRedColor,

        title: Text("Add Members"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: size.height / 20,
            ),
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 14,
                width: size.width / 1.15,
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    prefixIcon: Icon(FeatherIcons.search),
                    hintText: "Search",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height / 50,
            ),
            isLoading
                ? Container(
              height: size.height / 12,
              width: size.height / 12,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
                : ElevatedButton(
              onPressed: onSearch,
              style: ElevatedButton.styleFrom(
                  primary: ColorsX.appRedColor,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              child: Text("Search"),
            ),
            userMap != null
                ? ListTile(
              onTap: onAddMembers,
              leading: Material(
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  userMap!['photoUrl'],
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 50,
                      height: 50,
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
                    return const Icon(
                      Icons.account_circle,
                      size: 50,
                      color: ColorConstants.greyColor,
                    );
                  },
                ),
              ),
              title: Text(userMap!['username']),
              subtitle: Text(userMap!['email']),
              trailing: Icon(FeatherIcons.plusCircle),
            )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}