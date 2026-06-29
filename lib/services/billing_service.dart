import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class BillingService {
  BillingService._();

  static final BillingService instance = BillingService._();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;

  List<ProductDetails> products = [];

  /// Callback when a purchase succeeds
  Function(PurchaseDetails purchase)? onPurchaseSuccess;

  /// Callback when purchase fails
  Function(String error)? onPurchaseError;

  static const Set<String> productIds = {
    'basic_plan',
  };

  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      throw Exception("Google Play Billing is not available.");
    }

    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        onPurchaseError?.call(error.toString());
      },
    );

    await loadProducts();
  }

  Future<void> loadProducts() async {
  print("========== BILLING ==========");
  print("Loading products...");

  final response =
      await _inAppPurchase.queryProductDetails(productIds);

  print(
    "Products found: ${response.productDetails.length}",
  );

  print(
    "Products not found: ${response.notFoundIDs}",
  );

  if (response.error != null) {
    print(
      "Billing Error: ${response.error}",
    );

    throw Exception(
      response.error!.message,
    );
  }

  products = response.productDetails;

  for (final product in products) {
    print("----------------------");
    print("ID: ${product.id}");
    print("Title: ${product.title}");
    print("Price: ${product.price}");
  }

  print("=============================");
}

  Future<void> buyBasicPlan() async {
    if (products.isEmpty) {
      throw Exception("Products have not been loaded.");
    }

    final ProductDetails product = products.firstWhere(
      (p) => p.id == 'basic_plan',
    );

    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: product);

    await _inAppPurchase.buyConsumable(
      purchaseParam: purchaseParam,
    );
  }

  Future<void> _onPurchaseUpdated(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          print("Purchase pending...");
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          print("Purchase successful!");

          /// Notify UI
          onPurchaseSuccess?.call(purchase);

          if (purchase.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(
              purchase,
            );
          }

          break;

        case PurchaseStatus.error:
          onPurchaseError?.call(
            purchase.error?.message ??
                "Purchase failed.",
          );
          break;

        case PurchaseStatus.canceled:
          onPurchaseError?.call(
            "Purchase cancelled.",
          );
          break;
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}