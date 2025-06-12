import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:dangkong_app/screens/auth/login.dart';

import 'package:dangkong_app/providers/signup_provider.dart';

class SignupStep6 extends ConsumerStatefulWidget {
  const SignupStep6({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupStep6> createState() => _SignupStep6State();
}

class _SignupStep6State extends ConsumerState<SignupStep6> {
  bool _isSignupComplete = false;
  String _statusMessage = '회원가입을 진행 중입니다...';

  @override
  void initState() {
    super.initState();
    print('=== SignupStep6 initState 시작 ===');
    _performSignup();
  }

  Future<void> _performSignup() async {
    print('=== _performSignup 함수 시작 ===');

    // 회원가입 데이터 확인 (API 호출 전에 먼저 출력)
    final signupData = ref.read(signupProvider);
    print('=== 회원가입 데이터 상세 확인 ===');
    print('전체 데이터: $signupData');
    print('');

    // Step별 데이터 상세 출력
    print(' Step2 데이터 (사용자 기본정보):');
    print('  - 이메일 (userEmail): ${signupData.userEmail ?? "NULL"}');
    print('  - 비밀번호 (userPwd): ${signupData.userPwd ?? "NULL"}');
    print('  - 비상연락망 (userNumber): ${signupData.userNumber ?? "NULL"}');
    print('');

    print('Step3 데이터 (주소정보):');
    print('  - 주소 (userAddr): ${signupData.userAddr ?? "NULL"}');
    print('');

    print(' Step4 데이터 (환자 신체정보):');
    print('  - 환자 나이 (paAge): ${signupData.paAge ?? "NULL"}');
    print('  - 키 (paHei): ${signupData.paHei ?? "NULL"}');
    print('  - 체중 (paWei): ${signupData.paWei ?? "NULL"}');
    print('  - 낙상횟수 (paFact): ${signupData.paFact ?? "NULL"}');
    print('  - 욕창횟수 (paPrct): ${signupData.paPrct ?? "NULL"}');
    print('');

    print('Step5 데이터 (환자 의료정보):');
    print('  - 질병 (paDi): ${signupData.paDi ?? "NULL"}');
    print('  - 질병의중증도 (paDise): ${signupData.paDise ?? "NULL"}');
    print('  - 운동시간 (paExti): ${signupData.paExti ?? "NULL"}');
    print('  - 거동상태 (paBest): ${signupData.paBest ?? "NULL"}');
    print('  - 복용약 (paMedi): ${signupData.paMedi ?? "NULL"}');
    print('');

    // NOTNULL 필드 검증
    print('🔍 필수 데이터 검증:');
    final missingRequired = <String>[];
    if (signupData.userEmail == null || signupData.userEmail!.isEmpty)
      missingRequired.add('userEmail');
    if (signupData.userPwd == null || signupData.userPwd!.isEmpty)
      missingRequired.add('userPwd');
    if (signupData.userNumber == null || signupData.userNumber!.isEmpty)
      missingRequired.add('userNumber');
    if (signupData.userAddr == null || signupData.userAddr!.isEmpty)
      missingRequired.add('userAddr');

    if (missingRequired.isEmpty) {
      print('  ✅ 모든 필수 데이터가 입력되었습니다.');
    } else {
      print('  ❌ 누락된 필수 데이터: ${missingRequired.join(", ")}');
    }
    print('');

    print('사용자 입력 데이터 수집 완료! 위의 모든 정보가 사용자가 입력한 데이터입니다.');
    print('');

    try {
      print(' API 전송 시도 중...');

      // 회원가입 API 호출
      final success = await ref.read(signupProvider.notifier).submitSignup();

      print('회원가입 API 호출 결과: $success');

      if (success) {
        print('회원가입 성공! UI 업데이트 중...');
        setState(() {
          _isSignupComplete = true;
          _statusMessage = '회원가입을 축하합니다.\n자동으로 로그인 창으로 이동합니다.';
        });

        print('3초 후 로그인 화면으로 이동 예정...');
        // 3초 후 로그인 화면으로 이동
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            print('로그인 화면으로 이동 중...');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } else {
            print('Widget이 unmounted 상태여서 화면 이동을 취소합니다.');
          }
        });
      } else {
        print('회원가입 실패: API가 false를 반환했습니다.');
        setState(() {
          _statusMessage = '회원가입에 실패했습니다.\n잠시 후 이전 화면으로 돌아갑니다.';
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            print('이전 화면으로 돌아가는 중...');
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      print('=== 회원가입 에러 발생 ===');
      print('에러 타입: ${e.runtimeType}');
      print('에러 메시지: $e');
      print('스택 트레이스:');
      print(StackTrace.current);

      setState(() {
        _statusMessage = '회원가입 중 오류가 발생했습니다.\n$e';
      });

      // 에러 발생 시 3초 후 이전 화면으로 돌아가기
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          print('에러로 인해 이전 화면으로 돌아가는 중...');
          Navigator.pop(context);
        } else {
          print('Widget이 unmounted 상태여서 화면 이동을 취소합니다.');
        }
      });
    }

    print('=== _performSignup 함수 종료 ===');
  }

  @override
  void dispose() {
    print('=== SignupStep6 dispose 호출 ===');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('SignupStep6 build 호출 - _isSignupComplete: $_isSignupComplete');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isSignupComplete)
              const CircularProgressIndicator(color: Color(0xFF99BC85)),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            if (_isSignupComplete) ...[
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/signupfin.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
