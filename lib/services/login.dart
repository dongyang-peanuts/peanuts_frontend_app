import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dangkong_app/models/login_model.dart';

Future<bool> login(LoginModel loginData) async {
  final url = Uri.parse('http://kongback.kro.kr:8080/user/login');

  print('로그인 시도 - 이메일: ${loginData.userEmail}');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(loginData.toJson()),
  );

  if (response.statusCode == 200) {
    print('로그인 성공: ${response.body}');

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', loginData.userEmail);
    await prefs.setInt('userKey', responseData['userKey']);

    print('저장된 이메일: ${loginData.userEmail}');
    print('저장된 유저 키: ${responseData['userKey']}');

    return true;
  } else {
    print('로그인 실패: ${response.statusCode} - ${response.body}');
    return false;
  }
}
