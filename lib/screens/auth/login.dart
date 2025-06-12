import 'package:dangkong_app/main.dart';
import 'package:flutter/material.dart';
import 'package:dangkong_app/models/login_model.dart';
import 'package:dangkong_app/services/login.dart';

import 'package:dangkong_app/screens/auth/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loginFailed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.85;
    final boxHeight = boxWidth * (53 / 367);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),

                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('이메일', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: boxWidth,
                  height: boxHeight,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: '이메일을 입력해주세요.',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('비밀번호', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: boxWidth,
                  height: boxHeight,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '비밀번호를 입력해주세요.',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),

                if (_loginFailed)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '아이디 혹은 비밀번호가 일치하지 않습니다.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: boxWidth,
                  height: boxHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color(0xFFB1DB99);
                        }
                        return Colors.grey;
                      }),
                    ),
                    onPressed: () async {
                      final loginModel = LoginModel(
                        userEmail: _emailController.text.trim(),
                        userPwd: _passwordController.text.trim(),
                      );
                      final success = await login(loginModel);
                      if (success) {
                        setState(() {
                          _loginFailed = false;
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BottomNavApp(),
                          ),
                        );
                      } else {
                        setState(() {
                          _loginFailed = true;
                        });
                      }
                    },
                    child: const Text('로그인', style: TextStyle(fontSize: 15)),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('아직 계정이 없으신가요?', style: TextStyle(fontSize: 11)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '회원가입하기',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
