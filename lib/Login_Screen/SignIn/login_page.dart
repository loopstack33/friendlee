import 'package:chatapp/Login_Screen/Forget/forget_screen.dart';
import 'package:chatapp/chat_final/providers/providers.dart';
import 'package:chatapp/group_chat/group_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Login_Screen/signup/sign_up.dart';
import '../../Topics/size_config.dart';
import '../../chat_final/constants/firestore_constants.dart';
import '../../chat_final/widgets/loading_view.dart';
import '../../styles/app_color.dart';
import '../../utils/common-functions.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  bool isShow = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController? emailController = TextEditingController();
  TextEditingController? userNameController = TextEditingController();
  TextEditingController? passwordController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign in fail");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign in canceled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign in success");
        break;
      default:
        break;
    }
    return Scaffold(
      key: formKey,
      backgroundColor: Colors.white,
      body:SingleChildScrollView(
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
                  "Sign In",
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
            Container(
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Label("EMAIL"),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.01,
                    ),
                    Input("Email", emailController!),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),
                    Label("PASSWORD"),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.01,
                    ),
                    Input("Password", passwordController!),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Forget()),
                        );
                      },
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Forget Password",
                          style: TextStyle(
                            color: ColorsX.red,
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.07,
                    ),
                    isLoading == true?Center(child: CircularProgressIndicator(color: ColorsX.appRedColor,),) :
                    Container(
                      width: SizeConfig.screenWidth * 0.98,
                      height: SizeConfig.screenWidth * 0.14,
                      padding: EdgeInsets.only(
                          left: SizeConfig.screenHeight * 0.05,
                          right: SizeConfig.screenWidth * 0.05),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: FlatButton(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 16.0),
                          color: ColorsX.appRedColor,
                          onPressed: () {
                            checkFieldsAndSendData(context);
                          },
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 20,
                              color: ColorsX.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.06,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 87,
                          height: 1,
                          color: Color(0xFFEE7C83),
                        ),
                        const Text(
                          "OR SIGN IN WITH",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF7B4425)),
                        ),
                        Container(
                          width: 87,
                          height: 1,
                          color: Color(0xFFEE7C83),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),
                    SizedBox(

                      height: 60,
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: GestureDetector(
                                onTap: () async {
                              /*    bool isSuccess = await authProvider.handleSignIn();
                                  if (isSuccess) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(),
                                      ),
                                    );
                                  }*/
                                },
                                child: Image.asset("assets/images/googleauth.png",width: 50,height: 50,)),
                          ),
                          // Loading
                          Positioned(
                            child: authProvider.status == Status.authenticating ? LoadingView() : SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            )
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
              'Already have an account? ',
              style: TextStyle(
                fontSize: 17,
                color: ColorsX.greyText,
                fontWeight: FontWeight.w300,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(),
                  ),
                );
              },
              child: const Text(
                'Sign Up',
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

  //SignIn
   signIn(BuildContext context, String email, String password) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
    final auth = FirebaseAuth.instance;
      Functions.showProgressLoader("Please wait");
     setState(() {
         isLoading = true;
     });
    try {

      //Functions.hideProgressLoader();
    UserCredential userCredential=  await auth
          .signInWithEmailAndPassword(email: email, password: password);
    userCredential.user!.updateDisplayName(email).then((uid) => {


    Functions.hideProgressLoader(),
    setState(() {
    isLoading = false;
    prefs.setString(FirestoreConstants.id, auth.currentUser!.uid.toString());

    }),

      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
      builder: (context) => GroupChatScreen(),
      ),
      ),

      });
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          Functions.showErrorToast(
              context, "Error", "Your email address is invalid");
          Functions.hideProgressLoader();
             setState(() {
                 isLoading = false;
                        });

          break;
        case "wrong-password":
          Functions.showErrorToast(context, "Error", "Your password is wrong.");
          Functions.hideProgressLoader();
          setState(() {
            isLoading = false;
          });
          break;
        case "user-not-found":
          Functions.showErrorToast(
              context, "Error", "User with this email doesn't exist.");
          Functions.hideProgressLoader();
          setState(() {
            isLoading = false;
          });
          break;
        case "user-disabled":
          Functions.showErrorToast(
              context, "Error", "User with this email has been disabled.");
          Functions.hideProgressLoader();
          setState(() {
            isLoading = false;
          });
          break;
        case "too-many-requests":
          Functions.showErrorToast(context, "Error", "Too many requests");
          Functions.hideProgressLoader();
          setState(() {
            isLoading = false;
          });
          break;
        case "operation-not-allowed":
          Functions.showErrorToast(context, "Error",
              "Signing in with Email and Password is not enabled.");
          Functions.hideProgressLoader();
          setState(() {
            isLoading = false;
          });
          break;
        default:
          Functions.showErrorToast(
              context, "Error", "An undefined Error happened");
          Functions.hideProgressLoader();
          setState(() {
            isLoading = false;
          });
      }
    }
  }

  checkFieldsAndSendData(BuildContext context) async {
    // String username = "${userNameController?.text}";
    String email = "${emailController?.text}";
    String password = "${passwordController?.text}";
    if (email.isEmpty) {
      Functions.showErrorToast(context, "Required", "Email is required");
    }
    else if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email) == false){
      Functions.showErrorToast(context, "Error", "Enter a valid email!");
    }
    else if (password.isEmpty) {
      Functions.showErrorToast(context, "Required", "Password is required");
    }
    else if (password.length < 6) {
        Functions.showErrorToast(context, "Error", "Password should be at least six digits.");

    }
    else {
      Functions.hideKeyboard(context);
      signIn(context, email, password);
      }
    }
  }

  Widget Label(String Data) {
    return Padding(
      padding: EdgeInsets.only(left: SizeConfig.screenWidth * 0.11),
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
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
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
