import 'dart:convert';
import 'package:trash_pay/domain/entities/common/base_model.dart';

class PaginationWrapperResponsive<T extends BaseModel> {
  final int pageIndex;
  final int pageSize;
  final int totalItem;
  final List<T> data;
  PaginationWrapperResponsive({
    required this.totalItem,
    required this.data,
    required this.pageIndex,
    required this.pageSize,
  });

  PaginationWrapperResponsive<T> copyWith({
    int? pageIndex,
    int? pageSize,
    int? totalItem,
    List<T>? data,
  }) {
    return PaginationWrapperResponsive<T>(
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
      totalItem: totalItem ?? this.totalItem,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalItem': totalItem,
      'data': data.map((x) => x.toMap()).toList(),
    };
  }

  factory PaginationWrapperResponsive.fromMap(
    Map<String, dynamic> map, {
    required T Function(Map<String, dynamic>) fromMapT,
    int pageIndex = 1,
    int pageSize = 10,
  }) {
    return PaginationWrapperResponsive<T>(
      pageIndex: pageIndex,
      pageSize: pageSize,
      totalItem: map['totalItem'] as int,
      data: List<T>.from(
        (map['dataList'] as List).map<T>(
          (x) => fromMapT(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory PaginationWrapperResponsive.fromJson(
    String source, {
    required T Function(Map<String, dynamic>) fromMapT,
    int pageIndex = 1,
    int pageSize = 10,
  }) {
    return PaginationWrapperResponsive.fromMap(jsonDecode(source)['data'],
        fromMapT: fromMapT, pageIndex: pageIndex, pageSize: pageSize);
  }

  bool get hasReachedMax => pageIndex * pageSize >= totalItem;
}
