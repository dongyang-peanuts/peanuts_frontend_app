import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dangkong_app/providers/notification_provider.dart';
import 'package:dangkong_app/models/notification_item.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '히스토리',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: notifications.isEmpty
            ? const Center(child: Text('📭 알림 내역이 없습니다'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _getTodayDate(), // 오늘 날짜 출력
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ...notifications.map((item) => _buildItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  // 오늘 날짜 포맷
  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month.toString().padLeft(2, '0')}월 ${now.day.toString().padLeft(2, '0')}일';
  }

  // 개별 알림 렌더링
  Widget _buildItem(NotificationItem item) {
    // 시간
    final time = item.timestamp.toLocal().toString().substring(11, 16);

    // 타입 구분
    String type = '알림';
    Color color = Colors.black;

    if (item.message.contains('낙상')) {
      type = '비상';
      color = Colors.red;
    } else if (item.message.contains('소리') || item.message.contains('휘청')) {
      type = '경고';
      color = Colors.orange;
    } else if (item.message.contains('배회') || item.message.contains('떨림')) {
      type = '주의';
      color = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 줄 맞춤 상단 정렬
        children: [
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 25),
          Text(
            '[$type]',
            style: TextStyle(color: color, fontSize: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
            Text(
              item.message,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
