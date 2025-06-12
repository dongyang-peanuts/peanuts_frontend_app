import 'package:flutter/material.dart';
import 'package:dangkong_app/screens/auth/signup_step2.dart';

class SignupStep1 extends StatefulWidget {
  const SignupStep1({super.key});

  @override
  State<SignupStep1> createState() => _SignupStep1State();
}

class _SignupStep1State extends State<SignupStep1> {
  bool _agreeAll = false;
  List<bool> _agreements = [false, false, false, false];
  bool _showWarning = false;

  void _toggleAll(bool? value) {
    setState(() {
      _agreeAll = value ?? false;
      for (int i = 0; i < _agreements.length; i++) {
        _agreements[i] = _agreeAll;
      }
    });
  }

  void _toggleOne(int index, bool? value) {
    setState(() {
      _agreements[index] = value ?? false;
      _agreeAll = _agreements.every((element) => element);
    });
  }

  void _onSubmit() {
    if (_agreements.every((e) => e)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupStep2()),
      );
    } else {
      setState(() {
        _showWarning = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double buttonHeight = screenWidth * (83 / 412);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(centerTitle: true, title: const Text('이메일 회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                '땅콩 서비스 이용약관에\n동의해주세요',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 40),

            // 전체 동의 (네모 체크박스)
            // 기존 CheckboxListTile 제거 후 아래 코드로 대체
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _agreeAll,
                    onChanged: _toggleAll,
                    checkColor: Colors.white,
                    activeColor: const Color(0xFF99BC85),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  const Text('전체 약관에 동의합니다.', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 개별 약관 체크 (회색/초록 체크박스)
            _buildCheck(0, '[필수] 개인정보 취급방침'),
            _buildCheck(1, '[필수] 사용자 이용약관'),
            _buildCheck(2, '[필수] 위치정보 서비스 이용약관'),
            _buildCheck(3, '[필수] 만 14세 이상입니다.'),

            if (_showWarning)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '약관에 모두 동의해주세요.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const Spacer(),

            SizedBox(
              width: screenWidth, // 전체 가로 채움
              height: buttonHeight, // 비율 유지
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _agreements.every((e) => e)
                          ? const Color(0xFF99BC85)
                          : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: _onSubmit,
                child: const Text(
                  '동의하고 가입하기',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheck(int index, String text) {
    return CheckboxListTile(
      value: _agreements[index],
      onChanged: (val) => _toggleOne(index, val),
      controlAffinity: ListTileControlAffinity.leading,
      checkColor: Colors.white,
      activeColor: const Color(0xFF99BC85),
      side: BorderSide(
        color: _agreements[index] ? const Color(0xFF99BC85) : Colors.grey,
      ),
      contentPadding: EdgeInsets.zero, // 좌우 여백 제거
      visualDensity: VisualDensity.compact, // 위아래 여백 줄임
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화
      title: Text(text),
    );
  }
}
