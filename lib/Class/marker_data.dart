import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MarkerInfo {
  final String id;
  final NLatLng position;
  final String address;
  final String infoWindowText;

  MarkerInfo({
    required this.id,
    required this.position,
    required this.address,
    required this.infoWindowText,
  });

  NMarker toNMarker() {
    return NMarker(
      id: id,
      position: position,
      size: NSize(30, 30),
      icon: NOverlayImage.fromAssetImage('assets/images/medicine.png'),
    );
  }

  static double convertToDecimal(double rawCoordinate) {
    return rawCoordinate / 10000000.0;
  }

  static String stripHtmlTags(String html) {
    final RegExp exp = RegExp(r'<[^>]*>');
    return html.replaceAll(exp, '');
  }

  static Future<List<MarkerInfo>> fetchMarkersFromNaver(String query) async {
    final apiKey = 'Wy_IbBpAVX1M1HSZPIXP'; // Naver API Key 입력
    final secretKey = '9nhy7rF28p'; // Naver Client Secret 입력
    final encodedQuery = Uri.encodeComponent('$query 종합병원');
    List<MarkerInfo> allMarkers = [];

    for (int start = 1; start <= 100; start += 50) {
      final url =
          "https://openapi.naver.com/v1/search/local.json?query=$encodedQuery&display=50&start=$start";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Naver-Client-Id': apiKey,
          'X-Naver-Client-Secret': secretKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        if (items.isEmpty) break;

        allMarkers.addAll(items.map((item) {
          final mapx = item['mapx'] as String?;
          final mapy = item['mapy'] as String?;
          final title = item['title'] as String? ?? '';

          double latitude = 0.0;
          double longitude = 0.0;

          if (mapx != null && mapy != null) {
            longitude =
                MarkerInfo.convertToDecimal(double.tryParse(mapx) ?? 0.0);
            latitude =
                MarkerInfo.convertToDecimal(double.tryParse(mapy) ?? 0.0);
          }

          return MarkerInfo(
            id: MarkerInfo.stripHtmlTags(title),
            position: NLatLng(latitude, longitude),
            address: item['address'] ?? '',
            infoWindowText: MarkerInfo.stripHtmlTags(title),
          );
        }));
      } else {
        throw Exception('API 오류 발생: ${response.statusCode}');
      }
    }

    return allMarkers;
  }
}

Future<List<MarkerInfo>> getMarkers(String city, String borough) async {
  try {
    final query = '$city $borough'; // 예: 서울 강남구
    return await MarkerInfo.fetchMarkersFromNaver(query);
  } catch (e) {
    print('오류 발생: $e');
    return [];
  }
}
