import 'package:chatapp/chat_final/constants/firestore_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class GroupModel {
  String id;
  String photoUrl;
  String name;
  String type;



  GroupModel({required this.id, required this.photoUrl,required this.name,required this.type});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.gname: name,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.id: id,
      FirestoreConstants.type: type,
    };
  }

  factory GroupModel.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String name = "";
    String id = "";
    String type = "";

    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}

    try {
      name = doc.get(FirestoreConstants.gname);
    }
    catch (e) {}
    try {
      id = doc.get(FirestoreConstants.id);
    } catch (e) {}
    try {
      type = doc.get(FirestoreConstants.type);
    } catch (e) {}

    return GroupModel(
        id: id,
        photoUrl: photoUrl,
        name: name,
        type:type

    );
  }
}
