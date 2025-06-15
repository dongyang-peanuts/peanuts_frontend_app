import 'package:flutter/material.dart';
import 'package:dangkong_app/subpages/HistoryScreen.dart';
import 'package:dangkong_app/subpages/notification_screen.dart';
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            // ✅ 상단 로고 + 알림 아이콘

            // 상단 로고 + 알림 아이콘
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'assets/images/DDANGKONG.png',
                    height: 23,
                    fit: BoxFit.contain,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.green,
                        size: 33,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ 1. 히스토리 섹션
            SizedBox(height: 50),
            Text(
              '히스토리',
              style: TextStyle(
                color: const Color(0xFF373737),
                fontSize: 14,
                fontFamily: 'Cabin',
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
              child:Container(
                width: double.infinity,
                height: 263,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: const Color(0xFFE7E7E7),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    )
                  ],
                ),

                child: Center(child: Text('히스토리 영역')),
              ),
            ),
            SizedBox(height: 30),

            // ✅ 2. 낙상/욕창 퍼센트 원형 표시

            Row(

              children: [

                Column(
                  children: [

                    Container(
                      width: 97,
                      height: 130,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFE7E7E7),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 10,
                            offset: Offset(0, 1),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Center(child: Text('낙상 가능성')),
                    ),

                    SizedBox(height: 16,),

                    Container(
                      width: 97,
                      height: 130,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFE7E7E7),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 10,
                            offset: Offset(0, 1),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Center(child: Text('욕창 가능성')),
                    ),

                  ],
                ),
                SizedBox(width: 16,),


                Expanded(child:
                Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,

                      child: Text(
                        '오늘 이상행동 비율',
                        style: TextStyle(
                          color: const Color(0xFF373737),
                          fontSize: 13,
                          fontFamily: 'Cabin',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(

                      height:241,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 10,
                            offset: Offset(0, 1),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Center(child: Text('이상행동 비율')),
                    ),
                  ],
                ),
                ),

              ],
            ),




            SizedBox(height: 25),
            Text(
              '현재 의심 질병',
              style: TextStyle(
                color: const Color(0xFF373737),
                fontSize: 13  ,
                fontFamily: 'Cabin',
                fontWeight: FontWeight.w700,
              ),
            ),

            // ✅ 4. 의심 질병 바 차트
            Container(
              width: double.infinity,
              height: 180,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 10,
                    offset: Offset(0, 1),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Center(child: Text('의심 질병 비율')),
            ),

            SizedBox(height: 80), // 하단바 고려 여유 공간
          ],
        ),
      ),

    );
  }
}
