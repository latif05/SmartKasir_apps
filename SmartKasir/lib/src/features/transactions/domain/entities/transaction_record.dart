import 'package:equatable/equatable.dart';

class TransactionRecord extends Equatable {
  const TransactionRecord({
    required this.id,
    required this.code,
    required this.date,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeAmount,
    required this.status,
    this.createdBy,
  });

  final String id;
  final String? code;
  final DateTime date;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final String paymentMethod;
  final double amountPaid;
  final double changeAmount;
  final String status;
  final String? createdBy;

  @override
  List<Object?> get props => [
        id,
        code,
        date,
        totalAmount,
        discountAmount,
        finalAmount,
        paymentMethod,
        amountPaid,
        changeAmount,
        status,
        createdBy,
      ];
}
