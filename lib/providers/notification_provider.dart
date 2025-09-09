import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_item.dart'; // 모델 import

class NotificationListNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationListNotifier() : super([]);

  // ✅ 새로운 알림을 기존 목록에 추가
  void addNotification(NotificationItem newItem) {
    state = [newItem, ...state]; // 최신 알림을 가장 앞에 추가
  }

  // 기존 기능 유지
  void markAsRead(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          NotificationItem(
            message: state[i].message,
            isRead: true,
            timestamp: state[i].timestamp,
          )
        else
          state[i],
    ];
  }
}


final notificationListProvider =
StateNotifierProvider<NotificationListNotifier, List<NotificationItem>>(
      (ref) => NotificationListNotifier(),
);
