import '../models/product.dart';
import 'i_menu_repository.dart';

class ApiMenuRepository implements IMenuRepository {
  @override
  Future<String> insertProduct(Product item) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Product>> getProducts() {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<int> updateProduct(Product item) {
    throw UnimplementedError('API implementation pending');
  }
}
