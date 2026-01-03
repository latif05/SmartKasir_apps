import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../state/billing_notifier.dart';
import '../state/billing_state.dart';

final billingNotifierProvider =
    StateNotifierProvider<BillingNotifier, BillingState>((ref) {
      // ignore: unused_local_variable
      final _ = serviceLocator; // keep service locator warm if needed later
      return BillingNotifier(ref);
    });
