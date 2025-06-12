import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dangkong_app/providers/signup_provider.dart';

import 'package:dangkong_app/screens/auth/signup_step4.dart';

class SignupStep3 extends ConsumerStatefulWidget {
  final Function(String fullAddress, String detailAddress)? onAddressSelected;

  const SignupStep3({Key? key, this.onAddressSelected}) : super(key: key);

  @override
  ConsumerState<SignupStep3> createState() => _AddressSearchWidgetState();
}

class _AddressSearchWidgetState extends ConsumerState<SignupStep3> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();

  List<AddressResult> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_onAddressChanged);
    _addressFocusNode.addListener(_onFocusChanged);
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
          'https://dapi.kakao.com/v2/local/search/keyword.json?query=$query',
        ),
        headers: {
          'Authorization': 'KakaoAK 43c5bbef9d62c3193c7287eeae4d2e3e', //카카오키키
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> documents = data['documents'] ?? [];

        setState(() {
          _searchResults =
              documents.map((doc) {
                final roadAddr = doc['road_address_name'] ?? '';
                final jibunAddr = doc['address_name'] ?? '';
                final x = double.tryParse(doc['x'] ?? '0') ?? 0.0;
                final y = double.tryParse(doc['y'] ?? '0') ?? 0.0;

                return AddressResult(
                  roadAddress: roadAddr.isNotEmpty ? roadAddr : jibunAddr,
                  jibunAddress: jibunAddr,
                  x: x,
                  y: y,
                );
              }).toList();
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

  void _onNextPressed() {
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

    ref
        .read(signupProvider.notifier)
        .updateStep3Data(userAddr: completeAddress);

    widget.onAddressSelected?.call(fullAddress, detailAddress);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupStep4()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonHeight = screenWidth * (83 / 412);
    return Scaffold(
      appBar: AppBar(
        title: const Text('이메일로 회원가입'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(padding: const EdgeInsets.only(right: 16.0), child: Center()),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
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
                    ),

                  if (_selectedAddress.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      '상세주소',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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

          Container(
            height: buttonHeight,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 0,
              ),
              child: const Text(
                '다음',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 주소 검색 결과 모델 클래스
class AddressResult {
  final String roadAddress;
  final String jibunAddress;
  final double x; // 경도
  final double y; // 위도

  AddressResult({
    required this.roadAddress,
    required this.jibunAddress,
    required this.x,
    required this.y,
  });

  factory AddressResult.fromJson(Map<String, dynamic> json) {
    return AddressResult(
      roadAddress: json['roadAddress'] ?? '',
      jibunAddress: json['jibunAddress'] ?? '',
      x: double.tryParse(json['x']?.toString() ?? '0') ?? 0.0,
      y: double.tryParse(json['y']?.toString() ?? '0') ?? 0.0,
    );
  }
}
