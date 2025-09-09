import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dangkong_app/providers/notification_provider.dart';
import 'package:dangkong_app/models/notification_item.dart';
import 'package:intl/intl.dart';
import 'package:dangkong_app/providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);
    final notifier = ref.read(notificationListProvider.notifier);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/DDANGKONG.png',
          height: 23,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('📭 알림이 없습니다'))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          final formattedTime = DateFormat('yy.MM.dd\nHH:mm').format(item.timestamp);

          return GestureDetector(
            onTap: () => notifier.markAsRead(index),
            child: Container(
              height: screenHeight * 0.08,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: item.isRead ? Colors.white : const Color(0xFFE7F5D6),
                border: Border(
                  bottom: BorderSide(
                    color: item.isRead ? Colors.grey.shade200 : const Color(0xFFDFF1C6),
                    width: 1,
                  ),
                ),
              ),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 📍 왼쪽: 메시지
                  Expanded(
                    child: Text(
                      item.message,
                      style: const TextStyle(
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // 📍 오른쪽: 날짜 및 시간
                  Text(
                    formattedTime,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
