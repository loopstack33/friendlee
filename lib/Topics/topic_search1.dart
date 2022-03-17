import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../chat_final/constants/color_constants.dart';
import '../chat_final/constants/firestore_constants.dart';
import '../chat_final/utils/utilities.dart';
import '../styles/app_color.dart';
import '/utils/size_config.dart';
class Searchone extends StatefulWidget {
  final String userid;

  const Searchone({Key? key,required this.userid}) : super(key: key);
  @override
  SearchoneScreenState createState() => SearchoneScreenState();
}

class SearchoneScreenState extends State<Searchone> {

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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, membersList);
        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                //margin: EdgeInsets.only(top: SizeConfig.screenHeight * .02),
                margin: const EdgeInsets.only(top: 35),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  child: Container(
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _search,
                            onChanged:(String? s){
                              onSearch();
                            },
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _search.text = "";
                                  },
                                ),
                                hintText: 'Search',

                                border: InputBorder.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                color: Colors.grey[200],
                margin: const EdgeInsets.only(left: 15, right: 15),
                padding: const EdgeInsets.all(7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:const [
                     Text(
                      "Searched Members",
                      style: TextStyle(fontSize: 16),
                    ),
                     Text(
                      "Clear",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              userMap != null
                  ? SizedBox(
                height: 100,
                child: ListTile(
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
              ),
                  )
                  :_search.text.isEmpty? const SizedBox.shrink(): const Text("No User Found"),
              const SizedBox(height: 10,),
              Container(
                color: Colors.grey[200],
                margin: const EdgeInsets.only(left: 15, right: 15),
                padding: const EdgeInsets.all(7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:const [
                    Text(
                      "Added Members",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Clear",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
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
                            return const Icon(
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
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.pop(context, membersList);
          },
          backgroundColor: ColorsX.appRedColor,
          child: Icon(FeatherIcons.userPlus),
        ),
      ),
    );
  }

  Widget retrieveData(BuildContext context) {
    return SizedBox(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection(FirestoreConstants.pathUserCollection).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            return ListView.builder(
              itemCount: streamSnapshot.data?.docs.length ?? 0,
              itemBuilder: (ctx, index) => streamSnapshot.data?.docs[index]['id'] != widget.userid?
              Container(
                child: TextButton(
                  child:  ListTile(
                    leading: Material(
                      child: "${streamSnapshot.data?.docs[index]['photoUrl']}".isNotEmpty
                          ? Image.network(
                          "${streamSnapshot.data?.docs[index]['photoUrl']}",
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
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
                      )
                          :const Icon(
                        Icons.account_circle,
                        size: 50,
                        color: ColorConstants.greyColor,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    title: Text("${streamSnapshot.data?.docs[index]['username']}",
                      style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${streamSnapshot.data?.docs[index]['email']}"),
                  ),
                  onPressed: () {
                    if (Utilities.isKeyboardShowing()) {
                      Utilities.closeKeyboard(context);
                    }
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ChatPage(
                    //       peerId: userChat.id,
                    //       peerAvatar: userChat.photoUrl,
                    //       peerNickname: userChat.nickname,
                    //     ),
                    //   ),
                    // );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                margin:const EdgeInsets.only(bottom: 10, left: 5, right: 5),
              )
             :const SizedBox.shrink(),
              // Text(streamSnapshot.data?.docs[index]['username']),
            );
          },
        ));
  }
}

