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
  String? _selectedPlanName;
String? _selectedContacts;

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Basic',
      'price': '₹99',
      'contacts': '5 Contacts',
      'features': [
        'Basic features',
        'Limited support',
        'Ad-supported',
      ],
      'isHighlighted': false,
    },
    {
      'title': 'Standard',
      'price': '₹299',
      'contacts': '20 Contacts',
      'features': [
        'All Basic features',
        'Priority support',
        'Ad-free experience',
      ],
      'isHighlighted': false,
    },
    {
      'title': 'Pro',
      'price': '₹499',
      'contacts': '40 Contacts',
      'features': [
        'Priority support',
        'Ad-free experience',
        'Exclusive insights'
      ],
      'isHighlighted': true,
    },
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
    await BillingService.instance.initialize();

    BillingService.instance.onPurchaseSuccess =
        (purchase) async {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final firestore = FirebaseFirestore.instance;

      final contactsValue = int.tryParse(
        (_selectedContacts ?? "").replaceAll(
          RegExp(r'\D'),
          '',
        ),
      );

      if (contactsValue == null) return;

      try {
        await firestore
            .collection('users')
            .doc(user.uid)
            .set(
          {
            'currentPlan': _selectedPlanName,
            'currentPlanContacts': contactsValue,
            'remainingContacts': contactsValue,
            'planPurchaseDate':
                FieldValue.serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );

        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('purchases')
            .add({
          'planName': _selectedPlanName,
          'contactsPurchased': contactsValue,
          'productId': purchase.productID,
          'purchaseId': purchase.purchaseID,
          'purchaseDate':
              FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "🎉 Plan activated successfully!",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    };

    BillingService.instance.onPurchaseError =
        (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    };
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Billing initialization failed: $e",
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

 void _showPurchaseConfirmation(
  BuildContext context,
  String planName,
  String contactsString,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
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
              Container(
                height: 5,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF7C3AED),
                      Color(0xFF9333EA),
                      Color(0xFFEC4899),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 20),

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

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF9333EA,
                  ).withOpacity(.08),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Instant plan activation",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Access premium contacts",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Priority matching",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Your purchase is securely stored in your account.",
                        style: TextStyle(
                          color:
                              Colors.green.shade800,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                 onPressed: () async {
  try {
    await BillingService.instance.buyBasicPlan();
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ),
    );
  }
},
                  style: ElevatedButton
                      .styleFrom(
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
                          BorderRadius
                              .circular(
                                  18),
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(
                              0xFF7C3AED),
                          Color(
                              0xFF9333EA),
                          Color(
                              0xFFEC4899),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "CONFIRM PURCHASE",
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pop(
                      context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}