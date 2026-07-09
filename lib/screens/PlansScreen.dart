import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/billing_service.dart';
class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  int? _selectedIndex;
  bool _isPurchasing = false;
  String? _selectedPlanName;
String? _selectedContacts;

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Basic',
      'price': '₹29',
      'contacts': '5 Contacts',
      'features': [
        'Basic features',
        'Limited support',
        'Ad-supported',
      ],
      'isHighlighted': false,
    },
    // {
    //   'title': 'Standard',
    //   'price': '₹299',
    //   'contacts': '20 Contacts',
    //   'features': [
    //     'All Basic features',
    //     'Priority support',
    //     'Ad-free experience',
    //   ],
    //   'isHighlighted': false,
    // },
    // {
    //   'title': 'Pro',
    //   'price': '₹499',
    //   'contacts': '40 Contacts',
    //   'features': [
    //     'Priority support',
    //     'Ad-free experience',
    //     'Exclusive insights'
    //   ],
    //   'isHighlighted': true,
    // },
  ];

@override
void initState() {
  super.initState();

  _pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.85,
  );

Future.microtask(() async {
  try {
    // ============================================================
    // INITIALIZE BILLING
    // ============================================================

    await BillingService.instance.initialize();

    if (!mounted) return;


    // ============================================================
    // PURCHASE SUCCESS
    // ============================================================

    BillingService.instance.onPurchaseSuccess = (purchase) async {
  if (!mounted) return;

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });
    }

    throw Exception("User is not logged in.");
  }

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // GET CONTACT COUNT
  // ============================================================

  final int? contactsValue = int.tryParse(
    (_selectedContacts ?? '').replaceAll(
      RegExp(r'\D'),
      '',
    ),
  );

  if (contactsValue == null || contactsValue <= 0) {
    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });
    }

    throw Exception(
      "Invalid number of contacts for the selected plan.",
    );
  }


  // ============================================================
  // GET SELECTED PLAN
  // ============================================================

  final String planName =
      _selectedPlanName ?? 'Premium';


  try {
    final DocumentReference<Map<String, dynamic>> userRef =
        firestore
            .collection('users')
            .doc(user.uid);


    // ==========================================================
    // VALIDATE PURCHASE ID
    // ==========================================================

    final String? rawPurchaseId =
        purchase.purchaseID;

    if (rawPurchaseId == null ||
        rawPurchaseId.trim().isEmpty) {
      throw Exception(
        "Purchase ID is missing. "
        "Purchase cannot be activated safely.",
      );
    }

    final String purchaseId =
        rawPurchaseId.trim();


    // ==========================================================
    // UNIQUE PURCHASE DOCUMENT
    // ==========================================================

    final DocumentReference<Map<String, dynamic>>
        purchaseRef = userRef
            .collection('purchases')
            .doc(purchaseId);


    // ==========================================================
    // PROCESS PURCHASE EXACTLY ONCE
    // ==========================================================

    final bool contactsGranted =
        await firestore.runTransaction<bool>(
      (transaction) async {
        // ------------------------------------------------------
        // CHECK PURCHASE HISTORY FIRST
        // ------------------------------------------------------

        final purchaseSnapshot =
            await transaction.get(purchaseRef);

        // Purchase already processed.
        //
        // Do not increment contacts again.

        if (purchaseSnapshot.exists) {
          return false;
        }


        // ------------------------------------------------------
        // READ CURRENT USER BALANCE
        // ------------------------------------------------------

        final userSnapshot =
            await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception(
            "User account was not found.",
          );
        }

        final userData =
            userSnapshot.data();

        final int existingContacts =
            (userData?['remainingContacts'] as num?)
                    ?.toInt() ??
                0;

        final int updatedContacts =
            existingContacts + contactsValue;


        // ------------------------------------------------------
        // UPDATE USER CONTACT BALANCE
        // ------------------------------------------------------

        transaction.update(
          userRef,
          {
            'currentPlan':
                planName,

            'currentPlanContacts':
                contactsValue,

            'remainingContacts':
                updatedContacts,

            'planPurchaseDate':
                FieldValue.serverTimestamp(),
          },
        );


        // ------------------------------------------------------
        // SAVE UNIQUE PURCHASE RECORD
        // ------------------------------------------------------

        transaction.set(
          purchaseRef,
          {
            'planName':
                planName,

            'contactsPurchased':
                contactsValue,

            'productId':
                purchase.productID,

            'purchaseId':
                purchaseId,

            'purchaseDate':
                FieldValue.serverTimestamp(),

            'status':
                'completed',
          },
        );


        return true;
      },
    );


    // ==========================================================
    // HANDLE DUPLICATE PURCHASE CALLBACK
    // ==========================================================

    if (!contactsGranted) {
      debugPrint(
        '[PlansScreen] Purchase $purchaseId '
        'was already processed. '
        'Skipping duplicate contact grant.',
      );

      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }

      // IMPORTANT:
      //
      // Return normally.
      //
      // BillingService will then completePurchase(),
      // preventing this already-processed purchase from
      // remaining unfinished.

      return;
    }


    if (!mounted) return;


    // ==========================================================
    // RESET PURCHASE LOADING STATE
    // ==========================================================

    setState(() {
      _isPurchasing = false;
    });


    // ==========================================================
    // CLOSE PURCHASE CONFIRMATION BOTTOM SHEET
    // ==========================================================

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }


    // ==========================================================
    // WAIT FOR BOTTOM SHEET ANIMATION
    // ==========================================================

    await Future.delayed(
      const Duration(milliseconds: 350),
    );

    if (!mounted) return;


    // ==========================================================
    // SHOW PREMIUM SUCCESS POPUP
    // ==========================================================

    await _showPurchaseSuccessDialog(
      planName: planName,
      contacts: contactsValue,
    );
  } catch (e, stackTrace) {
    debugPrint(
      '[PlansScreen] Purchase activation failed: $e',
    );

    debugPrint(
      '[PlansScreen] Stack trace: $stackTrace',
    );

    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to activate purchase: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    // IMPORTANT:
    //
    // Rethrow the error.
    //
    // Your updated BillingService catches this and does NOT
    // completePurchase().
    //
    // This allows the purchase to be redelivered later instead
    // of losing a successfully paid purchase that failed during
    // Firestore activation.

    rethrow;
  }
};

    // ============================================================
    // PURCHASE ERROR / CANCELLED
    // ============================================================

    BillingService.instance.onPurchaseError = (error) {
      if (!mounted) return;

      setState(() {
        _isPurchasing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    };
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isPurchasing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Billing initialization failed: $e',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
});
  _pageController.addListener(() {
    setState(() {
      _currentPage = _pageController.page!.round();
    });
  });
}

