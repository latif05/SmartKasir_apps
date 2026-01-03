import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../activation/presentation/providers/activation_providers.dart';
import 'billing_state.dart';

class BillingNotifier extends StateNotifier<BillingState> {
  BillingNotifier(this._ref) : super(const BillingState()) {
    _init();
  }

  final Ref _ref;
  final InAppPurchase _iap = InAppPurchase.instance;
  // Harus sama persis dengan productId di Play Console (premium_01)
  static const _productId = 'premium_01';
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> _init() async {
    if (!Platform.isAndroid) {
      state = state.copyWith(
        errorMessage: 'Pembelian hanya tersedia di Android',
      );
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    final available = await _iap.isAvailable();
    if (!available) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Pembelian tidak tersedia',
      );
      return;
    }
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (Object _) {
        state = state.copyWith(
          purchasePending: false,
          errorMessage: 'Terjadi kesalahan pembelian',
        );
      },
    );
    await loadProducts();
  }

  Future<void> loadProducts() async {
  print("Memulai loadProducts untuk ID: $_productId"); // Tambahkan ini
  state = state.copyWith(isLoading: true, errorMessage: null);
  
  final response = await _iap.queryProductDetails({_productId});
  
  // DEBUG: Cek apakah ID ditemukan atau tidak
  print("Jumlah produk ditemukan: ${response.productDetails.length}");
  if (response.notFoundIDs.isNotEmpty) {
    print("ID BERIKUT TIDAK DITEMUKAN: ${response.notFoundIDs}");
  }

  if (response.error != null) {
    print("Error dari Google: ${response.error?.message}");
    state = state.copyWith(
      isLoading: false,
      errorMessage: response.error?.message ?? 'Gagal memuat produk',
    );
    return;
  }
  
  state = state.copyWith(isLoading: false, products: response.productDetails);
}

  Future<void> buyPremium() async {
    if (state.products.isEmpty) {
      await loadProducts();
    }
    if (state.products.isEmpty) {
      state = state.copyWith(
        purchasePending: false,
        errorMessage: 'Produk premium belum tersedia',
      );
      return;
    }

    ProductDetails product;
    try {
      product = state.products.firstWhere((p) => p.id == _productId);
    } catch (_) {
      product = state.products.first;
    }

    state = state.copyWith(purchasePending: true, errorMessage: null);
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restore() async {
    state = state.copyWith(purchasePending: true, errorMessage: null);
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(purchasePending: true);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          state = state.copyWith(purchasePending: false, errorMessage: null);
          await _handleVerifiedPurchase(purchase);
          break;
        case PurchaseStatus.error:
          state = state.copyWith(
            purchasePending: false,
            errorMessage: purchase.error?.message ?? 'Pembelian gagal',
          );
          break;
        case PurchaseStatus.canceled:
          state = state.copyWith(purchasePending: false);
          break;
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    if (purchases.isEmpty) {
      state = state.copyWith(purchasePending: false);
    }
  }

  Future<void> _handleVerifiedPurchase(PurchaseDetails purchase) async {
    // TODO: add real receipt verification. For now, trust Google Play flow.
    await _ref.read(activationNotifierProvider.notifier).activateFromPurchase();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
