import 'package:flutter/material.dart';

class MonitoringScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('모니터링'),
          backgroundColor: Colors.white),
      body: Center(child: Text('모니터링 화면')),
    );
  }
}
