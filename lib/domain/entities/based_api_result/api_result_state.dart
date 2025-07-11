import 'package:flutter_boilerplate/domain/entities/based_api_result/error_result_model.dart';

abstract class ApiResultState<T> {
  const ApiResultState();

  const factory ApiResultState.data({required T data}) = Data<T>;

  const factory ApiResultState.error({required ErrorResultModel errorResult}) =
      Error<T>;
}

class Loading<T> extends ApiResultState<T> {
  const Loading();
}

class Error<T> extends ApiResultState<T> {
  const Error({required this.errorResult});

  final ErrorResultModel errorResult;
}

class Data<T> extends ApiResultState<T> {
  const Data({required this.data});

  final T data;
}
