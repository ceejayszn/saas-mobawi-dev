import '../models/product.dart';

abstract class IMenuRepository {
  Future<String> insertProduct(Product item);
  Future<List<Product>> getProducts();
  Future<int> updateProduct(Product item);
}
