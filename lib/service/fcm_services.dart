// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:chatapp/utils/AppStrings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;


class FCMServices {
  static fcmGetTokenandSubscribe(topic) {
    FirebaseMessaging.instance.getToken().then((value) {
      FirebaseMessaging.instance.subscribeToTopic("$topic");
    });
  }

  static Future<http.Response> sendFCM(topic, id, title, name,description) {
    return http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "key=${AppStrings.serverKey}",
      },
      body: jsonEncode({
        "to": "/topics/$topic",
        "notification": {
          "title": "You got " +title +" from "+name,
          "body": description,
        },
        "data": {
          "id": id,
          "userid":FirebaseAuth.instance.currentUser!.uid,
          "userName": name,
        }
      }),
    );
  }
}
