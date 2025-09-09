class NotificationItem {
  final String message;
  final bool isRead;
  final DateTime timestamp;

  NotificationItem({
    required this.message,
    this.isRead = false,
    required this.timestamp,
  });
}
