// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BusinessType {
  final int id;
  final String? code;
  final String? label;
  final String? description;
  final bool? active;
  final bool? isDeleted;
  BusinessType({
    required this.id,
    this.code,
    this.label,
    this.description,
    this.active,
    this.isDeleted,
  });

  BusinessType copyWith({
    int? id,
    String? code,
    String? label,
    String? description,
    bool? active,
    bool? isDeleted,
  }) {
    return BusinessType(
      id: id ?? this.id,
      code: code ?? this.code,
      label: label ?? this.label,
      description: description ?? this.description,
      active: active ?? this.active,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'label': label,
      'description': description,
      'active': active,
      'isDeleted': isDeleted,
    };
  }

  factory BusinessType.fromMap(Map<String, dynamic> map) {
    return BusinessType(
      id: map['id'] as int,
      code: map['code'] != null ? map['code'] as String : null,
      label: map['label'] != null ? map['label'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      active: map['active'] != null ? map['active'] as bool : null,
      isDeleted: map['isDeleted'] != null ? map['isDeleted'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessType.fromJson(String source) =>
      BusinessType.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BusinessType(id: $id, code: $code, label: $label, description: $description, active: $active, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(covariant BusinessType other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.code == code &&
        other.label == label &&
        other.description == description &&
        other.active == active &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        code.hashCode ^
        label.hashCode ^
        description.hashCode ^
        active.hashCode ^
        isDeleted.hashCode;
  }
}
