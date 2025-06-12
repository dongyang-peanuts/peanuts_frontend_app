import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> NewUserPassword(UserPassword userPassword) async {
  final prefs = await SharedPreferences.getInstance();
  final userKey = prefs.getInt('userKey');

  if (userKey == null) {
    print('❌ userKey가 없습니다.');
    return false;
  }

  final url = Uri.parse('http://kongback.kro.kr:8080/user/$userKey/password');

  final response = await http.patch(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(userPassword.toJson()),
  );

  if (response.statusCode == 200) {
    print('✅ 비밀번호 변경 성공');
    return true;
  } else {
    print('❌ 비밀번호 변경 실패: ${response.statusCode} / ${response.body}');
    return false;
  }
}

class UserPassword {
  final String currentPwd;
  final String newPwd;

  UserPassword({required this.currentPwd, required this.newPwd});

  Map<String, dynamic> toJson() {
    return {'currentPwd': currentPwd, 'newPwd': newPwd};
  }
}
