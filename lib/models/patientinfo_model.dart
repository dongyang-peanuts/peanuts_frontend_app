class Patient {
  final String paName;
  final String paAddr;
  final int paAge;
  final int paHei;
  final int paWei;
  final List<PatientInfo> infos;

  Patient({
    required this.paName,
    required this.paAddr,
    required this.paAge,
    required this.paHei,
    required this.paWei,
    required this.infos,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    var infosFromJson = json['infos'] as List<dynamic>? ?? [];
    List<PatientInfo> infoList =
        infosFromJson.map((info) => PatientInfo.fromJson(info)).toList();

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return 0;
    }

    return Patient(
      paName: json['paName'] ?? '',
      paAddr: json['paAddr'] ?? '',
      paAge: parseInt(json['paAge']),
      paHei: parseInt(json['paHei']),
      paWei: parseInt(json['paWei']),
      infos: infoList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paName': paName,
      'paAddr': paAddr,
      'paAge': paAge,
      'paHei': paHei,
      'paWei': paWei,
      'infos': infos.map((e) => e.toJson()).toList(),
    };
  }
}

class PatientInfo {
  final int paFact;
  final int paPrct;
  final String paDi;
  final String paDise;
  final String paExti;
  final String paBest;
  final String paMedi;

  PatientInfo({
    required this.paFact,
    required this.paPrct,
    required this.paDi,
    required this.paDise,
    required this.paExti,
    required this.paBest,
    required this.paMedi,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return 0;
    }

    return PatientInfo(
      paFact: parseInt(json['paFact']),
      paPrct: parseInt(json['paPrct']),
      paDi: json['paDi'] ?? '',
      paDise: json['paDise'] ?? '',
      paExti: json['paExti'] ?? '',
      paBest: json['paBest'] ?? '',
      paMedi: json['paMedi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paFact': paFact,
      'paPrct': paPrct,
      'paDi': paDi,
      'paDise': paDise,
      'paExti': paExti,
      'paBest': paBest,
      'paMedi': paMedi,
    };
  }
}
