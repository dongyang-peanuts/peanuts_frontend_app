import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        iconTheme: IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '2024년 4월 18일',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            _buildItem('18:02', '경고', '휘청거림이 감지되었습니다.'),
            _buildItem('18:07', '주의', '배회가 감지되었습니다.'),
            _buildItem('19:07', '경고', '큰소리가 감지되었습니다.'),
            _buildItem('19:07', '주의', '손떨림이 감지되었습니다.'),
            _buildItem('20:07', '비상', '낙상이 감지되었습니다.'),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String time, String type, String message) {
    Color color;
    switch (type) {
      case '비상':
        color = Colors.red;
        break;
      case '경고':
        color = Colors.orange;
        break;
      case '주의':
        color = Colors.green;
        break;
      default:
        color = Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            time,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '[$type]',
            style: TextStyle(color: color, fontSize: 14),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
