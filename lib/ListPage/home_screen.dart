import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(title: Text('홈'),
        backgroundColor: Colors.white),
      body: Center(child: Text('홈 화면')),
    );
  }
}
