// lib/widgets/profile_display_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:mytennat/screens/full_screen_gallery.dart';
// ===============================
// PREMIUM 2026 LUXURY PALETTES
// ===============================

final List<MapEntry<Color, Color>> _vibrantColorPalettes = [

  // MyTennat Primary Purple
  const MapEntry(
    Color(0xFF5B21B6),
    Color(0xFF7C3AED),
  ),

  // Primary → Secondary
  const MapEntry(
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
  ),

  // Secondary → Accent
  const MapEntry(
    Color(0xFF9333EA),
    Color(0xFFEC4899),
  ),

  // Deep Purple → Pink
  const MapEntry(
    Color(0xFF6D28D9),
    Color(0xFFEC4899),
  ),

  // Royal Violet
  const MapEntry(
    Color(0xFF4C1D95),
    Color(0xFFC084FC),
  ),

  // Soft Purple
  const MapEntry(
    Color(0xFF7C3AED),
    Color(0xFFD8B4FE),
  ),

  // Luxury Magenta
  const MapEntry(
    Color(0xFF86198F),
    Color(0xFFF472B6),
  ),

  // Premium Indigo
  const MapEntry(
    Color(0xFF4338CA),
    Color(0xFF8B5CF6),
  ),

  // Glass Purple
  const MapEntry(
    Color(0xFF581C87),
    Color(0xFFA855F7),
  ),

  // Dark Premium
  const MapEntry(
    Color(0xFF312E81),
    Color(0xFF9333EA),
  ),

  // Signature MyTennat
  const MapEntry(
    Color(0xFF7C3AED),
    Color(0xFFEC4899),
  ),
];
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
// Helper widget to build consistent sections (Cards)
Widget _buildSection({
  required String title,
  required List<Widget> children,
  EdgeInsetsGeometry? margin,
  EdgeInsetsGeometry? padding,
}) {
  return Container(
    margin: margin ??
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: const Color(0xFFE9EDF3),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.04),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Header
          Row(
            children: [

              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: kPrimaryGradient,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kDarkText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withOpacity(.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          ...children,
        ],
      ),
    ),
  );
}
Widget _buildVerificationBadge(
  dynamic profile,
) {
  final bool isVerified =
      profile.userProfile.isVerified == true;

  final String verificationStatus =
      profile.userProfile.verificationStatus
          ?.toString()
          .trim()
          .toLowerCase() ??
      '';

  Color badgeColor;
  List<Color> badgeGradient;
  IconData badgeIcon;
  String badgeText;

  if (isVerified) {
    badgeColor = const Color(0xFF00C853);

    badgeGradient = const [
      Color(0xFF00C853),
      Color(0xFF64DD17),
    ];

    badgeIcon = Icons.verified_rounded;
    badgeText = "Verified";
  } else if (verificationStatus == "pending") {
    badgeColor = const Color(0xFFFF9800);

    badgeGradient = const [
      Color(0xFFFF9800),
      Color(0xFFFFC107),
    ];

    badgeIcon = Icons.hourglass_top_rounded;
    badgeText = "Verification Pending";
  } else if (verificationStatus == "rejected") {
    badgeColor = const Color(0xFFFF5252);

    badgeGradient = const [
      Color(0xFFFF5252),
      Color(0xFFFF1744),
    ];

    badgeIcon = Icons.gpp_bad_rounded;
    badgeText = "Verification Failed";
  } else {
    badgeColor = const Color(0xFF607D8B);

    badgeGradient = const [
      Color(0xFF607D8B),
      Color(0xFF90A4AE),
    ];

    badgeIcon = Icons.shield_outlined;
    badgeText = "Not Verified";
  }

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: badgeGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: Colors.white.withOpacity(.28),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: badgeColor.withOpacity(.45),
          blurRadius: 18,
          spreadRadius: 1,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.18),
            shape: BoxShape.circle,
          ),
          child: Icon(
            badgeIcon,
            color: Colors.white,
            size: 14,
          ),
        ),

        const SizedBox(width: 8),

        Flexible(
          child: Text(
            badgeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: .2,
              height: 1,
            ),
          ),
        ),

        if (isVerified) ...[
          const SizedBox(width: 6),

          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFF176),
                  Color(0xFFFFC107),
                ],
              ),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],

        if (verificationStatus == "pending") ...[
          const SizedBox(width: 6),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "LIVE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
// Helper widget to display a single profile field (label: value format) with an optional icon - (kept for non-grid sections)
Widget _buildProfileField(
  String label,
  String? value, {
  IconData? icon,
  int iconColorIndex = 0,
}) {
  if (value == null ||
      value.trim().isEmpty ||
      value == "N/A") {
    return const SizedBox.shrink();
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFE8ECF2),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.03),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      children: [

        if (icon != null)
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),

        if (icon != null)
          const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: kMediumText,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kDarkText,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
// Helper for displaying list fields (used for sections that remain as text chips, if any)
Widget _buildProfileListField(
  String title,
  List<String>? values,
) {
  // ============================================================
  // CLEAN VALUES
  // ============================================================

  final List<String> validValues =
      values
          ?.where((item) {
            final String value =
                item.trim();

            if (value.isEmpty) {
              return false;
            }

            final String normalized =
                value.toLowerCase();

            return normalized != 'n/a' &&
                normalized != 'null' &&
                normalized != 'none' &&
                normalized != 'not specified';
          })
          .toList() ??
      [];

  // ============================================================
  // EMPTY → HIDE COMPLETE SECTION
  // ============================================================

  if (validValues.isEmpty) {
    return const SizedBox.shrink();
  }

  // ============================================================
  // SECTION
  // ============================================================

  return _buildSection(
    title: title,
    children: [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: validValues.map((item) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(30),
              gradient: kPrimaryGradient,
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor
                      .withOpacity(.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withOpacity(.20),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  item,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ],
  );
}

// Comprehensive map for various characteristic values and their icons
// This map will now store either IconData or a String path to a Lottie animation
final Map<String, dynamic> _characteristicIcons = {
  // Common
  'Male': 'assets/lottie/male.json', // Lottie path for Male
  'Female': 'assets/lottie/female.json', // Lottie path for Female
  'Non-binary': 'assets/lottie/non_binary.json', // Example Lottie
  'Prefer not to say': 'assets/lottie/do_not_disturb_alt.json',
  'Yes': 'assets/lottie/check.json', // Example Lottie
  'No': 'assets/lottie/cross.json', // Example Lottie
  'Any': Icons.all_inclusive,
  'Both': Icons.people_outline,
  'Other': Icons.category,

  // Basic Information Specific
  'Gender': 'assets/lottie/person.json', // Example Lottie
  'Age': 'assets/lottie/cake.json', // Example Lottie
  'Occupation': 'assets/lottie/occupation.json', // Example Lottie
  'Current Location': 'assets/lottie/current_location.json', // Example Lottie
  'Desired City': 'assets/lottie/location_city.json', // Example Lottie
  'Area Pref.': 'assets/lottie/current_location.json', // Example Lottie
  'Move-in Date': 'assets/lottie/calendar.json', // Example Lottie
  'Budget Range': 'assets/lottie/currency_rupee.json', // Example Lottie
  'Bio': 'assets/lottie/info.json', // Example Lottie
  'Name': Icons.person_outline,
  'Availability Date': 'assets/lottie/calendar.json', // Example Lottie
  'Rent Price': 'assets/lottie/currency_rupee.json', // Example Lottie
  'Deposit Amt.': 'assets/lottie/currency_rupee.json', // Example Lottie
  'Address': 'assets/lottie/address.json', // Example Lottie
  'Landmark': 'assets/lottie/current_location.json', // Example Lottie
  'Description': 'assets/lottie/info.json', // Example Lottie

  // Habits & Lifestyle
  'Very Tidy': 'assets/lottie/cleanliness.json', // Example Lottie
  'Moderately Tidy': 'assets/lottie/cleanliness.json', // Example Lottie
  'Flexible': 'assets/lottie/cleanliness.json', // Example Lottie
  'Can be messy at times': 'assets/lottie/cleanliness.json', // Example Lottie
  'Social & outgoing': 'assets/lottie/socialhabits.json', // Example Lottie
  'Occasional gatherings': 'assets/lottie/socialhabits.json', // Example Lottie
  'Quiet & private': 'assets/lottie/socialhabits.json', // Example Lottie
  '9-5 Office hours': 'assets/lottie/freelancer.json', // Example Lottie
  'Freelance/Flexible hours': 'assets/lottie/freelancer.json', // Example Lottie
  'Night shifts': 'assets/lottie/nightshift.json', // Example Lottie
  'Student schedule': 'assets/lottie/student.json', // Example Lottie
  'Mixed': 'assets/lottie/mixed_schedule.json', // Example Lottie
  'Very quiet': 'assets/lottie/noise level.json', // Example Lottie
  'Moderate noise': 'assets/lottie/noise level.json', // Example Lottie
  'Lively': 'assets/lottie/noise level.json', // Example Lottie
  'Never': 'assets/lottie/nosmoking.json', // Example Lottie
  'Occasionally': 'assets/lottie/smoking.json', // Example Lottie
  'Socially': 'assets/lottie/smoking.json', // Example Lottie
  'Regularly': 'assets/lottie/smoking.json', // Example Lottie
  'Vegetarian': 'assets/lottie/food.json', // Example Lottie
  'Non-Vegetarian': 'assets/lottie/food.json', // Example Lottie
  'Vegan': 'assets/lottie/food.json', // Example Lottie
  'Eggetarian': 'assets/lottie/food.json', // Example Lottie
  'Jain': 'assets/lottie/food.json', // Example Lottie
  'Frequently': 'assets/lottie/frequent_guests.json', // Example Lottie //
  'Rarely': 'assets/lottie/rare_guests.json', // Example Lottie//
  'Frequent visitors': 'assets/lottie/frequent_visitors.json', // Example Lottie //
  'Occasional visitors': 'assets/lottie/occasional_visitors.json', // Example Lottie //
  'Rarely have visitors': 'assets/lottie/rare_visitors.json', // Example Lottie//
  'No visitors': 'assets/lottie/no_visitors.json', // Example Lottie //
  'Planning to get one': 'assets/lottie/pets.json', // Example Lottie
  'Comfortable with pets': 'assets/lottie/pets.json', // Example Lottie
  'Tolerant of pets': 'assets/lottie/pets.json', // Example Lottie
  'Prefer no pets': 'assets/lottie/nopets.json', // Example Lottie
  'Allergic to pets': 'assets/lottie/nopets.json', // Example Lottie
  'Early riser': 'assets/lottie/earlyriserrr.json', // Example Lottie
  'Night Owl': 'assets/lottie/nightowl.json', // Lottie specific to Night Owl in _preferenceIcons too.
  'Irregular': 'assets/lottie/earlyriserrr.json', // Example Lottie
  'Share everything': 'assets/lottie/sharing.json', // Example Lottie
  'Share some items': 'assets/lottie/sharing.json', // Example Lottie
  'Prefer separate items': 'assets/lottie/sharing.json', // Example Lottie//
  'Value personal space highly': 'assets/lottie/socialization.json', // Example Lottie
  'Enjoy a balance': 'assets/lottie/socialization.json', // Example Lottie
  'Prefer more socialization': 'assets/lottie/socialization.json', // Example Lottie

  // Flat Details
  'Studio Apartment': 'assets/lottie/address.json', // Example Lottie
  '1BHK': 'assets/lottie/address.json', // Example Lottie
  '2BHK': 'assets/lottie/address.json', // Example Lottie
  '3BHK': 'assets/lottie/address.json', // Example Lottie
  '4BHK+': 'assets/lottie/address.json', // Example Lottie
  'Furnished': 'assets/lottie/furnished.json', // Example Lottie
  'Semi-furnished': 'assets/lottie/furnished.json', // Example Lottie//
  'Unfurnished': 'assets/lottie/furnished.json', // Example Lottie//
  'Boys': 'assets/lottie/male.json', // Example Lottie
  'Girls': 'assets/lottie/female.json', // Example Lottie//
  'Couples': 'assets/lottie/person.json', // Example Lottie'//
  'Anyone': 'assets/lottie/person.json', // Example Lottie//
  'Attached Bathroom': 'assets/lottie/attached_bathroom.json', // Example Lottie//
  'Shared Bathroom': 'assets/lottie/shared_bathroom.json', // Example Lottie//
  'Yes, for Car': 'assets/lottie/car_parking.json', // Example Lottie//
  'Yes, for Two-wheeler': 'assets/lottie/two_wheeler_parking.json', // Example Lottie//
  'Only in living room': 'assets/lottie/living_room.json', // Example Lottie//
  'Only in bedroom': 'assets/lottie/bedroom.json', // Example Lottie//
  '18-24': 'assets/lottie/cake.json', // Example Lottie
  '25-30': 'assets/lottie/cake.json', // Example Lottie
  '30-40': 'assets/lottie/cake.json', // Example Lottie
  '40+': 'assets/lottie/cake.json', // Example Lottie
  'No preference': Icons.favorite_border,
  'Student': 'assets/lottie/student.json', // Example Lottie
  'Working Professional': 'assets/lottie/freelancer.json', // Example Lottie
  'Bathroom Type': Icons.bathtub, // Keeping as IconData
  'Balcony': Icons.balcony, // Keeping as IconData
  'Parking': Icons.local_parking, // Keeping as IconData

  // Amenities Specific Icons
  'Wi-Fi': 'assets/lottie/wifi.json', // Example Lottie
  'AC': 'assets/lottie/ac.json', // Example Lottie
  'Geyser': 'assets/lottie/gyser.json', // Example Lottie
  'Washing Machine': 'assets/lottie/washingmachine.json', // Example Lottie
  'Refrigerator': 'assets/lottie/refrigerator.json', // Example Lottie
  'Microwave': 'assets/lottie/microwave.json', // Example Lottie
  'Maid Service': 'assets/lottie/cleaning.json', // Example Lottie
  'Cook': 'assets/lottie/cook.json', // Example Lottie
  'Gym': 'assets/lottie/gym.json', // Example Lottie
  'Swimming Pool': 'assets/lottie/swimming.json', // Example Lottie
  'Power Backup': 'assets/lottie/powerbackup.json', // Example Lottie
  'Security': 'assets/lottie/security.json', // Example Lottie

  // Preferred Habits
  'Non-smoker': 'assets/lottie/nosmoker.json', // Example Lottie//
  'Non-drinker': 'assets/lottie/nosmoker.json', // Reusing
  'Tidy': 'assets/lottie/cleaniness.json', // Reusing
  'Quiet': 'assets/lottie/very_quiet.json', // Reusing
  'Social': 'assets/lottie/socialization.json', // Reusing
  'Respectful': 'assets/lottie/respectful.json', // Example Lottie
  'Financially responsible': 'assets/lottie/currency_rupee.json', // Example Lottie
  'Pet-friendly': 'assets/lottie/pets.json', // Reusing

  // Ideal Qualities
  'Communicative': 'assets/lottie/communicative.json', // Example Lottie
  'Friendly': 'assets/lottie/friendly.json', // Example Lottie
  'Responsible': 'assets/lottie/responsible.json', // Example Lottie
  'Social': 'assets/lottie/social_group.json', // Example Lottie
  'Independent': 'assets/lottie/independent.json', // Example Lottie
  'Shares chores': 'assets/lottie/chores.json', // Example Lottie
  'Financially stable': 'assets/lottie/financially_stable.json', // Example Lottie

  // Deal Breakers
  'Excessive Noise': 'assets/lottie/noise.json', // Example Lottie//
  'Untidiness': 'assets/lottie/cleanlinessjson', // Example Lottie//
  'Frequent Parties': 'assets/lottie/party.json', // Example Lottie//
  'Smoking Indoors': 'assets/lottie/smoking.json', // Example Lottie
  'Unpaid Bills': 'assets/lottie/unpaid_bills.json', // Example Lottie
  'Lack of Communication': 'assets/lottie/no_communication.json', // Example Lottie
  'Pets (if not allowed)': 'assets/lottie/nopets.json', // Example Lottie
  'Late Night Guests': 'assets/lottie/late_guests.json', // Example Lottie
  'Drugs': 'assets/lottie/drugs.json', // Example Lottie
  'Disrespectful behavior': 'assets/lottie/disrespectful.json', // Example Lottie
};

// Helper for displaying a single characteristic with icon and text, formatted as a card-like structure (without a container)
Widget _buildIconValueCard(
  String label,
  String? value, {
  Color? backgroundColor,
  Color? iconColor,
}) {
  if (value == null ||
      value.trim().isEmpty ||
      value == 'N/A') {
    return const SizedBox.shrink();
  }

  final dynamic iconData =
      _characteristicIcons[label] ??
      _characteristicIcons[value];

  Widget iconWidget;

  if (iconData is IconData) {
    iconWidget = Icon(
      iconData,
      size: 20,
      color: Colors.white,
    );
  } else if (iconData is String &&
      iconData.endsWith('.json')) {
    iconWidget = Lottie.asset(
      iconData,
      width: 26,
      height: 26,
      repeat: true,
    );
  } else {
    iconWidget = const Icon(
      Icons.auto_awesome_rounded,
      size: 20,
      color: Colors.white,
    );
  }

  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: backgroundColor ?? kCardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: kBorderColor,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.03),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: kPrimaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kMediumText,
                  letterSpacing: .3,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: kDarkText,
            height: 1.25,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            gradient: kPrimaryGradient,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    ),
  );
}
Widget _buildPremiumHeroSection(
  BuildContext context,
  FlatListingProfile profile,
  PageController pageController,
) {
  final imageUrls = profile.imageUrls ?? [];

  return SizedBox(
    height: 430,
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [

          /// IMAGES
          PageView.builder(
            controller: pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
            onPageChanged: (index) {
              debugPrint("PAGE CHANGED : $index");
            },
            itemBuilder: (context, index) {

              if (imageUrls.isEmpty) {
                return Container(
                  color: kLightGrey,
                  child: const Center(
                    child: Icon(
                      Icons.home_rounded,
                      size: 80,
                    ),
                  ),
                );
              }

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  debugPrint("IMAGE TAPPED");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenGallery(
                        images: imageUrls,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: imageUrls[index],
                  child: Image.network(
                    imageUrls[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          /// OVERLAY (doesn't block gestures)
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(.20),
                    Colors.black.withOpacity(.85),
                  ],
                ),
              ),
            ),
          ),

          /// BACK BUTTON
         
          /// PAGE INDICATOR
          Positioned(
            bottom: 82,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: imageUrls.isEmpty ? 1 : imageUrls.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white38,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3.5,
                  spacing: 8,
                ),
              ),
            ),
          ),

          /// NAME + VERIFIED
         Positioned(
  left: 20,
  right: 20,
  bottom: 24,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Expanded(
            child: Text(
              (profile.userProfile.name?.trim().isNotEmpty == true)
                  ? profile.userProfile.name!
                      .trim()
                      .split(RegExp(r'\s+'))
                      .first
                  : "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 10),

          _buildVerificationBadge(profile),
        ],
      ),

      const SizedBox(height: 10),

      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [

          if (profile.locationName != null &&
              profile.locationName!.isNotEmpty)
            _heroChip(
              Icons.location_on,
              profile.locationName!,
            ),

          if (profile.rentPrice != null)
            _heroChip(
              Icons.currency_rupee,
              "₹${profile.rentPrice}",
            ),

          if (profile.flatType != null)
            _heroChip(
              Icons.home_work,
              profile.flatType!,
            ),

          if (profile.roomType != null)
            _heroChip(
              Icons.bed,
              profile.roomType!,
            ),
        ],
      ),
    ],
  ),
),
        ],
      ),
    ),
  );
}
Widget _heroChip(
  IconData icon,
  String text,
) {
  return Container(
    constraints: const BoxConstraints(
      maxWidth: 320, // Prevent chip from becoming too wide
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(.35),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: Colors.white24,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 15,
        ),
        const SizedBox(width: 6),

        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}
// Helper for displaying a grid of characteristics, like "Habits & Lifestyle"
Widget _buildCharacteristicGrid(
  String title,
  List<MapEntry<String, String?>> characteristics,
) {
  final validItems = characteristics.where((entry) {
    final value = entry.value?.trim() ?? '';

    if (value.isEmpty) return false;

    final normalized = value.toLowerCase();

    return normalized != 'n/a' &&
        normalized != 'null' &&
        normalized != 'none' &&
        normalized != 'not specified';
  }).toList();

  if (validItems.isEmpty) {
    return const SizedBox.shrink();
  }

  return _buildSection(
    title: title,
    children: [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: validItems.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.55,
        ),
        itemBuilder: (context, index) {
          final item = validItems[index];

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kPrimaryColor.withOpacity(.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: kPrimaryGradient,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),

                Text(
                  item.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kMediumText,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  item.value!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kDarkText,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}
Widget _buildSeekingHeroSection(
  BuildContext context,
  SeekingFlatmateProfile profile,
  PageController pageController,
) {
  final imageUrls = profile.imageUrls ?? [];

  return SizedBox(
    height: 430,
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [

          /// IMAGES
          PageView.builder(
            controller: pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
            itemBuilder: (context, index) {

              if (imageUrls.isEmpty) {
                return Container(
                  color: kLightGrey,
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 90,
                    ),
                  ),
                );
              }

              return GestureDetector(
                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenGallery(
                        images: imageUrls,
                        initialIndex: index,
                      ),
                    ),
                  );

                },

                child: Hero(
                  tag: imageUrls[index],
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              );
            },
          ),

          /// OVERLAY
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(.20),
                    Colors.black.withOpacity(.85),
                  ],
                ),
              ),
            ),
          ),

          /// BACK BUTTON
          

          /// PAGE INDICATOR
          Positioned(
            bottom: 82,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: imageUrls.isEmpty ? 1 : imageUrls.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white38,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3.5,
                ),
              ),
            ),
          ),

          /// NAME + VERIFIED
          Positioned(
  left: 20,
  right: 20,
  bottom: 24,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Row(
        children: [

          Expanded(
            child: Text(
              (profile.userProfile.name?.trim().isNotEmpty == true)
                  ? profile.userProfile.name!
                      .trim()
                      .split(RegExp(r'\s+'))
                      .first
                  : "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          _buildVerificationBadge(profile),
        ],
      ),

      const SizedBox(height: 10),

      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [

          if (profile.locationName != null &&
              profile.locationName!.isNotEmpty)
            _heroChip(
              Icons.location_on,
              profile.locationName!,
            ),

          if (profile.budgetMin != null ||
              profile.budgetMax != null)
            _heroChip(
              Icons.currency_rupee,
              "₹${profile.budgetMin ?? "-"} - ₹${profile.budgetMax ?? "-"}",
            ),

          if (profile.preferredFlatType != null)
            _heroChip(
              Icons.apartment,
              profile.preferredFlatType!,
            ),

          if (profile.preferredRoomType != null)
            _heroChip(
              Icons.bed,
              profile.preferredRoomType!,
            ),
        ],
      ),
    ],
  ),
),
        ],
      ),
    ),
  );
}
// Helper for displaying preferences with custom icons in a grid (e.g., Night Owl, Early Bird)
final Map<String, dynamic> _preferenceIcons = { // Changed to dynamic to hold IconData or Lottie paths
  'Night Owl': 'assets/lottie/nightowl.json', // Assuming you have this Lottie file
  'Early Bird': 'assets/lottie/earlyriserrr.json', // Reusing early_riser Lottie file
  'Studious': 'assets/lottie/studious.json', // Example Lottie
  'Fitness Freak': 'assets/lottie/gym.json', // Example Lottie
  'Sporty': 'assets/lottie/sporty.json', // Example Lottie
  'Wanderer': 'assets/lottie/wanderer.json', // Example Lottie
  'Party Lover': 'assets/lottie/party.json', // Example Lottie
  'Vegan': 'assets/lottie/food.json', // Reusing
  'Music Lover': 'assets/lottie/music.json', // Example Lottie
  'Artist': 'assets/lottie/music.json', // Example Lottie
  'Gamer': 'assets/lottie/gamer.json', // Example Lottie
  'Cook': 'assets/lottie/cook.json', // Reusing
};
Widget _buildPreferenceGrid(
  String title,
  List<String>? preferences,
) {
  final List<String> validPreferences =
      preferences
              ?.where((e) {
                final value = e.trim();

                if (value.isEmpty) return false;

                final normalized = value.toLowerCase();

                return normalized != 'n/a' &&
                    normalized != 'null' &&
                    normalized != 'none' &&
                    normalized != 'not specified';
              })
              .toList() ??
          [];

  if (validPreferences.isEmpty) {
    return const SizedBox.shrink();
  }

  return _buildSection(
    title: title,
    children: [

      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: validPreferences.map((item) {

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(.18),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Text(
                  item,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );

        }).toList(),
      ),

      const SizedBox(height: 12),

      Align(
        alignment: Alignment.centerRight,
        child: Text(
          "${validPreferences.length} Selected",
          style: const TextStyle(
            color: kMediumText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
Widget _buildQuickOverview(List<MapEntry<String, String?>> items) {
  final validItems = items.where((e) {
    final value = e.value?.trim() ?? "";

    if (value.isEmpty) return false;

    final normalized = value.toLowerCase();

    return normalized != "n/a" &&
        normalized != "null" &&
        normalized != "none" &&
        normalized != "not specified";
  }).toList();

  if (validItems.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    child: Wrap(
      spacing: 10,
      runSpacing: 10,
      children: validItems.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: kBorderColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Icon(
                Icons.check_circle,
                size: 16,
                color: kPrimaryColor,
              ),

              const SizedBox(width: 8),

              Text(
                "${item.key}: ${item.value}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}
// Helper to convert List<String> to List<MapEntry<String, String?>> for grid display
List<MapEntry<String, String?>>
    _convertStringListToCharacteristicEntries(
  List<String>? list,
) {
  return list
          ?.where(
            (item) =>
                item.trim().isNotEmpty,
          )
          .map(
            (item) =>
                MapEntry(item, item),
          )
          .toList() ??
      [];
}

// --- Main Display Widgets ---

class SeekingFlatmateProfileDisplay extends StatefulWidget {
  final SeekingFlatmateProfile profile;

  const SeekingFlatmateProfileDisplay({
    super.key,
    required this.profile,
  });

  @override
  State<SeekingFlatmateProfileDisplay> createState() =>
      _SeekingFlatmateProfileDisplayState();
}

class _SeekingFlatmateProfileDisplayState
    extends State<SeekingFlatmateProfileDisplay> {

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final profile = widget.profile;
    return Scaffold(

      body: ListView(
        children: [
          // Profile Header (similar to the image)
          _buildSeekingHeroSection(
  context,
  profile,
  _pageController,
),


                // Basic Info - NOW AS A GRID
                        /// 👤 ABOUT ME
                        /// LOCATION
_buildSection(
  title: '📍 Location',
  children: [
    _buildProfileField(
      'Address',
      profile.locationName,
      icon: Icons.location_on_outlined,
    ),
  ],
),
                     _buildCharacteristicGrid(
  '👤 About Me',
  [
    MapEntry(
      'Gender',
      profile.userProfile.gender,
    ),

    MapEntry(
      'Age',
      profile.userProfile.age?.toString(),
    ),

    MapEntry(
      'Occupation',
      profile.userProfile.occupation,
    ),

    MapEntry(
      'Religion',
      profile.userProfile.religion,
    ),

    MapEntry(
      'Hometown',
      profile.userProfile.city,
    ),

    MapEntry(
      'Posted On',
      profile.createdAt == null
          ? null
          : DateFormat('dd MMM yyyy')
              .format(profile.createdAt!),
    ),

    MapEntry(
      'Move-in Date',
      profile.moveInDate == null
          ? null
          : DateFormat('dd MMM yyyy')
              .format(profile.moveInDate!),
    ),
  ],
),

                        /// 📝 BIO
                        if (profile.userProfile.bio != null &&
                            profile.userProfile.bio!.isNotEmpty)
                          _buildSection(
                            title: '📝 About Me',
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  color: Colors.white.withOpacity(.05),
                                ),
                                child: Text(
                                  profile.userProfile.bio!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        /// 🏠 HOUSING PREFERENCES
        _buildCharacteristicGrid(
  '🏠 My Home Preferences',
  [
    MapEntry(
      'Budget',
      profile.budgetMin != null || profile.budgetMax != null
          ? '₹${profile.budgetMin ?? 'N/A'} - ₹${profile.budgetMax ?? 'N/A'}'
          : null,
    ),
    MapEntry(
      'Desired City',
      profile.userProfile.city,
    ),
    MapEntry(
      'Flat Type',
      profile.preferredFlatType,
    ),
    MapEntry(
      'Room Type',
      profile.preferredRoomType,
    ),
    MapEntry(
      'Furnished',
      profile.preferredFurnishedStatus,
    ),
  ],
),
                        /// ✨ LIFESTYLE
                        _buildCharacteristicGrid(
  '🌿 My Lifestyle',
  [
    MapEntry(
      '🧹 Cleanliness',
      profile.userProfile.cleanlinessLevel,
    ),
    MapEntry(
      '🎉 Social',
      profile.userProfile.socialPreferences,
    ),
    MapEntry(
      '🚭 Smoking',
      profile.userProfile.smokingHabit,
    ),
    MapEntry(
      '🍺 Drinking',
      profile.userProfile.drinkingHabit,
    ),
    MapEntry(
      '🍛 Food',
      profile.userProfile.foodPreference,
    ),
    MapEntry(
      '🐶 Pet Ownership',
      profile.userProfile.petOwnership,
    ),
    MapEntry(
      '❤️ Pet Preference',
      profile.userProfile.petTolerance,
    ),
  ],
),
_buildSection(
                          title: "Who I'm Looking For",
                          children: [
                            _buildProfileField(
                              'Gender',
                              profile.preferredFlatmateGender,
                              icon: Icons.people_outline,
                            ),
                            _buildProfileField(
                              'Age Group',
                              profile.preferredFlatmateAge,
                              icon: Icons.cake_outlined,
                            ),
                            _buildProfileField(
                              'Occupation',
                              profile.preferredOccupation,
                              icon: Icons.work_outline,
                            ),
                          ],
                        ),
                        /// 🏡 DESIRED AMENITIES
                        _buildProfileListField(
                          "🏡 Amenities I'd Love",
                          profile.amenitiesDesired,
                        ),

                        /// 🤝 IDEAL FLATMATE
                        

                        /// ⭐ PREFERRED HABITS
                        _buildProfileListField(
                          "⭐ Habits I'd Prefer",
                          profile.preferredHabits,
                        ),

                        /// 💎 IDEAL QUALITIES
                        _buildProfileListField(
                          "💙 Qualities I Appreciate",
                          profile.idealQualities,
                        ),

                        /// 🚫 DEAL BREAKERS
                        _buildProfileListField(
                          '🚫 My Deal Breakers',
                          profile.dealBreakers,
                        ),
                // Profile Images (using the existing implementation)
                if (profile.imageUrls != null && profile.imageUrls!.isNotEmpty)
                  _buildSection(
                    title: '📸 My Photos',
                    children: [
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: profile.imageUrls!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  profile.imageUrls![index],
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 150,
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
}

class FlatListingProfileDisplay extends StatefulWidget {
  final FlatListingProfile profile;

  const FlatListingProfileDisplay({
    super.key,
    required this.profile,
  });

  @override
  State<FlatListingProfileDisplay> createState() =>
      _FlatListingProfileDisplayState();
}

class _FlatListingProfileDisplayState
    extends State<FlatListingProfileDisplay> {

  final PageController _pageController =
      PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final profile = widget.profile;

    return Scaffold(
      backgroundColor: kBackgroundColor,

      body: ListView(
        children: [

          /// HERO HEADER
          _buildPremiumHeroSection(
            context,
            profile,
            _pageController,
          ),
          
_buildSection(
  title: '📍 Location',
  children: [
    _buildProfileField(
      'Address',
      profile.locationName,
      icon: Icons.location_on_outlined,
    ),
  ],
),

          /// QUICK OVERVIEW
          _buildCharacteristicGrid(
            '🏠 My Home',
            [
              MapEntry('Flat Type', profile.flatType),
              MapEntry('Room Type', profile.roomType),
              MapEntry('Bathroom', profile.bathroomType),
              MapEntry('Furnished', profile.furnishedStatus),

              MapEntry(
                'Occupants',
                profile.currentOccupants,
              ),

              MapEntry(
                'Lease Pending',
                profile.leaseDuration != null
                    ? '${profile.leaseDuration}'
                    : null,
              ),
            ],
          ),

          /// RENT DETAILS
          _buildCharacteristicGrid(
            '💰Rent Details',
            [
              MapEntry(
                'Rent',
                profile.rentPrice != null
                    ? '₹${profile.rentPrice}'
                    : null,
              ),

              MapEntry(
                'Deposit',
                profile.depositAmount != null
                    ? '₹${profile.depositAmount}'
                    : null,
              ),

              MapEntry(
                'Available For',
                profile.availableFor,
              ),

              MapEntry(
                'Available From',
                profile.availabilityDate != null
                    ? DateFormat(
                        'dd MMM yyyy',
                      ).format(
                        profile.availabilityDate!,
                      )
                    : null,
              ),
            ],
          ),

          /// AMENITIES
          _buildPreferenceGrid(
            '🏡 Amenities I Offer',
            profile.amenities,
          ),

          /// ABOUT THE FLAT
          

          /// CURRENT FLATMATE
          _buildCharacteristicGrid(
            '👤 About Me',
            [
              MapEntry(
                'Name',
                (profile.userProfile.name?.trim().isNotEmpty == true)
    ? profile.userProfile.name!
        .trim()
        .split(RegExp(r'\s+'))
        .first
    : "",
              ),

              MapEntry(
                'Age',
                profile.userProfile.age?.toString(),
              ),

              MapEntry(
                'Gender',
                profile.userProfile.gender,
              ),

              MapEntry(
                'Occupation',
                profile.userProfile.occupation,
              ),

              MapEntry(
                'Religion',
                profile.userProfile.religion,
              ),
            ],
          ),

          /// LIFESTYLE
          _buildCharacteristicGrid(
            '🌿 My Lifestyle',
            [
              MapEntry(
                'Smoking',
                profile.userProfile.smokingHabit,
              ),

              MapEntry(
                'Drinking',
                profile.userProfile.drinkingHabit,
              ),

              MapEntry(
                'Food',
                profile.userProfile.foodPreference,
              ),

              MapEntry(
                'Cleanliness',
                profile.userProfile.cleanlinessLevel,
              ),

              MapEntry(
                'Social',
                profile.userProfile.socialPreferences,
              ),

              MapEntry(
                'Pets',
                profile.userProfile.petOwnership,
              ),

              MapEntry(
                'Pet Tolerance',
                profile.userProfile.petTolerance,
              ),
            ],
          ),

          /// FLATMATE PREFERENCES
          _buildCharacteristicGrid(
            "🤝 Who I'm Looking For",
            [
              MapEntry(
                'Gender',
                profile.preferredGender,
              ),

              MapEntry(
                'Age',
                profile.preferredAgeGroup,
              ),

              MapEntry(
                'Occupation',
                profile.preferredOccupation,
              ),
            ],
          ),

          _buildPreferenceGrid(
            "⭐ Habits I'd Prefer",
            profile.preferredHabits,
          ),

          _buildPreferenceGrid(
            '💙 Qualities I Appreciate',
            profile.flatmateIdealQualities,
          ),

          _buildPreferenceGrid(
            '🚫 My Deal Breakers',
            profile.flatmateDealBreakers,
          ),

          if (profile.imageUrls != null &&
              profile.imageUrls!.isNotEmpty)
            _buildSection(
              title: '📸Photo Gallery',
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount:
                      profile.imageUrls!.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),

                  itemBuilder:
                      (context, index) {

                   return Hero(
  tag: profile.imageUrls![index],
  child: Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenGallery(
              images: profile.imageUrls!,
              initialIndex: index,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          profile.imageUrls![index],
          fit: BoxFit.cover,
        ),
      ),
    ),
  ),
);
                  },
                ),
              ],
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}