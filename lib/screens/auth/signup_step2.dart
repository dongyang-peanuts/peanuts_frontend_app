import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dangkong_app/providers/signup_provider.dart';

import 'package:dangkong_app/screens/auth/signup_step3.dart';

class SignupStep2 extends ConsumerStatefulWidget {
  const SignupStep2({Key? key}) : super(key: key);

  @override
  _SignupStep2State createState() => _SignupStep2State();
}

class _SignupStep2State extends ConsumerState<SignupStep2> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();

  bool _isEmailChecked = false;

  final List<bool> _agreements = [true, true, true];

  @override
  void initState() {
    super.initState();

    final signupData = ref.read(signupProvider);
    _emailController.text = signupData.userEmail ?? '';
    _passwordController.text = signupData.userPwd ?? '';
    _emergencyContactController.text = signupData.userNumber ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _checkEmailDuplicate() {
    setState(() {
      _isEmailChecked = true;
    });
  }

  void _onSubmit() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일을 입력해주세요.')));
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호를 입력해주세요.')));
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')));
      return;
    }

    if (_emergencyContactController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비상연락망을 입력해주세요.')));
      return;
    }

    // Riverpod을 통해 데이터 저장
    ref
        .read(signupProvider.notifier)
        .updateStep2Data(
          userEmail: _emailController.text,
          userPwd: _passwordController.text,
          userNumber: _emergencyContactController.text,
        );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupStep3()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonHeight = screenWidth * (83 / 412);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('이메일로 회원가입'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16.0), child: Center()),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '로그인에 사용할\n이메일과 비밀번호를 입력해주세요.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text('이메일', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: '이메일을 입력해주세요',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _checkEmailDuplicate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      elevation: 0,
                    ),
                    child: const Text('중복확인', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('비밀번호', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '사용하실 비밀번호를 입력 해주세요.',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('비밀번호 확인', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordConfirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '비밀번호를 재확인',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('비상연락망', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _emergencyContactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '전화 번호를 입력해주세요.',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: buttonHeight,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _agreements.every((e) => e)
                      ? const Color(0xFF99BC85)
                      : Colors.grey,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: _agreements.every((e) => e) ? _onSubmit : null,
            child: const Text(
              '다음',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}
