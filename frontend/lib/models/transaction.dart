class Transaction {
  final String id;
  final String partner;   // แลกของกับใคร
  final DateTime time;

  const Transaction({
    required this.id,
    required this.partner,
    required this.time,
  });
}
