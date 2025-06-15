import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "title": "욕창 가능성이 높음으로 변경되었습니다.",
        "subtitle": "자세를 변경하여 욕창을 예방해주세요.",
        "datetime": "25.04.14 09:46",
        "highlight": true,
      },
      {
        "title": "낙상 가능성이 높음으로 변경되었습니다.",
        "subtitle": "자세를 변경하여 욕창을 예방해주세요.",
        "datetime": "25.04.14 07:30",
        "highlight": false,
      },
      {
        "title": "낙상이 감지되었습니다.",
        "subtitle": "서둘러 확인해주세요.",
        "datetime": "25.04.14 05:03",
        "image": "assets/images/fall_example.jpg",
        "highlight": true,
      },
      {
        "title": "낙상이 감지되었습니다.",
        "subtitle": "서둘러 확인해주세요.",
        "datetime": "25.04.14 03:44",
      },
      {
        "title": "이상행동이 감지되었습니다.",
        "subtitle": "서둘러 확인해주세요.",
        "datetime": "25.04.14 01:30",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/DDANGKONG.png',
          height: 23,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),

    );
  }
}
