import 'package:chatapp/chat_final/constants/firestore_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserChat2 {
  String id;
  String photoUrl;
  String firstname;
  String lastname;


  UserChat2({required this.id, required this.photoUrl,required this.firstname,required this.lastname});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.fname: firstname,
      FirestoreConstants.lname: lastname,
      FirestoreConstants.photoUrl: photoUrl,
    };
  }

  factory UserChat2.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String firstname = "";
    String lastname = "";

    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}
    try {
      firstname = doc.get(FirestoreConstants.fname);
    } catch (e) {}
    try {
      lastname = doc.get(FirestoreConstants.lname);
    }
    catch (e) {}

    return UserChat2(
        id: doc.id,
        photoUrl: photoUrl,
      firstname: firstname,
      lastname: lastname

    );
  }
}
