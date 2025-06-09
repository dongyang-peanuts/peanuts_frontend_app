import 'package:flutter/material.dart';
import 'ListPage/home_screen.dart';
import 'ListPage/hospital_screen.dart';
import 'ListPage/monitoring_screen.dart';
import 'ListPage/video_screen.dart';
import 'ListPage/mypage_screen.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NaverMapSdk.instance.initialize(
    clientId: 'e2yvr541f0',
    onAuthFailed: (e) {
      print('네이버맵 인증 실패: $e');
    },
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavApp(),
    );
  }
}

class BottomNavApp extends StatefulWidget {
  @override
  _BottomNavAppState createState() => _BottomNavAppState();
}

class _BottomNavAppState extends State<BottomNavApp> {
  int _currentIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        return HospitalScreen();
      case 2:
        return MonitoringScreen(); // ✅ 매번 새로 생성
      case 3:
        return VideoScreen();
      case 4:
        return MypageScreen();
      default:
        return HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_currentIndex),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem('assets/images/home.png', '홈', 0, Color(0xFFA8D18D)),
              _buildNavItem('assets/images/hospital.png', '인근병원찾기', 1, Color(0xFFF78C8C)),
              _buildNavItem('assets/images/monitering.png', '모니터링', 2, Color(0xFF95BFE9)),
              _buildNavItem('assets/images/video.png', '영상 목록', 3, Color(0xFFFFE38D)),
              _buildNavItem('assets/images/mypage.png', '마이페이지', 4, Color(0xFFC4C4C4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconPath, String label, int index, Color color) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 28,
            height: 28,
            color: color,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
