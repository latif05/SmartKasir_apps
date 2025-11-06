import 'package:flutter/material.dart';

class ReportsPlaceholderPage extends StatelessWidget {
  const ReportsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
      ),
      body: const Center(
        child: Text(
          'Visualisasi laporan akan dikembangkan setelah modul transaksi siap.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
