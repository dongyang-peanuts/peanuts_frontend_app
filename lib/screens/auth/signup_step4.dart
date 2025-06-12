import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dangkong_app/providers/signup_provider.dart';

import 'package:dangkong_app/screens/auth/signup_step5.dart';
import 'package:dangkong_app/screens/auth/signup_step6.dart';

class SignupStep4 extends ConsumerStatefulWidget {
  const SignupStep4({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupStep4> createState() => _SignupStep4State();
}

class _SignupStep4State extends ConsumerState<SignupStep4> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _fallCountController = TextEditingController();
  final TextEditingController _bathroomFallCountController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signupData = ref.read(signupProvider);
      if (signupData.paAge != null) {
        _ageController.text = signupData.paAge.toString();
      }
      if (signupData.paHei != null) {
        _heightController.text = signupData.paHei.toString();
      }
      if (signupData.paWei != null) {
        _weightController.text = signupData.paWei.toString();
      }
      if (signupData.paFact != null) {
        _fallCountController.text = signupData.paFact.toString();
      }
      if (signupData.paPrct != null) {
        _bathroomFallCountController.text = signupData.paPrct.toString();
      }
    });
  }

  void _saveStep4Data() {
    ref
        .read(signupProvider.notifier)
        .updateStep4Data(
          paAge:
              _ageController.text.isNotEmpty
                  ? int.tryParse(_ageController.text)
                  : null,
          paHei:
              _heightController.text.isNotEmpty
                  ? double.tryParse(_heightController.text)
                  : null,
          paWei:
              _weightController.text.isNotEmpty
                  ? double.tryParse(_weightController.text)
                  : null,
          paFact:
              _fallCountController.text.isNotEmpty
                  ? int.tryParse(_fallCountController.text)
                  : null,
          paPrct:
              _bathroomFallCountController.text.isNotEmpty
                  ? int.tryParse(_bathroomFallCountController.text)
                  : null,
        );
  }

  void _onNextPressed() {
    _saveStep4Data();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupStep5()),
    );
  }

  void _onSkipPressed() {
    _saveStep4Data();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignupStep6()),
    );
  }

  Widget _buildInputRow(
    String label,
    TextEditingController controller,
    String unit,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: label,
                border: const UnderlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(unit, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _fallCountController.dispose();
    _bathroomFallCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonHeight = screenWidth * (83 / 412);

    return Scaffold(
      appBar: AppBar(
        title: const Text('이메일로 회원가입'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                '환자 정보를 입력해주세요. (1/2)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _buildInputRow('나이', _ageController, '세'),
              _buildInputRow('키', _heightController, 'cm'),
              _buildInputRow('체중', _weightController, 'kg'),
              _buildInputRow('낙상 경험 횟수', _fallCountController, '번'),
              _buildInputRow('욕창 경험 횟수', _bathroomFallCountController, '번'),

              const SizedBox(height: 16),

              Center(
                child: SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF99BC85),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('다음', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  '입력된 정보는\n[ 마이페이지 - 환자 정보 조회 ]에서\n조회 및 수정이 가능합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _onSkipPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF99BC85),
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: EdgeInsets.zero,
            elevation: 0,
          ),
          child: const Text(
            '건너뛰고\n회원가입 완료하기',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
