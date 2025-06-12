class LoginModel {
  final String userEmail;
  final String userPwd;

  LoginModel({required this.userEmail, required this.userPwd});

  Map<String, dynamic> toJson() {
    return {'userEmail': userEmail, 'userPwd': userPwd};
  }
}
