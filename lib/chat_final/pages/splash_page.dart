import 'package:chatapp/chat_final/constants/constants.dart';
import 'package:chatapp/group_chat/group_chat.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Login_Screen/SignIn/login_page.dart';
import '../../Topics/size_config.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      // just delay for showing this slash page clearer because it too fast
      checkSignedIn();
    });
  }

  void checkSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(FirestoreConstants.id);
    if(id.toString() =="null") {
      Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
    );
    }
    else if(id.toString() !="null"){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) =>const GroupChatScreen()),
            (Route<dynamic> route) => false,
      );
    }
    else{
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(

      body: SafeArea(
        child: Image.asset(
          "assets/images/SplashScreen.png",
          fit: BoxFit.fill,
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
