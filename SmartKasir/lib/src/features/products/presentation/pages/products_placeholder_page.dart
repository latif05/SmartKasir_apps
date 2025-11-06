import 'package:flutter/material.dart';

class ProductsPlaceholderPage extends StatelessWidget {
  const ProductsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
      ),
      body: const Center(
        child: Text(
          'Daftar produk akan dikembangkan pada sprint berikutnya.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
