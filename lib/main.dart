import 'package:chatapp/chat_final/providers/group_provider.dart';
import 'package:chatapp/service/local_notification.dart';
import 'package:chatapp/utils/AppStrings.dart';
import 'package:chatapp/utils/common-functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_final/constants/color_constants.dart';
import 'chat_final/pages/splash_page.dart';
import 'chat_final/providers/auth_provider.dart';
import 'chat_final/providers/chat_provider.dart';
import 'chat_final/providers/home_provider.dart';
import 'chat_final/providers/setting_provider.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Functions.initializeLoader();
  await Firebase.initializeApp();
  await LocalNotificationsService.instance.initialize();
  Stripe.publishableKey = AppStrings.stripePublisherKey;
  await Stripe.instance.applySettings();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));

}


class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

   MyApp({Key? key,required this.prefs}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        Provider<SettingProvider>(
          create: (_) => SettingProvider(
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
          ),
        ),
        Provider<GroupProvider>(
          create: (_) => GroupProvider(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
          ),
        ),
        Provider<HomeProvider>(
          create: (_) => HomeProvider(
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        Provider<ChatProvider>(
          create: (_) => ChatProvider(
            prefs: prefs,
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage,
          ),
        ),
      ],
      child: MaterialApp(
        title: "Friendlee",
        theme: ThemeData(
          primaryColor: ColorConstants.themeColor,
        ),
        builder: EasyLoading.init(),
        home: SplashPage(),
        debugShowCheckedModeBanner: false,
      ),
    );





 /*   return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      builder: EasyLoading.init(),

      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => Splash_Screen(),
        '/signup': (context) => SignUpScreen(),
        '/Signin': (context) => Si(),
        '/Topic': (context) => Topic(),
        "/forget": (context) => Forget(),
        "/Checcking": (context) => CheckMail(),
      //  '/Searchone': (context) => Searchone(),
        '/SearchTwo': (context) => SearchTwo(),
        '/AllNetworks': (context) => AllNetworks(),
        '/NetworkList': (context) => NetworkList(),
        '/OnBoardingProfile': (context) => OnBoardingProfile(),
        '/OnBoardingNetwork': (context) => OnBoardingNetwork(),
        '/allUsers': (context) => AllUsers(),
      },

      *//*routes: {
          // When navigating to the "/" route, build the FirstScreen widget.
          '/': (context) => HandImage(),
          // When navigating to the "/second" route, build the SecondScreen widget.
          '/OnBoardingProfile': (context) => OnBoardingProfile(),
          '/OnBoardingNetwork': (context) => OnBoardingNetwork(),
          '/allUsers': (context) => AllUsers(),
        },*//*
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );*/
  }
}

