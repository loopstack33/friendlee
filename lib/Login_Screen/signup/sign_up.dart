import 'package:chatapp/views/on-boarding/hand-image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../chat_final/constants/firestore_constants.dart';
import '../../styles/app_color.dart';
import '../../utils/common-functions.dart';
import '../SignIn/login_page.dart';
import '/utils/size_config.dart';

class SignUpScreen extends StatefulWidget {
  static String routename = '/SignUpScreen';

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  bool isLoading = false;
  bool isShow = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);


    return Scaffold(
      key: formKey,
      backgroundColor: Colors.white,
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
                  "Sign up",
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
                  "assets/images/baselogo.png",
                  alignment: Alignment.center,
                ),
              ),
            ),
            Container(
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Label("USERNAME"),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.01,
                    ),
                    Input("Username", userNameController),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),
                    Label("EMAIL"),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.01,
                    ),
                    Input("Email", emailController),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),
                    Label("PASSWORD"),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.01,
                    ),
                    Input("Password", passwordController),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.03,
                    ),
                    Container(
                      width: SizeConfig.screenWidth * 0.98,
                      height: SizeConfig.screenWidth * 0.16,
                      padding: EdgeInsets.only(
                          left: SizeConfig.screenHeight * 0.05,
                          right: SizeConfig.screenWidth * 0.05),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: isLoading == true
                            ? Center(
                          child: CircularProgressIndicator(color: ColorsX.appRedColor,),
                        )
                            : FlatButton(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 16.0),
                          color: ColorsX.appRedColor,
                          onPressed: () {
                            checkFieldsAndSendData(context);
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 20,
                              color: ColorsX.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'By Signing up, I agree with',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: ColorsX.greyText,
                            ),
                          ),
                          Text(
                            'Term and Conditions',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xFFD22630),
                                fontWeight: FontWeight.w400,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.01,
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
                          "OR SIGN UP WITH",
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
                      height: SizeConfig.screenHeight * 0.01,
                    ),
                    Center(
                      child: Image.asset(
                          "assets/images/googleauth.png", width: 50,
                          height: 50,),
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
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: const Text(
                'Sign In',
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

  Widget Input(String hint, TextEditingController ctl) {
    return Padding(
      padding: EdgeInsets.only(
          left: SizeConfig.screenHeight * 0.05,
          right: SizeConfig.screenWidth * 0.05),
      child: TextFormField(
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
        controller: ctl,
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
 

  checkFieldsAndSendData(BuildContext context) async {
    String username = userNameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    if (username.isEmpty) {
      Functions.showErrorToast(context, "Required", "Username is required");
      if(mounted) {
        setState(() {
        isLoading = false;
      });
      }
    } else if (email.isEmpty) {
      Functions.showErrorToast(context, "Required", "Email is required");
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    else if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email) == false){
      Functions.showErrorToast(context, "Error", "Enter a valid email!");
    }
    else if (password.isEmpty) {
      Functions.showErrorToast(context, "Required", "Password is required");
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    else if (password.length < 6) {

      if(mounted) {
        setState(() {
          isLoading = false;
        });
        Functions.showErrorToast(context, "Error", "Password should be at least six digits.");
      }
    }

    else {
      signUp(context, email, password, username);
    }
  }

// this function checks if uniqueName already exists
  Future<bool> isDuplicateUniqueName(BuildContext context,
      String emailAddress) async {
    Functions.hideKeyboard(context);
    Functions.showProgressLoader("Please wait");
    setState(() {
      isLoading = true;
    });
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .where('email', isEqualTo: emailAddress)
        .get();
    Functions.hideProgressLoader();
    setState(() {
      isLoading = false;
    });
    return query.docs.isNotEmpty;
  }


  // SignUp-----------------------------------------
  signUp(BuildContext context,
      String emailAddress,
      String password,
      String username,) async {
    final _auth = FirebaseAuth.instance;
    Functions.hideKeyboard(context);
    if(mounted) {
      setState(() {
        isLoading = true;
      });
    }
    Functions.showProgressLoader("Please wait");
    try {
      UserCredential userCredential =    await _auth.createUserWithEmailAndPassword(email: emailAddress, password: password);
      userCredential.user!.updateDisplayName(emailAddress).then((value) =>
      {

        postDetailsToFirestore(context, emailAddress, password,
            username),

      })
          .catchError((e) {
        Functions.showErrorToast(context, "Error", e!.message,);
        Functions.hideProgressLoader();
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
    catch(signUpError) {
      if(signUpError is PlatformException) {
        if(signUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          Functions.hideProgressLoader();
          setState(() {
            isLoading = false;
          });

        }
      }
    }
  }

   postDetailsToFirestore(BuildContext context, emailAddress, password,
      username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _auth = FirebaseAuth.instance;
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    if (user != null) {

      await firebaseFirestore.collection(FirestoreConstants.pathUserCollection).doc(user.uid).set({
        'id': user.uid,
        'email': emailAddress,
        'password': password,
        'username': username,
        'payment':false,
      });
      prefs.setString(FirestoreConstants.id, user.uid.toString());

      Functions.hideProgressLoader();

      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
      Functions.showToast("Success Account created successfully");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HandImage(id:user.uid,email:emailAddress,pass:password,username:username)),
      );
    }



  }
}