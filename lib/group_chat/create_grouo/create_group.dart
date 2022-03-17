
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../chat_final/constants/color_constants.dart';
import '../../chat_final/constants/firestore_constants.dart';
import '../../chat_final/models/group_model.dart';
import '../../chat_final/providers/group_provider.dart';
import '../../chat_final/widgets/loading_view.dart';
import '../../styles/app_color.dart';
import '../group_chat.dart';

class CreateGroup extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;

  const CreateGroup({required this.membersList, Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  late GroupProvider groupProvider;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    groupProvider = context.read<GroupProvider>();

  }

  final TextEditingController _groupName = TextEditingController();

  TextEditingController network = TextEditingController();
  bool isLoading = false;
  File? avatarImageFile;

  String groupphotoUrl = '';

  String groupPhotoUrl='';
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;

  File? imageFile;
  bool gType = false;
  var gText = "Private";

  String groupId = Uuid().v1();

  Future uploadFile() async {

    String fileName = groupId;
    UploadTask uploadTask = groupProvider.uploadFile(avatarImageFile!, fileName);
    try {

      await _firestore.collection('groups').doc(groupId).set({
        "members": widget.membersList,
        "id": groupId,
      });

      TaskSnapshot snapshot = await uploadTask;
      groupPhotoUrl = await snapshot.ref.getDownloadURL();

      GroupModel updateInfo = GroupModel(
        id:groupId,
        photoUrl: groupPhotoUrl,
        name:network.text,
       type:gText.toString()
      );

      for (int i = 0; i < widget.membersList.length; i++) {
        String uid = widget.membersList[i]['id'];
        groupProvider.addDatatoFirestore(FirestoreConstants.pathUserCollection, uid,FirestoreConstants.pathGroupsCollection,groupId,updateInfo.toJson())
            .then((data) async {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "Group Created Successfully");
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => GroupChatScreen()), (route) => false);

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
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsX.appRedColor,
        title: Text("Network"),
      ),
      body: SafeArea(
        child:  Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    rowItemOfTextFields(context, "Network Title",network),
                    GroupRatioRow(context),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _myTextWidget(
                          "MEMBERS", 0xff7B4425, FontWeight.w700, 16, 10, 20, 0),
                    ),
                    SizedBox(
                      height: 350,
                      child: ListView.builder(itemBuilder: (context, index) {
                        return  ListTile(
                          leading: Material(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              widget.membersList[index]['photoUrl'],
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
                          title: Text( widget.membersList[index]['username'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          subtitle: Text( widget.membersList[index]['email'],style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300),),
                          trailing: Text(widget.membersList[index]['isAdmin'].toString() =="true"?"Group Admin":"User",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: ColorsX.appRedColor),),
                        );
                      },
                        itemCount: widget.membersList.length,),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: ColorsX.appRedColor,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300)),
                      onPressed: (){
                        if(network.text.isEmpty){
                          Fluttertoast.showToast(msg: "Please add network name..!");
                        }
                        else if(pickedFile == null){
                          Fluttertoast.showToast(msg: "Provide image for network");
                        }
                        else{
                          setState(() {
                            isLoading = true;
                          });
                          uploadFile();
                        }
                      },
                      child: Text("Create Group"),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(child: isLoading == true ? LoadingView() : const SizedBox.shrink()),
          ],
        )
      )

    );
  }
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