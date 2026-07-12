// Abstract repository interface for Staff data
// Implementations can switch between local storage, mock, or REST API
// without changing any UI code.

import '../models/staff_member.dart';

abstract class IStaffRepository {
  Future<List<StaffMember>> getAllStaff();
  Future<StaffMember?> getStaffById(String id);
  Future<void> addStaff(StaffMember staff);
  Future<void> updateStaff(StaffMember staff);
  Future<void> deleteStaff(String id);
  Future<void> addTransaction(StaffTransaction transaction);
  Future<void> addShift(StaffShift shift);
  Future<void> endShift(String shiftId, DateTime endTime);
  Future<List<StaffShift>> getShiftsForStaff(String staffId, {DateTime? from, DateTime? to});
  Future<List<StaffTransaction>> getTransactionsForStaff(String staffId, {DateTime? from, DateTime? to});
}
