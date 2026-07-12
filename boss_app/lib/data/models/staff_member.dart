// Staff domain model — unified financial transaction model
// Designed for future PostgreSQL + API integration

enum StaffStatus { onDuty, offDuty, onHoliday }

enum StaffTransactionType {
  salary,
  advance,
  allowance,
  bonus,
  deduction,
  expense;

  String get typeLabel {
    switch (this) {
      case StaffTransactionType.salary: return 'Salary';
      case StaffTransactionType.advance: return 'Advance';
      case StaffTransactionType.allowance: return 'Allowance';
      case StaffTransactionType.bonus: return 'Bonus';
      case StaffTransactionType.deduction: return 'Deduction';
      case StaffTransactionType.expense: return 'Expense';
    }
  }
}

class StaffMember {
  String id;
  String name;
  String role;
  StaffStatus status;
  String? phone;
  String? imagePath;
  DateTime lastModified;
  double hourlyWage;
  double totalHoursWorked;
  List<StaffTransaction> transactions;
  List<StaffShift> shifts;

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    this.status = StaffStatus.offDuty,
    this.phone,
    this.imagePath,
    required this.lastModified,
    this.hourlyWage = 0.0,
    this.totalHoursWorked = 0.0,
    List<StaffTransaction>? transactions,
    List<StaffShift>? shifts,
  })  : transactions = transactions ?? [],
        shifts = shifts ?? [];

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get statusLabel {
    switch (status) {
      case StaffStatus.onDuty: return 'On Duty';
      case StaffStatus.offDuty: return 'Off Duty';
      case StaffStatus.onHoliday: return 'On Holiday';
    }
  }

  double get totalWagesEarned => hourlyWage * totalHoursWorked;

  double get totalSalaryPaid {
    return transactions
        .where((t) => t.type == StaffTransactionType.salary)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalAdvances {
    return transactions
        .where((t) => t.type == StaffTransactionType.advance)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netPayable => totalWagesEarned - totalSalaryPaid - totalAdvances;

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      status: StaffStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StaffStatus.offDuty,
      ),
      phone: json['phone'] as String?,
      imagePath: json['imagePath'] as String?,
      lastModified: DateTime.parse(json['lastModified'] as String),
      hourlyWage: (json['hourlyWage'] as num?)?.toDouble() ?? 0.0,
      totalHoursWorked: (json['totalHoursWorked'] as num?)?.toDouble() ?? 0.0,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => StaffTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      shifts: (json['shifts'] as List<dynamic>?)
              ?.map((e) => StaffShift.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'status': status.name,
      'phone': phone,
      'imagePath': imagePath,
      'lastModified': lastModified.toIso8601String(),
      'hourlyWage': hourlyWage,
      'totalHoursWorked': totalHoursWorked,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'shifts': shifts.map((s) => s.toJson()).toList(),
    };
  }
}

class StaffTransaction {
  final String id;
  final String staffId;
  final StaffTransactionType type;
  final double amount;
  final DateTime date;
  final String? notes;

  const StaffTransaction({
    required this.id,
    required this.staffId,
    required this.type,
    required this.amount,
    required this.date,
    this.notes,
  });

  String get typeLabel {
    switch (type) {
      case StaffTransactionType.salary: return 'Salary';
      case StaffTransactionType.advance: return 'Advance';
      case StaffTransactionType.allowance: return 'Allowance';
      case StaffTransactionType.bonus: return 'Bonus';
      case StaffTransactionType.deduction: return 'Deduction';
      case StaffTransactionType.expense: return 'Expense';
    }
  }

  factory StaffTransaction.fromJson(Map<String, dynamic> json) {
    return StaffTransaction(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      type: StaffTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StaffTransactionType.salary,
      ),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'type': type.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }
}

class StaffShift {
  final String id;
  final String staffId;
  final DateTime startTime;
  final DateTime? endTime;
  final String date;

  const StaffShift({
    required this.id,
    required this.staffId,
    required this.startTime,
    this.endTime,
    required this.date,
  });

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  double? get hoursWorked {
    return duration?.inMinutes.toDouble() != null
        ? duration!.inMinutes / 60.0
        : null;
  }

  factory StaffShift.fromJson(Map<String, dynamic> json) {
    return StaffShift(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'date': date,
    };
  }
}
