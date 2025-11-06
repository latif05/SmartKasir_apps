import 'package:flutter/material.dart';

class TransactionsPlaceholderPage extends StatelessWidget {
  const TransactionsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
      ),
      body: const Center(
        child: Text(
          'Modul POS akan hadir di sprint transaksi.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
