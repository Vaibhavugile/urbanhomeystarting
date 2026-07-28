import 'package:flutter/material.dart';

import '../services/coupon_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/redeemed_coupon_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimaryColor = Color(0xFF7C3AED);
const Color kSecondaryColor = Color(0xFF9333EA);
const Color kAccentColor = Color(0xFFEC4899);

const Color kBackgroundColor = Color(0xFFF8FAFC);

const Color kCardColor = Colors.white;

const Color kLightGrey = Color(0xFFF1F5F9);

const Color kBorderColor = Color(0xFFE2E8F0);

const Color kDarkText = Color(0xFF111827);

const Color kMediumText = Color(0xFF64748B);

const Color kLightText = Color(0xFF94A3B8);

const Color kOnlineColor = Color(0xFF22C55E);

const Color kReadTickColor = Color(0xFF3B82F6);

const Color kErrorColor = Color(0xFFEF4444);

const LinearGradient kPrimaryGradient =
    LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
    Color(0xFFEC4899),
  ],
);

const LinearGradient kMessageGradient =
    LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF7C3AED),
    Color(0xFF8B5CF6),
  ],
);
class CouponScreen extends StatefulWidget {
  const CouponScreen({
    super.key,
  });

  @override
  State<CouponScreen> createState() =>
      _CouponScreenState();
}

class _CouponScreenState
    extends State<CouponScreen> {
  final TextEditingController
      _couponController =
      TextEditingController();

  bool _loading = false;

  int? _remainingContacts;
  @override
void initState() {
  super.initState();
  _loadRemainingContacts();
}
final _user =
    FirebaseAuth.instance.currentUser!;
  Future<void> _applyCoupon() async {
    final code =
        _couponController.text
            .trim()
            .toUpperCase();

    if (code.isEmpty) {
      _showError(
        "Please enter a coupon code.",
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final result =
          await CouponService
              .applyCoupon(code);

      setState(() {
        _remainingContacts =
            result["remainingContacts"];
      });

      _showSuccess(
        result,
      );
    } catch (e) {
      _showError(
        e.toString().replaceAll(
          "Exception: ",
          "",
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
  Future<void> _loadRemainingContacts() async {
  final doc = await FirebaseFirestore.instance
      .collection("users")
      .doc(_user.uid)
      .get();

  if (!mounted) return;

  setState(() {
    _remainingContacts =
        (doc.data()?["remainingContacts"] ?? 0) as int;
  });
}

void _showError(
  String message,
) {
  const Color primary = Color(0xFFEF4444);
  const Color secondary = Color(0xFFF87171);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    barrierColor: Colors.black54,
    transitionDuration:
        const Duration(milliseconds: 280),
    pageBuilder:
        (_, __, ___) =>
            const SizedBox.shrink(),
    transitionBuilder:
        (
          context,
          animation,
          _,
          __,
        ) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          );

          return ScaleTransition(
            scale: Tween<double>(
              begin: .85,
              end: 1,
            ).animate(curved),
            child: FadeTransition(
              opacity: animation,
              child: AlertDialog(
                elevation: 0,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    28,
                  ),
                ),
                contentPadding:
                    EdgeInsets.zero,
                content: Container(
                  width: 360,
                  padding:
                      const EdgeInsets.all(
                    28,
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [

                      Container(
                        width: 86,
                        height: 86,
                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              primary,
                              secondary,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary
                                  .withOpacity(
                                      .30),
                              blurRadius: 22,
                              offset:
                                  const Offset(
                                      0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      const Text(
                        "Unable to Apply Coupon",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(
                          18,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                        child: Text(
                          message,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color:
                                Color(0xFF64748B),
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        child: Container(
                          height: 56,
                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: [
                                primary,
                                secondary,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary
                                    .withOpacity(
                                        .30),
                                blurRadius: 16,
                                offset:
                                    const Offset(
                                  0,
                                  8,
                                ),
                              ),
                            ],
                          ),
                          child:
                              ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(
                              elevation: 0,
                              shadowColor:
                                  Colors
                                      .transparent,
                              backgroundColor:
                                  Colors
                                      .transparent,
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  16,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [

                                Icon(
                                  Icons.close_rounded,
                                  color:
                                      Colors.white,
                                ),

                                SizedBox(
                                  width: 10,
                                ),

                                Text(
                                  "Got It",
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    fontSize: 16,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          );
        },
  );
}

void _showSuccess(
  Map<String, dynamic> result,
) {
  const Color primary = Color(0xFF10B981);
  const Color secondary = Color(0xFF34D399);

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "",
    barrierColor: Colors.black54,
    transitionDuration:
        const Duration(milliseconds: 280),
    pageBuilder:
        (_, __, ___) =>
            const SizedBox.shrink(),
    transitionBuilder:
        (
          context,
          animation,
          _,
          __,
        ) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          );

          return ScaleTransition(
            scale: Tween<double>(
              begin: .85,
              end: 1,
            ).animate(curved),

            child: FadeTransition(
              opacity: animation,

              child: AlertDialog(
                elevation: 0,
                backgroundColor: Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    28,
                  ),
                ),

                contentPadding:
                    EdgeInsets.zero,

                content: Container(
                  width: 360,
                  padding:
                      const EdgeInsets.all(
                    28,
                  ),

                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      Container(
                        width: 86,
                        height: 86,

                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              primary,
                              secondary,
                            ],
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: primary
                                  .withOpacity(
                                      .30),
                              blurRadius: 22,
                              offset:
                                  const Offset(
                                      0, 10),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons
                              .verified_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      const Text(
                        "Coupon Applied!",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        result["message"] ??
                            "Congratulations!",
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color:
                              Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(
                          18,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.green.shade50,
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),

                        child: Column(
                          children: [

                            _rewardTile(
                              Icons.local_offer,
                              "Coupon",
                              result["couponCode"],
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            _rewardTile(
                              Icons.card_giftcard,
                              "Reward",
                              "+${result["rewardValue"]} Contacts",
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            _rewardTile(
                              Icons.contacts,
                              "Available Contacts",
                              "${result["remainingContacts"]}",
                            ),
                                                      ],
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                primary,
                                secondary,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(.30),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [

                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),

                                SizedBox(width: 10),

                                Text(
                                  "Continue",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          );
        },
  );
}
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
  elevation: 0,
  toolbarHeight: 95,
  automaticallyImplyLeading: false,

  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF7C3AED),
          Color(0xFF9333EA),
          Color(0xFFEC4899),
        ],
      ),
    ),
  ),

  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [

      Text(
        "Rewards Center 🎁",
        style: TextStyle(
          color: Colors.white.withOpacity(.85),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),

      const SizedBox(height: 2),

      const Text(
        "Coupons",
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -.5,
        ),
      ),
    ],
  ),

  actions: [

    Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white24,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
      ),
    ),

  ],
),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

_buildCouponCard(),

            const SizedBox(
              height: 24,
            ),

            _buildRemainingContacts(),
            const SizedBox(height: 30),

const Text(
  "Coupon History",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 16),

_buildHistory(),

          ],
        ),
      ),
    );
  }
  /* ==========================================
    HEADER
========================================== */

Widget _buildHeader() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        colors: [
          kPrimaryColor,
          Color(0xFF5A67D8),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: kPrimaryColor.withOpacity(.25),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: const Column(
      children: [
        Icon(
          Icons.card_giftcard_rounded,
          color: Colors.white,
          size: 54,
        ),
        SizedBox(height: 14),
        Text(
          "Coupons & Rewards",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Apply your coupon and instantly receive free contact unlocks.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

/* ==========================================
    COUPON CARD
========================================== */

Widget _buildCouponCard() {
  return Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Coupon Code",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _couponController,
          textCapitalization:
              TextCapitalization.characters,
          maxLength: 20,
          decoration: InputDecoration(
            hintText: "WELCOME5",
            prefixIcon: const Icon(
              Icons.local_offer_rounded,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            final upper =
                value
                    .replaceAll(" ", "")
                    .toUpperCase();

            if (upper != value) {
              _couponController.value =
                  TextEditingValue(
                text: upper,
                selection:
                    TextSelection.collapsed(
                  offset: upper.length,
                ),
              );
            }
          },
        ),

        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed:
                _loading
                    ? null
                    : _applyCoupon,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  kPrimaryColor,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),
            ),
            child:
                _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Apply Coupon",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
          ),
        ),
      ],
    ),
  );
}

