import 'package:chatapp/chat_final/constants/app_constants.dart';
import 'package:chatapp/styles/app_color.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';


class FullPhotoPage extends StatelessWidget {
  final String url;

  FullPhotoPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsX.appRedColor,
        title: Text(
          AppConstants.fullPhotoTitle,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
        ),
      ),
    );
  }
}
