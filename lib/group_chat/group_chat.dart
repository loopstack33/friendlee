import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:chatapp/chat_final/constants/color_constants.dart';
import 'package:chatapp/chat_final/constants/firestore_constants.dart';
import 'package:chatapp/chat_final/pages/pages.dart';
import 'package:chatapp/styles/app_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Login_Screen/SignIn/login_page.dart';
import '../Topics/size_config.dart';
import '../service/stripe.dart';
import '../utils/AppStrings.dart';
import '../utils/common-functions.dart';
import 'create_grouo/add_Member_g.dart';
import 'group_chat_room.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({Key? key}) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List groupList = [];
  List privateGroupList = [];
  List publicGroupList = [];
  StripePayment _stripePayment = StripePayment();

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
                color: ColorConstants.themeColor,
                padding: EdgeInsets.only(bottom: 10, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
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
                      child: Icon(
                        Icons.cancel,
                        color: ColorConstants.primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
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
                      child: Icon(
                        Icons.check_circle,
                        color: ColorConstants.primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      'Yes',
                      style: TextStyle(color: ColorConstants.primaryColor, fontWeight: FontWeight.bold),
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
        exit(0);
    }
  }

  Future<void> handleSignOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
   // preferences.clear();
    preferences.setString(FirestoreConstants.id, "null");
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
    Fluttertoast.showToast(msg: "Logged Out Successfully");
  }

 // StripePayment _stripePayment = StripePayment();

  @override
  void initState() {
    super.initState();
    getData2();
      getAvailableGroups();
      getData();
      _stripePayment = StripePayment();

  }

  makePayment2() async{

    if(payment== false){
       await _stripePayment.makePayment(context,'10000',uid);
       setState(() {
         isload = false;
       });
    }
    else{

      setState(() {
        isload = false;
      });
    }

  }
  String uid='';

  bool payment = false;
  getData2() async{
     uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      setState(() {
        payment = value.data()!["payment"];


      });
    });
  }

  int step = 0;
  String firstName= '';
  String photo = '';
  getData() async{
    String uid = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      setState(() {
        photo = value.data()!["photoUrl"];
        firstName = value.data()!["firstName"];
        isLoading = false;
      });
    });
  }
  int index = 0;

  List ids=[];
  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;
     await _firestore
         .collection('users')
         .doc(uid)
         .collection('groups')
         .get()
         .then((value) {
       setState(() {
         groupList = value.docs;
         isLoading = false;
       });
     });
    for (int index = 0; index < groupList.length; index++) {
      setState(() {
        ids.add(groupList[index]["id"]);
      });
    }
  }
  bool isload =false;
  bool floating = false;

  @override
  void dispose() {
    ids.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return payment == true?
    Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        toolbarHeight: 80,
        flexibleSpace: SafeArea(
          child: Container(
           // elevation: 5,
           decoration: BoxDecoration(

           ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){
                    if(firstName.toString() == ""){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SettingsPage(
                              floating:true,

                          ),
                        ),
                      );
                    }
                    else{
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SettingsPage(
                              floating:false,

                          ),
                        ),
                      );
                    }
                },


                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child:  Material(
                      child: photo.isNotEmpty
                          ? Image.network(
                        photo,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 30,
                            height: 30,
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
                            size: 40,
                            color: ColorConstants.greyColor,
                          );
                        },
                      )
                          :const Icon(
                        Icons.account_circle,
                        size: 40,
                        color: ColorConstants.greyColor,
                      ),
                      borderRadius:const BorderRadius.all(Radius.circular(25)),
                      clipBehavior: Clip.hardEdge,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/baselogo.png',
                  height: 60,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {

                      },
                      icon: const Icon(
                        Icons.search,
                        size: 35,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        handleSignOut();
                      },
                      child: Icon(Icons.exit_to_app),),
                    SizedBox(width: 10,)
                  ],
                )
              ],
            ),
          ),
        ),

      ),
      body: isLoading
          ? Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      )
          :ContainedTabBarView(
        tabBarViewProperties: const TabBarViewProperties(
          physics: BouncingScrollPhysics(),
        ),
        initialIndex: index,
        tabBarProperties: TabBarProperties(
          background: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD22630).withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          height: 35,
          width: 320,
          indicatorColor: ColorsX.appRedColor,
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorsX.appRedColor, width: 3), // Creates border
              color:ColorsX.appRedColor),
          indicatorWeight: 3.0,
          labelColor: ColorsX.white,
          unselectedLabelColor: ColorsX.white,
        ),
        tabs: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: _myTextWidget("All", 0xffffffff,
                  FontWeight.w400, 14, 0, 10, 10),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 15,
                  ),
                  Center(
                    child: _myTextWidget(
                        "Private",
                        0xffffffff,
                        FontWeight.w400,
                        14,
                        0,
                        10,
                        10),
                  ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: _myTextWidget("Public", 0xFFFFFFFF,
                  FontWeight.w400, 14, 0, 10, 10),
            ),
          ),
        ],
         views:[
           StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
             stream: FirebaseFirestore.instance
                 .collection(FirestoreConstants.pathUserCollection)
                 .doc(_auth.currentUser!.uid)
                 .collection('groups')
                 .snapshots(),
             builder: (BuildContext context, snapshot) {
               if (snapshot.data == null) {
                 return Center(child: CircularProgressIndicator(color: ColorsX.appRedColor));
               }

               else {
                 final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.data!.docs;

                 return docs.isNotEmpty?ListView.builder(
                   itemCount: docs.length,
                   itemBuilder: (context, index) {
                     return SafeArea(
                       child: Padding(
                         padding: const EdgeInsets.only(top:15.0),
                         child: ListTile(
                           onTap: () => Navigator.of(context).push(
                             MaterialPageRoute(
                               builder: (_) => GroupChatRoom(
                                 groupName: docs[index]['name'],
                                 groupChatId: docs[index]['id'],
                                 groupAvatar: docs[index]['photoUrl'],
                                 groupLength:docs.length,
                                 ids:ids,
                               ),
                             ),
                           ),
                           leading: Material(
                             child: docs[index]['photoUrl'].isNotEmpty
                                 ? Image.network(
                               docs[index]['photoUrl'],
                               fit: BoxFit.cover,
                               width: 60,
                               height: 60,
                               loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                 if (loadingProgress == null) return child;
                                 return Container(
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
                             )
                                 : Icon(
                               Icons.account_circle,
                               size: 50,
                               color: ColorConstants.greyColor,
                             ),
                             borderRadius: BorderRadius.all(Radius.circular(25)),
                             clipBehavior: Clip.hardEdge,
                           ),
                           title: Text(docs[index]['name'],style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                           subtitle: Text(docs[index]['name']+" Group"),
                           trailing: Text(DateTime.now().timeZoneName,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w300)),
                         ),
                       ),
                     );
                   },
                 ): const Center(child: Text("No groups created yet...",style:  TextStyle(fontSize: 18,fontWeight: FontWeight.w500)));;
               }
             },
           ),

           StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
             stream: FirebaseFirestore.instance
                 .collection(FirestoreConstants.pathUserCollection)
                 .doc(_auth.currentUser!.uid)
                 .collection('groups').where("type",isEqualTo: "Private")
                 .snapshots(),
             builder: (BuildContext context, snapshot) {
               if (snapshot.data == null) {
                 return Center(child: CircularProgressIndicator(color: ColorsX.appRedColor));
               }

               else {
                 final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.data!.docs;

                 return docs.isNotEmpty?ListView.builder(
                   itemCount: docs.length,
                   itemBuilder: (context, index) {
                     return SafeArea(
                       child: Padding(
                         padding: const EdgeInsets.only(top:15.0),
                         child: ListTile(
                           onTap: () => Navigator.of(context).push(
                             MaterialPageRoute(
                               builder: (_) => GroupChatRoom(
                                 groupName: docs[index]['name'],
                                 groupChatId: docs[index]['id'],
                                 groupAvatar: docs[index]['photoUrl'],
                                 groupLength:docs.length,
                                 ids:ids,
                               ),
                             ),
                           ),
                           leading: Material(
                             child: docs[index]['photoUrl'].isNotEmpty
                                 ? Image.network(
                               docs[index]['photoUrl'],
                               fit: BoxFit.cover,
                               width: 60,
                               height: 60,
                               loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                 if (loadingProgress == null) return child;
                                 return Container(
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
                             )
                                 : Icon(
                               Icons.account_circle,
                               size: 50,
                               color: ColorConstants.greyColor,
                             ),
                             borderRadius: BorderRadius.all(Radius.circular(25)),
                             clipBehavior: Clip.hardEdge,
                           ),
                           title: Text(docs[index]['name'],style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                           subtitle: Text(docs[index]['name']+" Group"),
                           trailing: Text(DateTime.now().timeZoneName,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w300)),
                         ),
                       ),
                     );
                   },
                 ): const Center(child: Text("No private groups created yet...",style:  TextStyle(fontSize: 18,fontWeight: FontWeight.w500)));;
               }
             },
           ),
           StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
             stream: FirebaseFirestore.instance
                 .collection(FirestoreConstants.pathUserCollection)
                 .doc(_auth.currentUser!.uid)
                 .collection('groups').where("type",isEqualTo: "Public")
                 .snapshots(),
             builder: (BuildContext context, snapshot) {
               if (snapshot.data == null) {
                 return Center(child: CircularProgressIndicator(color: ColorsX.appRedColor,));
               } else {
                 final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.data!.docs;

                 return docs.isNotEmpty? ListView.builder(
                   itemCount: docs.length,
                   itemBuilder: (context, index) {
                     return SafeArea(
                       child: Padding(
                         padding: const EdgeInsets.only(top:15.0),
                         child: ListTile(
                           onTap: () => Navigator.of(context).push(
                             MaterialPageRoute(
                               builder: (_) => GroupChatRoom(
                                 groupName: docs[index]['name'],
                                 groupChatId: docs[index]['id'],
                                 groupAvatar: docs[index]['photoUrl'],
                                 groupLength:docs.length,
                                 ids:ids,
                               ),
                             ),
                           ),
                           leading: Material(
                             child: docs[index]['photoUrl'].isNotEmpty
                                 ? Image.network(
                               docs[index]['photoUrl'],
                               fit: BoxFit.cover,
                               width: 60,
                               height: 60,
                               loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                 if (loadingProgress == null) return child;
                                 return Container(
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
                             )
                                 : Icon(
                               Icons.account_circle,
                               size: 50,
                               color: ColorConstants.greyColor,
                             ),
                             borderRadius: BorderRadius.all(Radius.circular(25)),
                             clipBehavior: Clip.hardEdge,
                           ),
                           title: Text(docs[index]['name'],style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                           subtitle: Text(docs[index]['name']+" Group"),
                           trailing: Text(DateTime.now().timeZoneName,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w300)),
                         ),
                       ),
                     );
                   },
                 ):const Center(child: Text("No public groups created yet...",style:  TextStyle(fontSize: 18,fontWeight: FontWeight.w500)));
               }
             },
           )
         ]
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorsX.appRedColor,
        child: const Icon(Icons.create),
        onPressed: () {
          if(firstName.toString() == ""){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsPage(
                    floating:true

                ),
              ),
            );
          }
          else{
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddMembersInGroup(),
              ),
            );
          }
          },
        tooltip: "Create Group",
      ),
    ): Scaffold(
      backgroundColor: ColorsX.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        toolbarHeight: 80,
        flexibleSpace: SafeArea(
          child: Container(
            // elevation: 5,
            decoration: BoxDecoration(

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child:  Material(
                    child:Icon(
                      Icons.account_circle,
                      size: 40,
                      color: ColorConstants.greyColor,
                    ),
                    borderRadius:const BorderRadius.all(Radius.circular(25)),
                    clipBehavior: Clip.hardEdge,
                  ),
                ),
                Image.asset(
                  'assets/images/baselogo.png',
                  height: 60,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {

                      },
                      icon: const Icon(
                        Icons.search,
                        size: 35,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        handleSignOut();
                      },
                      child: Icon(Icons.exit_to_app),),
                    SizedBox(width: 10,)
                  ],
                )
              ],
            ),
          ),
        ),

      ),
      body: isLoading
          ? Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      )
          :Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("Pay first to continue",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25,fontFamily: 'Futura'),),),
          SizedBox(height: 30,),
          isload == true?Center(child: CircularProgressIndicator(color: ColorsX.appRedColor,),):Container(
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
                  setState(() {
                    isload = true;
                  });
                  makePayment2();
                },
                child: const Text(
                  "Pay Now",
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
