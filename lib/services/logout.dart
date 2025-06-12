import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LogoutService {
  static Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');

    if (userEmail == null || userEmail.isEmpty) return false;

    final encodedEmail = Uri.encodeComponent(userEmail);
    final url = Uri.parse(
      'http://kongback.kro.kr:8080/user/logout/$encodedEmail',
    );

    final response = await http.post(url);

    if (response.statusCode == 200) {
      await prefs.remove('userEmail');
      await prefs.remove('userKey');
      print('로그아웃 성공: $userEmail');
      return true;
    } else {
      return false;
    }
  }
}
