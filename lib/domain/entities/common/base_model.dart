// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BaseModel {
  final int id;
  BaseModel({
    required this.id,
  });

  BaseModel copyWith({
    int? id,
  }) {
    return BaseModel(
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
    };
  }

  factory BaseModel.fromMap(Map<String, dynamic> map) {
    return BaseModel(
      id: map['id'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory BaseModel.fromJson(String source) =>
      BaseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'BaseModel(id: $id)';

  @override
  bool operator ==(covariant BaseModel other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
