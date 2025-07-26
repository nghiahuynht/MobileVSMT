// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:trash_pay/utils/extension.dart';
import 'package:trash_pay/domain/entities/common/base_model.dart';

class CustomerModel extends BaseModel {
  final String? code;
  final String? name;
  final String? provinceCode;
  final String? districtCode;
  final String? wardCode;
  final String? phone;
  final String? address;
  final String? description;
  final String? bankName;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final num? price;
  final String? taxCode;
  final String? taxAddress;
  final String? payerName;
  final String? agencyName;
  final num? oldPrice;
  final num? currentPrice;
  final String? customerGroupCode;
  final String? customerGroupName;
  final bool isDeleted;
  final String? areaSaleCode;
  final String? areaSaleName;
  final String? routeSaleCode;
  final String? routeSaleName;
  final String? saleUserCode;
  final String? saleName;
  final String? createdBy;
  final DateTime? createdDate;
  final String? updatedBy;
  final DateTime? updatedDate;
  CustomerModel({
    required int id,
    this.code,
    this.name,
    this.provinceCode,
    this.districtCode,
    this.wardCode,
    this.phone,
    this.address,
    this.description,
    this.bankName,
    this.bankAccountName,
    this.bankAccountNumber,
    this.price,
    this.taxCode,
    this.taxAddress,
    this.payerName,
    this.agencyName,
    this.oldPrice,
    this.currentPrice,
    this.customerGroupCode,
    this.customerGroupName,
    this.isDeleted = false,
    this.areaSaleCode,
    this.areaSaleName,
    this.routeSaleCode,
    this.routeSaleName,
    this.saleUserCode,
    this.saleName,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  }) : super(id: id);


