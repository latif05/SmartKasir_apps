import 'package:flutter/material.dart';

class SettingsPlaceholderPage extends StatelessWidget {
  const SettingsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: const Center(
        child: Text(
          'Form pengaturan toko akan hadir di sprint laporan & pengaturan.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
