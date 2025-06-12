import 'package:flutter/material.dart';
import 'package:dangkong_app/services/user_pwd.dart';

class MypageUserPwd extends StatefulWidget {
  const MypageUserPwd({Key? key}) : super(key: key);

  @override
  State<MypageUserPwd> createState() => _MypageUserPwdState();
}

class _MypageUserPwdState extends State<MypageUserPwd> {
  final TextEditingController _currentPwdController = TextEditingController();
  final TextEditingController _newPwdController = TextEditingController();

  @override
  void dispose() {
    _currentPwdController.dispose();
    _newPwdController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final currentPwd = _currentPwdController.text.trim();
    final newPwd = _newPwdController.text.trim();

    if (currentPwd.isEmpty || newPwd.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
      return;
    }

    final success = await NewUserPassword(
      UserPassword(currentPwd: currentPwd, newPwd: newPwd),
    );

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호 변경에 실패했습니다. 다시 시도해주세요.')),
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
        title: const Text('비밀번호 변경', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey,
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
                '현재 비밀번호와\n새 비밀번호를 입력해주세요.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text('현재 비밀번호', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _currentPwdController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '현재 비밀번호를 입력하세요',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('새 비밀번호', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _newPwdController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '새 비밀번호를 입력하세요',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
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
