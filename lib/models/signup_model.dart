class SignupData {
  // Step 2 - 필수 데이터
  String? userEmail;
  String? userPwd;
  String? userNumber;

  // Step 3 - 필수 데이터
  String? userAddr;

  // Step 4 - 선택 데이터
  int? paAge;
  double? paHei;
  double? paWei;
  int? paFact;
  int? paPrct;

  // Step 5 - 선택 데이터
  String? paDi;
  String? paDise;
  String? paExti;
  String? paBest;
  String? paMedi;

  // 기타 데이터
  String? proNum;

  SignupData({
    this.userEmail,
    this.userPwd,
    this.userNumber,
    this.userAddr,
    this.paAge,
    this.paHei,
    this.paWei,
    this.paFact,
    this.paPrct,
    this.paDi,
    this.paDise,
    this.paExti,
    this.paBest,
    this.paMedi,
    this.proNum,
  });

  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
      'userPwd': userPwd,
      'userNumber': userNumber,
      'userAddr': userAddr,
      'proNum': proNum,
      'patients': [
        {
          'paName': '환자이름', // 필요시 외부에서 받아올 수 있도록 개선 가능
          'paAddr': userAddr,
          'paAge': paAge,
          'paHei': paHei,
          'paWei': paWei,
          'infos': [
            {
              'paFact': paFact,
              'paPrct': paPrct,
              'paDi': paDi,
              'paDise': paDise,
              'paExti': paExti,
              'paBest': paBest,
              'paMedi': paMedi,
            },
          ],
        },
      ],
    };
  }

  bool get isStep2Valid =>
      userEmail != null &&
      userEmail!.isNotEmpty &&
      userPwd != null &&
      userPwd!.isNotEmpty &&
      userNumber != null &&
      userNumber!.isNotEmpty;

  bool get isStep3Valid => userAddr != null && userAddr!.isNotEmpty;

  bool get isRequiredDataComplete => isStep2Valid && isStep3Valid;

  SignupData copyWith({
    String? userEmail,
    String? userPwd,
    String? userNumber,
    String? userAddr,
    int? paAge,
    double? paHei,
    double? paWei,
    int? paFact,
    int? paPrct,
    String? paDi,
    String? paDise,
    String? paExti,
    String? paBest,
    String? paMedi,
    String? proNum,
  }) {
    return SignupData(
      userEmail: userEmail ?? this.userEmail,
      userPwd: userPwd ?? this.userPwd,
      userNumber: userNumber ?? this.userNumber,
      userAddr: userAddr ?? this.userAddr,
      paAge: paAge ?? this.paAge,
      paHei: paHei ?? this.paHei,
      paWei: paWei ?? this.paWei,
      paFact: paFact ?? this.paFact,
      paPrct: paPrct ?? this.paPrct,
      paDi: paDi ?? this.paDi,
      paDise: paDise ?? this.paDise,
      paExti: paExti ?? this.paExti,
      paBest: paBest ?? this.paBest,
      paMedi: paMedi ?? this.paMedi,
      proNum: proNum ?? this.proNum,
    );
  }
}
