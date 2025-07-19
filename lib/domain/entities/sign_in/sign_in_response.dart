import 'dart:convert';

class SignInResponse {
  final String accessToken;
  final String tokenType;
  final String startedTime;
  final String expiredTime;

  SignInResponse({
    required this.accessToken,
    required this.tokenType,
    required this.startedTime,
    required this.expiredTime,
  });

  SignInResponse copyWith({
    String? accessToken,
    String? tokenType,
    String? startedTime,
    String? expiredTime,
  }) {
    return SignInResponse(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      startedTime: startedTime ?? this.startedTime,
      expiredTime: expiredTime ?? this.expiredTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'tokenType': tokenType,
      'startedTime': startedTime,
      'expiredTime': expiredTime,
    };
  }

  factory SignInResponse.fromMap(Map<String, dynamic> map) {
    return SignInResponse(
      accessToken: map['accessToken'] as String,
      tokenType: map['tokenType'] as String,
      startedTime: map['startedTime'] as String,
      expiredTime: map['expiredTime'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SignInResponse.fromJson(String source) =>
      SignInResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SignInResponse(accessToken: $accessToken, tokenType: $tokenType, startedTime: $startedTime, expiredTime: $expiredTime)';
  }

  @override
  bool operator ==(covariant SignInResponse other) {
    if (identical(this, other)) return true;

    return other.accessToken == accessToken &&
        other.tokenType == tokenType &&
        other.startedTime == startedTime &&
        other.expiredTime == expiredTime;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        tokenType.hashCode ^
        startedTime.hashCode ^
        expiredTime.hashCode;
  }

  /// Kiểm tra token có hết hạn hay không
  bool get isExpired {
    try {
      final expiry = DateTime.parse(expiredTime.replaceAll('/', '-'));
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      // Nếu không parse được thì coi như đã hết hạn
      return true;
    }
  }

  /// Thời gian còn lại trước khi token hết hạn (tính bằng phút)
  int get minutesUntilExpiry {
    try {
      final expiry = DateTime.parse(expiredTime.replaceAll('/', '-'));
      final now = DateTime.now();
      final difference = expiry.difference(now);
      return difference.inMinutes;
    } catch (e) {
      return 0;
    }
  }

  /// Kiểm tra token sắp hết hạn (trong vòng 30 phút)
  bool get isNearExpiry {
    return minutesUntilExpiry <= 30;
  }

  /// Lấy authorization header
  String get authorizationHeader {
    return '$tokenType $accessToken';
  }
}
