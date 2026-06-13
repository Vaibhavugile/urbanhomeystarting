import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/liked_by_me_list.dart';
import 'package:mytennat/screens/who_liked_me_list.dart';

class ActivityScreen extends StatefulWidget {
  final String profileType;
  final String profileId;

  const ActivityScreen({
    super.key,
    required this.profileType,
    required this.profileId,
  });

  @override
  State<ActivityScreen> createState() =>
      _ActivityScreenState();
}

class _ActivityScreenState
    extends State<ActivityScreen> {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        backgroundColor:
            const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration:
                const BoxDecoration(
              gradient:
                  LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF9333EA),
                  Color(0xFFEC4899),
                ],
              ),
            ),
          ),
          centerTitle: true,
          title: const Text(
            "Activity",
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            "Please login to continue",
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            const Color(0xFFF8FAFC),

        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(
                  150),
          child: Container(
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
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              Navigator.pop(
                                  context),
                          icon:
                              const Icon(
                            Icons
                                .arrow_back_ios_new_rounded,
                            color: Colors
                                .white,
                          ),
                        ),

                        const Expanded(
                          child: Text(
                            "Activity",
                            textAlign:
                                TextAlign
                                    .center,
                            style:
                                TextStyle(
                              color: Colors
                                  .white,
                              fontSize:
                                  24,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 48,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  Container(
                    margin:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 20,
                    ),
                    padding:
                        const EdgeInsets
                            .all(6),
                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withOpacity(
                              .15),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                    ),
                    child:
                        const TabBar(
                      dividerColor:
                          Colors
                              .transparent,
                      indicatorSize:
                          TabBarIndicatorSize
                              .tab,
                      indicator:
                          BoxDecoration(
                        color: Colors
                            .white,
                        borderRadius:
                            BorderRadius
                                .all(
                          Radius.circular(
                              16),
                        ),
                      ),
                      labelColor:
                          Color(
                              0xFF7C3AED),
                      unselectedLabelColor:
                          Colors
                              .white,
                      labelStyle:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                      tabs: [
                        Tab(
                          icon: Icon(
                            Icons
                                .favorite_rounded,
                          ),
                          text:
                              "Liked",
                        ),
                        Tab(
                          icon: Icon(
                            Icons
                                .favorite_border_rounded,
                          ),
                          text:
                              "Received",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        body: Container(
          decoration:
              const BoxDecoration(
            color:
                Color(0xFFF8FAFC),
          ),
          child: TabBarView(
            children: [
              LikedByMeList(
                currentUserId:
                    _currentUser!.uid,
              ),
              WhoLikedMeList(
                currentUserId:
                    _currentUser!.uid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}