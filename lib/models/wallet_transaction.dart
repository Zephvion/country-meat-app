enum WalletTransactionType { credit, debit }
enum WalletTransactionStatus { success, pending, failed }

class WalletTransaction {
  final String id;
  final double amount;
  final WalletTransactionType type;
  final String title;
  final DateTime date;
  final WalletTransactionStatus status;
  final String reference;

  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.title,
    required this.date,
    this.status = WalletTransactionStatus.success,
    this.reference = '',
  });

  bool get isCredit => type == WalletTransactionType.credit;

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minuteStr $period';
  }
}
