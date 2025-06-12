import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'ListPage/home_screen.dart';
import 'ListPage/hospital_screen.dart';
import 'ListPage/monitoring_screen.dart';
import 'ListPage/video_screen.dart';
import 'ListPage/mypage_screen.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// 희주 추가
import 'package:dangkong_app/screens/auth/login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
  KakaoSdk.init(nativeAppKey: '3009f310bc7b91b7ddc6c26636dbd41d');

  //해시키
  // Android 해시키 출력 (안드로이드에서만 작동)
  String? keyHash = await getAndroidKeyHash();
  print('Android KeyHash: $keyHash');
}

//해시키 땜에 추가가
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

// 로그인 여부 확인
class SplashRouter extends StatelessWidget {
  const SplashRouter({super.key});

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    if (userEmail != null && userEmail.isNotEmpty) {
      print('로그인된 이메일: $userEmail'); // 콘솔 출력
      return true;
    } else {
      return false;
    }
  }

  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.hasData && snapshot.data == true) {
            // 로그인 되어있으면 홈으로 이동
            Future.microtask(
              () => Navigator.pushReplacementNamed(context, '/home'),
            );
          } else {
            // 로그인 안되어있으면 로그인 화면으로 이동
            Future.microtask(
              () => Navigator.pushReplacementNamed(context, '/login'),
            );
          }
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class BottomNavApp extends StatefulWidget {
  const BottomNavApp({super.key});

  @override
  _BottomNavAppState createState() => _BottomNavAppState();
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
              _buildNavItem(
                'assets/images/home.png',
                '홈',
                0,
                const Color(0xFFA8D18D),
              ),
              _buildNavItem(
                'assets/images/hospital.png',
                '인근병원찾기',
                1,
                const Color(0xFFF78C8C),
              ),
              _buildNavItem(
                'assets/images/monitering.png',
                '모니터링',
                2,
                const Color(0xFF95BFE9),
              ),
              _buildNavItem(
                'assets/images/video.png',
                '영상 목록',
                3,
                const Color(0xFFFFE38D),
              ),
              _buildNavItem(
                'assets/images/mypage.png',
                '마이페이지',
                4,
                const Color(0xFFC4C4C4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconPath, String label, int index, Color color) {
    final isSelected = _currentIndex == index;
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
