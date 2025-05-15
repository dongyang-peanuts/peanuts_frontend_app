import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('영상목록'),
          backgroundColor: Colors.white),
      body: Center(child: Text('영상목록 화면')),
    );
  }
}