  CustomerModel copyWith({
    int? id,
    String? code,
    String? name,
    String? provinceCode,
    String? districtCode,
    String? wardCode,
    String? phone,
    String? address,
    String? description,
    String? bankName,
    String? bankAccountName,
    String? bankAccountNumber,
    double? price,
    String? taxCode,
    String? taxAddress,
    String? payerName,
    String? agencyName,
    double? oldPrice,
    double? currentPrice,
    String? customerGroupCode,
    String? customerGroupName,
    bool? isDeleted,
    String? areaSaleCode,
    String? areaSaleName,
    String? routeSaleCode,
    String? routeSaleName,
    String? saleUserCode,
    String? saleName,
    String? createdBy,
    DateTime? createdDate,
    String? updatedBy,
    DateTime? updatedDate,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      provinceCode: provinceCode ?? this.provinceCode,
      districtCode: districtCode ?? this.districtCode,
      wardCode: wardCode ?? this.wardCode,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      description: description ?? this.description,
      bankName: bankName ?? this.bankName,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      price: price ?? this.price,
      taxCode: taxCode ?? this.taxCode,
      taxAddress: taxAddress ?? this.taxAddress,
      payerName: payerName ?? this.payerName,
      agencyName: agencyName ?? this.agencyName,
      oldPrice: oldPrice ?? this.oldPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      customerGroupCode: customerGroupCode ?? this.customerGroupCode,
      customerGroupName: customerGroupName ?? this.customerGroupName,
      isDeleted: isDeleted ?? this.isDeleted,
      areaSaleCode: areaSaleCode ?? this.areaSaleCode,
      areaSaleName: areaSaleName ?? this.areaSaleName,
      routeSaleCode: routeSaleCode ?? this.routeSaleCode,
      routeSaleName: routeSaleName ?? this.routeSaleName,
      saleUserCode: saleUserCode ?? this.saleUserCode,
      saleName: saleName ?? this.saleName,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  Map<String, dynamic> toMap({
    bool isCreate = false,
  }) {
    return <String, dynamic>{
      if (!isCreate) 'id': id,
      if (!isCreate) 'code': code,
      'name': name,
      'provinceCode': provinceCode,
      'districtCode': districtCode,
      'wardCode': wardCode,
      'phone': phone,
      'address': address,
      'description': description,
      'bankName': bankName,
      'bankAccountName': bankAccountName,
      'bankAccountNumber': bankAccountNumber,
      'price': price,
      'taxCode': taxCode,
      'taxAddress': taxAddress,
      'payerName': payerName,
      'agencyName': agencyName,
      'oldPrice': oldPrice,
      'currentPrice': currentPrice,
      'customerGroupCode': customerGroupCode,
      'customerGroupName': customerGroupName,
      'isDeleted': isDeleted,
      'areaSaleCode': areaSaleCode,
      'areaSaleName': areaSaleName,
      'routeSaleCode': routeSaleCode,
      'routeSaleName': routeSaleName,
      'saleUserCode': saleUserCode,
      'saleName': saleName,
      'createdBy': createdBy,
      'createdDate': createdDate?.getDateString(),
      'updatedBy': updatedBy,
      'updatedDate': updatedDate?.getDateString(),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as int,
      code: map['code'] != null ? map['code'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      provinceCode: map['provinceCode'] != null ? map['provinceCode'] as String : null,
      districtCode: map['districtCode'] != null ? map['districtCode'] as String : null,
      wardCode: map['wardCode'] != null ? map['wardCode'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      description: map['description'] != null ? map['description'] as String : null,
      bankName: map['bankName'] != null ? map['bankName'] as String : null,
      bankAccountName: map['bankAccountName'] != null ? map['bankAccountName'] as String : null,
      bankAccountNumber: map['bankAccountNumber'] != null ? map['bankAccountNumber'] as String : null,
      price: map['price'] != null ? map['price'] as num : null,
      taxCode: map['taxCode'] != null ? map['taxCode'] as String : null,
      taxAddress: map['taxAddress'] != null ? map['taxAddress'] as String : null,
      payerName: map['payerName'] != null ? map['payerName'] as String : null,
      agencyName: map['agencyName'] != null ? map['agencyName'] as String : null,
      oldPrice: map['oldPrice'] != null ? map['oldPrice'] as num : null,
      currentPrice: map['currentPrice'] != null ? map['currentPrice'] as num : null,
      customerGroupCode: map['customerGroupCode'] != null ? map['customerGroupCode'] as String : null,
      customerGroupName: map['customerGroupName'] != null ? map['customerGroupName'] as String : null,
      isDeleted: map['isDeleted'] as bool,
      areaSaleCode: map['areaSaleCode'] != null ? map['areaSaleCode'] as String : null,
      areaSaleName: map['areaSaleName'] != null ? map['areaSaleName'] as String : null,
      routeSaleCode: map['routeSaleCode'] != null ? map['routeSaleCode'] as String : null,
      routeSaleName: map['routeSaleName'] != null ? map['routeSaleName'] as String : null,
      saleUserCode: map['saleUserCode'] != null ? map['saleUserCode'] as String : null,
      saleName: map['saleName'] != null ? map['saleName'] as String : null,
      createdBy: map['createdBy'] != null ? map['createdBy'] as String : null,
      createdDate: map['createdDate'] != null ? DateTime.tryParse(map['createdDate'] as String) : null,
      updatedBy: map['updatedBy'] != null ? map['updatedBy'] as String : null,
      updatedDate: map['updatedDate'] != null ? DateTime.tryParse(map['updatedDate'] as String) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomerModel.fromJson(String source) => CustomerModel.fromMap(json.decode(source)['data'] as Map<String, dynamic>);

  @override
  String toString() {
    return 'CustomerModel(id: $id, code: $code, name: $name, provinceCode: $provinceCode, districtCode: $districtCode, wardCode: $wardCode, phone: $phone, address: $address, description: $description, bankName: $bankName, bankAccountName: $bankAccountName, bankAccountNumber: $bankAccountNumber, price: $price, taxCode: $taxCode, taxAddress: $taxAddress, payerName: $payerName, agencyName: $agencyName, oldPrice: $oldPrice, currentPrice: $currentPrice, customerGroupCode: $customerGroupCode, customerGroupName: $customerGroupName, isDeleted: $isDeleted, areaSaleCode: $areaSaleCode, areaSaleName: $areaSaleName, routeSaleCode: $routeSaleCode, routeSaleName: $routeSaleName, saleUserCode: $saleUserCode, saleName: $saleName, createdBy: $createdBy, createdDate: $createdDate, updatedBy: $updatedBy, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(covariant CustomerModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.code == code &&
      other.name == name &&
      other.provinceCode == provinceCode &&
      other.districtCode == districtCode &&
      other.wardCode == wardCode &&
      other.phone == phone &&
      other.address == address &&
      other.description == description &&
      other.bankName == bankName &&
      other.bankAccountName == bankAccountName &&
      other.bankAccountNumber == bankAccountNumber &&
      other.price == price &&
      other.taxCode == taxCode &&
      other.taxAddress == taxAddress &&
      other.payerName == payerName &&
      other.agencyName == agencyName &&
      other.oldPrice == oldPrice &&
      other.currentPrice == currentPrice &&
      other.customerGroupCode == customerGroupCode &&
      other.customerGroupName == customerGroupName &&
      other.isDeleted == isDeleted &&
      other.areaSaleCode == areaSaleCode &&
      other.areaSaleName == areaSaleName &&
      other.routeSaleCode == routeSaleCode &&
      other.routeSaleName == routeSaleName &&
      other.saleUserCode == saleUserCode &&
      other.saleName == saleName &&
      other.createdBy == createdBy &&
      other.createdDate == createdDate &&
      other.updatedBy == updatedBy &&
      other.updatedDate == updatedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      code.hashCode ^
      name.hashCode ^
      provinceCode.hashCode ^
      districtCode.hashCode ^
      wardCode.hashCode ^
      phone.hashCode ^
      address.hashCode ^
      description.hashCode ^
      bankName.hashCode ^
      bankAccountName.hashCode ^
      bankAccountNumber.hashCode ^
      price.hashCode ^
      taxCode.hashCode ^
      taxAddress.hashCode ^
      payerName.hashCode ^
      agencyName.hashCode ^
      oldPrice.hashCode ^
      currentPrice.hashCode ^
      customerGroupCode.hashCode ^
      customerGroupName.hashCode ^
      isDeleted.hashCode ^
      areaSaleCode.hashCode ^
      areaSaleName.hashCode ^
      routeSaleCode.hashCode ^
      routeSaleName.hashCode ^
      saleUserCode.hashCode ^
      saleName.hashCode ^
      createdBy.hashCode ^
      createdDate.hashCode ^
      updatedBy.hashCode ^
      updatedDate.hashCode;
  }
} 
