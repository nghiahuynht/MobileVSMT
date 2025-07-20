class CustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? email;
  final DateTime? createdAt;
  final double? totalSpent;
  final String status; // 'active', 'inactive', 'pending'
  
  // New fields for location and customer group
  final int? wardId;
  final String? wardName;
  final int? groupId;
  final String? groupName;
  final int? areaId;
  final String? areaName;
  final String? customerGroup; // 'regular', 'vip', 'premium'
  final double? price; // Giá tiền dịch vụ

  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.email,
    this.createdAt,
    this.totalSpent,
    this.status = 'active',
    this.wardId,
    this.wardName,
    this.groupId,
    this.groupName,
    this.areaId,
    this.areaName,
    this.customerGroup,
    this.price,
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
      wardId: json['wardId'],
      wardName: json['wardName'],
      groupId: json['groupId'],
      groupName: json['groupName'],
      areaId: json['areaId'],
      areaName: json['areaName'],
      customerGroup: json['customerGroup'],
      price: json['price']?.toDouble(),
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
      'wardId': wardId,
      'wardName': wardName,
      'groupId': groupId,
      'groupName': groupName,
      'areaId': areaId,
      'areaName': areaName,
      'customerGroup': customerGroup,
      'price': price,
    };
  }
} 