/* ==========================================
    REMAINING CONTACTS
========================================== */
Widget _buildHistory() {
  return StreamBuilder<
      List<RedeemedCouponModel>>(
    stream:
        CouponService.redeemedCoupons(
      _user.uid,
    ),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(
          child:
              CircularProgressIndicator(),
        );
      }

      final coupons =
          snapshot.data!;

      if (coupons.isEmpty) {
        return Container(
          padding:
              const EdgeInsets.all(30),
          child: const Center(
            child: Text(
              "No coupons redeemed yet.",
            ),
          ),
        );
      }

      return Column(
        children: coupons
            .map(
              (coupon) =>
                  _historyCard(coupon),
            )
            .toList(),
      );
    },
  );
}
Widget _historyCard(
  RedeemedCouponModel coupon,
) {
  return Container(
    margin:
        const EdgeInsets.only(
      bottom: 14,
    ),
    padding:
        const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color:
              Colors.black.withOpacity(
            .05,
          ),
          blurRadius: 15,
        ),
      ],
    ),
    child: Row(
      children: [

        const CircleAvatar(
          radius: 26,
          backgroundColor:
              kPrimaryColor,
          child: Icon(
            Icons.local_offer,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                coupon.couponCode,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              Text(
                "+${coupon.rewardValue} Contacts",
              ),

              Text(
                coupon.redeemedAt
                    .toString()
                    .substring(0, 10),
                style:
                    const TextStyle(
                  color: Colors.grey,
                ),
              ),

            ],
          ),
        ),

        Text(
          "${coupon.remainingContactsAfter}",
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 20,
            color: Colors.green,
          ),
        ),

      ],
    ),
  );
}
Widget _rewardTile(
  IconData icon,
  String title,
  String value,
) {
  return Container(
    padding:
        const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius:
          BorderRadius.circular(16),
    ),
    child: Row(
      children: [

        Icon(
          icon,
          color: kPrimaryColor,
        ),

        const SizedBox(
          width: 16,
        ),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 16,
          ),
        ),

      ],
    ),
  );
}
Widget _buildRemainingContacts() {
  return Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                kPrimaryColor.withOpacity(.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.contacts,
            color: kPrimaryColor,
            size: 30,
          ),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "Available Contacts",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _remainingContacts == null
                    ? "--"
                    : _remainingContacts
                        .toString(),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
    }