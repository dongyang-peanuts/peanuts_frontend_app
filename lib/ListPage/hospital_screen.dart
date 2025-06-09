import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Class/marker_data.dart';
import '../Class/location_data.dart';

class HospitalScreen extends StatefulWidget {
  @override
  _HospitalScreenState createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  Position? _currentPosition;
  NaverMapController? _mapController;
  List<MarkerInfo> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  String _defaultKeyword = '보건소';
  String _selectedCategory = '보건소';
  MarkerInfo? _selectedMarker;
  bool _isInfoVisible = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      _currentPosition = await _determinePosition();
      setState(() {});
    } catch (e) {
      print('❌ 위치 오류: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('GPS 꺼짐');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한 거부됨');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void _performSearch([String? customKeyword]) async {
    final keyword = (customKeyword ?? _searchController.text.trim()).isEmpty
        ? _defaultKeyword
        : customKeyword ?? _searchController.text.trim();

    if (_currentPosition == null) return;

    final placemarks = await placemarkFromCoordinates(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    final placemark = placemarks.first;
    final address =
    "${placemark.administrativeArea} ${placemark.locality}".trim();
    final region = getCityAndBoroughFromAddress(address);
    final query = "${region['city']} ${region['borough']} $keyword";

    final markers = await MarkerInfo.fetchMarkersFromKakao(
        query, _currentPosition!.latitude, _currentPosition!.longitude);

    setState(() {
      _searchResults = markers;
      _isInfoVisible = false;
      _selectedMarker = null;
    });

    _updateMapMarkers();
  }

  void _updateMapMarkers() {
    if (_mapController == null) return;

    _mapController!.clearOverlays();

    for (final markerInfo in _searchResults) {
      final marker = markerInfo.toNMarker((String tappedId) {
        setState(() {
          for (var m in _searchResults) {
            m.setSelected(m.id == tappedId); // 클릭한 마커만 선택 상태 true
          }

          _selectedMarker = markerInfo;
          _isInfoVisible = true;

          _mapController!.updateCamera(
            NCameraUpdate.scrollAndZoomTo(
              target: markerInfo.position,
              zoom: 14,
            ),
          );


        });
      });

      _mapController!.addOverlay(marker);
    }
  }


  void _moveCameraToCurrent() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 13,
        ),
      );
    }
  }

  double _calculateDistance(double lat, double lng) {
    if (_currentPosition == null) return 0.0;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    ) /
        1000;
  }

  // ✅ 병원을 출발지로 (도착은 비워짐)
  Future<void> _launchNaverMapWithHospitalAsStart() async {
    if (_selectedMarker == null) return;

    final startLat = _selectedMarker!.position.latitude;
    final startLng = _selectedMarker!.position.longitude;
    final startName = Uri.encodeComponent(_selectedMarker!.infoWindowText);

    final url = Uri.parse(
      'nmap://route/car'
          '?slat=$startLat&slng=$startLng&sname=$startName'
          '&appname=com.dangkong.dangkong_app',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('❌ 네이버 지도 실행 실패: $url');
    }
  }

  // ✅ 병원을 도착지로 (출발은 현재위치)
  Future<void> _launchNaverMapWithHospitalAsDest() async {
    if (_currentPosition == null || _selectedMarker == null) return;

    final startLat = _currentPosition!.latitude;
    final startLng = _currentPosition!.longitude;
    final destLat = _selectedMarker!.position.latitude;
    final destLng = _selectedMarker!.position.longitude;
    final destName = Uri.encodeComponent(_selectedMarker!.infoWindowText);

    final url = Uri.parse(
      'nmap://route/car'
          '?slat=$startLat&slng=$startLng&sname=출발지'
          '&dlat=$destLat&dlng=$destLng&dname=$destName'
          '&appname=com.dangkong.dangkong_app',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('❌ 네이버 지도 실행 실패: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 13,
              ),
              locationButtonEnable: true,
            ),
            onMapReady: (controller) {
              _mapController = controller;
              _moveCameraToCurrent();

            },
          ),
          // 검색창
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            height: 50,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _performSearch,
                      decoration: InputDecoration(
                        hintText: '병원, 보건소 검색',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: Icon(Icons.clear, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
          // 병원 정보 컨테이너
          if (_isInfoVisible && _selectedMarker != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedMarker!.infoWindowText,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isInfoVisible = false;
                              _selectedMarker = null;
                            });
                          },
                        ),
                      ],
                    ),
                    Text(
                      _selectedMarker!.address,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                        if (_selectedMarker!.phone.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              children: [
                                Icon(Icons.phone, size: 18, color: Colors.grey),
                                SizedBox(width: 8),
                                Text(
                                  _selectedMarker!.phone,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),

                    Text(
                      "현재 위치로부터 ${_calculateDistance(_selectedMarker!.position.latitude, _selectedMarker!.position.longitude).toStringAsFixed(2)}km 거리",
                      style: TextStyle(color: Colors.grey[600]),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 32,
                            margin: EdgeInsets.only(right: 8),
                            child: OutlinedButton(
                              onPressed: _launchNaverMapWithHospitalAsStart,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.blueAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(
                                '출발',
                                style: TextStyle(fontSize: 13, color: Colors.blueAccent),
                              ),
                            ),
                          ),
                          Container(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: _launchNaverMapWithHospitalAsDest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(
                                '도착',
                                style: TextStyle(fontSize: 13, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
