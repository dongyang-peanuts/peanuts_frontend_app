import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MarkerInfo {
  final String id;
  final NLatLng position;
  final String address;
  final String infoWindowText;
  final String phone;
  final String category;

  late NMarker marker; // 마커 저장
  bool isSelected = false;

  MarkerInfo({
    required this.id,
    required this.position,
    required this.address,
    required this.infoWindowText,
    required this.phone,
    required this.category,
  });

  NMarker toNMarker(void Function(String) onTapMarker) {
    marker = NMarker(
      id: id,
      position: position,
      size: NSize(30, 30),
      icon: NOverlayImage.fromAssetImage(
        isSelected
            ? 'assets/images/medicine_selected.png'
            : 'assets/images/medicine.png',
      ),
    );

    marker.setOnTapListener((_) {
      onTapMarker(id);
    });

    return marker;
  }

  void setSelected(bool selected) {
    isSelected = selected;

    marker.setIcon(NOverlayImage.fromAssetImage(
      selected
          ? 'assets/images/medicine_selected.png'
          : 'assets/images/medicine.png',
    ));

    marker.setSize(
      selected ? NSize(50, 60) : NSize(30, 30), // ✅ 클릭되면 50x50으로 확대
    );
  }


  static Future<List<MarkerInfo>> fetchMarkersFromKakao(
      String query,
      double userLat,
      double userLng,
      ) async {
    final apiKey = 'd995bf6fbf5dd156e87868720ada7ed4';
    final encodedQuery = Uri.encodeComponent(query);
    final url =
        'https://dapi.kakao.com/v2/local/search/keyword.json?query=$encodedQuery&x=$userLng&y=$userLat&radius=3000';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'KakaoAK $apiKey'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List documents = data['documents'];
      return documents.map((item) {
        return MarkerInfo(
          id: item['id'],
          position: NLatLng(
            double.parse(item['y']),
            double.parse(item['x']),
          ),
          address: item['road_address_name'] ?? item['address_name'] ?? '',
          infoWindowText: item['place_name'],
          phone: item['phone'] ?? '',
          category: item['category_group_name'] ?? '',
        );
      }).toList();
    } else {
      throw Exception('카카오 API 오류: ${response.body}');
    }
  }
}
