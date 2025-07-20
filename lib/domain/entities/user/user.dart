// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final int userId;
  final String? code;
  final String? loginName;
  final String? fullName;
  final String? email;
  final String? phone;
  final bool isActive;
  final String? roleCode;
  final String? coreRoles;

  UserModel({
    required this.userId,
    this.code,
    this.loginName,
    this.fullName,
    this.email,
    this.phone,
    required this.isActive,
    this.roleCode,
    this.coreRoles,
  });

  UserModel copyWith({
    int? userId,
    String? code,
    String? loginName,
    String? fullName,
    String? email,
    String? phone,
    bool? isActive,
    String? roleCode,
    String? coreRoles,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      code: code ?? this.code,
      loginName: loginName ?? this.loginName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      roleCode: roleCode ?? this.roleCode,
      coreRoles: coreRoles ?? this.coreRoles,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'code': code,
      'loginName': loginName,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'isActive': isActive,
      'roleCode': roleCode,
      'coreRoles': coreRoles,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] as int,
      code: map['code'] != null ? map['code'] as String : null,
      loginName: map['loginName'] != null ? map['loginName'] as String : null,
      fullName: map['fullName'] != null ? map['fullName'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      isActive: map['isActive'] as bool,
      roleCode: map['roleCode'] != null ? map['roleCode'] as String : null,
      coreRoles: map['coreRoles'] != null ? map['coreRoles'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source)['data'] as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(userId: $userId, code: $code, loginName: $loginName, fullName: $fullName, email: $email, phone: $phone, isActive: $isActive, roleCode: $roleCode, coreRoles: $coreRoles)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.userId == userId &&
      other.code == code &&
      other.loginName == loginName &&
      other.fullName == fullName &&
      other.email == email &&
      other.phone == phone &&
      other.isActive == isActive &&
      other.roleCode == roleCode &&
      other.coreRoles == coreRoles;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
      code.hashCode ^
      loginName.hashCode ^
      fullName.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      isActive.hashCode ^
      roleCode.hashCode ^
      coreRoles.hashCode;
  }
}
