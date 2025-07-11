import 'package:flutter_boilerplate/domain/entities/based_api_result/error_result_model.dart';

abstract class ApiResultModel<T> {
  const factory ApiResultModel.success({required T data}) = Success<T>;

  const factory ApiResultModel.failure(
      {required ErrorResultModel errorResultEntity}) = Failure<T>;
}

class Success<T> implements ApiResultModel<T> {
  const Success({required this.data});

  final T data;
}

class Failure<T> implements ApiResultModel<T> {
  const Failure({required this.errorResultEntity});

  final ErrorResultModel errorResultEntity;
}
