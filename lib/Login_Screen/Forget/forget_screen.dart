
import 'package:flutter/material.dart';
import '../../styles/app_color.dart';
import '../Email/email_scree.dart';
import '/utils/size_config.dart';

class Forget extends StatefulWidget {
  static const route = "/forget";
  const Forget({Key? key}) : super(key: key);

  @override
  _ForgetState createState() => _ForgetState();
}

class _ForgetState extends State<Forget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: SizeConfig.screenHeight * 0.05,
                  left: 0,
                ),
                child: const Text(
                  "Forget Your password",
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
                "Enter your register email  bellow  to \n receive password reset instruction",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7B4425),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(
              height: SizeConfig.screenHeight * 0.07,
            ),
            Input(),
            SizedBox(
              height: SizeConfig.screenHeight * 0.10,
            ),
            Container(
              width: SizeConfig.screenWidth * 0.98,
              height: SizeConfig.screenWidth * 0.16,
              padding: EdgeInsets.only(
                  left: SizeConfig.screenHeight * 0.05,
                  right: SizeConfig.screenWidth * 0.05),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: FlatButton(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 16.0),
                  color: ColorsX.appRedColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CheckMail()),
                    );
                  },
                  child: const Text(
                    "Send",
                    style: TextStyle(
                      fontSize: 20,
                      color: ColorsX.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Back to',
              style: TextStyle(
                fontSize: 17,
                color: ColorsX.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Sign in',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFD22630),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget Input() {
  return Padding(
    padding: EdgeInsets.only(
        left: SizeConfig.screenHeight * 0.05,
        right: SizeConfig.screenWidth * 0.05),
    child: TextFormField(
      decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
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
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              width: 1,
              color: Colors.red,
            ),
          ),
          hintText: "Johndoe@gmail.com"),
    ),
  );
}
