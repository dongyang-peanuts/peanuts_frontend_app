import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dangkong_app/subpages/HistoryScreen.dart';
import 'package:dangkong_app/subpages/notification_screen.dart';
import 'package:dangkong_app/providers/notification_provider.dart';
import 'package:dangkong_app/models/notification_item.dart';
import 'package:dangkong_app/widget/HistoryAlertRow.dart';
import 'package:dangkong_app/widget/AbnormalBehaviorSection.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    final notifications = ref.watch(notificationListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/DDANGKONG.png',
                  height: screenHeight * 0.03,
                  fit: BoxFit.contain,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    );
                  },
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.green,
                    size: 33,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.05),
            const Text(
              '히스토리',
              style: TextStyle(
                color: Color(0xFF373737),
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
              child: Container(
                width: double.infinity,
                height: screenHeight * 0.3,
                padding: EdgeInsets.all(screenWidth * 0.03),
                margin: EdgeInsets.only(top: screenHeight * 0.01),
                decoration: _cardDecoration(),
                child: notifications.isEmpty
                    ? const Center(child: Text('히스토리 없음'))
                    : ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: notifications.length > 3 ? 3 : notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    final isFall = item.message.contains('낙상');
                    final time = item.timestamp?.toLocal().toString().substring(11, 19) ?? '';
                    return HistoryAlertRow(
                      label: isFall ? '[비상]' : '[알림]',
                      message: item.message,
                      time: time,
                      labelColor: isFall ? Colors.red : Colors.green,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: screenWidth * 0.26,
                      height: screenHeight * 0.17,
                      decoration: _cardDecoration(),
                      child: const Center(child: Text('낙상 가능성')),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      width: screenWidth * 0.26,
                      height: screenHeight * 0.17,
                      decoration: _cardDecoration(),
                      child: const Center(child: Text('욕창 가능성')),
                    ),
                  ],
                ),
                SizedBox(width: screenWidth * 0.04),
                const Expanded(child: AbnormalBehaviorSection()),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            const Text(
              '현재 의심 질병',
              style: TextStyle(
                color: Color(0xFF373737),
                fontSize: 13,
                fontFamily: 'Cabin',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              width: double.infinity,
              height: screenHeight * 0.22,
              decoration: _cardDecoration(),
              child: const Center(child: Text('의심 질병 비율')),
            ),
            SizedBox(height: screenHeight * 0.08),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(width: 1, color: const Color(0xFFE7E7E7)),
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x19000000),
          blurRadius: 10,
          offset: Offset(0, 1),
          spreadRadius: 0,
        )
      ],
    );
  }
}