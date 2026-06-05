enum TransactionType { lend, borrow }
enum TransactionStatus { pending, completed }

class TransactionModel {
  final int? id;
  final String personName;
  final String itemOrAmount;
  final String description;
  final DateTime dateCreated;
  final DateTime dueDate;
  final bool hasReminder;
  final TransactionType type;
  final TransactionStatus status;

  TransactionModel({
    this.id,
    required this.personName,
    required this.itemOrAmount,
    required this.description,
    required this.dateCreated,
    required this.dueDate,
    this.hasReminder = false,
    required this.type,
    this.status = TransactionStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'itemOrAmount': itemOrAmount,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'hasReminder': hasReminder ? 1 : 0,
      'type': type.index,
      'status': status.index,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      personName: map['personName'],
      itemOrAmount: map['itemOrAmount'],
      description: map['description'],
      dateCreated: DateTime.parse(map['dateCreated']),
      dueDate: DateTime.parse(map['dueDate']),
      hasReminder: map['hasReminder'] == 1,
      type: TransactionType.values[map['type']],
      status: TransactionStatus.values[map['status']],
    );
  }

  TransactionModel copyWith({
    int? id,
    String? personName,
    String? itemOrAmount,
    String? description,
    DateTime? dateCreated,
    DateTime? dueDate,
    bool? hasReminder,
    TransactionType? type,
    TransactionStatus? status,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      itemOrAmount: itemOrAmount ?? this.itemOrAmount,
      description: description ?? this.description,
      dateCreated: dateCreated ?? this.dateCreated,
      dueDate: dueDate ?? this.dueDate,
      hasReminder: hasReminder ?? this.hasReminder,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}
