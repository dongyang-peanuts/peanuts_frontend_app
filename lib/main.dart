import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'ListPage/home_screen.dart';
import 'ListPage/hospital_screen.dart';
import 'ListPage/monitoring_screen.dart';
import 'ListPage/video_screen.dart';
import 'ListPage/mypage_screen.dart';

import 'package:dangkong_app/screens/auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NaverMapSdk.instance.initialize(
    clientId: 'e2yvr541f0',
    onAuthFailed: (e) {
      print('네이버맵 인증 실패: $e');
    },
  );

  KakaoSdk.init(nativeAppKey: '3009f310bc7b91b7ddc6c26636dbd41d');

  runApp(const ProviderScope(child: MyApp()));
}

Future<String?> getAndroidKeyHash() async {
  const platform = MethodChannel('com.example.app/keyhash');
  try {
    final String? keyHash = await platform.invokeMethod('getKeyHash');
    return keyHash;
  } on PlatformException catch (e) {
    print('Failed to get key hash: ${e.message}');
    return null;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashRouter(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => const BottomNavApp(),
      },
    );
  }
}

class SplashRouter extends StatelessWidget {
  const SplashRouter({super.key});

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    return userEmail != null && userEmail.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          Future.microtask(() {
            if (snapshot.data == true) {
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class BottomNavApp extends StatefulWidget {
  const BottomNavApp({super.key});

  @override
  State<BottomNavApp> createState() => _BottomNavAppState();
}

class _BottomNavAppState extends State<BottomNavApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    HospitalScreen(),
    MonitoringScreen(),
    VideoScreen(),
    MypageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem('assets/images/home.png', '홈', 0, const Color(0xFFA8D18D)),
              _buildNavItem('assets/images/hospital.png', '인근병원찾기', 1, const Color(0xFFF78C8C)),
              _buildNavItem('assets/images/monitering.png', '모니터링', 2, const Color(0xFF95BFE9)),
              _buildNavItem('assets/images/video.png', '영상 목록', 3, const Color(0xFFFFE38D)),
              _buildNavItem('assets/images/mypage.png', '마이페이지', 4, const Color(0xFFC4C4C4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconPath, String label, int index, Color color) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 28, height: 28, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
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
