import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;

  final BuildContext context;

  PaymentService(this.context) {
    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );
  }

  String? _planName;
  int? _contacts;
  int? _amount;

  void openCheckout({
    required String planName,
    required int contacts,
    required int amount,
  }) {
    _planName = planName;
    _contacts = contacts;
    _amount = amount;

    var options = {
      'key': 'YOUR_RAZORPAY_KEY',
      'amount': amount * 100,
      'name': 'UrbanHomey',
      'description': '$planName Plan',
      'prefill': {
        'contact':
            FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
      },
      'theme': {
        'color': '#7C3AED',
      }
    };

    _razorpay.open(options);
  }

  Future<void> _handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'currentPlan': _planName,
      'currentPlanContacts': _contacts,
      'remainingContacts': _contacts,
      'paymentId':
          response.paymentId,
      'planPurchaseDate':
          FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('purchases')
        .add({
      'planName': _planName,
      'contactsPurchased':
          _contacts,
      'amount': _amount,
      'paymentId':
          response.paymentId,
      'purchaseDate':
          FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          '🎉 Payment Successful',
        ),
        backgroundColor:
            Colors.green,
      ),
    );
  }

  void _handlePaymentError(
    PaymentFailureResponse response,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          response.message ??
              'Payment Failed',
        ),
        backgroundColor:
            Colors.red,
      ),
    );
  }

  void _handleExternalWallet(
    ExternalWalletResponse response,
  ) {}

  void dispose() {
    _razorpay.clear();
  }
}