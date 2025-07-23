// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/meta_data/arrear.dart';
import 'package:trash_pay/domain/entities/meta_data/payment_type.dart';
import 'package:trash_pay/domain/entities/meta_data/province.dart';
import 'package:trash_pay/domain/entities/meta_data/ward.dart';

class MetaData {
  final List<Province>? provinces;
  final List<Ward>? wards;
  final List<Group>? businessTypes;
  final List<Arrear>? arrears;
  final List<PaymentType>? paymentTypes;
  MetaData({
    this.provinces,
    this.wards,
    this.businessTypes,
    this.arrears,
    this.paymentTypes,
  });

  MetaData copyWith({
    List<Province>? provinces,
    List<Ward>? wards,
    List<Group>? businessTypes,
    List<Arrear>? arrears,
    List<PaymentType>? paymentTypes,
  }) {
    return MetaData(
      provinces: provinces ?? this.provinces,
      wards: wards ?? this.wards,
      businessTypes: businessTypes ?? this.businessTypes,
      arrears: arrears ?? this.arrears,
      paymentTypes: paymentTypes ?? this.paymentTypes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'provinces': provinces?.map((x) => x.toMap()).toList(),
      'wards': wards?.map((x) => x.toMap()).toList(),
      'businessTypes': businessTypes?.map((x) => x.toMap()).toList(),
      'arrears': arrears?.map((x) => x.toMap()).toList(),
      'paymentTypes': paymentTypes?.map((x) => x.toMap()).toList(),
    };
  }

  factory MetaData.fromMap(Map<String, dynamic> map) {
    return MetaData(
      provinces: map['provinces'] != null
          ? List<Province>.from(
              (map['provinces'] as List).map<Province?>(
                (x) => Province.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      wards: map['wards'] != null
          ? List<Ward>.from(
              (map['wards'] as List).map<Ward?>(
                (x) => Ward.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      businessTypes: map['businessTypes'] != null
          ? List<Group>.from(
              (map['businessTypes'] as List).map<Group?>(
                (x) => Group.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      arrears: map['arrears'] != null
          ? List<Arrear>.from(
              (map['arrears'] as List).map<Arrear?>(
                (x) => Arrear.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      paymentTypes: map['paymentTypes'] != null
          ? List<PaymentType>.from(
              (map['paymentTypes'] as List).map<PaymentType?>(
                (x) => PaymentType.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MetaData.fromJson(String source) =>
      MetaData.fromMap(json.decode(source)['data'] as Map<String, dynamic>);

  @override
  String toString() {
    return 'MetaData(provinces: $provinces, wards: $wards, businessTypes: $businessTypes, arrears: $arrears, paymentTypes: $paymentTypes)';
  }

  @override
  bool operator ==(covariant MetaData other) {
    if (identical(this, other)) return true;

    return listEquals(other.provinces, provinces) &&
        listEquals(other.wards, wards) &&
        listEquals(other.businessTypes, businessTypes) &&
        listEquals(other.arrears, arrears) &&
        listEquals(other.paymentTypes, paymentTypes);
  }

  @override
  int get hashCode {
    return provinces.hashCode ^
        wards.hashCode ^
        businessTypes.hashCode ^
        arrears.hashCode ^
        paymentTypes.hashCode;
  }
}
