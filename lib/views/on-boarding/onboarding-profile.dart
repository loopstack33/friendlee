import 'dart:io';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../chat_final/constants/color_constants.dart';
import '../../chat_final/constants/firestore_constants.dart';
import '../../chat_final/models/user_chat2.dart';
import '../../chat_final/providers/setting_provider.dart';
import '../../chat_final/widgets/loading_view.dart';

import '../../styles/app_color.dart';
import '../../utils/common-functions.dart';
import 'package:image_picker/image_picker.dart';

import 'onboarding-netwok.dart';

class OnBoardingProfile extends StatefulWidget {
  String email;
  String pass;
  String username;
  String id;
  OnBoardingProfile({Key? key, required this.email,required this.id,required this.username,required this.pass}) : super(key: key);

  @override
  State<OnBoardingProfile> createState() => _OnBoardingProfileState();
}

class _OnBoardingProfileState extends State<OnBoardingProfile> {
  String valuee = "";

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fnameController = TextEditingController();

  TextEditingController lnameController = TextEditingController();

  bool isLoading = false;

  File? avatarImageFile;
  String photoUrl = '';
  String fname = '';
  String lname = '';

  late SettingProvider settingProvider;


  @override
  void initState() {
    super.initState();
    settingProvider = context.read<SettingProvider>();

  }


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

  Future uploadFile(fname,lname) async {
    String fileName = widget.id;
    UploadTask uploadTask = settingProvider.uploadFile(avatarImageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      UserChat2 updateInfo = UserChat2(
          id: widget.id,
          photoUrl: photoUrl,
          firstname: fname,
          lastname: lname,
      );
      settingProvider
          .updateDataFirestore(FirestoreConstants.pathUserCollection, widget.id, updateInfo.toJson())
          .then((data) async {

        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Upload success");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OnBoardingNetwork(id:widget.id,email:widget.email,pass:widget.pass,username:widget.username)),
        );
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          child: Container(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 20),
                                  child: const Icon(Icons.arrow_back),
                                ),
                                _myTextWidget("Profile", 0xFFD22630, FontWeight.w700,
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
                      ),

                      CupertinoButton(
                        onPressed: getImage,
                        child: Container(

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
                                return const Icon(
                                  Icons.account_circle,
                                  size: 90,
                                  color: ColorConstants.greyColor,
                                );
                              },
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
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
                              : Image.asset("assets/images/camera.png")
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
                      rowItemOfTextFields(context, "First Name", "Isebelle",fnameController),
                      const SizedBox(
                        height: 10,
                      ),
                      rowItemOfTextFields(context, "Last Name", "Modric",lnameController),
                      Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * .20,
                          margin: const EdgeInsets.only(top: 5),
                          child: Image.asset("assets/images/drawing_one.png"),
                        ),
                      ),
                      _myTextWidget(
                        "Enter a display name and upload a profile picture that will help people to find you."
                            "Your display name and picture are visible to other users.",
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
                      fname.isEmpty && fname.isEmpty && pickedFile == null? SizedBox() :  GestureDetector(
                        onTap: () {
                          checkFieldsAndSendData(context);

                        },
                        child: Container(
                          width: 100,
                          decoration: const BoxDecoration(
                            color: ColorsX.appRedColor,
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: _myTextWidget("NEXT", 0xffffffff,
                                  FontWeight.w400, 14, 0, 10, 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(child: isLoading == true ? LoadingView() : SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }




  Widget rowItemOfTextFields(
      BuildContext context,
      String text1,
      String hint,
      TextEditingController controller
      ) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _myTextWidget(text1, 0xff7B4425, FontWeight.w700, 14, 0, 20, 0),
          Container(
            width:MediaQuery.of(context).size.width * .10,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ColorsX.white,
                borderRadius: const BorderRadius.all(const Radius.circular(20)),
                border: Border.all(color: ColorsX.brownTextColor),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(

                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  border: InputBorder.none,
                  hintText: hint,
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

  checkFieldsAndSendData(BuildContext context) async {
    String fname = fnameController.text;
    String lname = lnameController.text;
    if (fname.isEmpty) {
      Functions.showErrorToast(context, "Required", "First Name is required");
    } else if (lname.isEmpty) {
      Functions.showErrorToast(context, "Required", "Last Name is required");

    }
    else if (pickedFile == null) {
      Functions.showErrorToast(context, "Required", "Please select profile picture");

    }
    else {
      setState(() {
        isLoading = true;
      });
      uploadFile(fname,lname);

    }
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
