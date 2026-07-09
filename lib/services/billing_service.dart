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

  List<ProductDetails> products = [];


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

  static const Set<String> productIds = {
    'basic_plan',
  };


  // ============================================================
  // GETTERS
  // ============================================================

  bool get isAvailable => _isAvailable;

  bool get isInitialized => _isInitialized;

  bool get isStartingPurchase => _isStartingPurchase;


  // ============================================================
  // INITIALIZE BILLING
  // ============================================================

  Future<void> initialize() async {
    print("========== BILLING INITIALIZE ==========");

    // ----------------------------------------------------------
    // CHECK BILLING AVAILABILITY
    // ----------------------------------------------------------

    _isAvailable =
        await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      throw Exception(
        "Google Play Billing is not available.",
      );
    }


    // ----------------------------------------------------------
    // CANCEL OLD SUBSCRIPTION
    // ----------------------------------------------------------

    await _subscription?.cancel();

    _subscription = null;


    // ----------------------------------------------------------
    // LISTEN TO PURCHASE STREAM
    // ----------------------------------------------------------

    _subscription =
        _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdated,

      onDone: () async {
        print("Billing purchase stream closed.");

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


    // ----------------------------------------------------------
    // LOAD PRODUCTS
    // ----------------------------------------------------------

    await loadProducts();

    _isInitialized = true;

    print("Billing initialized successfully.");
    print("========================================");
  }


  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> loadProducts() async {
    print("========== BILLING PRODUCTS ==========");

    print("Loading products...");


    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(
      productIds,
    );


    print(
      "Products found: "
      "${response.productDetails.length}",
    );

    print(
      "Products not found: "
      "${response.notFoundIDs}",
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
      print("--------------------------------");

      print("ID: ${product.id}");

      print("Title: ${product.title}");

      print("Price: ${product.price}");
    }


    if (products.isEmpty) {
      print(
        "WARNING: No billing products loaded.",
      );
    }


    print("======================================");
  }


  // ============================================================
  // BUY BASIC PLAN
  // ============================================================

  Future<void> buyBasicPlan() async {
    // ----------------------------------------------------------
    // PREVENT MULTIPLE RAPID PURCHASE STARTS
    // ----------------------------------------------------------

    if (_isStartingPurchase) {
      print(
        "Purchase request ignored: "
        "another purchase is already starting.",
      );

      return;
    }


    if (!_isAvailable) {
      throw Exception(
        "Google Play Billing is not available.",
      );
    }


    if (!_isInitialized) {
      throw Exception(
        "Billing has not been initialized.",
      );
    }


    if (products.isEmpty) {
      throw Exception(
        "Products have not been loaded.",
      );
    }


    final ProductDetails product;

    try {
      product = products.firstWhere(
        (item) => item.id == 'basic_plan',
      );
    } catch (_) {
      throw Exception(
        "Basic plan product was not found.",
      );
    }


    final PurchaseParam purchaseParam =
        PurchaseParam(
      productDetails: product,
    );


    _isStartingPurchase = true;


    try {
      print("Starting Basic Plan purchase...");


      final bool purchaseStarted =
          await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
      );


      print(
        "Purchase flow started: $purchaseStarted",
      );


      if (!purchaseStarted) {
        _isStartingPurchase = false;

        throw Exception(
          "Unable to start purchase.",
        );
      }


      // IMPORTANT:
      //
      // Do not reset _isStartingPurchase here.
      //
      // buyConsumable() returning does NOT mean that the purchase
      // finished.
      //
      // It is reset when purchaseStream sends:
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
  }
}