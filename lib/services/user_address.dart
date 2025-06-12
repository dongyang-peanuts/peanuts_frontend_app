import 'dart:convert';
import 'package:http/http.dart' as http;

class UserAddressService {
  final int userKey;
  final Map<String, String> headers;

  UserAddressService({required this.userKey, Map<String, String>? headers})
    : headers = headers ?? {'Content-Type': 'application/json'};

  /// 주소 업데이트
  Future<bool> updateAddress(String address) async {
    final url = Uri.parse('http://kongback.kro.kr:8080/user/address/$userKey');

    final body = jsonEncode({'address': address});

    try {
      final response = await http.patch(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('주소 업데이트 성공 $address');
        return true;
      } else {
        print('Failed to update address: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }
}
