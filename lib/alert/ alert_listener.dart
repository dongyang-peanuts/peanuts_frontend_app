import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dangkong_app/models/notification_item.dart'; // ✅ 모델
import 'package:dangkong_app/providers/notification_provider.dart'; // ✅ provider

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class AlertListener extends ConsumerStatefulWidget {
  const AlertListener({super.key});

  @override
  ConsumerState<AlertListener> createState() => _AlertListenerState();
}

class _AlertListenerState extends ConsumerState<AlertListener> {
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();

    _channel = WebSocketChannel.connect(
      Uri.parse('ws://kongback.kro.kr:8080/ws/alert'),
    );

    _channel.stream.listen(
          (data) async {
        print('🟠 [ALERT] 수신된 메시지: $data');

        try {
          final parsed = jsonDecode(data);
          final eventType = parsed['eventType']?.toString();
          final alertLevel = parsed['alertLevel']?.toString();
          final detectedAt =
              DateTime.tryParse(parsed['detectedAt'] ?? '') ?? DateTime.now();

          if (eventType == '낙상') {
            await _showFallDetectedNotification();

            final msg = '낙상 감지됨';
            final newItem = NotificationItem(
              message: msg,
              isRead: false,
              timestamp: detectedAt,
            );

            final currentList = ref.read(notificationListProvider);
            final latest = currentList.isNotEmpty ? currentList.first : null;

            // ✅ 정확한 시간 중복 판단
            final isDuplicate = latest != null &&
                latest.message == msg &&
                latest.timestamp.isAtSameMomentAs(detectedAt);

            if (!isDuplicate) {
              ref.read(notificationListProvider.notifier).state = [
                newItem,
                ...currentList,
              ];
              print('✅ 히스토리에 알림 추가됨');
            } else {
              print('⚠️ 중복 알림 무시됨');
            }
          }
        } catch (e) {
          print('❌ 메시지 파싱 오류: $e');
        }
      },
      onError: (error) {
        print("❌ WebSocket 오류: $error");
      },
      onDone: () {
        print("🔌 WebSocket 연결 종료됨");
      },
    );
  }

  Future<void> _showFallDetectedNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fall_channel',
      '낙상 알림',
      channelDescription: '낙상이 감지되었을 때 알림을 표시합니다.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '⚠️ 낙상 감지',
      '환자가 넘어졌습니다. 즉시 확인하세요.',
      notificationDetails,
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // 표시 없이 숨김 상태로 유지
  }
}
