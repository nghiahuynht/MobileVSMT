import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/product/product.dart';
import 'package:trash_pay/domain/repository/product/product_repository.dart';
import 'package:trash_pay/domain/repository/product/product_repository_impl.dart';
import 'product_events.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository = ProductRepositoryImpl();

  ProductBloc() : super(ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<GetProductByIdEvent>(_onGetProductById);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    
    try {
      final result = await _productRepository.getProducts(
        queryParameters: event.queryParameters,
      );
      
      if (result is Success<List<ProductModel>>) {
        emit(ProductLoaded(products: result.data));
      } else if (result is Failure<List<ProductModel>>) {
        emit(ProductError(message: result.errorResultEntity.message ?? 'Failed to load products'));
      }
    } catch (e) {
      emit(ProductError(message: 'Error: $e'));
    }
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    
    try {
      final result = await _productRepository.searchProducts(event.query);
      
      if (result is Success<List<ProductModel>>) {
        emit(ProductLoaded(products: result.data));
      } else if (result is Failure<List<ProductModel>>) {
        emit(ProductError(message: result.errorResultEntity.message ?? 'Failed to search products'));
      }
    } catch (e) {
      emit(ProductError(message: 'Error: $e'));
    }
  }

  Future<void> _onGetProductById(
    GetProductByIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    
    try {
      final result = await _productRepository.getProductById(event.id);
      
      if (result is Success<ProductModel>) {
        emit(ProductDetailLoaded(product: result.data));
      } else if (result is Failure<ProductModel>) {
        emit(ProductError(message: result.errorResultEntity.message ?? 'Failed to load product'));
      }
    } catch (e) {
      emit(ProductError(message: 'Error: $e'));
    }
  }
} 