class CustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? email;
  final DateTime? createdAt;
  final double? totalSpent;
  final String status; // 'active', 'inactive', 'pending'

  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.email,
    this.createdAt,
    this.totalSpent,
    this.status = 'active',
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      email: json['email'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      totalSpent: json['totalSpent']?.toDouble(),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
      'totalSpent': totalSpent,
      'status': status,
    };
  }
} 