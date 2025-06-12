// import 'package:flutter/material.dart';
// import 'package:dangkong_app/screens/auth/signup_step1.dart';

// class SignupScreen extends StatelessWidget {
//   const SignupScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final _ = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(centerTitle: true, title: const Text('회원가입')),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               SizedBox(height: 80),

//               // 로고 이미지
//               Image.asset('assets/images/logo.png', width: 150, height: 150),

//               // 안내 문구
//               const Text(
//                 '땅콩에 오신 것을 환영합니다!',
//                 style: TextStyle(fontSize: 13, color: Colors.grey),
//               ),

//               const Text(
//                 '서비스를 사용하기 위해 회원가입이 필요합니다.',
//                 style: TextStyle(fontSize: 13, color: Colors.grey),
//               ),
//               const SizedBox(height: 32),

//               // 이메일 아이디로 회원가입 버튼
//               SizedBox(
//                 width: 372,
//                 height: 50,
//                 child: ElevatedButton.icon(
//                   icon: Image.asset(
//                     'assets/images/emailicon.png',
//                     width: 24,
//                     height: 24,
//                   ),
//                   label: const Text('이메일 아이디로 회원가입하기'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF99BC85),
//                     foregroundColor: Colors.white,
//                     textStyle: const TextStyle(fontSize: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SignupStep1(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // 구글 계정으로 회원가입 버튼
//               SizedBox(
//                 width: 372,
//                 height: 50,
//                 child: ElevatedButton.icon(
//                   icon: Image.asset(
//                     'assets/images/googleicon.png',
//                     width: 24,
//                     height: 24,
//                   ),
//                   label: const Text('구글 계정으로 회원가입하기'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFF5F5F5),
//                     foregroundColor: Colors.black,
//                     textStyle: const TextStyle(fontSize: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: () {
//                     // 구글 로그인 로직
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // 카카오 계정으로 회원가입 버튼
//               SizedBox(
//                 width: 372,
//                 height: 50,
//                 child: ElevatedButton.icon(
//                   icon: Image.asset(
//                     'assets/images/kakaoicon.png',
//                     width: 24,
//                     height: 24,
//                   ),
//                   label: const Text('카카오 계정으로 회원가입하기'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFFEE404),
//                     foregroundColor: Colors.black,
//                     textStyle: const TextStyle(fontSize: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: () {
//                     // 카카오 로그인 로직
//                   },
//                 ),
//               ),
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:dangkong_app/screens/auth/signup_step1.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  void _kakaoLogin(BuildContext context) async {
    try {
      bool installed = await isKakaoTalkInstalled();

      OAuthToken token;

      if (installed) {
        try {
          // 카카오톡 앱으로 로그인 시도
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          // 실패 시 카카오 계정 웹 로그인 시도 (웹뷰 없이 SDK 내장 처리)
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // 카카오톡 앱 미설치 시 카카오 계정 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 로그인 성공 시 사용자 정보 조회
      User user = await UserApi.instance.me();

      print('카카오 사용자 닉네임: ${user.kakaoAccount?.profile?.nickname}');
      print('카카오 이메일: ${user.kakaoAccount?.email}');

      // 로그인 성공 후 앱 내 화면 이동 (예: 홈 화면)
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('카카오톡 회원가입 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오톡 회원가입 실패: $e'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _loginGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        debugPrint('[GoogleLogin] 사용자가 로그인 취소');
        return;
      }

      debugPrint(
        '[GoogleLogin] 사용자 정보: ${googleUser.displayName}, ${googleUser.email}',
      );

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint('[GoogleLogin] accessToken: ${googleAuth.accessToken}');
      debugPrint('[GoogleLogin] idToken: ${googleAuth.idToken}');

      // 로그인 성공 시 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e, stackTrace) {
      debugPrint('[GoogleLogin] 로그인 중 예외 발생: $e');
      debugPrint('[GoogleLogin] StackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구글 로그인 실패'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _ = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(centerTitle: true, title: const Text('회원가입')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Image.asset('assets/images/logo.png', width: 150, height: 150),
              const Text(
                '땅콩에 오신 것을 환영합니다!',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Text(
                '서비스를 사용하기 위해 회원가입이 필요합니다.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // 이메일 회원가입 버튼
              SizedBox(
                width: 372,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/images/emailicon.png',
                    width: 24,
                    height: 24,
                  ),
                  label: const Text('이메일 아이디로 회원가입하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF99BC85),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupStep1(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 구글 회원가입 버튼 (구현 필요)
              SizedBox(
                width: 372,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/images/googleicon.png',
                    width: 24,
                    height: 24,
                  ),
                  label: const Text('구글 계정으로 회원가입하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F5F5),
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _loginGoogle(context),
                ),
              ),
              const SizedBox(height: 16),

              // 카카오 회원가입 버튼
              SizedBox(
                width: 372,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/images/kakaoicon.png',
                    width: 24,
                    height: 24,
                  ),
                  label: const Text('카카오 계정으로 회원가입하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE404),
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _kakaoLogin(context),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
