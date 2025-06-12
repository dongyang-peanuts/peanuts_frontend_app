import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dangkong_app/services/user_patientinfo.dart';
import 'package:dangkong_app/models/patientinfo_model.dart';
import 'package:dangkong_app/services/user_patientput.dart';

class MypagePainfo extends ConsumerStatefulWidget {
  const MypagePainfo({Key? key}) : super(key: key);

  @override
  ConsumerState<MypagePainfo> createState() => _MypagePainfoState();
}

class _MypagePainfoState extends ConsumerState<MypagePainfo> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _fallCountController = TextEditingController();
  final TextEditingController _bathroomFallCountController =
      TextEditingController();
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

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fetchAndLoadPatientInfo();
  }

  Future<void> _fetchAndLoadPatientInfo() async {
    final patients = await getPatients();
    if (patients.isEmpty) return;

    final patient = patients.first;
    final info = patient.infos.isNotEmpty ? patient.infos[0] : null;

    setState(() {
      _ageController.text = patient.paAge.toString();
      _heightController.text = patient.paHei.toString();
      _weightController.text = patient.paWei.toString();
      _fallCountController.text = info?.paFact.toString() ?? '';
      _bathroomFallCountController.text = info?.paPrct.toString() ?? '';
      _diseaseController.text = info?.paDi ?? '';
      _selectedSeverity = info?.paDise;
      _selectedExerciseTime = info?.paExti;
      _selectedMobility = info?.paBest;
      _medicationController.text = info?.paMedi ?? '';
    });
  }

  Future<void> _savePatientInfo() async {
    final patientInfo = PatientInfo(
      paFact: int.tryParse(_fallCountController.text) ?? 0,
      paPrct: int.tryParse(_bathroomFallCountController.text) ?? 0,
      paDi: _diseaseController.text,
      paDise: _selectedSeverity ?? '',
      paExti: _selectedExerciseTime ?? '',
      paBest: _selectedMobility ?? '',
      paMedi: _medicationController.text,
    );

    final patient = Patient(
      paName: _nameController.text,
      paAddr: _addressController.text,
      paAge: int.tryParse(_ageController.text) ?? 0,
      paHei: int.tryParse(_heightController.text) ?? 0,
      paWei: int.tryParse(_weightController.text) ?? 0,
      infos: [patientInfo],
    );

    final success = await updatePatientInfo(patient);

    if (success) {
      setState(() {
        _isEditMode = false; // 수정 모드 종료
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장되었습니다.')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장에 실패했습니다.')));
    }
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
              enabled: _isEditMode,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.black),
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

  Widget _buildTextInputRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
      child: TextField(
        controller: controller,
        enabled: _isEditMode,
        decoration: InputDecoration(
          labelText: label,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownRow(
    String label,
    List<String> options,
    String? value,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: _isEditMode ? onChanged : null,
        isExpanded: true,
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
                    child: Text(option, style: const TextStyle(fontSize: 14)),
                  ),
                )
                .toList(),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _fallCountController.dispose();
    _bathroomFallCountController.dispose();
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
        title: const Text('환자 정보 조회'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() => _isEditMode = true);
                  },
                  child: const Text(
                    '수정하기',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildInputRow('나이', _ageController, '세'),
              _buildInputRow('키', _heightController, 'cm'),
              _buildInputRow('체중', _weightController, 'kg'),
              _buildInputRow('낙상 경험 횟수', _fallCountController, '번'),
              _buildInputRow('욕창 경험 횟수', _bathroomFallCountController, '번'),
              _buildTextInputRow('질병 입력', _diseaseController),
              _buildDropdownRow(
                '질병의 중증도',
                _severityOptions,
                _selectedSeverity,
                (v) => setState(() => _selectedSeverity = v),
              ),
              _buildDropdownRow(
                '하루 평균 운동 시간',
                _exerciseTimeOptions,
                _selectedExerciseTime,
                (v) => setState(() => _selectedExerciseTime = v),
              ),
              _buildDropdownRow(
                '현재 거동 상태',
                _mobilityOptions,
                _selectedMobility,
                (v) => setState(() => _selectedMobility = v),
              ),
              _buildTextInputRow('복용 중인 약 입력', _medicationController),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          _isEditMode
              ? SizedBox(
                height: buttonHeight,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePatientInfo,
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
                    '저장하기',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
              )
              : null,
    );
  }
}
