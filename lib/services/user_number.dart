import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserNumber {
  final String newUserNumber;

  UserNumber({required this.newUserNumber});

  Map<String, dynamic> toJson() {
    return {'newUserNumber': newUserNumber};
  }
}

Future<bool> newUserNumber(UserNumber userNumber) async {
  final prefs = await SharedPreferences.getInstance();
  final userKey = prefs.getInt('userKey');

  if (userKey == null) {
    print(' userKey가 존재하지 않습니다. 로그인 상태를 확인하세요.');
    return false;
  }

  final url = Uri.parse('http://kongback.kro.kr:8080/user/$userKey/number');

  final response = await http.patch(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(userNumber.toJson()),
  );

  if (response.statusCode == 200) {
    print('전화번호 업데이트 성공: ${userNumber.newUserNumber}');
    return true;
  } else {
    print('전화번호 업데이트 실패: ${response.statusCode} / ${response.body}');
    return false;
  }
}
