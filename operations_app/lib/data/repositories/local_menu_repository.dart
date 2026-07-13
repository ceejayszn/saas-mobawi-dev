import '../db/database_helper.dart';
import '../models/menu_item.dart';
import 'i_menu_repository.dart';

class LocalMenuRepository implements IMenuRepository {
  @override
  Future<String> insertMenuItem(MenuItem item) async {
    return await DatabaseHelper.instance.insertMenuItem(item);
  }

  @override
  Future<List<MenuItem>> getMenuItems() async {
    return await DatabaseHelper.instance.getMenuItems();
  }

  @override
  Future<int> updateMenuItem(MenuItem item) async {
    return await DatabaseHelper.instance.updateMenuItem(item);
  }
}
