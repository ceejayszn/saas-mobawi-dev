class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String accountName;
  final String status; // 'Settled' or 'Unsettled'

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.accountName = 'General',
    this.status = 'Settled',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'account_name': accountName,
      'status': status,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'] ?? '',
      amount: ((map['amount'] ?? 0) as num).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      accountName: map['account_name'] ?? 'General',
      status: map['status'] ?? 'Settled',
    );
  }
}
