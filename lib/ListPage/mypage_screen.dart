import 'package:flutter/material.dart';

class MypageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('마이페이지'),
          backgroundColor: Colors.white),
      body: Center(child: Text('마이페이지 화면')),
    );
  }
}

