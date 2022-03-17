import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../chat_final/constants/color_constants.dart';
import '../group_chat/add_member.dart';
import '../styles/app_color.dart';
import '../utils/AppStrings.dart';
import '../utils/common-functions.dart';
import 'package:chatapp/group_chat/group_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';


class NetworkList extends StatefulWidget {
  final String groupId, groupName,groupAvatar;
  const NetworkList({Key? key,required this.groupId, required this.groupName,required this.groupAvatar}) : super(key: key);

  @override
  _FamilyState createState() => _FamilyState();
}

class _FamilyState extends State<NetworkList> {
  List membersList = [];
  bool isLoading = true;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    getGroupDetails();
  }

  Future getGroupDetails() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((chatMap) {
      membersList = chatMap['members'];
      isLoading = false;
      setState(() {});
    });
  }

  bool checkAdmin() {
    bool isAdmin = false;
    membersList.forEach((element) {
      if (element['id'] == _auth.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    });
    return isAdmin;
  }

  Future removeMembers(int index) async {
    String uid = membersList[index]['id'];

    setState(() {
      isLoading = true;
      membersList.removeAt(index);
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    }).then((value) async {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();
      Fluttertoast.showToast(msg: "Member Removed");
      setState(() {
        isLoading = false;
      });
    });
  }

  // Future removeGroup() async {
  //   await _firestore
  //       .collection('users')
  //       .doc(_auth.currentUser!.uid)
  //       .collection("groups")
  //       .doc(widget.groupId)
  //       .delete();
  //   await _firestore
  //       .collection('groups')
  //       .doc(widget.groupId)
  //       .delete();
  //   setState((){
  //     isLoading = false;
  //   });
  //   Fluttertoast.showToast(msg: "Network Removed!");
  //   Navigator.of(context).push(
  //       MaterialPageRoute(
  //           builder: (_) => GroupChatScreen())
  //   );
  // }

  void showDialogBox(int index) {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != membersList[index]['id']) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: ListTile(
                  onTap: () => removeMembers(index),
                  title:const Text("Remove This Member"),
                ),
              );
            });
      }
    }
  }

  Future onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });

      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['id'] == _auth.currentUser!.uid) {
          membersList.removeAt(i);
        }
      }

      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GroupChatScreen()),
            (route) => false,
      );
    }
    else{
      Fluttertoast.showToast(msg: "You can't Leave group you are admin. You can remove network.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          elevation: 5,
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: ColorsX.black,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:  [
              Text(
                widget.groupName,
                style:const TextStyle(fontSize: 20, color: ColorsX.red,fontWeight: FontWeight.bold),
              ),
              const Text(
                'Group',
                style: TextStyle(
                    fontSize: 12, color: Color.fromRGBO(127, 128, 138, 1)),
              ),
            ],
          ),

          actions: [
            Container(
              margin: EdgeInsets.only(left: 5),
              child: const CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 30,
                child: Icon(
                  Icons.edit,
                  color: Color.fromRGBO(218, 218, 218, 1),
                ),
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 30,
              child: Icon(
                Icons.add,
                color: Color.fromRGBO(218, 218, 218, 1),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color:ColorsX.appRedColor),
      ):
      SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Material(
                child: widget.groupAvatar.isNotEmpty
                    ? Material(
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                  clipBehavior: Clip.hardEdge,
                      child: Image.network(
                  widget.groupAvatar,
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
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
                    )
                    : const Icon(
                  Icons.account_circle,
                  size: 50,
                  color: ColorConstants.greyColor,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                clipBehavior: Clip.hardEdge,
              ),
              Container(
                margin: EdgeInsets.only(left: 10, top: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Members (${membersList.length})',
                    style:const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(123, 68, 37, 1)),
                  ),
                ),
              ),
              checkAdmin()?
              Container(
                margin:const EdgeInsets.only(left: 0, top: 15),
                child: ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddMembersINGroup(
                        groupChatId: widget.groupId,
                        name: widget.groupName,
                        membersList: membersList,
                      ),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Color.fromRGBO(196, 196, 196, 1),
                    radius: 25,
                    child: Icon(
                      Icons.add,
                      color: ColorsX.white,
                    ),
                  ),
                  title: Text(
                    'Add members',
                    style: TextStyle(
                        fontSize: 15, color: Color.fromRGBO(127, 128, 138, 1)),
                  ),
                ),
              )
             : const SizedBox.shrink(),
              Flexible(
                child: ListView.builder(
                  itemCount: membersList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => showDialogBox(index),
                      leading: Material(
                        borderRadius: const BorderRadius.all(Radius.circular(25)),
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
                      title: Text(
                        membersList[index]['username'],
                        style: TextStyle(
                          fontSize: size.width / 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(membersList[index]['email']),
                      trailing: Text(
                          membersList[index]['isAdmin'] ? "Group Admin" : "User",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500,fontStyle: FontStyle.italic),),
                    );
                  },
                ),
              ),
              ListTile(
                onTap: onLeaveGroup,
                leading: const Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                ),
                title: Text(
                  "Leave Group",
                  style: TextStyle(
                    fontSize: size.width / 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // setState((){
                  //   isLoading = true;
                  // });
                  // removeGroup();
                },
                child: Container(
                  margin:const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  child:const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Remove Network',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(210, 38, 48, 1)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
