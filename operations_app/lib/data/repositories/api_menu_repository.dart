import '../models/menu_item.dart';
import 'i_menu_repository.dart';

class ApiMenuRepository implements IMenuRepository {
  @override
  Future<String> insertMenuItem(MenuItem item) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<MenuItem>> getMenuItems() {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<int> updateMenuItem(MenuItem item) {
    throw UnimplementedError('API implementation pending');
  }
}
