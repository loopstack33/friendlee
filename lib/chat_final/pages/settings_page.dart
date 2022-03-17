import 'dart:async';
import 'dart:io';
import 'package:chatapp/chat_final/constants/app_constants.dart';
import 'package:chatapp/chat_final/constants/firestore_constants.dart';
import 'package:chatapp/chat_final/models/models.dart';
import 'package:chatapp/chat_final/providers/providers.dart';
import 'package:chatapp/chat_final/widgets/loading_view.dart';
import 'package:chatapp/styles/app_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Login_Screen/SignIn/login_page.dart';
import '../../Topics/size_config.dart';
import '../constants/color_constants.dart';
import '../models/user_chat2.dart';

class SettingsPage extends StatefulWidget {
  bool floating;

   SettingsPage({Key? key,required this.floating}) : super(key: key);
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> handleSignOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(FirestoreConstants.id, "null");
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
    Fluttertoast.showToast(msg: "Logged Out Successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsX.white,
        elevation: 10,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
              },
            child: Icon(FeatherIcons.arrowLeft,color:ColorConstants.greyColor)),
        title: Text(
          AppConstants.myProfile,
          style: TextStyle(color: ColorsX.appRedColor),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: (){
              handleSignOut();
            },
            child: Icon(Icons.exit_to_app,color: ColorsX.borderGrey,),),
          SizedBox(width: 10,)
        ],
      ),
      body: SettingsPageState(floating:widget.floating),
    );
  }
}


class SettingsPageState extends StatefulWidget {
  bool floating;
  SettingsPageState({Key? key,required this.floating}) : super(key: key);
  @override
  State createState() => SettingsPageStateState();
}

class SettingsPageStateState extends State<SettingsPageState> {
  TextEditingController  controllerNickname =TextEditingController();
  TextEditingController controllerLastname =TextEditingController();
  TextEditingController controllerFirstname =TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String id = '';
  String username = '';
  String photoUrl = '';

  String fname = '';
  String lname = '';
  String phone ='';

  bool isLoading = false;
  File? avatarImageFile;
  late SettingProvider settingProvider;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();

  @override
  void initState() {
    super.initState();
    settingProvider = context.read<SettingProvider>();
    if( widget.floating == false){
     getData();
   }
   else{

   }

  }
  getData() async{
    String uid = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      setState(() {
        id =value.data()!["id"];
        photoUrl = value.data()!["photoUrl"];
        fname = value.data()!["firstName"];
        lname = value.data()!["lastName"];
        username = value.data()!["username"];
        isLoading = false;
      });
      controllerNickname = TextEditingController(text: username);
      controllerFirstname = TextEditingController(text: fname);
      controllerLastname = TextEditingController(text: lname);
    });
  }

  CollectionReference usersCollection = FirebaseFirestore.instance.collection(FirestoreConstants.pathUserCollection);

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile = await imagePicker.getImage(source: ImageSource.gallery).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = _auth.currentUser!.uid;
    UploadTask uploadTask = settingProvider.uploadFile(avatarImageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      UserChat2 updateInfo = UserChat2(
        id: _auth.currentUser!.uid,
        photoUrl: photoUrl,
        lastname: controllerLastname.text,
        firstname: controllerFirstname.text,
      );
      settingProvider
          .updateDataFirestore(FirestoreConstants.pathUserCollection,_auth.currentUser!.uid, updateInfo.toJson())
          .then((data) async {
        if(widget.floating == false){
          await settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "Profile Update Success");
        }
        else{
          await settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
          setState(() {
            isLoading = false;
          });
          handleSignOut();
        }


      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  Future<void> handleSignOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(FirestoreConstants.id, "null");
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
    Fluttertoast.showToast(msg: "Login Again");
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });
    UserChat2 updateInfo = UserChat2(
      id: id,
      photoUrl: photoUrl,
      lastname: controllerLastname.text,
      firstname: controllerFirstname.text,
    );
    settingProvider
        .updateDataFirestore(FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
        .then((data) async {

      if(widget.floating == false){
        setState(() {
          isLoading = false;
        });

        Fluttertoast.showToast(msg: "Saved");
      }
      else{
        setState(() {
          isLoading = false;
        });
        handleSignOut();
      }
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return  Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.floating == false?SizedBox():Padding(
                padding: const EdgeInsets.only(top:10.0),
                child: Text("Please update profile first"),
              ),
              CupertinoButton(
                onPressed: getImage,
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: avatarImageFile == null
                      ? photoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                                errorBuilder: (context, object, stackTrace) {
                                  return Icon(
                                    Icons.account_circle,
                                    size: 90,
                                    color: ColorConstants.greyColor,
                                  );
                                },
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 90,
                                    height: 90,
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
                          : Icon(
                              Icons.account_circle,
                              size: 90,
                              color: ColorConstants.greyColor,
                            )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(45),
                          child: Image.file(
                            avatarImageFile!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Text(
                      username,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF7B4425),
                        fontWeight: FontWeight.w700,
                      ),
                    )),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),
                    Label("FIRST NAME:"),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),
                    Input("FIRST NAME", controllerFirstname),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),
                    Label("LAST NAME:"),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),
                    Input("LAST NAME", controllerLastname),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),


                  ],
                ),
              ),
              // Button
              Container(
                child: TextButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    'Update',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(ColorConstants.primaryColor),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.fromLTRB(30, 10, 30, 10),
                    ),
                  ),
                ),
                margin: EdgeInsets.only(top: 50, bottom: 50),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15, right: 15),
        ),

        // Loading
        Positioned(child: isLoading ? LoadingView() : SizedBox.shrink()),
      ],
    );
  }


  Widget Label(String Data) {
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.screenWidth * 0.1),
      child: Text(
        Data,
        style: const TextStyle(
          fontSize: 16.0,
          color: Color(0xFF7B4425),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget Input(String hint, TextEditingController ctl) {
    return Padding(
      padding: EdgeInsets.only(
          left: SizeConfig.screenHeight * 0.05,
          right: SizeConfig.screenWidth * 0.05),
      child: TextFormField(
        controller: ctl,

        decoration: InputDecoration(
          contentPadding:
          EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Colors.red,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(
              width: 1,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );

  }
}
