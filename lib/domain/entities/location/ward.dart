class Ward {
  final int id;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
  final int? districtId;

  const Ward({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.isActive = true,
    this.districtId,
  });

  factory Ward.fromMap(Map<String, dynamic> json) {
    return Ward(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      districtId: json['districtId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'isActive': isActive,
      'districtId': districtId,
    };
  }

  @override
  String toString() {
    return 'Ward(id: $id, code: $code, name: $name)';
  }
} 