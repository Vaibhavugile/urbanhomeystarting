import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/billing_service.dart';
import 'package:mytennat/models/chat_plan.dart';
import 'package:mytennat/services/chat_plan_service.dart';
import 'package:mytennat/models/payment_method.dart';
import '../services/razorpay_service.dart';
import 'package:url_launcher/url_launcher.dart';
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


// ============================================================
// FIRESTORE CHAT PLANS
// ============================================================

List<ChatPlan> _plans = [];

bool _isLoadingPlans = true;

String? _plansError;


// ============================================================
// CURRENT SELECTED PLAN
// ============================================================

ChatPlan? _selectedPlan;
// ============================================================
// PAYMENT METHOD
// ============================================================

PaymentMethod _selectedPaymentMethod =
    PaymentMethod.inApp;
  // ============================================================
// LOAD CHAT PLANS FROM FIRESTORE
// ============================================================

Future<void> _loadPlans() async {
  if (mounted) {
    setState(() {
      _isLoadingPlans = true;
      _plansError = null;
    });
  }

  try {
    // ============================================================
    // LOAD ACTIVE PLANS FROM FIRESTORE
    // ============================================================

    final List<ChatPlan> loadedPlans =
        await ChatPlanService.instance
            .getActivePlans();


    if (loadedPlans.isEmpty) {
      throw Exception(
        "No active chat plans are available.",
      );
    }


    // ============================================================
    // EXTRACT STORE PRODUCT IDS
    // ============================================================

    final Set<String> productIds =
        loadedPlans
            .map(
              (plan) =>
                  plan.productId.trim(),
            )
            .where(
              (productId) =>
                  productId.isNotEmpty,
            )
            .toSet();


    if (productIds.isEmpty) {
      throw Exception(
        "No valid billing product IDs were found.",
      );
    }


    debugPrint(
      '[PlansScreen] '
      'Firestore plans loaded: '
      '${loadedPlans.length}',
    );


    debugPrint(
      '[PlansScreen] '
      'Initializing billing products: '
      '$productIds',
    );


    // ============================================================
    // INITIALIZE BILLING WITH FIRESTORE PRODUCT IDS
    // ============================================================

    await BillingService.instance.initialize(
  productIds: productIds,
);

await RazorpayService.instance.initialize();


    if (!mounted) {
      return;
    }


    // ============================================================
    // KEEP ONLY PLANS WHOSE STORE PRODUCT EXISTS
    // ============================================================

    final List<ChatPlan> availablePlans =
        loadedPlans.where(
      (plan) {
        return BillingService.instance
                .getProductDetails(
              plan.productId,
            ) !=
            null;
      },
    ).toList();


    // ============================================================
    // LOG UNAVAILABLE STORE PRODUCTS
    // ============================================================

    for (final ChatPlan plan
        in loadedPlans) {
      final bool storeProductExists =
          BillingService.instance
                  .getProductDetails(
                plan.productId,
              ) !=
              null;

      if (!storeProductExists) {
        debugPrint(
          '[PlansScreen] '
          'Store product unavailable: '
          '${plan.productId}',
        );
      }
    }


    if (availablePlans.isEmpty) {
      throw Exception(
        "No purchasable chat plans are currently available.",
      );
    }


    // ============================================================
    // UPDATE SCREEN STATE
    // ============================================================

    setState(() {
      _plans = availablePlans;

      _isLoadingPlans = false;

      _plansError = null;

      _selectedIndex = null;

      _selectedPlan = null;

      if (_currentPage >=
          _plans.length) {
        _currentPage = 0;
      }
    });


    // ============================================================
    // LOG FINAL AVAILABLE PLANS
    // ============================================================

    for (final ChatPlan plan
        in availablePlans) {
      final product =
          BillingService.instance
              .getProductDetails(
        plan.productId,
      );


      debugPrint(
        '[PlansScreen] AVAILABLE PLAN | '
        '${plan.productId} | '
        '${plan.title} | '
        '${plan.contacts} contacts | '
        '${product?.price}',
      );
    }
  } catch (e, stackTrace) {
    debugPrint(
      '[PlansScreen] '
      'Unable to initialize plans: $e',
    );

    debugPrint(
      '[PlansScreen] '
      'Stack trace: $stackTrace',
    );


    if (!mounted) {
      return;
    }


    setState(() {
      _plans = [];

      _isLoadingPlans = false;

      _plansError =
          'Unable to load chat plans. '
          'Please try again.';
    });
  }
}
Future<ChatPlan> _resolvePlanForPurchase(
  String productId,
) async {
  final String normalizedProductId =
      productId.trim();

  if (normalizedProductId.isEmpty) {
    throw Exception(
      'Purchase product ID is missing.',
    );
  }


  // ============================================================
  // FIRST: CHECK ALREADY LOADED PLANS
  // ============================================================

  for (final ChatPlan plan in _plans) {
    if (plan.productId ==
        normalizedProductId) {
      return plan;
    }
  }


  // ============================================================
  // SECOND: LOAD PLAN DIRECTLY FROM FIRESTORE
  // ============================================================

  final DocumentSnapshot<Map<String, dynamic>>
      snapshot = await FirebaseFirestore.instance
          .collection('chatPlans')
          .doc(normalizedProductId)
          .get();


  if (!snapshot.exists) {
    throw Exception(
      'No chat plan exists for product '
      '$normalizedProductId.',
    );
  }


  final Map<String, dynamic>? data =
      snapshot.data();

  if (data == null) {
    throw Exception(
      'Chat plan data is missing.',
    );
  }


  final ChatPlan plan =
      ChatPlan.fromMap(
    data,
    snapshot.id,
  );


  // ============================================================
  // VALIDATE RECOVERED PLAN
  // ============================================================

  if (plan.productId !=
      normalizedProductId) {
    throw Exception(
      'Chat plan product ID does not match '
      'the purchased product.',
    );
  }


  if (!plan.isActive) {
    throw Exception(
      'The purchased chat plan is no longer active.',
    );
  }


  if (plan.contacts <= 0) {
    throw Exception(
      'The purchased chat plan has an invalid '
      'contact count.',
    );
  }


  return plan;
}
Future<void> _activatePurchase({
  required String purchaseId,
  required String productId,
}) async {
 if (!mounted) {
      return;
    }


    // ==========================================================
    // GET CURRENT USER
    // ==========================================================

    final user =
        FirebaseAuth.instance.currentUser;


    if (user == null) {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }


      throw Exception(
        "User is not logged in.",
      );
    }


    final FirebaseFirestore firestore =
        FirebaseFirestore.instance;


    try {
      // ========================================================
      // RESOLVE FIRESTORE PLAN FROM PURCHASE PRODUCT ID
      // ========================================================

      final ChatPlan selectedPlan =
    await _resolvePlanForPurchase(
  productId,
);

      // ========================================================
      // UPDATE CURRENT SELECTED PLAN
      // ========================================================

      if (mounted) {
        setState(() {
          _selectedPlan =
              selectedPlan;
        });
      }


      // ========================================================
      // GET PLAN VALUES
      // ========================================================

      final int contactsValue =
          selectedPlan.contacts;


      final String planName =
          selectedPlan.title;


      final String purchasedProductId =
    selectedPlan.productId;


      final String planId =
          selectedPlan.id;


      // ========================================================
      // USER DOCUMENT
      // ========================================================

      final DocumentReference<
              Map<String, dynamic>>
          userRef = firestore
              .collection('users')
              .doc(user.uid);


      // ========================================================
      // VALIDATE PURCHASE ID
      // ========================================================

      final String rawPurchaseId =
    purchaseId;

if (rawPurchaseId.trim().isEmpty) {
  throw Exception(
    "Purchase ID is missing."
  );
}


      final String normalizedPurchaseId =
    rawPurchaseId.trim();


      // ========================================================
      // UNIQUE PURCHASE DOCUMENT
      // ========================================================

      final DocumentReference<
              Map<String, dynamic>>
          purchaseRef = userRef
              .collection('purchases')
              .doc(normalizedPurchaseId);


      // ========================================================
      // PROCESS PURCHASE EXACTLY ONCE
      // ========================================================

      final bool contactsGranted =
          await firestore
              .runTransaction<bool>(
        (transaction) async {
          // ----------------------------------------------------
          // CHECK PURCHASE HISTORY
          // ----------------------------------------------------

          final purchaseSnapshot =
              await transaction.get(
            purchaseRef,
          );


          // Already processed.
          //
          // Return normally so BillingService can call
          // completePurchase() safely.

          if (purchaseSnapshot.exists) {
            return false;
          }


          // ----------------------------------------------------
          // READ CURRENT USER BALANCE
          // ----------------------------------------------------

          final userSnapshot =
              await transaction.get(
            userRef,
          );


          if (!userSnapshot.exists) {
            throw Exception(
              "User account was not found.",
            );
          }


          final Map<String, dynamic>?
              userData =
              userSnapshot.data();


          final int existingContacts =
              (userData?[
                          'remainingContacts']
                      as num?)
                  ?.toInt() ??
              0;


          final int updatedContacts =
              existingContacts +
                  contactsValue;


          // ----------------------------------------------------
          // UPDATE USER CONTACT BALANCE
          // ----------------------------------------------------

          transaction.update(
            userRef,
            {
              'currentPlan':
                  planName,

              'currentPlanId':
                  planId,

              'currentPlanProductId': purchasedProductId,

              'currentPlanContacts':
                  contactsValue,

              'remainingContacts':
                  updatedContacts,

              'planPurchaseDate':
                  FieldValue
                      .serverTimestamp(),
            },
          );


          // ----------------------------------------------------
          // SAVE UNIQUE PURCHASE RECORD
          // ----------------------------------------------------

          transaction.set(
            purchaseRef,
            {
              'planId':
                  planId,

              'planName':
                  planName,

              'contactsPurchased':
                  contactsValue,

              'productId': purchasedProductId,

              'purchaseId':
                  normalizedPurchaseId,

              'purchaseDate':
                  FieldValue
                      .serverTimestamp(),

              'status':
                  'completed',
            },
          );


          return true;
        },
      );


      // ========================================================
      // HANDLE DUPLICATE PURCHASE CALLBACK
      // ========================================================

      if (!contactsGranted) {
        debugPrint(
          '[PlansScreen] '
          'Purchase $normalizedPurchaseId '
          'was already processed. '
          'Skipping duplicate contact grant.',
        );


        if (mounted) {
          setState(() {
            _isPurchasing = false;
          });
        }


        // Return normally.
        //
        // BillingService will complete the purchase.
        //
        // Credits are not granted twice.

        return;
      }


      if (!mounted) {
        return;
      }


      // ========================================================
      // RESET PURCHASE LOADING STATE
      // ========================================================

      setState(() {
        _isPurchasing = false;
      });


      // ========================================================
      // CLOSE PURCHASE CONFIRMATION BOTTOM SHEET
      // ========================================================

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }


      // ========================================================
      // WAIT FOR BOTTOM SHEET CLOSE ANIMATION
      // ========================================================

      await Future.delayed(
        const Duration(
          milliseconds: 350,
        ),
      );


      if (!mounted) {
        return;
      }


      // ========================================================
      // SHOW PURCHASE SUCCESS DIALOG
      // ========================================================

      await _showPurchaseSuccessDialog(
        planName: planName,
        contacts: contactsValue,
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[PlansScreen] '
        'Purchase activation failed: $e',
      );


      debugPrint(
        '[PlansScreen] '
        'Stack trace: $stackTrace',
      );


      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });


        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Unable to activate purchase: $e',
            ),
            backgroundColor:
                Colors.red,
          ),
        );
      }


      // IMPORTANT:
      //
      // Rethrow so BillingService DOES NOT call
      // completePurchase().
      //
      // This allows the store to redeliver an unfinished
      // successfully-paid purchase.

      rethrow;
    }
}
Future<void> _openWhatsApp() async {
  final Uri url = Uri.parse(
    'https://wa.me/918793744117?text=Hi%20UrbanHomey,%20I%20need%20help%20choosing%20a%20plan.',
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}
@override
void initState() {
  super.initState();


  // ============================================================
  // PAGE CONTROLLER
  // ============================================================

  _pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.85,
  );


  // ============================================================
  // REGISTER PURCHASE SUCCESS CALLBACK
  //
  // IMPORTANT:
  // Register callbacks BEFORE _loadPlans().
  //
  // _loadPlans() will:
  //
  // 1. Fetch active plans from Firestore.
  // 2. Extract product IDs.
  // 3. Initialize BillingService.
  // 4. Subscribe to purchaseStream.
  // 5. Load ProductDetails from the store.
  //
  // Registering callbacks first ensures that a redelivered
  // unfinished purchase can be processed safely.
  // ============================================================

 BillingService.instance.onPurchaseSuccess =
    (purchase) async {
  await _activatePurchase(
    purchaseId: purchase.purchaseID!,
    productId: purchase.productID,
  );
};


  // ============================================================
  // REGISTER PURCHASE ERROR / CANCEL CALLBACK
  // ============================================================

  BillingService.instance.onPurchaseError =
      (error) {
    if (!mounted) {
      return;
    }


    setState(() {
      _isPurchasing = false;
    });


    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          error,
        ),
        backgroundColor:
            Colors.red,
      ),
    );
  };
