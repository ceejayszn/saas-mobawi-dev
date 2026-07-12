// StaffProvider — sits between StaffRepository and UI
// All staff CRUD, shift management, and transaction recording lives here.

import 'package:flutter/material.dart';
import '../data/models/staff_member.dart';
import '../data/repositories/i_staff_repository.dart';

class StaffProvider with ChangeNotifier {
  final IStaffRepository _repository;

  StaffProvider(this._repository) {
    loadStaff();
  }

  List<StaffMember> _staff = [];
  bool _isLoading = false;
  String? _error;

  List<StaffMember> get staff => List.unmodifiable(_staff);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get onDutyCount => _staff.where((s) => s.status == StaffStatus.onDuty).length;
  int get offDutyCount => _staff.where((s) => s.status == StaffStatus.offDuty).length;
  int get onHolidayCount => _staff.where((s) => s.status == StaffStatus.onHoliday).length;

  Future<void> loadStaff() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _staff = await _repository.getAllStaff();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStaff(StaffMember staff) async {
    await _repository.addStaff(staff);
    await loadStaff();
  }

  Future<void> updateStaff(StaffMember staff) async {
    await _repository.updateStaff(staff);
    await loadStaff();
  }

  Future<void> deleteStaff(String id) async {
    await _repository.deleteStaff(id);
    await loadStaff();
  }

  Future<void> clockIn(StaffMember staff, {DateTime? time}) async {
    final now = time ?? DateTime.now();
    final shift = StaffShift(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      staffId: staff.id,
      startTime: now,
      date: _dateStr(now),
    );
    staff.status = StaffStatus.onDuty;
    staff.lastModified = DateTime.now();
    await _repository.addShift(shift);
    await _repository.updateStaff(staff);
    await loadStaff();
  }

  Future<void> clockOut(StaffMember staff, {DateTime? time}) async {
    final now = time ?? DateTime.now();
    // Find the latest open shift
    final shifts = await _repository.getShiftsForStaff(staff.id);
    final openShift = shifts.where((s) => s.endTime == null).toList();
    if (openShift.isNotEmpty) {
      await _repository.endShift(openShift.last.id, now);
    }
    staff.status = StaffStatus.offDuty;
    staff.lastModified = DateTime.now();
    await _repository.updateStaff(staff);
    await loadStaff();
  }

  Future<void> markHoliday(StaffMember staff) async {
    staff.status = staff.status == StaffStatus.onHoliday
        ? StaffStatus.offDuty
        : StaffStatus.onHoliday;
    staff.lastModified = DateTime.now();
    await _repository.updateStaff(staff);
    await loadStaff();
  }

  Future<void> addTransaction(StaffTransaction transaction) async {
    await _repository.addTransaction(transaction);
    await loadStaff();
  }

  Future<List<StaffShift>> getShifts(String staffId, {DateTime? from, DateTime? to}) {
    return _repository.getShiftsForStaff(staffId, from: from, to: to);
  }

  Future<List<StaffTransaction>> getTransactions(String staffId, {DateTime? from, DateTime? to}) {
    return _repository.getTransactionsForStaff(staffId, from: from, to: to);
  }

  String _dateStr(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
