import '../models/staff_member.dart';
import 'i_staff_repository.dart';

class ApiStaffRepository implements IStaffRepository {
  @override
  Future<List<StaffMember>> getAllStaff() {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<StaffMember?> getStaffById(String id) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<void> addStaff(StaffMember staff) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<void> updateStaff(StaffMember staff) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<void> deleteStaff(String id) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<void> addShift(StaffShift shift) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<void> endShift(String shiftId, DateTime endTime) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<StaffShift>> getShiftsForStaff(String staffId, {DateTime? from, DateTime? to}) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<void> addTransaction(StaffTransaction transaction) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<StaffTransaction>> getTransactionsForStaff(String staffId, {DateTime? from, DateTime? to}) {
    throw UnimplementedError('API implementation pending');
  }
}