RazorpayService.instance.onPurchaseSuccess =
(
  payment,
  planId,
) async {

  await _activatePurchase(
    purchaseId: payment.paymentId!,
    productId: planId,
  );
};

RazorpayService.instance.onPurchaseError =
(
  error,
) {
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
  // ============================================================
  // LOAD FIRESTORE PLANS AND INITIALIZE BILLING
  // ============================================================

  _loadPlans();


  // ============================================================
  // PAGE CONTROLLER LISTENER
  // ============================================================

  _pageController.addListener(() {
    if (!mounted ||
        !_pageController.hasClients) {
      return;
    }


    final double? page =
        _pageController.page;


    if (page == null) {
      return;
    }


    final int newPage =
        page.round();


    if (newPage ==
        _currentPage) {
      return;
    }


    setState(() {
      _currentPage =
          newPage;
    });
  });
}
@override
void dispose() {
  // ============================================================
  // REMOVE SCREEN-SPECIFIC BILLING CALLBACKS
  //
  // BillingService is a singleton.
  //
  // Do NOT call BillingService.instance.dispose() here because
  // leaving PlansScreen would cancel the global purchase stream.
  // ============================================================

  BillingService.instance.onPurchaseSuccess = null;

  BillingService.instance.onPurchaseError = null;

RazorpayService.instance.onPurchaseSuccess = null;

RazorpayService.instance.onPurchaseError = null;
  // ============================================================
  // DISPOSE PAGE CONTROLLER
  // ============================================================

  _pageController.dispose();


  // ============================================================
  // DISPOSE STATE
  // ============================================================

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
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [

    isMobile
        ? _buildMobilePlanLayout(context)
        : _buildWebPlanLayout(context),

    const SizedBox(height: 32),

    InkWell(
  onTap: _openWhatsApp,
  borderRadius: BorderRadius.circular(12),
  child: const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Column(
      children: [
        Text(
          'Need help choosing a plan?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Chat with us on WhatsApp',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    ),
  ),
),

    const SizedBox(height: 20),
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
Widget _buildPlanCard(
  BuildContext context, {
  required String title,
  required String price,
  required String contacts,
  required List<String> features,
  required bool isHighlighted,
  required bool isSelected,
  required VoidCallback onTap,
  required double minHeight,
}) {
  return AnimatedContainer(
    duration: const Duration(
      milliseconds: 300,
    ),
    curve: Curves.easeOutCubic,

    constraints: BoxConstraints(
      minHeight: minHeight,
    ),

    decoration: BoxDecoration(
      color: Colors.white,

      borderRadius: BorderRadius.circular(28),

      border: Border.all(
        color: isSelected
            ? const Color(0xFFFFD700)
            : isHighlighted
                ? const Color(0xFFEC4899)
                : Colors.white.withOpacity(.20),

        width: isSelected ? 3 : 1.5,
      ),

      boxShadow: [
        BoxShadow(
          color: isHighlighted
              ? const Color(
                  0xFFEC4899,
                ).withOpacity(.25)
              : Colors.black.withOpacity(.12),

          blurRadius:
              isHighlighted ? 30 : 20,

          offset: const Offset(
            0,
            12,
          ),
        ),
      ],
    ),

    child: Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(28),

        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(28),

          child: SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),

            padding:
                const EdgeInsets.all(24),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ==============================================
                // HIGHLIGHTED BADGE
                // ==============================================

                if (isHighlighted) ...[
                  Align(
                    alignment:
                        Alignment.center,

                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
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
                            BorderRadius.circular(
                          30,
                        ),
                      ),

                      child: const Text(
                        'MOST POPULAR',

                        style: TextStyle(
                          color:
                              Colors.white,

                          fontSize:
                              11,

                          fontWeight:
                              FontWeight.w900,

                          letterSpacing:
                              1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),
                ],


                // ==============================================
                // ICON + SELECTED INDICATOR
                // ==============================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [
                    Container(
                      height: 58,
                      width: 58,

                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          begin:
                              Alignment.topLeft,

                          end:
                              Alignment.bottomRight,

                          colors: [
                            Color(
                              0xFF7C3AED,
                            ),
                            Color(
                              0xFF9333EA,
                            ),
                            Color(
                              0xFFEC4899,
                            ),
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),

                      child: const Icon(
                        Icons
                            .workspace_premium_rounded,

                        color:
                            Colors.white,

                        size: 30,
                      ),
                    ),


                    AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds:
                            250,
                      ),

                      height: 28,
                      width: 28,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,

                        color:
                            isSelected
                                ? const Color(
                                    0xFF7C3AED,
                                  )
                                : Colors
                                    .transparent,

                        border:
                            Border.all(
                          color:
                              isSelected
                                  ? const Color(
                                      0xFF7C3AED,
                                    )
                                  : Colors
                                      .grey
                                      .shade300,

                          width: 2,
                        ),
                      ),

                      child:
                          isSelected
                              ? const Icon(
                                  Icons
                                      .check_rounded,

                                  color:
                                      Colors.white,

                                  size: 18,
                                )
                              : null,
                    ),
                  ],
                ),


                const SizedBox(
                  height: 22,
                ),


                // ==============================================
                // PLAN TITLE
                // ==============================================

                Text(
                  title,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF111827,
                    ),

                    fontSize:
                        26,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),


                const SizedBox(
                  height: 6,
                ),


                // ==============================================
                // CHAT CREDITS
                // ==============================================

                Text(
                  contacts,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF7C3AED,
                    ),

                    fontSize:
                        16,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),


                const SizedBox(
                  height: 20,
                ),


                // ==============================================
                // REAL STORE PRICE
                // ==============================================

                Text(
                  price,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF111827,
                    ),

                    fontSize:
                        38,

                    fontWeight:
                        FontWeight.w900,

                    height:
                        1,
                  ),
                ),


                const SizedBox(
                  height: 7,
                ),


                const Text(
                  'One-time purchase',

                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFF64748B,
                    ),

                    fontSize:
                        13,

                    fontWeight:
                        FontWeight.w500,
                  ),
                ),


                const SizedBox(
                  height: 22,
                ),


                Divider(
                  color:
                      Colors.grey.shade200,

                  height:
                      1,
                ),


                const SizedBox(
                  height: 20,
                ),


                // ==============================================
                // FIRESTORE FEATURES
                // ==============================================

                ...features.asMap().entries.map(
                  (entry) {
                    final int index =
                        entry.key;

                    final String feature =
                        entry.value;


                    return Padding(
                      padding:
                          EdgeInsets.only(
                        bottom:
                            index ==
                                    features.length -
                                        1
                                ? 0
                                : 13,
                      ),

                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Container(
                            height:
                                22,

                            width:
                                22,

                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFF22C55E,
                              ).withOpacity(
                                .12,
                              ),

                              shape:
                                  BoxShape.circle,
                            ),

                            child:
                                const Icon(
                              Icons
                                  .check_rounded,

                              color:
                                  Color(
                                0xFF16A34A,
                              ),

                              size:
                                  15,
                            ),
                          ),


                          const SizedBox(
                            width: 10,
                          ),


                          Expanded(
                            child: Text(
                              feature,

                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFF475569,
                                ),

                                fontSize:
                                    14,

                                fontWeight:
                                    FontWeight.w600,

                                height:
                                    1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),


                const SizedBox(
                  height: 26,
                ),


                // ==============================================
                // PURCHASE BUTTON
                // ==============================================

                SizedBox(
                  width:
                      double.infinity,

                  height:
                      54,

                  child:
                      DecoratedBox(
                    decoration:
                        BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(
                            0xFF7C3AED,
                          ),
                          Color(
                            0xFF9333EA,
                          ),
                          Color(
                            0xFFEC4899,
                          ),
                        ],
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        17,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF7C3AED,
                          ).withOpacity(
                            .22,
                          ),

                          blurRadius:
                              15,

                          offset:
                              const Offset(
                            0,
                            7,
                          ),
                        ),
                      ],
                    ),

                    child:
                        const Center(
                      child: Text(
                        'SELECT PLAN',

                        style:
                            TextStyle(
                          color:
                              Colors.white,

                          fontSize:
                              14,

                          fontWeight:
                              FontWeight.w900,

                          letterSpacing:
                              .5,
                        ),
                      ),
                    ),
                  ),
                ),


                // Extra bottom room for the button shadow.

                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
