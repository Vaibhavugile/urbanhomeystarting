import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSearchResult {
  final String address;
  final String? placeId;
  final double? latitude;
  final double? longitude;

  const LocationSearchResult({
    required this.address,
    this.placeId,
    this.latitude,
    this.longitude,
  });
}

class LocationSearchScreen extends StatefulWidget {
  final String city;
  final double cityLatitude;
  final double cityLongitude;
  final int searchRadiusMeters;

  const LocationSearchScreen({
    super.key,
    required this.city,
    required this.cityLatitude,
    required this.cityLongitude,
    this.searchRadiusMeters = 100000,
  });

  @override
  State<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState
    extends State<LocationSearchScreen> {
  static const Color kPrimaryColor =
      Color(0xff7C3AED);

  static const Color kAccentColor =
      Color(0xffEC4899);

  static const Color kDarkText =
      Color(0xff111827);

  static const Color kMediumText =
      Color(0xff64748B);

  static const Color kBorderColor =
      Color(0xffE5E7EB);

  static const Color kBackgroundColor =
      Color(0xffF8FAFC);

  static const LinearGradient kGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff7C3AED),
      Color(0xff9333EA),
      Color(0xffEC4899),
    ],
  );

  late final TextEditingController
      _addressController;

  final FocusNode _focusNode =
      FocusNode();

  double? _latitude;
  double? _longitude;
  String? _placeId;

  @override
  void initState() {
    super.initState();

    _addressController =
        TextEditingController();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _addressController.dispose();
    super.dispose();
  }
    double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat =
        (lat2 - lat1) * math.pi / 180;

    final dLon =
        (lon2 - lon1) * math.pi / 180;

    final a =
        math.sin(dLat / 2) *
                math.sin(dLat / 2) +
            math.cos(lat1 * math.pi / 180) *
                math.cos(lat2 * math.pi / 180) *
                math.sin(dLon / 2) *
                math.sin(dLon / 2);

    final c = 2 *
        math.atan2(
          math.sqrt(a),
          math.sqrt(1 - a),
        );

    return earthRadiusKm * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kDarkText,
          ),
        ),

        titleSpacing: 0,

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              "Find Property Location",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: kDarkText,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              widget.city,
              style: const TextStyle(
                fontSize: 13,
                color: kMediumText,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior
                  .onDrag,

          padding:
              const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              //------------------------------------------------
              // PREMIUM HERO
              //------------------------------------------------

            //   Container(
            //     width: double.infinity,

            //     padding:
            //         const EdgeInsets.all(24),

            //     decoration: BoxDecoration(
            //       gradient: kGradient,

            //       borderRadius:
            //           BorderRadius.circular(30),

            //       boxShadow: [

            //         BoxShadow(
            //           color:
            //               kPrimaryColor.withOpacity(.22),
            //           blurRadius: 35,
            //           offset:
            //               const Offset(0, 18),
            //         ),
            //       ],
            //     ),

            //     child: Row(
            //       children: [

            //         Container(
            //           width: 70,
            //           height: 70,

            //           decoration:
            //               BoxDecoration(
            //             color: Colors.white
            //                 .withOpacity(.15),
            //             shape: BoxShape.circle,
            //           ),

            //           child: const Icon(
            //             Icons.location_searching,
            //             color: Colors.white,
            //             size: 34,
            //           ),
            //         ),

            //         const SizedBox(width: 18),

            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment:
            //                 CrossAxisAlignment.start,

            //             children: [

            //               const Text(
            //                 "Find Your Flat",
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontWeight:
            //                       FontWeight.w800,
            //                   fontSize: 24,
            //                 ),
            //               ),

            //               const SizedBox(height: 8),

            //               Text(
            //                 "Search apartments,\nlandmarks and societies\nwithin ${widget.city}.",
            //                 style: const TextStyle(
            //                   color: Colors.white70,
            //                   height: 1.45,
            //                   fontSize: 14,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),

            //   const SizedBox(height: 26),

              Row(
                children: [

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color:
                          const Color(0xffF3E8FF),
                      borderRadius:
                          BorderRadius.circular(
                              100),
                    ),

                    child: Row(
                      children: [

                        const Icon(
                          Icons.location_city,
                          color: kPrimaryColor,
                          size: 18,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          widget.city,
                          style:
                              const TextStyle(
                            color:
                                kPrimaryColor,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color:
                          Colors.green.shade50,
                      borderRadius:
                          BorderRadius.circular(
                              100),
                    ),

                    child: const Row(
                      children: [

                        Icon(
                          Icons.verified,
                          size: 18,
                          color: Colors.green,
                        ),

                        SizedBox(width: 6),

                        Text(
                          "100 km",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                "Search Address",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: kDarkText,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(24),
                  border: Border.all(
                    color: kBorderColor,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(.05),
                      blurRadius: 28,
                      offset:
                          const Offset(0, 14),
                    ),
                  ],
                ),

                child:GooglePlaceAutoCompleteTextField(
  textEditingController: _addressController,
  focusNode: _focusNode,
  googleAPIKey: 'AIzaSyBK82kg-QdV1TdTrOoC3-jvbSstRhz1wZ0',

  debounceTime: 500,
  isLatLngRequired: true,
  countries: const ["in"],

  latitude: widget.cityLatitude,
  longitude: widget.cityLongitude,
  radius: widget.searchRadiusMeters,

  isCrossBtnShown: false,

  inputDecoration: InputDecoration(
    border: InputBorder.none,

    hintText:
        "Search apartment, street or landmark",

    hintStyle: const TextStyle(
      fontSize: 15,
      color: kMediumText,
      fontWeight: FontWeight.w500,
    ),

    prefixIcon: Container(
      margin: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: const Icon(
        Icons.search_rounded,
        color: Colors.white,
        size: 22,
      ),
    ),

    suffixIcon:
        ValueListenableBuilder<TextEditingValue>(
      valueListenable: _addressController,
      builder: (_, value, __) {

        if (value.text.isEmpty) {
          return const SizedBox();
        }

        return IconButton(
          splashRadius: 20,

          icon: const Icon(
            Icons.close_rounded,
            color: kMediumText,
          ),

          onPressed: () {

            _addressController.clear();

            setState(() {
              _latitude = null;
              _longitude = null;
              _placeId = null;
            });

          },
        );
      },
    ),

    contentPadding:
        const EdgeInsets.symmetric(
      vertical: 18,
      horizontal: 12,
    ),
  ),

  itemClick: (Prediction prediction) {

    final address =
        prediction.description ?? '';

    _addressController.value =
        TextEditingValue(
      text: address,
      selection:
          TextSelection.collapsed(
        offset: address.length,
      ),
    );

    _placeId = prediction.placeId;

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      if (!mounted) return;

      _focusNode.unfocus();

    });
  },
    getPlaceDetailWithLatLng:
      (Prediction prediction) {

    final lat =
        double.tryParse(
      prediction.lat ?? '',
    );

    final lng =
        double.tryParse(
      prediction.lng ?? '',
    );

    if (lat == null ||
        lng == null) {
      return;
    }

    //-------------------------------------------------------
    // 100 KM VALIDATION
    //-------------------------------------------------------

    final distance =
        _calculateDistanceKm(
      widget.cityLatitude,
      widget.cityLongitude,
      lat,
      lng,
    );

    if (distance > 100) {

      _addressController.clear();

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          behavior:
              SnackBarBehavior.floating,

          backgroundColor:
              Colors.red.shade600,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),

          margin:
              const EdgeInsets.all(16),

          content: Row(
            children: [

              const Icon(
                Icons.location_off,
                color: Colors.white,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  "Please choose a location within 100 km of ${widget.city}.",
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      return;
    }

    //-------------------------------------------------------
    // VALID LOCATION
    //-------------------------------------------------------

    setState(() {
      _latitude = lat;
      _longitude = lng;
      _placeId =
          prediction.placeId;
    });

    Navigator.pop(
      context,
      LocationSearchResult(
        address:
            _addressController.text,
        latitude: lat,
        longitude: lng,
        placeId:
            prediction.placeId,
      ),
    );
  },

  seperatedBuilder:
      const SizedBox(height: 8),

  itemBuilder: (
    context,
    index,
    Prediction prediction,
  ) {

    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              Colors.grey.shade200,
        ),

        boxShadow: [

          BoxShadow(
            color: Colors.black
                .withOpacity(.03),
            blurRadius: 15,
            offset:
                const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            width: 46,
            height: 46,

            decoration:
                BoxDecoration(
              color: const Color(
                      0xffF3E8FF)
                  .withOpacity(.9),

              borderRadius:
                  BorderRadius.circular(
                      14),
            ),

            child: const Icon(
              Icons.location_on,
              color: kPrimaryColor,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  prediction.description ??
                      "",
                  maxLines: 2,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 15,
                    color:
                        kDarkText,
                  ),
                ),

                const SizedBox(
                    height: 4),

                Text(
                  widget.city,
                  style:
                      const TextStyle(
                    color:
                        kMediumText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            size: 15,
            color: kMediumText,
          ),
        ],
      ),
    );
  },
),
              ),
const SizedBox(height: 24),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.grey.shade200,
    ),
  ),
  child: Row(
    children: [

      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: kGradient,
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.verified_user_rounded,
          color: Colors.white,
        ),
      ),

      const SizedBox(width: 14),

      const Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              "Verified Google Locations",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: kDarkText,
              ),
            ),

            SizedBox(height: 4),

            Text(
              "Only locations within 100 km can be selected.",
              style: TextStyle(
                color: kMediumText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(height: 20),

Center(
  child: Text(
    "Powered by Google Places",
    style: TextStyle(
      color: Colors.grey.shade500,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  ),
),

const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}
    }
    