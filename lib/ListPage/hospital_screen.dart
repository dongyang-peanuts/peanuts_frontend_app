<<<<<<< HEAD
  import 'package:flutter/material.dart';
  import 'package:flutter_naver_map/flutter_naver_map.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:url_launcher/url_launcher.dart';
  import 'package:dangkong_app/Class/marker_data.dart';
  import 'package:dangkong_app/Class/location_data.dart';

  class HospitalScreen extends StatefulWidget {
    @override
    _HospitalScreenState createState() => _HospitalScreenState();
  }

  class _HospitalScreenState extends State<HospitalScreen> {
    Position? _currentPosition;
    NaverMapController? _mapController;
    String? _selectedCity;
    String? _selectedBorough;
    List<String> _boroughList = [];
    List<MarkerInfo> _filteredMarkers = [];
    List<MarkerInfo> _searchResults = [];
    double _containerHeight = 180.0;
    bool _isExpanded = false;

    @override
    void initState() {
      super.initState();
      _initLocation();
      setState(() {
        _selectedCity = null;
        _selectedBorough = null;
        _boroughList = [];
      });
    }

    Future<void> _initLocation() async {
      try {
        _currentPosition = await _determinePosition();
        setState(() {});
        _filterMarkers();
      } catch (e) {
        print(e);
      }
    }

    void _onCityChanged(String? newCity) {
      if (newCity != null) {
        setState(() {
          _selectedCity = newCity;
          _boroughList = boroughs[_selectedCity] ?? [];
          _selectedBorough = _boroughList.isNotEmpty ? _boroughList[0] : '';
          _filterMarkers();
        });
      }
    }

    void _filterMarkers() async {
      if (_selectedCity != null && _selectedBorough != null) {
        try {
          List<MarkerInfo> markers =
          await MarkerInfo.fetchMarkersFromNaver('$_selectedCity $_selectedBorough');
          setState(() {
            _filteredMarkers = markers;
          });
          if (_mapController != null) {
            _updateMapMarkers();
          }
        } catch (e) {
          print('Error fetching markers: $e');
        }
      } else {
        print('City or Borough is not selected.');
      }
    }

    void _updateMapMarkers() {
      if (_mapController != null) {
        _mapController!.clearOverlays();
        for (var markerInfo in _filteredMarkers) {
          final marker = markerInfo.toNMarker();
          _mapController!.addOverlay(marker);
          final infoWindow = NInfoWindow.onMarker(
            id: marker.info.id,
            text: markerInfo.infoWindowText,
          );
          marker.openInfoWindow(infoWindow);
        }
      }
    }

    void _search() {
      setState(() {
        _searchResults = _filteredMarkers;
      });

      if (_mapController != null && _searchResults.isNotEmpty) {
        final centerLatLng = _searchResults.first.position;
        _mapController!.updateCamera(
          NCameraUpdate.scrollAndZoomTo(target: centerLatLng),
        );
      }
    }

    void _toggleContainer() {
      setState(() {
        _isExpanded = !_isExpanded;
        _containerHeight = _isExpanded ? 400.0 : 180.0;
      });
    }

    Future<void> _launchNavigationForMarker(MarkerInfo marker) async {
      final latitude = marker.position.latitude;
      final longitude = marker.position.longitude;
      final encodedAddress = Uri.encodeComponent(marker.address ?? '');
      final Uri url = Uri.parse(
          'https://map.naver.com/p/directions/-/$latitude,$longitude,$encodedAddress,PLACE_POI/-/transit?c=15.00,0,0,0,dh');
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }

    void _moveCameraToMarker(MarkerInfo marker) {
      if (_mapController != null) {
        _mapController!.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: marker.position,
            zoom: 14.0,
          ),
        );
      }
    }

    Future<Position> _determinePosition() async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return Future.error('Location permissions are denied');
        }
      }

      return await Geolocator.getCurrentPosition();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: _currentPosition == null
                  ? Center(child: CircularProgressIndicator())
                  : NaverMap(
                options: NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    target: NLatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 14.0,
                  ),
                  locationButtonEnable: true,
                ),
                onMapReady: (mapController) {
                  _mapController = mapController;
                  _updateMapMarkers();
                },
                onMapTapped: (point, latLng) {
                  print("${latLng.latitude}, ${latLng.longitude}");
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildDropdown(String? selectedValue, List<String> items, Function(String?) onChanged) {
      return Container(
        margin: EdgeInsets.only(top: 30),
        width: 116,
        height: 36,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.5, color: Color(0xFF939393)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text('선택'),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFF939393)),
          ),
        ),
      );
    }

    Widget _buildSearchButton() {
      return GestureDetector(
        onTap: _search,
        child: Container(
          margin: EdgeInsets.only(top: 30),
          width: 58,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text('검색', style: TextStyle(color: Colors.white, fontSize: 14)),
        ),
      );
    }

    Widget _buildActionButton(String label, VoidCallback onPressed) {
      return Container(
        width: 80,
        height: 31,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.50),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: TextButton(
          onPressed: onPressed,
          child: Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300, color: Colors.black)),
        ),
      );
    }
  }
