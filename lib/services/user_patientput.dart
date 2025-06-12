import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dangkong_app/models/patientinfo_model.dart';

Future<bool> updatePatientInfo(Patient patient) async {
  final prefs = await SharedPreferences.getInstance();
  final userKey = prefs.getInt('userKey');

  if (userKey == null) {
    print('❌ userKey가 없습니다.');
    return false;
  }

  final url = Uri.parse('http://kongback.kro.kr:8080/user/$userKey/patients');

  try {
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode([patient.toJson()]),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('환자 정보 수정 성공: ${response.statusCode}');
      // 성공 처리
      return true;
    } else {
      print('환자 정보 수정 실패: ${response.statusCode} / ${response.body}');
      return false;
    }
  } catch (e) {
    print('네트워크 오류: $e');
    return false;
  }
}
