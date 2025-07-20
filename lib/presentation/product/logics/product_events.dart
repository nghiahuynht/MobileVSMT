import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductEvent {
  final Map<String, dynamic>? queryParameters;

  const LoadProductsEvent({this.queryParameters});

  @override
  List<Object?> get props => [queryParameters];
}

class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class GetProductByIdEvent extends ProductEvent {
  final int id;

  const GetProductByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
} 