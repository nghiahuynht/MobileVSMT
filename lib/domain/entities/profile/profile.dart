import 'package:trash_pay/domain/entities/user/user.dart';

class ProfileModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;
  final DateTime? joinedAt;
  final bool isActive;
  final Map<String, dynamic>? preferences;

  ProfileModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    this.joinedAt,
    this.isActive = true,
    this.preferences,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      joinedAt: json['joinedAt'] != null 
          ? DateTime.parse(json['joinedAt']) 
          : null,
      isActive: json['isActive'] ?? true,
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'joinedAt': joinedAt?.toIso8601String(),
      'isActive': isActive,
      'preferences': preferences,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    DateTime? joinedAt,
    bool? isActive,
    Map<String, dynamic>? preferences,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
    );
  }
}

// Extension to convert UserModel to ProfileModel
extension UserModelToProfile on UserModel {
  ProfileModel toProfileModel() {
    return ProfileModel(
      id: userId.toString(),
      name: fullName ?? loginName ?? 'Unknown User',
      email: email,
      phone: phone,
      isActive: isActive,
      preferences: {
        'notifications': true,
        'darkMode': false,
        'language': 'vi',
        'autoSync': true,
      },
    );
  }
} 