// Local (SharedPreferences-backed) implementation of StaffRepository
// Persists staff data locally until REST API backend is ready.
// All UI code references the abstract StaffRepository interface.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/staff_member.dart';
import 'i_staff_repository.dart';

class LocalStaffRepository implements IStaffRepository {
  LocalStaffRepository._();
  static final instance = LocalStaffRepository._();

  static const String _staffKey = 'eh_staff_list';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<List<StaffMember>> getAllStaff() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_staffKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => StaffMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<StaffMember?> getStaffById(String id) async {
    final all = await getAllStaff();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addStaff(StaffMember staff) async {
    final all = await getAllStaff();
    all.add(staff);
    await _saveAll(all);
  }

  @override
  Future<void> updateStaff(StaffMember staff) async {
    final all = await getAllStaff();
    final idx = all.indexWhere((s) => s.id == staff.id);
    if (idx >= 0) {
      all[idx] = staff;
      await _saveAll(all);
    }
  }

  @override
  Future<void> deleteStaff(String id) async {
    final all = await getAllStaff();
    all.removeWhere((s) => s.id == id);
    await _saveAll(all);
  }

  @override
  Future<void> addTransaction(StaffTransaction transaction) async {
    final all = await getAllStaff();
    final idx = all.indexWhere((s) => s.id == transaction.staffId);
    if (idx >= 0) {
      all[idx].transactions.add(transaction);
      await _saveAll(all);
    }
  }

  @override
  Future<void> addShift(StaffShift shift) async {
    final all = await getAllStaff();
    final idx = all.indexWhere((s) => s.id == shift.staffId);
    if (idx >= 0) {
      all[idx].shifts.add(shift);
      await _saveAll(all);
    }
  }

  @override
  Future<void> endShift(String shiftId, DateTime endTime) async {
    final all = await getAllStaff();
    for (final staff in all) {
      final shiftIdx = staff.shifts.indexWhere((s) => s.id == shiftId);
      if (shiftIdx >= 0) {
        final old = staff.shifts[shiftIdx];
        final updated = StaffShift(
          id: old.id,
          staffId: old.staffId,
          startTime: old.startTime,
          endTime: endTime,
          date: old.date,
        );
        staff.shifts[shiftIdx] = updated;
        // Update total hours worked
        if (updated.hoursWorked != null) {
          staff.totalHoursWorked += updated.hoursWorked!;
        }
        break;
      }
    }
    await _saveAll(all);
  }

  @override
  Future<List<StaffShift>> getShiftsForStaff(
    String staffId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final staff = await getStaffById(staffId);
    if (staff == null) return [];
    return staff.shifts.where((s) {
      if (from != null && s.startTime.isBefore(from)) return false;
      if (to != null && s.startTime.isAfter(to)) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<StaffTransaction>> getTransactionsForStaff(
    String staffId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final staff = await getStaffById(staffId);
    if (staff == null) return [];
    return staff.transactions.where((t) {
      if (from != null && t.date.isBefore(from)) return false;
      if (to != null && t.date.isAfter(to)) return false;
      return true;
    }).toList();
  }

  Future<void> _saveAll(List<StaffMember> staff) async {
    final prefs = await _prefs;
    await prefs.setString(
      _staffKey,
      jsonEncode(staff.map((s) => s.toJson()).toList()),
    );
  }
}