Widget _buildMobilePlanLayout(
  BuildContext context,
) {
  const double cardHeight = 520;


  // ============================================================
  // LOADING
  // ============================================================

  if (_isLoadingPlans) {
    return const SizedBox(
      height: cardHeight,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }


  // ============================================================
  // ERROR
  // ============================================================

  if (_plansError != null) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white,
              size: 50,
            ),

            const SizedBox(height: 16),

            Text(
              _plansError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _loadPlans,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // NO ACTIVE PLANS
  // ============================================================

  if (_plans.isEmpty) {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Text(
          'No chat plans are available right now.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }


  // ============================================================
  // PLAN PAGE VIEW
  // ============================================================

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
            final ChatPlan plan =
                _plans[index];


            // ==================================================
            // GET REAL STORE PRODUCT
            // ==================================================

            final productDetails =
                BillingService.instance
                    .getProductDetails(
              plan.productId,
            );


            // ==================================================
            // GET REAL STORE PRICE
            // ==================================================

            final String price =
                productDetails?.price ??
                    'Unavailable';


            final bool isCurrentCard =
                _currentPage == index;


            return AnimatedContainer(
              duration: const Duration(
                milliseconds: 350,
              ),
              curve: Curves.easeOutCubic,

              margin: EdgeInsets.symmetric(
                horizontal: 10,
                vertical:
                    isCurrentCard
                        ? 0
                        : 20,
              ),

              child: _buildPlanCard(
                context,

                title:
                    plan.title,

                price:
                    price,

                contacts:
                    '${plan.contacts} Chat Credits',

                features:
                    plan.features,

                isHighlighted:
                    plan.isHighlighted,

                isSelected:
                    _selectedPlan?.id ==
                        plan.id,

                onTap: () {
                  // ============================================
                  // DO NOT ALLOW PURCHASE IF STORE PRODUCT
                  // WAS NOT LOADED
                  // ============================================

                  if (productDetails == null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This purchase is currently unavailable.',
                        ),
                        backgroundColor:
                            Colors.red,
                      ),
                    );

                    return;
                  }


                  // ============================================
                  // SELECT FIRESTORE PLAN
                  // ============================================

                  setState(() {
                    _selectedIndex =
                        index;

                    _selectedPlan =
                        plan;
                  });


                  // ============================================
                  // OPEN PURCHASE CONFIRMATION
                  // ============================================

                  _showPurchaseConfirmation(
                    context,
                    plan,
                  );
                },

                minHeight:
                    cardHeight * .90,
              ),
            );
          },
        ),
      ),


      // ========================================================
      // PAGE INDICATORS
      // ========================================================

      if (_plans.length > 1) ...[
        const SizedBox(height: 28),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: List.generate(
            _plans.length,
            (index) {
              final bool isActive =
                  _currentPage ==
                      index;

              return AnimatedContainer(
                duration: const Duration(
                  milliseconds: 300,
                ),
                curve: Curves.easeInOut,

                margin:
                    const EdgeInsets.symmetric(
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
                                Colors.white,
                                Color(
                                  0xFFFFD700,
                                ),
                              ],
                            )
                          : null,

                  color:
                      isActive
                          ? null
                          : Colors.white30,

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Swipe to compare plans',
          style: TextStyle(
            color:
                Colors.white.withOpacity(.75),
            fontSize: 13,
            fontWeight:
                FontWeight.w500,
          ),
        ),
      ],
    ],
  );
}

