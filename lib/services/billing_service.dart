import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class BillingService {
  BillingService._();

  static final BillingService instance = BillingService._();

  final InAppPurchase _inAppPurchase =
      InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;

  bool _isInitialized = false;

  bool _isStartingPurchase = false;
  ProductDetails? getProductDetails(
  String productId,
) {
  try {
    return products.firstWhere(
      (product) =>
          product.id == productId,
    );
  } catch (_) {
    return null;
  }
}

  List<ProductDetails> products = [];

Set<String> _productIds = {};
  // ============================================================
  // CALLBACKS
  // ============================================================

  /// Called when a NEW purchase is received.
  ///
  /// IMPORTANT:
  /// This callback is async because Firestore processing must
  /// finish successfully before completePurchase() is called.
  Future<void> Function(PurchaseDetails purchase)?
      onPurchaseSuccess;


  /// Called when purchase processing fails or is cancelled.
  void Function(String error)? onPurchaseError;


  // ============================================================
  // PRODUCT IDS
  // ============================================================

  


  // ============================================================
  // GETTERS
  // ============================================================

  bool get isAvailable => _isAvailable;

  bool get isInitialized => _isInitialized;

  bool get isStartingPurchase => _isStartingPurchase;


  // ============================================================
  // INITIALIZE BILLING
  // ============================================================

  Future<void> initialize({
  required Set<String> productIds,
}) async {
  print("========== BILLING INITIALIZE ==========");


  // ============================================================
  // VALIDATE PRODUCT IDS
  // ============================================================

  final Set<String> normalizedProductIds =
      productIds
          .map(
            (id) => id.trim(),
          )
          .where(
            (id) => id.isNotEmpty,
          )
          .toSet();


  if (normalizedProductIds.isEmpty) {
    throw Exception(
      "No billing product IDs were provided.",
    );
  }


  // ============================================================
  // SAVE CURRENT PRODUCT IDS
  // ============================================================

  _productIds =
      normalizedProductIds;


  // ============================================================
  // RESET INITIALIZATION STATE
  // ============================================================

  _isInitialized = false;


  // ============================================================
  // CHECK BILLING AVAILABILITY
  // ============================================================

  _isAvailable =
      await _inAppPurchase.isAvailable();


  if (!_isAvailable) {
    throw Exception(
      "Google Play Billing is not available.",
    );
  }


  // ============================================================
  // CANCEL OLD PURCHASE STREAM SUBSCRIPTION
  // ============================================================

  await _subscription?.cancel();

  _subscription = null;


  // ============================================================
  // LISTEN TO PURCHASE STREAM
  // ============================================================

  _subscription =
      _inAppPurchase.purchaseStream.listen(
    _onPurchaseUpdated,

    onDone: () async {
      print(
        "Billing purchase stream closed.",
      );

      await _subscription?.cancel();

      _subscription = null;
    },

    onError: (Object error) {
      print(
        "Billing purchase stream error: $error",
      );

      _isStartingPurchase = false;

      onPurchaseError?.call(
        error.toString(),
      );
    },
  );


  // ============================================================
  // LOAD STORE PRODUCTS
  // ============================================================

  await loadProducts();


  // ============================================================
  // MARK BILLING INITIALIZED
  // ============================================================

  _isInitialized = true;


  print(
    "Billing initialized successfully.",
  );

  print(
    "Loaded product IDs: $_productIds",
  );

  print(
    "========================================",
  );
}


  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

Future<void> loadProducts() async {
  print("========== BILLING PRODUCTS ==========");


  // ============================================================
  // VALIDATE PRODUCT IDS
  // ============================================================

  if (_productIds.isEmpty) {
    throw Exception(
      "No product IDs are available to load.",
    );
  }


  print(
    "Loading products: $_productIds",
  );


  // ============================================================
  // QUERY PRODUCTS FROM STORE
  // ============================================================

  final ProductDetailsResponse response =
      await _inAppPurchase.queryProductDetails(
    _productIds,
  );


  // ============================================================
  // LOG QUERY RESULT
  // ============================================================

  print(
    "Products found: "
    "${response.productDetails.length}",
  );


  print(
    "Products not found: "
    "${response.notFoundIDs}",
  );


  // ============================================================
  // HANDLE BILLING ERROR
  // ============================================================

  if (response.error != null) {
    print(
      "Billing Error: "
      "${response.error}",
    );


    // Clear old products.
    //
    // This prevents stale ProductDetails from remaining
    // available after a failed reload.

    products = [];


    throw Exception(
      response.error!.message,
    );
  }


  // ============================================================
  // SAVE LOADED PRODUCTS
  // ============================================================

  products =
      List<ProductDetails>.from(
    response.productDetails,
  );


  // ============================================================
  // LOG LOADED PRODUCTS
  // ============================================================

  for (final ProductDetails product
      in products) {
    print("--------------------------------");


    print(
      "ID: ${product.id}",
    );


    print(
      "Title: ${product.title}",
    );


    print(
      "Price: ${product.price}",
    );
  }


  // ============================================================
  // WARN ABOUT PRODUCTS NOT FOUND
  // ============================================================

  if (response.notFoundIDs.isNotEmpty) {
    print(
      "WARNING: Store products not found: "
      "${response.notFoundIDs}",
    );
  }


  // ============================================================
  // WARN IF NO PRODUCTS LOADED
  // ============================================================

  if (products.isEmpty) {
    print(
      "WARNING: No billing products loaded.",
    );
  }


  print(
    "======================================",
  );
}

  // ============================================================
  // BUY BASIC PLAN
  // ============================================================

  // ============================================================
// BUY PLAN
// ============================================================

Future<void> buyPlan(
  String productId,
) async {
  // ============================================================
  // PREVENT MULTIPLE RAPID PURCHASE STARTS
  // ============================================================

  if (_isStartingPurchase) {
    print(
      "Purchase request ignored: "
      "another purchase is already starting.",
    );

    return;
  }


  // ============================================================
  // VALIDATE PRODUCT ID
  // ============================================================

  final String normalizedProductId =
      productId.trim();

  if (normalizedProductId.isEmpty) {
    throw Exception(
      "Invalid product ID.",
    );
  }


  // ============================================================
  // CHECK BILLING AVAILABILITY
  // ============================================================

  if (!_isAvailable) {
    throw Exception(
      "Google Play Billing is not available.",
    );
  }


  // ============================================================
  // CHECK BILLING INITIALIZATION
  // ============================================================

  if (!_isInitialized) {
    throw Exception(
      "Billing has not been initialized.",
    );
  }


  // ============================================================
  // CHECK LOADED PRODUCTS
  // ============================================================

  if (products.isEmpty) {
    throw Exception(
      "Products have not been loaded.",
    );
  }


  // ============================================================
  // FIND SELECTED PRODUCT
  // ============================================================

  final ProductDetails? product =
      getProductDetails(
    normalizedProductId,
  );

  if (product == null) {
    throw Exception(
      "Product $normalizedProductId was not found.",
    );
  }


  // ============================================================
  // CREATE PURCHASE PARAM
  // ============================================================

  final PurchaseParam purchaseParam =
      PurchaseParam(
    productDetails: product,
  );


  // ============================================================
  // LOCK PURCHASE FLOW
  // ============================================================

  _isStartingPurchase = true;


  try {
    print(
      "Starting purchase: "
      "$normalizedProductId",
    );


    // ==========================================================
    // START CONSUMABLE PURCHASE
    // ==========================================================

    final bool purchaseStarted =
        await _inAppPurchase.buyConsumable(
      purchaseParam: purchaseParam,
    );


    print(
      "Purchase flow started: "
      "$purchaseStarted",
    );


    if (!purchaseStarted) {
      _isStartingPurchase = false;

      throw Exception(
        "Unable to start purchase.",
      );
    }


    // Do not reset _isStartingPurchase here.
    //
    // It will be reset when purchaseStream sends:
    //
    // purchased
    // error
    // cancelled
  } catch (e) {
    _isStartingPurchase = false;

    rethrow;
  }
}


  // ============================================================
  // PURCHASE STREAM
  // ============================================================

  Future<void> _onPurchaseUpdated(
    List<PurchaseDetails> purchases,
  ) async {
    for (final PurchaseDetails purchase in purchases) {
      print("========== PURCHASE UPDATE ==========");

      print(
        "Product ID: ${purchase.productID}",
      );

      print(
        "Purchase ID: ${purchase.purchaseID}",
      );

      print(
        "Status: ${purchase.status}",
      );

      print(
        "Pending Complete Purchase: "
        "${purchase.pendingCompletePurchase}",
      );


      switch (purchase.status) {

        // ======================================================
        // PENDING
        // ======================================================

        case PurchaseStatus.pending:
          print("Purchase pending...");

          // Keep purchase lock enabled.

          break;


        // ======================================================
        // PURCHASED
        // ======================================================

        case PurchaseStatus.purchased:
          print("New purchase received.");

          try {
            // --------------------------------------------------
            // PROCESS PURCHASE IN APP
            // --------------------------------------------------
            //
            // PlansScreen will:
            //
            // 1. Verify user.
            // 2. Run Firestore transaction.
            // 3. Check purchase ID.
            // 4. Add contacts exactly once.
            // 5. Save purchase history.
            //
            // This MUST finish before completePurchase().

            if (onPurchaseSuccess == null) {
              throw Exception(
                "Purchase success handler is not registered.",
              );
            }


            await onPurchaseSuccess!(purchase);


            // --------------------------------------------------
            // COMPLETE PURCHASE
            // --------------------------------------------------

            if (purchase.pendingCompletePurchase) {
              print(
                "Completing purchase...",
              );

              await _inAppPurchase.completePurchase(
                purchase,
              );

              print(
                "Purchase completed successfully.",
              );
            }


            _isStartingPurchase = false;
          } catch (e, stackTrace) {
            print(
              "Purchase processing failed: $e",
            );

            print(stackTrace);


            _isStartingPurchase = false;


            onPurchaseError?.call(
              "Unable to activate your purchase. "
              "Please try again.",
            );


            // IMPORTANT:
            //
            // Do NOT call completePurchase() here.
            //
            // The purchase has not been safely processed.
            //
            // Leaving it incomplete allows recovery/redelivery.
          }

          break;


        // ======================================================
        // RESTORED
        // ======================================================

        case PurchaseStatus.restored:
          print(
            "Restored purchase received.",
          );


          _isStartingPurchase = false;


          // basic_plan is a CONSUMABLE product.
          //
          // Do NOT grant contacts again from a restored event.
          //
          // Complete the restored transaction if required.

          try {
            if (purchase.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(
                purchase,
              );
            }
          } catch (e) {
            print(
              "Unable to complete restored purchase: $e",
            );
          }

          break;


        // ======================================================
        // ERROR
        // ======================================================

        case PurchaseStatus.error:
          print(
            "Purchase error: ${purchase.error}",
          );


          _isStartingPurchase = false;


          onPurchaseError?.call(
            purchase.error?.message ??
                "Purchase failed.",
          );

          break;


        // ======================================================
        // CANCELLED
        // ======================================================

        case PurchaseStatus.canceled:
          print(
            "Purchase cancelled.",
          );


          _isStartingPurchase = false;


          onPurchaseError?.call(
            "Purchase cancelled.",
          );

          break;
      }


      print("=====================================");
    }
  }


  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    print("Disposing BillingService...");


    _subscription?.cancel();

    _subscription = null;


    // Remove screen callbacks.

    onPurchaseSuccess = null;

    onPurchaseError = null;


    _isInitialized = false;

    _isStartingPurchase = false;
    _productIds = {};

products = [];
  }
}