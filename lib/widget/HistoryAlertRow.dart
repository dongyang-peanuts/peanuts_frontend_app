import 'package:flutter/material.dart';

class HistoryAlertRow extends StatelessWidget {
  final String label;           // 예: '[비상]'
  final String message;         // 예: '사용자에게 낙상이 감지되었습니다.'
  final String time;            // 예: '13:29:17'
  final Color labelColor;       // 예: Colors.red

  const HistoryAlertRow({
    super.key,
    required this.label,
    required this.message,
    required this.time,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final rowHeight = screenHeight * 0.025; // 예: 높이 비율 (화면 높이의 약 2.5%)

    return Container(
      width: double.infinity,
      height: rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          // 오른쪽 시간
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Text(
              time,
              style: const TextStyle(
                color: Color(0xFF373737),
                fontSize: 12,
                fontFamily: 'Cabin',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // 왼쪽 메시지
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 12,
                      fontFamily: 'Cabin',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: message,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Cabin',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
