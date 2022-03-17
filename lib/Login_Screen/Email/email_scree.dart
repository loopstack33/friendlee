import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/styles/app_color.dart';
import '/utils/size_config.dart';

class CheckMail extends StatelessWidget {
  static const routename = "/Checcking";
  const CheckMail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.screenHeight * 0.05,
                left: 0,
              ),
              child: const Text(
                "Check your mail",
                style: TextStyle(
                    fontSize: 20.0,
                    color: Color(0xFF7B4425),
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
          SizedBox(
            height: SizeConfig.screenHeight * 0.02,
          ),
          Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: Image.asset(
                "assets/images/logo.png",
                alignment: Alignment.center,
              ),
            ),
          ),
          SizedBox(
            height: SizeConfig.screenHeight * 0.07,
          ),
          const Center(
            child: Text(
              "Check your mail",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7B4425),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: SizeConfig.screenHeight * 0.07,
          ),
          const Center(
            child: Text(
              "We have sent a password recovery\n    instruction to your mail",
              style: TextStyle(
                letterSpacing: 0.5,
                fontSize: 16,
                color: Color(0xFF7B4425),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
