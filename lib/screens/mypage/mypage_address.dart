import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dangkong_app/services/user_address.dart';

class AddressResult {
  final String roadAddress;
  final String jibunAddress;
  final double x;
  final double y;

  AddressResult({
    required this.roadAddress,
    required this.jibunAddress,
    required this.x,
    required this.y,
  });
}

class MypageAddress extends StatefulWidget {
  const MypageAddress({Key? key}) : super(key: key);

  @override
  State<MypageAddress> createState() => _MypageAddressState();
}

class _MypageAddressState extends State<MypageAddress> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();

  List<AddressResult> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;
  String _selectedAddress = '';
  int? _userKey;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_onAddressChanged);
    _addressFocusNode.addListener(_onFocusChanged);
    _loadUserKey();
  }

  Future<void> _loadUserKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userKey = prefs.getInt('userKey');
    });
  }

  @override
  void dispose() {
    _addressController.removeListener(_onAddressChanged);
    _addressController.dispose();
    _detailController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_addressFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showResults = false;
          });
        }
      });
    }
  }

  void _onAddressChanged() {
    final query = _addressController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _showResults = false;
      });
      return;
    }
    if (query.length >= 2) {
      _searchAddress(query);
    }
  }

  Future<void> _searchAddress(String query) async {
    if (_isSearching) return;

    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://dapi.kakao.com/v2/local/search/address.json?query=${Uri.encodeQueryComponent(query)}',
        ),
        headers: {'Authorization': 'KakaoAK 43c5bbef9d62c3193c7287eeae4d2e3e'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> documents = data['documents'] ?? [];

        // 중복 제거 (좌표 기준)
        final uniqueResults = <String, AddressResult>{};
        for (var doc in documents) {
          final roadAddr = doc['road_address']?['address_name'] ?? '';
          final jibunAddr = doc['address_name'] ?? '';
          final x = doc['x'];
          final y = doc['y'];
          final key = '$x,$y';
          if (!uniqueResults.containsKey(key)) {
            uniqueResults[key] = AddressResult(
              roadAddress: roadAddr.isNotEmpty ? roadAddr : jibunAddr,
              jibunAddress: jibunAddr,
              x: double.tryParse(x ?? '0') ?? 0.0,
              y: double.tryParse(y ?? '0') ?? 0.0,
            );
          }
        }

        setState(() {
          _searchResults = uniqueResults.values.toList();
        });
      } else {
        setState(() {
          _searchResults.clear();
        });
      }
    } catch (e) {
      setState(() {
        _searchResults.clear();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _selectAddress(AddressResult address) {
    setState(() {
      _selectedAddress = address.roadAddress;
      _addressController.text = address.roadAddress;
      _showResults = false;
    });
    FocusScope.of(context).nextFocus();
  }

  Future<void> _onSavePressed() async {
    if (_userKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보가 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    final fullAddress =
        _selectedAddress.isNotEmpty
            ? _selectedAddress
            : _addressController.text;
    final detailAddress = _detailController.text.trim();

    if (fullAddress.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('주소를 입력해주세요.')));
      return;
    }

    final completeAddress =
        detailAddress.isNotEmpty ? '$fullAddress $detailAddress' : fullAddress;
    final service = UserAddressService(userKey: _userKey!);
    final success = await service.updateAddress(completeAddress);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('주소가 변경되었습니다.')));
      Navigator.pop(context, completeAddress);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('주소 변경에 실패했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonHeight = screenWidth * (83 / 412);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 수정'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset),
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '주소를 입력해주세요.\n인근 병원을 안내할 때 사용됩니다.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  '주소',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _addressController,
                    focusNode: _addressFocusNode,
                    decoration: InputDecoration(
                      hintText: '도로명 주소 또는 지번으로 검색해주세요',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      suffixIcon:
                          _isSearching
                              ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                              : const Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
                if (_showResults && _searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 200,
                    child: ListView.separated(
                      itemCount: _searchResults.length,
                      separatorBuilder:
                          (context, index) =>
                              Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final address = _searchResults[index];
                        return ListTile(
                          title: Text(
                            address.roadAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            address.jibunAddress,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          onTap: () => _selectAddress(address),
                        );
                      },
                    ),
                  ),
                if (_selectedAddress.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    '상세주소',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _detailController,
                      decoration: InputDecoration(
                        hintText: '상세주소를 입력해주세요.',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: buttonHeight,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _onSavePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
          ),
          child: const Text(
            '수정하기',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
      ),
    );
  }
}