=======
  import 'package:flutter/material.dart';
  import 'package:flutter_naver_map/flutter_naver_map.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:url_launcher/url_launcher.dart';
  import 'package:dangkong_app/Class/marker_data.dart';
  import 'package:dangkong_app/Class/location_data.dart';

  class HospitalScreen extends StatefulWidget {
    @override
    _HospitalScreenState createState() => _HospitalScreenState();
  }

  class _HospitalScreenState extends State<HospitalScreen> {
    Position? _currentPosition;
    NaverMapController? _mapController;
    String? _selectedCity;
    String? _selectedBorough;
    List<String> _boroughList = [];
    List<MarkerInfo> _filteredMarkers = [];
    List<MarkerInfo> _searchResults = [];
    double _containerHeight = 180.0;
    bool _isExpanded = false;

    @override
    void initState() {
      super.initState();
      _initLocation();
      setState(() {
        _selectedCity = null;
        _selectedBorough = null;
        _boroughList = [];
      });
    }

    Future<void> _initLocation() async {
      try {
        _currentPosition = await _determinePosition();
        setState(() {});
        _filterMarkers();
      } catch (e) {
        print(e);
      }
    }

    void _onCityChanged(String? newCity) {
      if (newCity != null) {
        setState(() {
          _selectedCity = newCity;
          _boroughList = boroughs[_selectedCity] ?? [];
          _selectedBorough = _boroughList.isNotEmpty ? _boroughList[0] : '';
          _filterMarkers();
        });
      }
    }

    void _filterMarkers() async {
      if (_selectedCity != null && _selectedBorough != null) {
        try {
          List<MarkerInfo> markers =
          await MarkerInfo.fetchMarkersFromNaver('$_selectedCity $_selectedBorough');
          setState(() {
            _filteredMarkers = markers;
          });
          if (_mapController != null) {
            _updateMapMarkers();
          }
        } catch (e) {
          print('Error fetching markers: $e');
        }
      } else {
        print('City or Borough is not selected.');
      }
    }

    void _updateMapMarkers() {
      if (_mapController != null) {
        _mapController!.clearOverlays();
        for (var markerInfo in _filteredMarkers) {
          final marker = markerInfo.toNMarker();
          _mapController!.addOverlay(marker);
          final infoWindow = NInfoWindow.onMarker(
            id: marker.info.id,
            text: markerInfo.infoWindowText,
          );
          marker.openInfoWindow(infoWindow);
        }
      }
    }

    void _search() {
      setState(() {
        _searchResults = _filteredMarkers;
      });

      if (_mapController != null && _searchResults.isNotEmpty) {
        final centerLatLng = _searchResults.first.position;
        _mapController!.updateCamera(
          NCameraUpdate.scrollAndZoomTo(target: centerLatLng),
        );
      }
    }

    void _toggleContainer() {
      setState(() {
        _isExpanded = !_isExpanded;
        _containerHeight = _isExpanded ? 400.0 : 180.0;
      });
    }

    Future<void> _launchNavigationForMarker(MarkerInfo marker) async {
      final latitude = marker.position.latitude;
      final longitude = marker.position.longitude;
      final encodedAddress = Uri.encodeComponent(marker.address ?? '');
      final Uri url = Uri.parse(
          'https://map.naver.com/p/directions/-/$latitude,$longitude,$encodedAddress,PLACE_POI/-/transit?c=15.00,0,0,0,dh');
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }

    void _moveCameraToMarker(MarkerInfo marker) {
      if (_mapController != null) {
        _mapController!.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: marker.position,
            zoom: 14.0,
          ),
        );
      }
    }

    Future<Position> _determinePosition() async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return Future.error('Location permissions are denied');
        }
      }

      return await Geolocator.getCurrentPosition();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: _currentPosition == null
                  ? Center(child: CircularProgressIndicator())
                  : NaverMap(
                options: NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    target: NLatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 14.0,
                  ),
                  locationButtonEnable: true,
                ),
                onMapReady: (mapController) {
                  _mapController = mapController;
                  _updateMapMarkers();
                },
                onMapTapped: (point, latLng) {
                  print("${latLng.latitude}, ${latLng.longitude}");
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildDropdown(String? selectedValue, List<String> items, Function(String?) onChanged) {
      return Container(
        margin: EdgeInsets.only(top: 30),
        width: 116,
        height: 36,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.5, color: Color(0xFF939393)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text('선택'),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFF939393)),
          ),
        ),
      );
    }

    Widget _buildSearchButton() {
      return GestureDetector(
        onTap: _search,
        child: Container(
          margin: EdgeInsets.only(top: 30),
          width: 58,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text('검색', style: TextStyle(color: Colors.white, fontSize: 14)),
        ),
      );
    }

    Widget _buildActionButton(String label, VoidCallback onPressed) {
      return Container(
        width: 80,
        height: 31,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.50),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: TextButton(
          onPressed: onPressed,
          child: Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300, color: Colors.black)),
        ),
      );
    }
  }
>>>>>>> 2cc3f3b7039665d13ec68419f046cd64aa6aabc7
