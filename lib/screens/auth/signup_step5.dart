import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dangkong_app/providers/signup_provider.dart';

import 'package:dangkong_app/screens/auth/signup_step6.dart';

class SignupStep5 extends ConsumerStatefulWidget {
  const SignupStep5({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupStep5> createState() => _SignupStep5State();
}

class _SignupStep5State extends ConsumerState<SignupStep5> {
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();

  String? _selectedSeverity;
  String? _selectedExerciseTime;
  String? _selectedMobility;

  final List<String> _severityOptions = ['경증', '중증', '관계 없음 또는 잘 모르겠음'];
  final List<String> _exerciseTimeOptions = ['30분', '1시간', '1시간 30분', '2시간 이상'];
  final List<String> _mobilityOptions = [
    '보행 가능',
    '워커 사용',
    '지팡이 사용',
    '휠체어 사용',
    '거동 불가능',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signupData = ref.read(signupProvider);
      if (signupData.paDi != null) {
        _diseaseController.text = signupData.paDi!;
      }
      if (signupData.paDise != null) {
        _selectedSeverity = signupData.paDise!;
      }
      if (signupData.paExti != null) {
        _selectedExerciseTime = signupData.paExti!;
      }
      if (signupData.paBest != null) {
        _selectedMobility = signupData.paBest!;
      }
      if (signupData.paMedi != null) {
        _medicationController.text = signupData.paMedi!;
      }
    });
  }

  void _saveStep5Data() {
    // 입력된 데이터를 provider에 저장
    ref
        .read(signupProvider.notifier)
        .updateStep5Data(
          paDi:
              _diseaseController.text.isNotEmpty
                  ? _diseaseController.text
                  : null,
          paDise: _selectedSeverity,
          paExti: _selectedExerciseTime,
          paBest: _selectedMobility,
          paMedi:
              _medicationController.text.isNotEmpty
                  ? _medicationController.text
                  : null,
        );
  }

  void _onFinishSignup() {
    _saveStep5Data();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignupStep6()),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String? value,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Container(
        width: 350,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            border: const UnderlineInputBorder(),
          ),
          dropdownColor: Colors.white,
          items:
              options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _diseaseController.dispose();
    _medicationController.dispose();
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
                '환자 정보를 입력해주세요. (2/2)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16,
                ),
                child: TextField(
                  controller: _diseaseController,
                  decoration: const InputDecoration(
                    labelText: '질병 입력',
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),

              _buildDropdown(
                '질병의 중증도',
                _severityOptions,
                _selectedSeverity,
                (value) => setState(() => _selectedSeverity = value),
              ),

              _buildDropdown(
                '하루 평균 운동 시간',
                _exerciseTimeOptions,
                _selectedExerciseTime,
                (value) => setState(() => _selectedExerciseTime = value),
              ),

              _buildDropdown(
                '현재 거동 상태',
                _mobilityOptions,
                _selectedMobility,
                (value) => setState(() => _selectedMobility = value),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16,
                ),
                child: TextField(
                  controller: _medicationController,
                  decoration: const InputDecoration(
                    labelText: '복용 중인 약 입력',
                    border: UnderlineInputBorder(),
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

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _onFinishSignup,
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
            '회원가입 완료하기',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
