import '../models/menu_item.dart';

abstract class IMenuRepository {
  Future<String> insertMenuItem(MenuItem item);
  Future<List<MenuItem>> getMenuItems();
  Future<int> updateMenuItem(MenuItem item);
}
