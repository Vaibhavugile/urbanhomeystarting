import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late final Razorpay _razorpay;

  void initialize({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onFailure,
    required void Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      onSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      onFailure,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      onExternalWallet,
    );
  }

  void openCheckout({
    required String razorpayKey,
    required int amount, // In paise
    required String planName,
    required String phoneNumber,
    String? orderId,
  }) {
    try {
      final Map<String, dynamic> options = {
        'key': razorpayKey,
        'amount': amount,
        'currency': 'INR',

        'name': 'UrbanHomey',

        'description':
            '$planName Premium Membership',

        if (orderId != null) 'order_id': orderId,

        'prefill': {
          'contact': phoneNumber,
        },

        'retry': {
          'enabled': true,
          'max_count': 3,
        },

        'send_sms_hash': true,

        'theme': {
          'color': '#7C3AED',
        },

        'modal': {
          'confirm_close': true,
          'escape': false,
        },
      };

      _razorpay.open(options);
    } catch (e, stackTrace) {
      debugPrint(
        'Razorpay Error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}