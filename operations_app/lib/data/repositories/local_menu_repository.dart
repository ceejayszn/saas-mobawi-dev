import '../db/database_helper.dart';
import '../models/product.dart';
import 'i_menu_repository.dart';

class LocalMenuRepository implements IMenuRepository {
  @override
  Future<String> insertProduct(Product item) async {
    return await DatabaseHelper.instance.insertProduct(item);
  }

  @override
  Future<List<Product>> getProducts() async {
    return await DatabaseHelper.instance.getProducts();
  }

  @override
  Future<int> updateProduct(Product item) async {
    return await DatabaseHelper.instance.updateProduct(item);
  }
}
