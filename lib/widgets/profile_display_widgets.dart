// lib/widgets/profile_display_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:lottie/lottie.dart'; // Import Lottie

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
          horizontal: 20,
          vertical: 10,
        ),

    decoration: BoxDecoration(
      color: kCardColor,

      borderRadius: BorderRadius.circular(28),

      border: Border.all(
        color: kBorderColor,
        width: 1,
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.04),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ],
    ),

    child: Padding(
      padding:
          padding ??
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [

              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: kPrimaryGradient,

                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor
                          .withOpacity(.30),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kDarkText,
                    letterSpacing: -.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withOpacity(.15),
                  kAccentColor.withOpacity(.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          ...children,
        ],
      ),
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
      value == 'N/A') {
    return const SizedBox.shrink();
  }

  return Container(
    margin: const EdgeInsets.only(
      bottom: 14,
    ),
    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(
      color: kCardColor,

      borderRadius:
          BorderRadius.circular(22),

      border: Border.all(
        color: kBorderColor,
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(
            .04,
          ),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),

    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        /// ICON
        if (icon != null)
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                16,
              ),

              gradient:
                  kPrimaryGradient,
            ),

            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),

        if (icon != null)
          const SizedBox(width: 16),

        /// TEXT
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: kLightText,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                value,
                style: const TextStyle(
                  color: kDarkText,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        /// STATUS DOT
        Container(
          width: 10,
          height: 10,
          margin:
              const EdgeInsets.only(
            top: 8,
          ),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: kOnlineColor,
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
  if (values == null || values.isEmpty) {
    return _buildSection(
      title: title,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: kLightGrey,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: kBorderColor,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: kMediumText,
                size: 18,
              ),
              SizedBox(width: 10),
              Text(
                "No information added yet",
                style: TextStyle(
                  color: kMediumText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  return _buildSection(
    title: title,
    children: [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: values.map((item) {
          return Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(30),

              gradient:
                  kPrimaryGradient,

              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor
                      .withOpacity(.15),
                  blurRadius: 12,
                  offset:
                      const Offset(0, 6),
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
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
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
                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Colors.white,
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

  dynamic iconData =
      _characteristicIcons[label] ??
      _characteristicIcons[value];

  Widget iconWidget;

  if (iconData is IconData) {
    iconWidget = Icon(
      iconData,
      size: 24,
      color: Colors.white,
    );
  } else if (iconData is String &&
      iconData.endsWith('.json')) {
    iconWidget = Lottie.asset(
      iconData,
      width: 36,
      height: 36,
      repeat: true,
    );
  } else {
    iconWidget = const Icon(
      Icons.auto_awesome_rounded,
      size: 24,
      color: Colors.white,
    );
  }

  return Container(
    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(
      color: kCardColor,

      borderRadius:
          BorderRadius.circular(24),

      border: Border.all(
        color: kBorderColor,
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(
            .04,
          ),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        /// TOP ROW
        Row(
          children: [

            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),

                gradient:
                    kPrimaryGradient,
              ),

              child: Center(
                child: iconWidget,
              ),
            ),

            const Spacer(),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color: kLightGrey,
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),

              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: kMediumText,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w700,
                  letterSpacing: .8,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Text(
          value,
          maxLines: 2,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.w800,
            color: kDarkText,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              100,
            ),
            gradient:
                kPrimaryGradient,
          ),
        ),
      ],
    ),
  );
}
Widget _buildPremiumHeroSection(
  FlatListingProfile profile,
) {
  final imageUrls = profile.imageUrls ?? [];

  return Container(
    height: 420,
    margin: const EdgeInsets.only(
      bottom: 20,
    ),

    child: Stack(
      children: [

        /// PROPERTY IMAGE
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
          child: imageUrls.isNotEmpty
              ? PageView.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      imageUrls[index],
                      width: double.infinity,
                      height: 420,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Container(
                  height: 420,
                  color: kLightGrey,
                  child: const Center(
                    child: Icon(
                      Icons.home_rounded,
                      size: 80,
                      color: kMediumText,
                    ),
                  ),
                ),
        ),

        /// DARK OVERLAY
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(.10),
                Colors.black.withOpacity(.25),
                Colors.black.withOpacity(.75),
              ],
            ),
          ),
        ),

        /// BACK BUTTON
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CircleAvatar(
              backgroundColor:
                  Colors.black.withOpacity(.30),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ),

        /// CONTENT
        Positioned(
          left: 20,
          right: 20,
          bottom: 25,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              /// RENT BADGE
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: kPrimaryGradient,
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: Text(
                  profile.rentPrice != null
                      ? '₹${profile.rentPrice}/month'
                      : 'Rent Not Available',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// FLAT TYPE
              Text(
                '${profile.flatType} • ${profile.roomType}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              /// LOCATION
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      profile.address.isNotEmpty
                          ? profile.address
                          : profile.userProfile.city ??
                              'Location not specified',
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// OWNER CARD
              Container(
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(.12),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Row(
                  children: [

                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Colors.white,
                      backgroundImage:
                          profile.userProfile
                                      .profilePhotoUrl !=
                                  null
                              ? NetworkImage(
                                  profile
                                      .userProfile
                                      .profilePhotoUrl!,
                                )
                              : null,
                      child: profile
                                  .userProfile
                                  .profilePhotoUrl ==
                              null
                          ? const Icon(
                              Icons.person,
                            )
                          : null,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            profile.userProfile
                                    .name ??
                                'Owner',
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),

                          Text(
                            profile.userProfile
                                    .occupation ??
                                '',
                            style:
                                const TextStyle(
                              color: Colors
                                  .white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            kOnlineColor,
                        borderRadius:
                            BorderRadius
                                .circular(
                          30,
                        ),
                      ),
                      child: const Text(
                        'Verified',
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// ACTION BUTTONS
              Row(
                children: [

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Open Chat
                      },
                      icon:
                          const Icon(Icons.chat),
                      label:
                          const Text("Chat"),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            kPrimaryColor,
                        foregroundColor:
                            Colors.white,
                        minimumSize:
                            const Size(
                          double.infinity,
                          52,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Call Owner
                      },
                      icon:
                          const Icon(Icons.call),
                      label:
                          const Text("Call"),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            Colors.white,
                        side:
                            const BorderSide(
                          color:
                              Colors.white,
                        ),
                        minimumSize:
                            const Size(
                          double.infinity,
                          52,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
  final validItems = characteristics
      .where(
        (e) =>
            e.value != null &&
            e.value!.trim().isNotEmpty &&
            e.value != 'N/A',
      )
      .toList();

  if (validItems.isEmpty) {
    return _buildSection(
      title: title,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: kLightGrey,

            borderRadius:
                BorderRadius.circular(20),

            border: Border.all(
              color: kBorderColor,
            ),
          ),

          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: kMediumText,
                size: 18,
              ),

              SizedBox(width: 10),

              Text(
                'No details available yet',
                style: TextStyle(
                  color: kMediumText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  return _buildSection(
    title: title,
    children: [

      GridView.builder(
        shrinkWrap: true,

        physics:
            const NeverScrollableScrollPhysics(),

        itemCount: validItems.length,

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,

          crossAxisSpacing: 14,
          mainAxisSpacing: 14,

          childAspectRatio: 1.05,
        ),

        itemBuilder: (context, index) {
          final entry =
              validItems[index];

          return TweenAnimationBuilder<double>(
            duration: Duration(
              milliseconds:
                  250 + (index * 60),
            ),

            curve:
                Curves.easeOutCubic,

            tween: Tween(
              begin: 0,
              end: 1,
            ),

            builder:
                (context, value, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  20 * (1 - value),
                ),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },

            child: _buildIconValueCard(
              entry.key,
              entry.value,
            ),
          );
        },
      ),

      const SizedBox(height: 8),

      Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: kPrimaryColor
                .withOpacity(.08),

            borderRadius:
                BorderRadius.circular(
              30,
            ),
          ),

          child: Text(
            '${validItems.length} Details',
            style: const TextStyle(
              color: kPrimaryColor,
              fontWeight:
                  FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    ],
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
  if (preferences == null ||
      preferences.isEmpty) {
    return _buildSection(
      title: title,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: kLightGrey,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: kBorderColor,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: kMediumText,
                size: 18,
              ),
              SizedBox(width: 10),
              Text(
                'No preferences added yet',
                style: TextStyle(
                  color: kMediumText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  return _buildSection(
    title: title,
    children: [
      GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),

        itemCount: preferences.length,

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.0,
        ),

        itemBuilder: (context, index) {
          final preference =
              preferences[index];

          dynamic iconData =
              _preferenceIcons[
                  preference];

          Widget iconWidget;

          if (iconData is IconData) {
            iconWidget = Icon(
              iconData,
              size: 24,
              color: Colors.white,
            );
          } else if (iconData is String &&
              iconData.endsWith('.json')) {
            iconWidget = Lottie.asset(
              iconData,
              width: 36,
              height: 36,
              repeat: true,
            );
          } else {
            iconWidget = const Icon(
              Icons.auto_awesome_rounded,
              size: 24,
              color: Colors.white,
            );
          }

          return TweenAnimationBuilder<double>(
            duration: Duration(
              milliseconds:
                  250 + (index * 60),
            ),
            curve:
                Curves.easeOutCubic,
            tween: Tween(
              begin: 0,
              end: 1,
            ),
            builder:
                (context, value, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  15 * (1 - value),
                ),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },

            child: Container(
              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: kCardColor,

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),

                border: Border.all(
                  color: kBorderColor,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(.04),
                    blurRadius: 18,
                    offset:
                        const Offset(
                      0,
                      8,
                    ),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Container(
                    width: 52,
                    height: 52,

                    decoration: BoxDecoration(
                      gradient:
                          kPrimaryGradient,

                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                    ),

                    child: Center(
                      child:
                          iconWidget,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    preference,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight
                              .w700,
                      color:
                          kDarkText,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    width: 45,
                    height: 4,
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                      gradient:
                          kPrimaryGradient,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      const SizedBox(height: 8),

      Align(
        alignment:
            Alignment.centerRight,
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: kPrimaryColor
                .withOpacity(.08),
            borderRadius:
                BorderRadius.circular(
              30,
            ),
          ),
          child: Text(
            '${preferences.length} Selected',
            style: const TextStyle(
              color: kPrimaryColor,
              fontWeight:
                  FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    ],
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

class SeekingFlatmateProfileDisplay extends StatelessWidget {
  final SeekingFlatmateProfile profile;

  const SeekingFlatmateProfileDisplay({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        children: [
          // Profile Header (similar to the image)
          Container(
  margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
  height: 420,
  child: Stack(
    children: [

      /// COVER IMAGE
      ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: profile.imageUrls != null &&
                profile.imageUrls!.isNotEmpty
            ? PageView.builder(
                itemCount: profile.imageUrls!.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    profile.imageUrls![index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            : Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
      ),

      /// DARK OVERLAY
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(.15),
              Colors.black.withOpacity(.85),
            ],
          ),
        ),
      ),

      /// MATCH SCORE
      Positioned(
        top: 20,
        left: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFFAD1457),
              ],
            ),
          ),
          child: const Text(
            "95% Match",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      /// VERIFIED
      Positioned(
        top: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.verified,
            color: Colors.white,
          ),
        ),
      ),

      /// PROFILE DETAILS
      Positioned(
        left: 24,
        right: 24,
        bottom: 24,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              "${profile.userProfile.name ?? 'User'}, ${profile.userProfile.age ?? ''}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              profile.userProfile.occupation ??
                  "Occupation not specified",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    profile.userProfile.city ??
                        "Location not specified",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [

                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed: () {},
                    icon:
                        const Icon(Icons.chat),
                    label:
                        const Text("Chat"),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                              0xFFAD1457),
                      foregroundColor:
                          Colors.white,
                      minimumSize:
                          const Size(
                              0, 50),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () {},
                    icon:
                        const Icon(Icons.call),
                    label:
                        const Text("Call"),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.white,
                      side:
                          const BorderSide(
                        color:
                            Colors.white,
                      ),
                      minimumSize:
                          const Size(
                              0, 50),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
      ),


                // Basic Info - NOW AS A GRID
                        /// 👤 ABOUT ME
                        _buildSection(
                          title: '👤 About Me',
                          children: [
                            _buildProfileField(
                              'Gender',
                              profile.userProfile.gender,
                              icon: Icons.person_outline,
                            ),
                            _buildProfileField(
                              'Age',
                              profile.userProfile.age?.toString(),
                              icon: Icons.cake_outlined,
                            ),
                            _buildProfileField(
                              'Occupation',
                              profile.userProfile.occupation,
                              icon: Icons.work_outline,
                            ),
                            _buildProfileField(
                              'Religion',
                              profile.userProfile.religion,
                              icon: Icons.temple_hindu_outlined,
                            ),
                            _buildProfileField(
                              'Current Location',
                              profile.userProfile.city,
                              icon: Icons.location_on_outlined,
                            ),
                            _buildProfileField(
                              'Move-in Date',
                              profile.moveInDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(profile.moveInDate!)
                                  : null,
                              icon: Icons.calendar_month_outlined,
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
                        _buildSection(
                          title: '🏠 Housing Preferences',
                          children: [
                            _buildProfileField(
                              'Budget',
                              '₹${profile.budgetMin ?? 'N/A'} - ₹${profile.budgetMax ?? 'N/A'}',
                              icon: Icons.currency_rupee,
                            ),
                            _buildProfileField(
                              'Desired City',
                              profile.userProfile.city,
                              icon: Icons.location_city,
                            ),
                            _buildProfileField(
                              'Flat Type',
                              profile.preferredFlatType,
                              icon: Icons.apartment,
                            ),
                            _buildProfileField(
                              'Room Type',
                              profile.preferredRoomType,
                              icon: Icons.bed_outlined,
                            ),
                            _buildProfileField(
                              'Furnished',
                              profile.preferredFurnishedStatus,
                              icon: Icons.chair_outlined,
                            ),
                          ],
                        ),

                        /// ✨ LIFESTYLE
                        _buildProfileListField(
                          '✨ Lifestyle',
                          [
                            profile.userProfile.cleanlinessLevel ?? '',
                            profile.userProfile.socialPreferences ?? '',
                            profile.userProfile.smokingHabit ?? '',
                            profile.userProfile.drinkingHabit ?? '',
                            profile.userProfile.foodPreference ?? '',
                            profile.userProfile.petOwnership ?? '',
                            profile.userProfile.petTolerance ?? '',
                          ].where((e) => e.isNotEmpty).toList(),
                        ),

                        /// 🏡 DESIRED AMENITIES
                        _buildProfileListField(
                          '🏡 Desired Amenities',
                          profile.amenitiesDesired,
                        ),

                        /// 🤝 IDEAL FLATMATE
                        _buildSection(
                          title: '🤝 Ideal Flatmate',
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

                        /// ⭐ PREFERRED HABITS
                        _buildProfileListField(
                          '⭐ Preferred Habits',
                          profile.preferredHabits,
                        ),

                        /// 💎 IDEAL QUALITIES
                        _buildProfileListField(
                          '💎 Ideal Qualities',
                          profile.idealQualities,
                        ),

                        /// 🚫 DEAL BREAKERS
                        _buildProfileListField(
                          '🚫 Deal Breakers',
                          profile.dealBreakers,
                        ),
                // Profile Images (using the existing implementation)
                if (profile.imageUrls != null && profile.imageUrls!.isNotEmpty)
                  _buildSection(
                    title: 'Profile Images',
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

class FlatListingProfileDisplay extends StatelessWidget {
  final FlatListingProfile profile;

  const FlatListingProfileDisplay({super.key, required this.profile});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: kBackgroundColor,

    body: ListView(
      children: [

        /// HERO HEADER
        _buildPremiumHeroSection(profile),

        /// QUICK OVERVIEW
        _buildCharacteristicGrid(
          'Quick Overview',
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
              'Lease',
              profile.leaseDuration != null
                  ? '${profile.leaseDuration} Months'
                  : null,
            ),
          ],
        ),

        /// RENT DETAILS
        _buildCharacteristicGrid(
          'Rent Details',
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
          'Amenities',
          profile.amenities,
        ),

        /// ABOUT THE FLAT
        _buildSection(
          title: 'About The Flat',
          children: [
            _buildProfileField(
              'Address',
              profile.address,
              icon: Icons.location_on,
            ),

            _buildProfileField(
              'Landmark',
              profile.landmark,
              icon: Icons.place,
            ),

            _buildProfileField(
              'Description',
              profile.flatDescription,
              icon: Icons.description,
            ),
          ],
        ),

        /// CURRENT FLATMATE
        _buildCharacteristicGrid(
          'Current Flatmate',
          [
            MapEntry(
              'Name',
              profile.userProfile.name,
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
          'Lifestyle & Habits',
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
          'Flatmate Preferences',
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
          'Preferred Habits',
          profile.preferredHabits,
        ),

        _buildPreferenceGrid(
          'Ideal Qualities',
          profile.flatmateIdealQualities,
        ),

        _buildPreferenceGrid(
          'Deal Breakers',
          profile.flatmateDealBreakers,
        ),

        /// PHOTO GALLERY
        if (profile.imageUrls != null &&
            profile.imageUrls!.isNotEmpty)
          _buildSection(
            title: 'Photo Gallery',
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
                  return ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    child: Image.network(
                      profile.imageUrls![index],
                      fit: BoxFit.cover,
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