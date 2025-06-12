
import 'package:flutter/material.dart';
import 'package:dangkong_app/services/logout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dangkong_app/screens/mypage/mypage_address.dart';
import 'package:dangkong_app/screens/mypage/mypage_painfo.dart';
import 'package:dangkong_app/screens/mypage/mypage_usernumber.dart';
import 'package:dangkong_app/screens/mypage/mypage_userpwd.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({Key? key}) : super(key: key);

  @override
  _MypageScreenState createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail') ?? '이메일 없음';
    setState(() {
      userEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/logo2.png', height: 30),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[100]),
        ),
      ),
      body: Column(
        children: [
          // Profile Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userEmail ?? '로딩 중...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // const Text(
                    //   '비밀번호변경',
                    //   style: TextStyle(fontSize: 12, color: Colors.grey),
                    // ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MypageUserPwd(),
                          ),
                        );
                      },
                      child: const Text(
                        '비밀번호변경',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.home_outlined,
                    title: '주소 수정',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MypageAddress(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.people_outline,
                    title: '환자 정보 조회',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MypagePainfo()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.phone_outlined,
                    title: '비상연락망 변경',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MypageUserNumber(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.language_outlined,
                    title: '땅콩 웹 으로 이동',
                    onTap: () {
                      print('땅콩 웹으로 이동 클릭');
                    },
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        _showLogoutDialog(context); // 수정된 부분: context 전달
                      },
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: Colors.grey[600], size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  // 🔧 수정된 부분: 외부 context 전달
  void _showLogoutDialog(BuildContext outerContext) {
    showDialog(
      context: outerContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃', style: TextStyle(fontSize: 16)),
          content: const Text(
            '정말 로그아웃 하시겠습니까?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout(outerContext); // 핵심: 외부 context 사용
              },
              child: const Text('로그아웃', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final success = await LogoutService.logout();

    if (!context.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('userKey');

    if (success) {
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => const AlertDialog(
              title: Text('로그아웃 실패'),
              content: Text('로그아웃에 실패했습니다.'),
              actions: [TextButton(onPressed: null, child: Text('확인'))],
            ),
      );
    }
  }
}
>>>>>>> 2cc3f3b7039665d13ec68419f046cd64aa6aabc7
