import 'package:equatable/equatable.dart';
import 'package:trash_pay/domain/entities/product/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;

  const ProductLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductDetailLoaded extends ProductState {
  final ProductModel product;

  const ProductDetailLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object?> get props => [message];
} 