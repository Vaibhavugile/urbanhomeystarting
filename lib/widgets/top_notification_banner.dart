import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class TopNotificationBanner {
  static OverlayEntry? _currentBanner;
  static Timer? _timer;

  static void show({
    required BuildContext context,
    required String title,
    required String body,
  }) {
    _timer?.cancel();

    _currentBanner?.remove();

    final overlay = Overlay.of(context);

    _currentBanner = OverlayEntry(
      builder: (context) {
        return Positioned(
          top:
              MediaQuery.of(context)
                      .padding
                      .top +
                  90,
          left: 16,
          right: 16,

          child: Material(
            color: Colors.transparent,

            child: TweenAnimationBuilder<
                double>(
              duration: const Duration(
                milliseconds: 450,
              ),

              curve:
                  Curves.easeOutBack,

              tween: Tween(
                begin: -150,
                end: 0,
              ),

              builder: (
                context,
                value,
                child,
              ) {
                return Transform.translate(
                  offset:
                      Offset(0, value),
                  child: child,
                );
              },

              child: Dismissible(
                key: UniqueKey(),

                direction:
                    DismissDirection.up,

                onDismissed: (_) {
                  _currentBanner
                      ?.remove();

                  _currentBanner =
                      null;
                },

                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(
                    28,
                  ),

                  onTap: () {
                    _currentBanner
                        ?.remove();

                    _currentBanner =
                        null;
                  },

                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      28,
                    ),

                    child:
                        BackdropFilter(
                      filter:
                          ImageFilter.blur(
                        sigmaX: 15,
                        sigmaY: 15,
                      ),

                      child:
                          Container(
                        padding:
                            const EdgeInsets
                                .all(
                          18,
                        ),

                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            begin:
                                Alignment
                                    .topLeft,
                            end:
                                Alignment
                                    .bottomRight,
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
                            28,
                          ),

                          border:
                              Border.all(
                            color: Colors
                                .white
                                .withOpacity(
                              .18,
                            ),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(
                                0xFF7C3AED,
                              ).withOpacity(
                                .30,
                              ),
                              blurRadius:
                                  30,
                              spreadRadius:
                                  2,
                              offset:
                                  const Offset(
                                0,
                                12,
                              ),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [

                            Container(
                              height:
                                  56,
                              width:
                                  56,

                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .white
                                    .withOpacity(
                                  .15,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                              ),

                              child:
                                  const Icon(
                                Icons
                                    .notifications_active_rounded,
                                color:
                                    Colors.white,
                                size:
                                    28,
                              ),
                            ),

                            const SizedBox(
                              width:
                                  16,
                            ),

                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    title,
                                    maxLines:
                                        1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        4,
                                  ),

                                  Text(
                                    body,
                                    maxLines:
                                        2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .white
                                          .withOpacity(
                                        .95,
                                      ),
                                      fontSize:
                                          13,
                                      height:
                                          1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              onPressed:
                                  () {
                                _currentBanner
                                    ?.remove();

                                _currentBanner =
                                    null;
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .close_rounded,
                                color:
                                    Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(
      _currentBanner!,
    );

    _timer = Timer(
      const Duration(
        seconds: 4,
      ),
      () {
        _currentBanner?.remove();
        _currentBanner = null;
      },
    );
  }
}