@override
void dispose() {
  BillingService.instance.dispose();
  _pageController.dispose();
  super.dispose();
}

  @override
Widget build(BuildContext context) {
  final double screenWidth =
      MediaQuery.of(context).size.width;

  final bool isMobile =
      screenWidth < 700;

  final double appBarHeight =
      AppBar().preferredSize.height;

  final double statusBarHeight =
      MediaQuery.of(context).padding.top;

  final double totalTopPadding =
      appBarHeight +
          statusBarHeight +
          20.0;

  return Scaffold(
    extendBodyBehindAppBar: true,

    appBar: AppBar(
      backgroundColor:
          Colors.transparent,
      elevation: 0,
      centerTitle: true,

      title: const Text(
        'Premium Plans',
        style: TextStyle(
          color: Colors.white,
          fontWeight:
              FontWeight.w800,
          fontSize: 24,
          letterSpacing: -.5,
        ),
      ),

      iconTheme:
          const IconThemeData(
        color: Colors.white,
      ),
    ),

    body: Stack(
      children: [
        Container(
          decoration:
              const BoxDecoration(
            gradient:
                LinearGradient(
              begin:
                  Alignment.topLeft,
              end: Alignment
                  .bottomRight,
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF9333EA),
                Color(0xFFEC4899),
              ],
            ),
          ),
        ),

        SingleChildScrollView(
          padding:
              EdgeInsets.fromLTRB(
            isMobile ? 20 : 40,
            totalTopPadding,
            isMobile ? 20 : 40,
            30,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              const Icon(
                Icons
                    .workspace_premium_rounded,
                size: 70,
                color: Colors.white,
              ),

              const SizedBox(
                  height: 20),

              const Text(
                'Unlock Premium Matching 🚀',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.w900,
                  color:
                      Colors.white,
                  height: 1.2,
                ),
              ),

              const SizedBox(
                  height: 12),

              const Text(
                'Get more profile views, contact access, priority matching and premium perks.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      Colors.white70,
                  height: 1.5,
                ),
              ),

              const SizedBox(
                  height: 30),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceEvenly,
                children: [
                  _statItem(
                    "1500+",
                    "Users",
                  ),
                  _statItem(
                    "500+",
                    "Matches",
                  ),
                  _statItem(
                    "25+",
                    "Cities",
                  ),
                ],
              ),

              const SizedBox(
                  height: 40),

              isMobile
                  ? _buildMobilePlanLayout(
                      context)
                  : _buildWebPlanLayout(
                      context),

              const SizedBox(
                  height: 40),

              Container(
                padding:
                    const EdgeInsets
                        .all(20),
                decoration:
                    BoxDecoration(
                  color: Colors
                      .white
                      .withOpacity(
                          .10),
                  borderRadius:
                      BorderRadius
                          .circular(
                              24),
                  border:
                      Border.all(
                    color: Colors
                        .white24,
                  ),
                ),
                child:
                    const Column(
                  children: [
                    Icon(
                      Icons
                          .verified_user_rounded,
                      color: Colors
                          .white,
                      size: 40,
                    ),

                    SizedBox(
                        height: 10),

                    Text(
                      "Secure Purchase",
                      style:
                          TextStyle(
                        color: Colors
                            .white,
                        fontSize:
                            18,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    SizedBox(
                        height: 6),

                    Text(
                      "Your subscription is securely stored and instantly activated.",
                      textAlign:
                          TextAlign
                              .center,
                      style:
                          TextStyle(
                        color: Colors
                            .white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                  height: 30),

              const Text(
                'Need help choosing a plan?',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Colors.white,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                  height: 8),

              const Text(
                'Our support team is always here to help.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
Widget _statItem(
  String value,
  String label,
) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
    ],
  );
}

  Widget _buildMobilePlanLayout(
  BuildContext context,
) {
  const double cardHeight = 520;

  return Column(
    children: [
      SizedBox(
        height: cardHeight,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _plans.length,
          physics:
              const BouncingScrollPhysics(),
          itemBuilder: (
            context,
            index,
          ) {
            final plan =
                _plans[index];

            final bool isCurrentCard =
                _currentPage == index;

            return AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 350,
              ),
              curve:
                  Curves.easeOutCubic,
              margin:
                  EdgeInsets.symmetric(
                horizontal: 10,
                vertical:
                    isCurrentCard
                        ? 0
                        : 20,
              ),
              child: _buildPlanCard(
                context,
                title:
                    plan['title'],
                price:
                    plan['price'],
                contacts:
                    plan['contacts'],
                features:
                    plan['features'],
                isHighlighted:
                    plan[
                        'isHighlighted'],
                isSelected:
                    _selectedIndex ==
                        index,
                onTap: () {
                  setState(() {
  _selectedIndex = index;
  _selectedPlanName = plan['title'];
  _selectedContacts = plan['contacts'];
});

                  _showPurchaseConfirmation(
                    context,
                    plan['title']
                        as String,
                    plan['contacts']
                        as String,
                  );
                },
                minHeight:
                    cardHeight * .90,
              ),
            );
          },
        ),
      ),

      const SizedBox(height: 28),

      Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: List.generate(
          _plans.length,
          (index) {
            final isActive =
                _currentPage ==
                    index;

            return AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 300,
              ),
              curve:
                  Curves.easeInOut,
              margin:
                  const EdgeInsets
                      .symmetric(
                horizontal: 5,
              ),
              height: 10,
              width:
                  isActive
                      ? 32
                      : 10,
              decoration:
                  BoxDecoration(
                gradient:
                    isActive
                        ? const LinearGradient(
                            colors: [
                              Colors
                                  .white,
                              Color(
                                0xFFFFD700,
                              ),
                            ],
                          )
                        : null,
                color:
                    isActive
                        ? null
                        : Colors
                            .white30,
                borderRadius:
                    BorderRadius
                        .circular(
                  20,
                ),
              ),
            );
          },
        ),
      ),

      const SizedBox(height: 20),

      Text(
        "Swipe to compare plans",
        style: TextStyle(
          color: Colors.white
              .withOpacity(.75),
          fontSize: 13,
          fontWeight:
              FontWeight.w500,
        ),
      ),
    ],
  );
}

  Widget _buildWebPlanLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_plans.length, (index) {
        final plan = _plans[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: index == 1 ? 15.0 : 0.0),
            child: _buildPlanCard(
              context,
              title: plan['title'],
              price: plan['price'],
              contacts: plan['contacts'],
              features: plan['features'],
              isHighlighted: plan['isHighlighted'],
              isSelected: _selectedIndex == index,
              onTap: () {
               setState(() {
  _selectedIndex = index;
  _selectedPlanName = plan['title'];
  _selectedContacts = plan['contacts'];
});
                _showPurchaseConfirmation(
                    context, plan['title'] as String, plan['contacts'] as String);
              },
            ),
          ),
        );
      }),
    );
  }

  // --- Reusable Plan Card Widget ---
  Widget _buildPlanCard(
  BuildContext context, {
  required String title,
  required String price,
  required String contacts,
  required List<String> features,
  required bool isHighlighted,
  required bool isSelected,
  required VoidCallback onTap,
  double? minHeight,
}) {
  final Color primaryColor =
      isHighlighted
          ? const Color(0xFFEC4899)
          : const Color(0xFF7C3AED);

  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(
        milliseconds: 350,
      ),
      curve: Curves.easeOutCubic,
      constraints: minHeight != null
          ? BoxConstraints(
              minHeight: minHeight,
            )
          : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(32),
        border: Border.all(
          color: isHighlighted
              ? const Color(
                  0xFFEC4899,
                )
              : isSelected
                  ? const Color(
                      0xFF9333EA,
                    )
                  : Colors.grey.shade200,
          width: isHighlighted
              ? 3
              : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.08),
            blurRadius: 25,
            offset:
                const Offset(0, 15),
          ),
        ],
      ),

      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
              28,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .center,
              children: [
                if (isHighlighted)
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration:
                        BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(
                            0xFF7C3AED,
                          ),
                          Color(
                            0xFFEC4899,
                          ),
                        ],
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  30),
                    ),
                    child:
                        const Text(
                      "⭐ MOST POPULAR",
                      style:
                          TextStyle(
                        color: Colors
                            .white,
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize:
                            11,
                      ),
                    ),
                  ),

                const SizedBox(
                    height: 18),

                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight
                            .w900,
                    color: Color(
                      0xFF111827,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 10),

                Text(
                  price,
                  style:
                      TextStyle(
                    fontSize: 52,
                    fontWeight:
                        FontWeight
                            .w900,
                    color:
                        primaryColor,
                    height: 1,
                  ),
                ),

                const SizedBox(
                    height: 8),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        primaryColor
                            .withOpacity(
                                .08),
                    borderRadius:
                        BorderRadius
                            .circular(
                                30),
                  ),
                  child: Text(
                    contacts,
                    style:
                        TextStyle(
                      color:
                          primaryColor,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 28),

                ...features.map(
                  (feature) =>
                      Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      bottom: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 28,
                          width: 28,
                          decoration:
                              BoxDecoration(
                            color: primaryColor
                                .withOpacity(
                                    .10),
                            shape: BoxShape
                                .circle,
                          ),
                          child:
                              Icon(
                            Icons
                                .check_rounded,
                            size: 18,
                            color:
                                primaryColor,
                          ),
                        ),

                        const SizedBox(
                            width: 12),

                        Expanded(
                          child:
                              Text(
                            feature,
                            style:
                                const TextStyle(
                              fontSize:
                                  15,
                              fontWeight:
                                  FontWeight
                                      .w500,
                              color:
                                  Color(
                                0xFF374151,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                Container(
                  width:
                      double.infinity,
                  height: 58,
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius
                            .circular(
                                18),
                    gradient:
                        LinearGradient(
                      colors:
                          isHighlighted
                              ? const [
                                  Color(
                                    0xFF7C3AED,
                                  ),
                                  Color(
                                    0xFF9333EA,
                                  ),
                                  Color(
                                    0xFFEC4899,
                                  ),
                                ]
                              : [
                                  Colors
                                      .deepPurple
                                      .shade400,
                                  Colors
                                      .deepPurple
                                      .shade600,
                                ],
                    ),
                  ),
                  child:
                      ElevatedButton(
                    onPressed:
                        onTap,
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors
                              .transparent,
                      shadowColor:
                          Colors
                              .transparent,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),
                    ),
                    child: Text(
                      isHighlighted
                          ? "GO PREMIUM"
                          : "SELECT PLAN",
                      style:
                          const TextStyle(
                        color: Colors
                            .white,
                        fontSize:
                            16,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
Future<void> _showPurchaseSuccessDialog({
  required String planName,
  required int contacts,
}) async {
  if (!mounted) return;

  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Purchase Successful',
    barrierColor: Colors.black.withOpacity(.70),
    transitionDuration: const Duration(milliseconds: 500),

    transitionBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: .72,
            end: 1,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },

    pageBuilder: (
      dialogContext,
      animation,
      secondaryAnimation,
    ) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(dialogContext).size.width * .88,
            constraints: const BoxConstraints(
              maxWidth: 410,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(.40),
                  blurRadius: 45,
                  spreadRadius: 4,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // =================================================
                // PREMIUM SUCCESS HEADER
                // =================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    32,
                    24,
                    30,
                  ),
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [

                      Container(
                        height: 94,
                        width: 94,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(.35),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "PURCHASE SUCCESSFUL 🎉",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 9),

                      const Text(
                        "You're Premium!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.6,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        "$planName plan activated successfully",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),


                // =================================================
                // BODY
                // =================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    25,
                  ),
                  child: Column(
                    children: [

                      const Text(
                        "Your purchase is ready to use",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Start connecting with more flatmates and unlock new conversations.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 22),


                      // =================================================
                      // PURCHASE REWARD CARD
                      // =================================================

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF7C3AED).withOpacity(.08),
                              const Color(0xFFEC4899).withOpacity(.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF7C3AED)
                                .withOpacity(.15),
                          ),
                        ),
                        child: Row(
                          children: [

                            Container(
                              height: 54,
                              width: 54,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF7C3AED),
                                    Color(0xFFEC4899),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    "+$contacts CHAT UNLOCKS",
                                    style: const TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "Added to your account",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF7C3AED),
                              size: 27,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 23),


                      // =================================================
                      // SUCCESS STATUS
                      // =================================================

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green.shade700,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "Payment verified and contacts activated",
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 23),


                      // =================================================
                      // CONTINUE BUTTON
                      // =================================================

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF7C3AED),
                                Color(0xFF9333EA),
                                Color(0xFFEC4899),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C3AED)
                                    .withOpacity(.25),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Start Matching",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
 void _showPurchaseConfirmation(
  BuildContext context,
  String planName,
  String contactsString,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,

    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return PopScope(
            canPop: !_isPurchasing,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // =====================================================
                    // HANDLE
                    // =====================================================

                    Container(
                      height: 5,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 24),


                    // =====================================================
                    // PREMIUM ICON
                    // =====================================================

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7C3AED),
                            Color(0xFF9333EA),
                            Color(0xFFEC4899),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED)
                                .withOpacity(.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 20),


                    // =====================================================
                    // PLAN NAME
                    // =====================================================

                    Text(
                      planName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      contactsString,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9333EA),
                      ),
                    ),

                    const SizedBox(height: 24),


                    // =====================================================
                    // PLAN FEATURES
                    // =====================================================

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7C3AED).withOpacity(.06),
                            const Color(0xFFEC4899).withOpacity(.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF9333EA)
                              .withOpacity(.10),
                        ),
                      ),
                      child: const Column(
                        children: [

                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Instant plan activation",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Access premium contacts",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Priority matching",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),


                    // =====================================================
                    // SECURITY MESSAGE
                    // =====================================================

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isPurchasing
                            ? const Color(0xFF7C3AED).withOpacity(.08)
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [

                          Icon(
                            _isPurchasing
                                ? Icons.lock_clock_rounded
                                : Icons.verified_user_rounded,
                            color: _isPurchasing
                                ? const Color(0xFF7C3AED)
                                : Colors.green.shade700,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _isPurchasing
                                    ? "Please wait while your secure purchase is being processed."
                                    : "Your purchase is securely stored in your account.",
                                key: ValueKey(_isPurchasing),
                                style: TextStyle(
                                  color: _isPurchasing
                                      ? const Color(0xFF7C3AED)
                                      : Colors.green.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),


                    // =====================================================
                    // PURCHASE BUTTON
                    // =====================================================

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isPurchasing
                            ? null
                            : () async {
                                // Disable immediately.

                                setState(() {
                                  _isPurchasing = true;
                                });

                                // Update the open bottom sheet.

                                setSheetState(() {});

                                try {
                                  await BillingService.instance
                                      .buyBasicPlan();
                                } catch (e) {
                                  if (!mounted) return;

                                  setState(() {
                                    _isPurchasing = false;
                                  });

                                  // Bottom sheet may have been closed.

                                  if (sheetContext.mounted) {
                                    setSheetState(() {});
                                  }

                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },

                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                        ),

                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),

                            gradient: LinearGradient(
                              colors: _isPurchasing
                                  ? [
                                      const Color(0xFF7C3AED)
                                          .withOpacity(.70),
                                      const Color(0xFF9333EA)
                                          .withOpacity(.70),
                                      const Color(0xFFEC4899)
                                          .withOpacity(.70),
                                    ]
                                  : const [
                                      Color(0xFF7C3AED),
                                      Color(0xFF9333EA),
                                      Color(0xFFEC4899),
                                    ],
                            ),

                            boxShadow: _isPurchasing
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF7C3AED)
                                          .withOpacity(.25),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                          ),

                          child: Center(
                            child: AnimatedSwitcher(
                              duration:
                                  const Duration(milliseconds: 250),

                              child: _isPurchasing

                                  // =======================================
                                  // LOADING STATE
                                  // =======================================

                                  ? const Row(
                                      key: ValueKey('purchasing'),
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [

                                        SizedBox(
                                          height: 22,
                                          width: 22,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<
                                                    Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 12),

                                        Text(
                                          "PROCESSING PURCHASE...",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    )

                                  // =======================================
                                  // NORMAL STATE
                                  // =======================================

                                  : const Text(
                                      "CONFIRM PURCHASE",
                                      key: ValueKey('confirm'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),


                    // =====================================================
                    // CANCEL BUTTON
                    // =====================================================

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isPurchasing
                          ? const Padding(
                              key: ValueKey('waitMessage'),
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              child: Text(
                                "Please don't close the app while processing",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : TextButton(
                              key: const ValueKey('cancelButton'),
                              onPressed: () {
                                Navigator.pop(sheetContext);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
    );

}
}