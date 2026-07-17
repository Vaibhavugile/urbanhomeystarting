import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  RazorpayService._();

  static final RazorpayService instance =
      RazorpayService._();

  final FirebaseFunctions _functions =
      FirebaseFunctions.instance;

  Razorpay? _razorpay;
String? _currentPlanId;
  bool _isInitialized = false;

  bool _isStartingPurchase = false;

  // ============================================================
  // CALLBACKS
  // ============================================================

  /// Called after Razorpay payment has been verified.
  ///
  /// PlansScreen will:
  ///
  /// 1. Verify payment.
  /// 2. Run Firestore transaction.
  /// 3. Prevent duplicate credits.
  /// 4. Save purchase history.
  /// 5. Activate user plan.
  ///
  /// This callback MUST finish successfully before
  /// Razorpay purchase flow is considered complete.
  Future<void> Function(
    PaymentSuccessResponse response,
    String planId,
  )? onPurchaseSuccess;

  /// Called whenever purchase fails.
  void Function(String error)? onPurchaseError;

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isInitialized =>
      _isInitialized;

  bool get isStartingPurchase =>
      _isStartingPurchase;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    print(
      "========== RAZORPAY INITIALIZE ==========",
    );

    if (_isInitialized) {
      print(
        "Razorpay already initialized.",
      );

      return;
    }

    _razorpay = Razorpay();

    _razorpay!.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    _razorpay!.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    _razorpay!.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );

    _isInitialized = true;

    print(
      "Razorpay initialized successfully.",
    );

    print(
      "=========================================",
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    print(
      "Disposing RazorpayService...",
    );

    _razorpay?.clear();

    _razorpay = null;

    onPurchaseSuccess = null;

    onPurchaseError = null;

    _isInitialized = false;

    _isStartingPurchase = false;
  }

  // ============================================================
  // PLACEHOLDERS
  // ============================================================

  

  


 

  // ============================================================
  // BUY PLAN
  // ============================================================

  Future<void> buyPlan(
    String planId,
    int amount,
    String userId,
  ) async {
    // ============================================================
    // PREVENT MULTIPLE PURCHASES
    // ============================================================

    if (_isStartingPurchase) {
      print(
        "Purchase request ignored: "
        "another purchase is already starting.",
      );

      return;
    }

    // ============================================================
    // CHECK INITIALIZATION
    // ============================================================

    if (!_isInitialized) {
      throw Exception(
        "Razorpay has not been initialized.",
      );
    }

    // ============================================================
    // VALIDATE INPUT
    // ============================================================

    if (planId.trim().isEmpty) {
      throw Exception(
        "Invalid plan ID.",
      );
    }

    if (amount <= 0) {
      throw Exception(
        "Invalid purchase amount.",
      );
    }

    if (userId.trim().isEmpty) {
      throw Exception(
        "Invalid user ID.",
      );
    }

    _isStartingPurchase = true;

    try {
      print(
        "========== CREATE RAZORPAY ORDER ==========",
      );

      final HttpsCallable callable =
          _functions.httpsCallable(
        "createRazorpayOrder",
      );

      final HttpsCallableResult result =
          await callable.call({
        "planId": planId,
        "amount": amount,
        "userId": userId,
      });

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(
        result.data,
      );

      print(
        "Order created successfully.",
      );

      final Map<String, Object> options = {
        "key": data["key"],
        "amount": data["amount"],
        "currency": data["currency"],
        "order_id": data["orderId"],
        "name": "UrbanHomey",
        "description": "Purchase Contacts",
        "prefill": {
          "contact": "",
          "email": "",
        },
        "theme": {
          "color": "#4A90E2",
        },
      };

      _currentPlanId = planId;

      _razorpay!.open(options);

      print(
        "Razorpay checkout opened.",
      );
    } catch (e, stackTrace) {
      debugPrint(
        stackTrace.toString(),
      );

      _isStartingPurchase = false;

      rethrow;
    }
  }
    // ============================================================
  // PAYMENT SUCCESS
  // ============================================================

  Future<void> _handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    print(
      "========== PAYMENT SUCCESS ==========",
    );

    try {
      final HttpsCallable callable =
          _functions.httpsCallable(
        "verifyRazorpayPayment",
      );

      final HttpsCallableResult result =
          await callable.call({
        "razorpay_order_id":
            response.orderId,
        "razorpay_payment_id":
            response.paymentId,
        "razorpay_signature":
            response.signature,
      });

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(
        result.data,
      );

      final bool success =
          data["success"] == true;

      if (!success) {
        throw Exception(
          "Payment verification failed.",
        );
      }

      if (onPurchaseSuccess == null) {
        throw Exception(
          "Purchase callback is not registered.",
        );
      }

      await onPurchaseSuccess!(
        response,
        _currentPlanId!,
      );

      _isStartingPurchase = false;

      print(
        "Purchase activated successfully.",
      );
    } catch (e, stackTrace) {
      debugPrint(
        stackTrace.toString(),
      );

      _isStartingPurchase = false;

      onPurchaseError?.call(
        "Unable to activate your purchase.",
      );
    }

    print(
      "=====================================",
    );
  }

  // ============================================================
  // PAYMENT ERROR
  // ============================================================

  void _handlePaymentError(
    PaymentFailureResponse response,
  ) {
    print(
      "Payment failed: "
      "${response.message}",
    );

    _isStartingPurchase = false;

    onPurchaseError?.call(
      response.message ??
          "Payment failed.",
    );
  }

  // ============================================================
  // EXTERNAL WALLET
  // ============================================================

  void _handleExternalWallet(
    ExternalWalletResponse response,
  ) {
    print(
      "External Wallet: "
      "${response.walletName}",
    );
  }
  }