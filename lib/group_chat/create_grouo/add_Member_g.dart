
import 'package:chatapp/styles/app_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../chat_final/constants/color_constants.dart';
import '../../chat_final/constants/firestore_constants.dart';
import 'create_group.dart';

class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({Key? key}) : super(key: key);

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "username": map['username'],
          "id": map['id'],
          "email": map['email'],
          "photoUrl": map['photoUrl'],
          "isAdmin": true,
        });
      });
    });
  }

  void onSearch() async {
    if(_search.text.isEmpty){
      Fluttertoast.showToast(msg: "Please write email..");
    }
    else {
      setState(() {
      isLoading = true;
    });
      await _firestore
          .collection(FirestoreConstants.pathUserCollection)
          .where("email", isEqualTo: _search.text.toLowerCase())
          .get()
          .then((value) {
        setState(() {
          if(value.docs.isNotEmpty){
            isLoading = false;
            userMap = value.docs[0].data();
          }
          else {

            isLoading = false;
          }

        });

      });
    }


  }

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['id'] == userMap!['id']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {

        membersList.add({
          "username": userMap!['username'],
          "id": userMap!['id'],
          "email": userMap!['email'],
          "photoUrl": userMap!['photoUrl'],
          "isAdmin": false,
        });

        userMap = null;
      });
    }
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['id'] != _auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
      Fluttertoast.showToast(msg: "Member Removed");
    }
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
            Flexible(
              child: ListView.builder(
                itemCount: membersList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => onRemoveMembers(index),
                    leading: Material(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        membersList[index]['photoUrl'],
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
                          return Icon(
                            Icons.account_circle,
                            size: 50,
                            color: ColorConstants.greyColor,
                          );
                        },
                      ),
                    ),
                    title: Text(membersList[index]['username'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    subtitle: Text(membersList[index]['email'],style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300),),
                    trailing: Icon(FeatherIcons.xCircle),
                  );
                },
              ),
            ),
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
                  onChanged:(String? s){
                    onSearch();
                  },
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: Icon(FeatherIcons.search),
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

            userMap != null
                ? ListTile(
              onTap: onResultTap,
              leading: Material(
                borderRadius: BorderRadius.all(Radius.circular(25)),
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
                    return Icon(
                      Icons.account_circle,
                      size: 50,
                      color: ColorConstants.greyColor,
                    );
                  },
                ),
              ),
              title: Text(userMap!['username'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
              subtitle: Text(userMap!['email'],style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300),),
              trailing: Icon(FeatherIcons.plusCircle),
            )
                : _search.text.isEmpty? const SizedBox.shrink(): const Text("No User Found"),
          ],
        ),
      ),
      floatingActionButton: membersList.length >= 2
          ? FloatingActionButton(
        backgroundColor: ColorsX.appRedColor,
        child: Icon(Icons.forward),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateGroup(
              membersList: membersList,
            ),
          ),
        ),
      )
          : SizedBox(),
    );
  }
}