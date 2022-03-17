// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:developer';
import 'package:chatapp/group_chat/group_chat.dart';
import 'package:chatapp/utils/AppStrings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/common-functions.dart';

//  await _paymentProvider.makePayment(context, "450");
class StripePayment {
  var stripeToken;
  var customerId;
  var paymentMethodId;

   Map<String, dynamic>? paymentIntentData;

  Future<void> makePayment(BuildContext context, String rs,String id) async {
    try {
      paymentIntentData =
          await createPaymentIntent(rs, 'USD'); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntentData!['client_secret'],
                  applePay: true,
                  googlePay: true,
                  testEnv: true,
                  style: ThemeMode.dark,
                  merchantCountryCode: 'US',
                  merchantDisplayName: 'FRIENDLEE'))
          .then((value) {
        print("initial payment ok");
      });

      ///now finally display payment sheeet
      displayPaymentSheet(context,id);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }
  displayPaymentSheet(BuildContext context,String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    try {
      await Stripe.instance.presentPaymentSheet(
        parameters: PresentPaymentSheetParameters(clientSecret: paymentIntentData!['client_secret'],confirmPayment: true)
      );
      paymentIntentData = null;

      Functions.showSuccessToast(
          context, "Success", "Payment successfully completed");

      var collection = FirebaseFirestore.instance.collection('users');
      collection.doc(id).update({
        'payment':true
      });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) =>GroupChatScreen()),(Route<dynamic> route) => false,
        );
      });


    }
    on StripeException catch (e) {

      Functions.showErrorToast(
          context, "Error", "Payment Cancelled");

    }
  }



  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer ${AppStrings.stripeSecretKey}',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

}