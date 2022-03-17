import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../Topics/topic_search1.dart';
import '../../chat_final/constants/color_constants.dart';
import '../../chat_final/constants/firestore_constants.dart';
import '../../chat_final/models/group_model.dart';
import '../../chat_final/providers/group_provider.dart';
import '../../chat_final/widgets/loading_view.dart';
import '../../group_chat/group_chat.dart';
import '../../styles/app_color.dart';
import 'package:chatapp/group_chat/group_chat.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';


class OnBoardingNetwork extends StatefulWidget {
  String email;
  String pass;
  String username;
  String id;
  final List<Map<String, dynamic>>? membersList;

  OnBoardingNetwork({Key? key, required this.email,required this.id,required this.username,required this.pass,this.membersList}) : super(key: key);

  @override
  State<OnBoardingNetwork> createState() => _OnBoardingNetworkState();
}

class _OnBoardingNetworkState extends State<OnBoardingNetwork> {
  String valuee = "";
  String valuee2 = "";

  late GroupProvider groupProvider;

  @override
  void initState() {
    super.initState();
    groupProvider = context.read<GroupProvider>();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController network = TextEditingController();
  bool isLoading = false;
  File? avatarImageFile;
  String groupphotoUrl = '';

  PickedFile? pickedFile;
  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    pickedFile = await imagePicker.getImage(source: ImageSource.gallery).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile!.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
      });
    }
  }
   List<Map<String, dynamic>> membersList=[];
  bool gotData = false;
  bool gType = false;
  var gText = "Private";

  void onRemoveMembers(int index) {
    if (membersList[index]['id'] != _auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
      Fluttertoast.showToast(msg: "Member Removed");
    }
    else{
      Fluttertoast.showToast(msg: "Can't Remove Admin, skip step if you don't want to create group");
    }
  }

  String groupId = const Uuid().v1();

  Future uploadFile() async {

    String fileName = groupId;
    UploadTask uploadTask = groupProvider.uploadFile(avatarImageFile!, fileName);
    try {
      await _firestore.collection('groups').doc(groupId).set({
        "members": membersList,
        "id": groupId,
        "type":gText.toString()
      });

      TaskSnapshot snapshot = await uploadTask;
      groupphotoUrl = await snapshot.ref.getDownloadURL();

      GroupModel updateInfo = GroupModel(
        id:groupId,
        photoUrl: groupphotoUrl,
        name:network.text,
        type:gText.toString()

      );
      for (int i = 0; i < membersList.length; i++) {
        String uid = membersList[i]['id'];
        groupProvider.addDatatoFirestore(FirestoreConstants.pathUserCollection, uid, FirestoreConstants.pathGroupsCollection, groupId, updateInfo.toJson())
            .then((data) async {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "Group Created Successfully");
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => const GroupChatScreen()),(Route<dynamic> route) => false,);
        }).catchError((err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: err.toString());
        });
      }

    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 20),
                                child: const Icon(Icons.arrow_back),
                              ),
                              _myTextWidget("Network", 0xFFD22630, FontWeight.w700,
                                  16, 0, 30, 0),
                              Expanded(child: Container()),
                              Container(
                                margin: const EdgeInsets.only(left: 20),
                                child: const Icon(FeatherIcons.x),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      rowItemOfTextFields(context, "Network Title",network),
                      GroupRatioRow(context),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _myTextWidget(
                            "MEMBERS", 0xff7B4425, FontWeight.w700, 16, 10, 20, 0),
                      ),
                      gotData == false? GestureDetector(
                        onTap: (){
                          if(network.text.isEmpty){
                            Fluttertoast.showToast(msg: "Please add network name..!");
                          }
                          else if(pickedFile == null){
                            Fluttertoast.showToast(msg: "Provide image for network");
                          }
                          else{
                            gotoSearch(context);

                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                          decoration: BoxDecoration(
                            color: ColorsX.white,
                            borderRadius: const BorderRadius.all( Radius.circular(20)),
                            border: Border.all(color: ColorsX.brownTextColor),
                          ),
                          child: IgnorePointer(
                            child: TextField(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 5),
                                border: InputBorder.none,
                                hintText: "Add new Member",
                              ),
                              onChanged: (text) {
                                valuee2 = text;
                              },
                            ),
                          ),
                        ),
                      ) :
                      membersList.isEmpty?GestureDetector(
                        onTap: (){
                          if(network.text.isEmpty){
                            Fluttertoast.showToast(msg: "Please add network name..!");
                          }
                          else if(pickedFile == null){
                            Fluttertoast.showToast(msg: "Provide image for network");
                          }
                          else{
                            gotoSearch(context);

                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                          decoration: BoxDecoration(
                            color: ColorsX.white,
                            borderRadius: const BorderRadius.all( Radius.circular(20)),
                            border: Border.all(color: ColorsX.brownTextColor),
                          ),
                          child: IgnorePointer(
                            child: TextField(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 5),
                                border: InputBorder.none,
                                hintText: "Add new Member",
                              ),
                              onChanged: (text) {
                                valuee2 = text;
                              },
                            ),
                          ),
                        ),
                      ):
                      SizedBox(
                        height: 180,
                        child: ListView.builder(itemBuilder: (context, index) {
                          return  Container(
                            margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
                            decoration: BoxDecoration(
                              color: ColorsX.white,
                              borderRadius: const BorderRadius.all( Radius.circular(20)),
                              border: Border.all(color: ColorsX.brownTextColor),
                            ),
                            child: ListTile(
                              leading: Material(
                                borderRadius: const BorderRadius.all(const Radius.circular(25)),
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
                              title: Text( membersList[index]['username'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                              trailing: GestureDetector(
                                  onTap: () => onRemoveMembers(index),
                                  child: const Icon(FeatherIcons.x)),
                            ),
                          );
                        },
                          itemCount: membersList.length,),
                      ),
                           Center(
                    child: Container(
                      height: 150,
                      margin: const EdgeInsets.only(top: 5),
                      child: Image.asset("assets/images/drawing2.png"),
                    ),
                  ),
                  _myTextWidget(
                    "Create a network, upload its picture, and add people related to this network. "
                        "You can hide this network from other users, or make it public.",
                    0xff7B4425,
                    FontWeight.w400,
                    18,
                    20,
                    15,
                    15,
                  ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              openDialog();
                            },
                            child: _myTextWidget("SKIP PROCESS", 0xffD22630,
                                FontWeight.w400, 14, 0, 10, 10),
                          ),
                          const SizedBox(
                            width: 60,
                          ),
                          GestureDetector(
                            onTap: () {
                              if(network.text.isEmpty){
                                Fluttertoast.showToast(msg: "Please add network name..!");
                              }
                              else if(pickedFile == null){
                                Fluttertoast.showToast(msg: "Provide image for network");
                              }
                              else if(gotData == false){
                                Fluttertoast.showToast(msg: "Please Add Members!!");
                              }
                              else{

                                if(membersList.toString() == "[]"){
                                  Fluttertoast.showToast(msg: "Please Add Members!!");
                                }
                                else{
                                  setState(() {
                                    isLoading = true;
                                  });
                                   uploadFile();
                                }

                              }
                            },
                            child: Container(
                              width: 100,
                              decoration: const BoxDecoration(
                                color: ColorsX.appRedColor,
                                borderRadius:  BorderRadius.all( Radius.circular(5)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: _myTextWidget("READY", 0xffffffff,
                                      FontWeight.w400, 14, 0, 10, 10),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(child: isLoading == true ? LoadingView() : const SizedBox.shrink()),
            ],
          )
        ),
      ),
    );
  }

  void gotoSearch(BuildContext context)async {
      await  Navigator.push(context, MaterialPageRoute(builder: (context) => Searchone(userid: widget.id,)),).then((value){
        setState(() {
          gotData = true;
          membersList = value;
        });
      });

  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<void> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                color: ColorsX.appRedColor,
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Image.asset("assets/images/logofriendlee.png"),
                      margin: const EdgeInsets.only(bottom: 10),
                    ),
                    const Text(
                      'Finish On Boarding',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Are you sure to skip these steps?',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: const Icon(
                        Icons.cancel,
                        color: ColorConstants.primaryColor,
                      ),
                      margin: const EdgeInsets.only(right: 10),
                    ),
                    const Text(
                      'Cancel',
                      style: TextStyle(color: ColorConstants.primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: const Icon(
                        Icons.check_circle,
                        color: ColorConstants.primaryColor,
                      ),
                      margin: const EdgeInsets.only(right: 10),
                    ),
                    const Text(
                      'Yes',
                      style: const TextStyle(color: ColorConstants.primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const GroupChatScreen()));
    }
  }


  // ignore: non_constant_identifier_names
  Widget GroupRatioRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        GestureDetector(
          onTap:(){
            setState(()
            {
              gType=false;
              gText = "Private";
            });
          },
          child: Container(
            width: 100,
            decoration:  BoxDecoration(
                color: gType == false?ColorsX.appRedColor:ColorsX.white,
                borderRadius: BorderRadius.all( Radius.circular(5)),
              border: Border.all(color: gType == false?ColorsX.white:ColorsX.greyText),
                ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FeatherIcons.lock,color:gType == false?ColorsX.white:ColorsX.appRedColor,size: 16,),
                  const SizedBox(width:5),
                   Text(
                    "Private",
                    style:  TextStyle(
                        color: gType == false?ColorsX.white:ColorsX.appRedColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        GestureDetector(
          onTap: () {
            setState(()
            {gType=true;
              gText = "Public";
            });
          },
          child: Container(
            width: 100,
            decoration:  BoxDecoration(
              color:gType == false?ColorsX.white:ColorsX.appRedColor,
               border: Border.all(color: gType == false?ColorsX.greyText:ColorsX.white),
              borderRadius:  const BorderRadius.all( const Radius.circular(5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: _myTextWidget(
                    "Public",  gType == false?0xFFD22630:0xFFFFFFFF, FontWeight.w400, 14, 0, 10, 10),
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget rowItemOfTextFields(
    BuildContext context,
    String hint,
      TextEditingController controller
  ) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CupertinoButton(
            onPressed: getImage,
            child: Container(

              child: avatarImageFile == null
                  ? groupphotoUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Image.network(
                  groupphotoUrl,
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, object, stackTrace) {
                    return const Icon(
                      Icons.account_circle,
                      size: 90,
                      color: ColorConstants.greyColor,
                    );
                  },
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
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              )
                  :const Icon(
                Icons.account_circle,
                size: 50,
                color: ColorConstants.greyColor,
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Image.file(
                  avatarImageFile!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * .01,
          ),
          Expanded(
            child: Container(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  border: const UnderlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.zero)),
                  hintText: hint,
                  labelText: hint,
                  labelStyle: const TextStyle(color: ColorsX.brownTextColor),
                ),
                onChanged: (text) {
                  valuee = text;
                },
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }

  Widget _myTextWidget(
    String text,
    int colorCode,
    FontWeight fontWeight,
    double fontsize,
    double top,
    double left,
    double right,
  ) {
    return Container(
      margin: EdgeInsets.only(top: top, left: left, right: right),
      child: Text(
        text,
        style: TextStyle(
            color: Color(
              colorCode,
            ),
            fontWeight: fontWeight,
            fontSize: fontsize),
      ),
    );
  }
}
