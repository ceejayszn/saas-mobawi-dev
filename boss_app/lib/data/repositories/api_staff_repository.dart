import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/api/api_client.dart';
import '../models/staff_member.dart';
import 'i_staff_repository.dart';

class ApiStaffRepository implements IStaffRepository {
  @override
  Future<List<StaffMember>> getAllStaff() async {
    try {
      final response = await ApiClient.instance.get('/api/staff');
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((json) => StaffMember.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('ApiStaffRepository getAllStaff error: $e');
    }
    return [];
  }

  @override
  Future<StaffMember?> getStaffById(String id) async {
    try {
      final response = await ApiClient.instance.get('/api/staff/$id');
      if (response.statusCode == 200) {
        return StaffMember.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('ApiStaffRepository getStaffById error: $e');
    }
    return null;
  }

  @override
  Future<void> addStaff(StaffMember staff) async {
    try {
      await ApiClient.instance.post('/api/staff', staff.toJson());
    } catch (e) {
      debugPrint('ApiStaffRepository addStaff error: $e');
    }
  }

  @override
  Future<void> updateStaff(StaffMember staff) async {
    try {
      await ApiClient.instance.put('/api/staff/${staff.id}', staff.toJson());
    } catch (e) {
      debugPrint('ApiStaffRepository updateStaff error: $e');
    }
  }

  @override
  Future<void> deleteStaff(String id) async {
    try {
      await ApiClient.instance.delete('/api/staff/$id');
    } catch (e) {
      debugPrint('ApiStaffRepository deleteStaff error: $e');
    }
  }

  @override
  Future<void> addShift(StaffShift shift) async {
    try {
      await ApiClient.instance.post('/api/staff/${shift.staffId}/shifts', shift.toJson());
    } catch (e) {
      debugPrint('ApiStaffRepository addShift error: $e');
    }
  }

  @override
  Future<void> endShift(String shiftId, DateTime endTime) async {
    try {
      await ApiClient.instance.put('/api/staff/any/shifts/$shiftId', {
        'endTime': endTime.toIso8601String(),
      });
    } catch (e) {
      debugPrint('ApiStaffRepository endShift error: $e');
    }
  }

  @override
  Future<List<StaffShift>> getShiftsForStaff(String staffId, {DateTime? from, DateTime? to}) async {
    try {
      final response = await ApiClient.instance.get('/api/staff/$staffId/shifts');
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        var shifts = list.map((json) => StaffShift.fromJson(json as Map<String, dynamic>)).toList();
        if (from != null) {
          shifts = shifts.where((s) => s.startTime.isAfter(from) || s.startTime.isAtSameMomentAs(from)).toList();
        }
        if (to != null) {
          shifts = shifts.where((s) => s.startTime.isBefore(to) || s.startTime.isAtSameMomentAs(to)).toList();
        }
        return shifts;
      }
    } catch (e) {
      debugPrint('ApiStaffRepository getShiftsForStaff error: $e');
    }
    return [];
  }

  @override
  Future<void> addTransaction(StaffTransaction transaction) async {
    try {
      await ApiClient.instance.post('/api/staff/${transaction.staffId}/transactions', transaction.toJson());
    } catch (e) {
      debugPrint('ApiStaffRepository addTransaction error: $e');
    }
  }

  @override
  Future<List<StaffTransaction>> getTransactionsForStaff(String staffId, {DateTime? from, DateTime? to}) async {
    try {
      final response = await ApiClient.instance.get('/api/staff/$staffId/transactions');
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        var transactions = list.map((json) => StaffTransaction.fromJson(json as Map<String, dynamic>)).toList();
        if (from != null) {
          transactions = transactions.where((t) => t.date.isAfter(from) || t.date.isAtSameMomentAs(from)).toList();
        }
        if (to != null) {
          transactions = transactions.where((t) => t.date.isBefore(to) || t.date.isAtSameMomentAs(to)).toList();
        }
        return transactions;
      }
    } catch (e) {
      debugPrint('ApiStaffRepository getTransactionsForStaff error: $e');
    }
    return [];
  }
}
