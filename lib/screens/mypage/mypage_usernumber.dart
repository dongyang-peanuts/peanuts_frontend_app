import 'package:flutter/material.dart';
import 'package:dangkong_app/services/user_number.dart';

class MypageUserNumber extends StatefulWidget {
  const MypageUserNumber({Key? key}) : super(key: key);

  @override
  State<MypageUserNumber> createState() => _MypageUserNumberState();
}

class _MypageUserNumberState extends State<MypageUserNumber> {
  final TextEditingController _newNumberController = TextEditingController();

  // 현재 연결된 전화번호는 예시로 고정값 사용
  final String currentNumber = '010-1234-5678';

  @override
  void dispose() {
    _newNumberController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final newNumber = _newNumberController.text.trim();

    if (newNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('변경할 전화번호를 입력해주세요.')));
      return;
    }

    final success = await newUserNumber(UserNumber(newUserNumber: newNumber));

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('전화번호가 성공적으로 변경되었습니다.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전화번호 변경에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonHeight = screenWidth * (83 / 412);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('비상연락망 변경', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '긴급 상황 시\n연락될 번호를 변경합니다.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text('현재 연결된 전화번호', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: currentNumber),
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('새로 변경할 번호', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _newNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '새로 변경할 전화번호를 입력해주세요',
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF99BC85),
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: const Text(
            '저장하기',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
