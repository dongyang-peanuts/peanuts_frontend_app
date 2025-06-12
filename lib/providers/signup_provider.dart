import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dangkong_app/models/signup_model.dart';

// 회원가입 데이터를 관리하는 StateNotifier
class SignupNotifier extends StateNotifier<SignupData> {
  SignupNotifier() : super(SignupData());

  // Step 2 데이터 업데이트
  void updateStep2Data({
    required String userEmail,
    required String userPwd,
    required String userNumber,
  }) {
    state = state.copyWith(
      userEmail: userEmail,
      userPwd: userPwd,
      userNumber: userNumber,
    );
  }

  // Step 3 데이터 업데이트
  void updateStep3Data({required String userAddr}) {
    state = state.copyWith(userAddr: userAddr);
  }

  // Step 4 데이터 업데이트
  void updateStep4Data({
    int? paAge,
    double? paHei,
    double? paWei,
    int? paFact,
    int? paPrct,
  }) {
    state = state.copyWith(
      paAge: paAge,
      paHei: paHei,
      paWei: paWei,
      paFact: paFact,
      paPrct: paPrct,
    );
  }

  // Step 5 데이터 업데이트
  void updateStep5Data({
    String? paDi,
    String? paDise,
    String? paExti,
    String? paBest,
    String? paMedi,
  }) {
    state = state.copyWith(
      paDi: paDi,
      paDise: paDise,
      paExti: paExti,
      paBest: paBest,
      paMedi: paMedi,
    );
  }

  // 회원가입 API 호출
  Future<bool> submitSignup() async {
    if (!state.isRequiredDataComplete) {
      throw Exception('필수 정보가 누락되었습니다.');
    }

    try {
      final response = await http.post(
        Uri.parse('http://kongback.kro.kr:8080/user/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(state.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 성공시 데이터 초기화
        state = SignupData();
        return true;
      } else {
        throw Exception('회원가입 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 데이터 초기화
  void clearData() {
    state = SignupData();
  }
}

// Provider 정의
final signupProvider = StateNotifierProvider<SignupNotifier, SignupData>(
  (ref) => SignupNotifier(),
);

// 로딩 상태 관리를 위한 Provider
final signupLoadingProvider = StateProvider<bool>((ref) => false);