Widget _buildWebPlanLayout(
  BuildContext context,
) {
  // ============================================================
  // LOADING
  // ============================================================

  if (_isLoadingPlans) {
    return const SizedBox(
      height: 520,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }


  // ============================================================
  // ERROR
  // ============================================================

  if (_plansError != null) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white,
              size: 50,
            ),

            const SizedBox(height: 16),

            Text(
              _plansError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _loadPlans,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // NO ACTIVE PLANS
  // ============================================================

  if (_plans.isEmpty) {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Text(
          'No chat plans are available right now.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }


  // ============================================================
  // PLAN CARDS
  // ============================================================

  return LayoutBuilder(
    builder: (
      context,
      constraints,
    ) {
      // Keep cards readable if you later add more plans.

      final double availableWidth =
          constraints.maxWidth;

      final double spacing =
          _plans.length > 1
              ? 20
              : 0;

      final double cardWidth =
          _plans.length == 1
              ? 440
              : ((availableWidth -
                          (spacing *
                              (_plans.length - 1))) /
                      _plans.length)
                  .clamp(
                    280.0,
                    420.0,
                  )
                  .toDouble();


      return Wrap(
        alignment:
            WrapAlignment.center,

        crossAxisAlignment:
            WrapCrossAlignment.start,

        spacing:
            spacing,

        runSpacing:
            24,

        children: List.generate(
          _plans.length,
          (index) {
            final ChatPlan plan =
                _plans[index];


            // ==================================================
            // GET REAL STORE PRODUCT
            // ==================================================

            final productDetails =
                BillingService.instance
                    .getProductDetails(
              plan.productId,
            );


            // ==================================================
            // GET REAL STORE PRICE
            // ==================================================

            final String price =
                productDetails?.price ??
                    'Unavailable';


            return SizedBox(
              width: cardWidth,

              child: _buildPlanCard(
                context,

                title:
                    plan.title,

                price:
                    price,

                contacts:
                    '${plan.contacts} Chat Credits',

                features:
                    plan.features,

                isHighlighted:
                    plan.isHighlighted,

                isSelected:
                    _selectedPlan?.id ==
                        plan.id,

                onTap: () {
                  // ============================================
                  // DO NOT ALLOW PURCHASE IF STORE PRODUCT
                  // WAS NOT LOADED
                  // ============================================

                  if (productDetails == null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This purchase is currently unavailable.',
                        ),
                        backgroundColor:
                            Colors.red,
                      ),
                    );

                    return;
                  }


                  // ============================================
                  // SELECT FIRESTORE PLAN
                  // ============================================

                  setState(() {
                    _selectedIndex =
                        index;

                    _selectedPlan =
                        plan;
                  });


                  // ============================================
                  // OPEN PURCHASE CONFIRMATION
                  // ============================================

                  _showPurchaseConfirmation(
                    context,
                    plan,
                  );
                },

                minHeight:
                    500,
              ),
            );
          },
        ),
      );
    },
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
  ChatPlan plan,
) {
  final productDetails =
      BillingService.instance
          .getProductDetails(
    plan.productId,
  );

  if (productDetails == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This purchase is currently unavailable.',
        ),
        backgroundColor: Colors.red,
      ),
    );

    return;
  }


  final String price =
      productDetails.price;


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: !_isPurchasing,
    enableDrag: !_isPurchasing,

    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (
          context,
          setSheetState,
        ) {
          return PopScope(
            canPop: !_isPurchasing,

            child: Container(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(sheetContext)
                            .size
                            .height *
                        .92,
              ),

              decoration:
                  const BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),

              child: SafeArea(
                top: false,

                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    24,
                    14,
                    24,
                    24,
                  ),

                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      // =========================================
                      // HANDLE
                      // =========================================

                      Container(
                        height: 5,
                        width: 60,

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.grey.shade300,

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),


                      const SizedBox(
                        height: 24,
                      ),


                      // =========================================
                      // PREMIUM ICON
                      // =========================================

                      AnimatedContainer(
                        duration:
                            const Duration(
                          milliseconds: 300,
                        ),

                        height: 80,
                        width: 80,

                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,

                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(
                                0xFF7C3AED,
                              ),
                              Color(
                                0xFF9333EA,
                              ),
                              Color(
                                0xFFEC4899,
                              ),
                            ],
                          ),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(
                                0xFF7C3AED,
                              ).withOpacity(
                                .25,
                              ),

                              blurRadius: 20,

                              offset:
                                  const Offset(
                                0,
                                10,
                              ),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons
                              .workspace_premium_rounded,

                          color:
                              Colors.white,

                          size: 40,
                        ),
                      ),


                      const SizedBox(
                        height: 20,
                      ),


                      // =========================================
                      // PLAN NAME
                      // =========================================

                      Text(
                        plan.title,

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          fontSize: 28,

                          fontWeight:
                              FontWeight.w900,

                          color:
                              Color(
                            0xFF111827,
                          ),
                        ),
                      ),


                      const SizedBox(
                        height: 8,
                      ),


                      // =========================================
                      // CONTACTS
                      // =========================================

                      Text(
                        '${plan.contacts} Chat Credits',

                        style:
                            const TextStyle(
                          fontSize: 18,

                          fontWeight:
                              FontWeight.w700,

                          color:
                              Color(
                            0xFF9333EA,
                          ),
                        ),
                      ),


                      const SizedBox(
                        height: 8,
                      ),


                      // =========================================
                      // REAL STORE PRICE
                      // =========================================

                      Text(
                        price,

                        style:
                            const TextStyle(
                          fontSize: 34,

                          fontWeight:
                              FontWeight.w900,

                          color:
                              Color(
                            0xFF111827,
                          ),
                        ),
                      ),


                      const SizedBox(
                        height: 6,
                      ),


                      const Text(
                        'One-time purchase',

                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFF64748B,
                          ),

                          fontSize: 13,

                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),


                      const SizedBox(
                        height: 24,
                      ),


                      // =========================================
                      // FIRESTORE PLAN FEATURES
                      // =========================================

                      Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets.all(
                          18,
                        ),

                        decoration:
                            BoxDecoration(
                          gradient:
                              LinearGradient(
                            colors: [
                              const Color(
                                0xFF7C3AED,
                              ).withOpacity(
                                .06,
                              ),

                              const Color(
                                0xFFEC4899,
                              ).withOpacity(
                                .06,
                              ),
                            ],
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),

                          border:
                              Border.all(
                            color:
                                const Color(
                              0xFF9333EA,
                            ).withOpacity(
                              .10,
                            ),
                          ),
                        ),

                        child: Column(
                          children:
                              List.generate(
                            plan.features.length,
                            (index) {
                              final String feature =
                                  plan.features[
                                      index];

                              return Padding(
                                padding:
                                    EdgeInsets.only(
                                  bottom:
                                      index ==
                                              plan.features.length -
                                                  1
                                          ? 0
                                          : 12,
                                ),

                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons
                                          .check_circle_rounded,

                                      color:
                                          Colors.green,
                                    ),

                                    const SizedBox(
                                      width: 10,
                                    ),

                                    Expanded(
                                      child: Text(
                                        feature,

                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),


                      const SizedBox(
                        height: 24,
                      ),
// =========================================
// PAYMENT METHOD
// =========================================

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Choose Payment Method",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: Color(0xFF111827),
    ),
  ),
),

const SizedBox(height: 16),

Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: _selectedPaymentMethod ==
              PaymentMethod.razorpay
          ? const Color(0xFF7C3AED)
          : Colors.grey.shade300,
      width: 2,
    ),
  ),
  child: RadioListTile<PaymentMethod>(
    value: PaymentMethod.razorpay,
    groupValue: _selectedPaymentMethod,
    activeColor: const Color(0xFF7C3AED),
    onChanged: (value) {
      if (value == null) return;

      setState(() {
        _selectedPaymentMethod = value;
      });

      setSheetState(() {});
    },
    title: const Text(
      "Razorpay",
      style: TextStyle(
        fontWeight: FontWeight.w700,
      ),
    ),
    subtitle: const Text(
      "UPI • Google Pay • PhonePe • Cards",
    ),
  ),
),

