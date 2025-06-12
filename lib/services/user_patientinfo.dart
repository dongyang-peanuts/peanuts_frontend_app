import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dangkong_app/models/patientinfo_model.dart';

Future<List<Patient>> getPatients() async {
  final prefs = await SharedPreferences.getInstance();
  final userKey = prefs.getInt('userKey');

  if (userKey == null) {
    print('❌ userKey가 없습니다.');
    return [];
  }

  final url = Uri.parse('http://kongback.kro.kr:8080/user/$userKey/patients');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Patient.fromJson(e)).toList();
    } else {
      print('❌ 환자 정보 조회 실패: ${response.statusCode} / ${response.body}');
      return [];
    }
  } catch (e) {
    print('❌ 네트워크 오류: $e');
    return [];
  }
}
