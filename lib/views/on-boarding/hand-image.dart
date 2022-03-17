
import 'package:chatapp/views/on-boarding/onboarding-profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Topics/size_config.dart';
import '../../chat_final/constants/color_constants.dart';
import '../../group_chat/group_chat.dart';
import '../../styles/app_color.dart';

class HandImage extends StatefulWidget {
  String email;
  String pass;
  String username;
  String id;
  HandImage({Key? key, required this.email,required this.id,required this.username,required this.pass}) : super(key: key);

  @override
  State<HandImage> createState() => _HandImageState();
}

class _HandImageState extends State<HandImage> {



  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);

    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.all(10),
            height: SizeConfig.screenHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: _myTextWidget("Welcome to", 0xff7B4425, FontWeight.bold,
                      28, SizeConfig.screenHeight * .05, 0, 0),
                ),
                Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          top: SizeConfig.screenHeight * .02,
                          left: SizeConfig.screenWidth * .75),
                      child: Image.asset("assets/images/small_flower.png"),
                    ),
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: SizeConfig.screenHeight * .03),
                        child: Image.asset("assets/images/red_logo.png"),
                      ),
                    ),
                  ],
                ),
                _myTextWidget(
                  "Make the important steps to start ",
                  0xff7B4425,
                  FontWeight.w400,
                  18,
                  20,
                  SizeConfig.screenWidth * .15,
                  SizeConfig.screenWidth * .15,
                ),
                _myTextWidget(
                  "communicating people with ",
                  0xff7B4425,
                  FontWeight.w400,
                  18,
                  0,
                  SizeConfig.screenWidth * .15,
                  SizeConfig.screenWidth * .15,
                ),
                _myTextWidget(
                  "common interests",
                  0xff7B4425,
                  FontWeight.w400,
                  18,
                  0,
                  SizeConfig.screenWidth * .15,
                  SizeConfig.screenWidth * .15,
                ),
                Center(
                  child: Container(
                    height: SizeConfig.screenHeight * .35,
                    margin: EdgeInsets.only(top: 5),
                    child: Image.asset("assets/images/hand.png"),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool("noProfile", true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OnBoardingProfile(id:widget.id,email:widget.email,pass:widget.pass,username:widget.username)),
                    );
                  },
                  child: Container(
                    width: 100,
                    decoration:const BoxDecoration(
                      color: ColorsX.appRedColor,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: _myTextWidget(
                            "Next", 0xffffffff, FontWeight.w400, 14, 0, 10, 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
      //margin: EdgeInsets.only(top: top, left: left, right: right),
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