const SizedBox(height: 14),

Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: _selectedPaymentMethod ==
              PaymentMethod.inApp
          ? const Color(0xFF7C3AED)
          : Colors.grey.shade300,
      width: 2,
    ),
  ),
  child: RadioListTile<PaymentMethod>(
    value: PaymentMethod.inApp,
    groupValue: _selectedPaymentMethod,
    activeColor: const Color(0xFF7C3AED),
    onChanged: (value) {
      if (value == null) return;

      setState(() {
        _selectedPaymentMethod = value;
      });

      setSheetState(() {});
    },
    title: const Text(
      "Google Play / Apple",
      style: TextStyle(
        fontWeight: FontWeight.w700,
      ),
    ),
    subtitle: const Text(
      "Official In-App Purchase",
    ),
  ),
),

const SizedBox(height: 24),

                      // =========================================
                      // SECURITY / PROCESSING MESSAGE
                      // =========================================

                      AnimatedContainer(
                        duration:
                            const Duration(
                          milliseconds: 250,
                        ),

                        padding:
                            const EdgeInsets.all(
                          14,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              _isPurchasing
                                  ? const Color(
                                      0xFF7C3AED,
                                    ).withOpacity(
                                      .08,
                                    )
                                  : Colors
                                      .green
                                      .shade50,

                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),

                        child: Row(
                          children: [
                            Icon(
                              _isPurchasing
                                  ? Icons
                                      .lock_clock_rounded
                                  : Icons
                                      .verified_user_rounded,

                              color:
                                  _isPurchasing
                                      ? const Color(
                                          0xFF7C3AED,
                                        )
                                      : Colors
                                          .green
                                          .shade700,
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  AnimatedSwitcher(
                                duration:
                                    const Duration(
                                  milliseconds:
                                      200,
                                ),

                                child: Text(
                                  _isPurchasing
                                      ? 'Please wait while your secure purchase is being processed.'
                                      : 'Secure one-time purchase through the app store.',

                                  key:
                                      ValueKey(
                                    _isPurchasing,
                                  ),

                                  style:
                                      TextStyle(
                                    color:
                                        _isPurchasing
                                            ? const Color(
                                                0xFF7C3AED,
                                              )
                                            : Colors
                                                .green
                                                .shade800,

                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),


                      const SizedBox(
                        height: 28,
                      ),


                      // =========================================
                      // PURCHASE BUTTON
                      // =========================================

                      SizedBox(
                        width:
                            double.infinity,

                        height: 58,

                        child:
                            ElevatedButton(
                          onPressed:
                              _isPurchasing
                                  ? null
                                  : () async {
                                      // =========================
                                      // ENSURE THIS PLAN REMAINS
                                      // SELECTED
                                      // =========================

                                      setState(() {
                                        _selectedPlan =
                                            plan;

                                        _isPurchasing =
                                            true;
                                      });


                                      // Update open bottom sheet.

                                      setSheetState(
                                        () {},
                                      );


                                      try {
                                        // =======================
                                        // PURCHASE FIRESTORE PLAN
                                        // USING STORE PRODUCT ID
                                        // =======================

                                       switch (_selectedPaymentMethod) {
  case PaymentMethod.inApp:
    await BillingService.instance.buyPlan(
      plan.productId,
    );
    break;

  case PaymentMethod.razorpay:
  await RazorpayService.instance.buyPlan(
    plan.productId,
    plan.amount,
    FirebaseAuth.instance.currentUser!.uid,
  );
  break;
}
                                      } catch (e) {
                                        if (!mounted) {
                                          return;
                                        }


                                        setState(() {
                                          _isPurchasing =
                                              false;
                                        });


                                        if (sheetContext
                                            .mounted) {
                                          setSheetState(
                                            () {},
                                          );
                                        }


                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content:
                                                Text(
                                              e.toString(),
                                            ),

                                            backgroundColor:
                                                Colors.red,
                                          ),
                                        );
                                      }
                                    },

                          style:
                              ElevatedButton.styleFrom(
                            disabledBackgroundColor:
                                Colors.transparent,

                            backgroundColor:
                                Colors.transparent,

                            shadowColor:
                                Colors.transparent,

                            padding:
                                EdgeInsets.zero,
                          ),

                          child: Ink(
                            decoration:
                                BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),

                              gradient:
                                  LinearGradient(
                                colors:
                                    _isPurchasing
                                        ? [
                                            const Color(
                                              0xFF7C3AED,
                                            ).withOpacity(
                                              .70,
                                            ),

                                            const Color(
                                              0xFF9333EA,
                                            ).withOpacity(
                                              .70,
                                            ),

                                            const Color(
                                              0xFFEC4899,
                                            ).withOpacity(
                                              .70,
                                            ),
                                          ]
                                        : const [
                                            Color(
                                              0xFF7C3AED,
                                            ),
                                            Color(
                                              0xFF9333EA,
                                            ),
                                            Color(
                                              0xFFEC4899,
                                            ),
                                          ],
                              ),

                              boxShadow:
                                  _isPurchasing
                                      ? []
                                      : [
                                          BoxShadow(
                                            color:
                                                const Color(
                                              0xFF7C3AED,
                                            ).withOpacity(
                                              .25,
                                            ),

                                            blurRadius:
                                                15,

                                            offset:
                                                const Offset(
                                              0,
                                              8,
                                            ),
                                          ),
                                        ],
                            ),

                            child: Center(
                              child:
                                  AnimatedSwitcher(
                                duration:
                                    const Duration(
                                  milliseconds:
                                      250,
                                ),

                                child:
                                    _isPurchasing
                                        ? const Row(
                                            key:
                                                ValueKey(
                                              'purchasing',
                                            ),

                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,

                                            children: [
                                              SizedBox(
                                                height:
                                                    22,

                                                width:
                                                    22,

                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth:
                                                      2.5,

                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors
                                                        .white,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(
                                                width:
                                                    12,
                                              ),

                                              Text(
                                                'PROCESSING PURCHASE...',

                                                style:
                                                    TextStyle(
                                                  color:
                                                      Colors.white,

                                                  fontSize:
                                                      14,

                                                  fontWeight:
                                                      FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            'BUY ${plan.contacts} CHAT CREDITS • $price',

                                            key:
                                                const ValueKey(
                                              'confirm',
                                            ),

                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.white,

                                              fontSize:
                                                  15,

                                              fontWeight:
                                                  FontWeight.w800,
                                            ),
                                          ),
                              ),
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(
                        height: 12,
                      ),


                      // =========================================
                      // CANCEL / WAIT MESSAGE
                      // =========================================

                      AnimatedSwitcher(
                        duration:
                            const Duration(
                          milliseconds: 200,
                        ),

                        child:
                            _isPurchasing
                                ? const Padding(
                                    key:
                                        ValueKey(
                                      'waitMessage',
                                    ),

                                    padding:
                                        EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),

                                    child:
                                        Text(
                                      "Please don't close the app while processing",

                                      textAlign:
                                          TextAlign.center,

                                      style:
                                          TextStyle(
                                        color:
                                            Color(
                                          0xFF94A3B8,
                                        ),

                                        fontSize:
                                            12,

                                        fontWeight:
                                            FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : TextButton(
                                    key:
                                        const ValueKey(
                                      'cancelButton',
                                    ),

                                    onPressed:
                                        () {
                                      Navigator.pop(
                                        sheetContext,
                                      );
                                    },

                                    child:
                                        const Text(
                                      'Cancel',

                                      style:
                                          TextStyle(
                                        color:
                                            Colors.grey,
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
    },
  );
}
}