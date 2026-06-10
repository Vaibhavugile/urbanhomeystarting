// lib/widgets/profile_display_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:lottie/lottie.dart'; // Import Lottie

// --- Premium UrbanHomey Color Palettes ---
final List<MapEntry<Color, Color>> _vibrantColorPalettes = [
  MapEntry(
    const Color(0xFFF3E8FF),
    const Color(0xFF6A1B9A),
  ), // Purple

  MapEntry(
    const Color(0xFFFCE7F3),
    const Color(0xFFAD1457),
  ), // Pink

  MapEntry(
    const Color(0xFFE0E7FF),
    const Color(0xFF4338CA),
  ), // Indigo

  MapEntry(
    const Color(0xFFDBEAFE),
    const Color(0xFF2563EB),
  ), // Blue

  MapEntry(
    const Color(0xFFD1FAE5),
    const Color(0xFF059669),
  ), // Emerald

  MapEntry(
    const Color(0xFFFEF3C7),
    const Color(0xFFD97706),
  ), // Amber

  MapEntry(
    const Color(0xFFFFEDD5),
    const Color(0xFFEA580C),
  ), // Orange

  MapEntry(
    const Color(0xFFFEE2E2),
    const Color(0xFFDC2626),
  ), // Rose Red
];
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
          vertical: 10,
        ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),

      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.12),
          Colors.white.withOpacity(0.05),
        ],
      ),

      border: Border.all(
        color: Colors.white.withOpacity(0.12),
        width: 1,
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Padding(
      padding:
          padding ??
              const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          /// SECTION HEADER
          Row(
            children: [

              Container(
                width: 5,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFF6A1B9A),
                      Color(0xFFAD1457),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: .3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white
                      .withOpacity(.20),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

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

  final palette =
      _vibrantColorPalettes[
          iconColorIndex %
              _vibrantColorPalettes.length];

  return Container(
    margin: const EdgeInsets.only(
      bottom: 12,
    ),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius:
          BorderRadius.circular(18),
      color: Colors.white.withOpacity(.05),
      border: Border.all(
        color: Colors.white.withOpacity(.08),
      ),
    ),
    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [

        /// ICON
        if (icon != null)
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.key,
              boxShadow: [
                BoxShadow(
                  color: palette.value
                      .withOpacity(.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: palette.value,
              size: 22,
            ),
          ),

        if (icon != null)
          const SizedBox(width: 14),

        /// CONTENT
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              /// LABEL
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w600,
                  letterSpacing: 1,
                  color: Colors.white
                      .withOpacity(.60),
                ),
              ),

              const SizedBox(height: 4),

              /// VALUE
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
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
  String label,
  List<String>? values,
) {
  if (values == null || values.isEmpty) {
    return _buildSection(
      title: label,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
            color: Colors.white.withOpacity(.05),
            border: Border.all(
              color:
                  Colors.white.withOpacity(.08),
            ),
          ),
          child: Text(
            'No preferences added yet',
            style: TextStyle(
              color:
                  Colors.white.withOpacity(.65),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  return _buildSection(
    title: label,
    children: [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: values.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final item = entry.value;

            final palette =
                _vibrantColorPalettes[
                    index %
                        _vibrantColorPalettes
                            .length];

            return Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),

                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                  colors: [
                    palette.key,
                    palette.key.withOpacity(
                      .75,
                    ),
                  ],
                ),

                boxShadow: [
                  BoxShadow(
                    color: palette.value
                        .withOpacity(.15),
                    blurRadius: 8,
                    offset:
                        const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: palette.value,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    item,
                    style:
                        TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          palette.value,
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
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
      value.isEmpty ||
      value == 'N/A') {
    return const SizedBox.shrink();
  }

  final palette =
      _vibrantColorPalettes[
          (label.hashCode.abs()) %
              _vibrantColorPalettes.length];

  final bgColor =
      backgroundColor ?? palette.key;

  final fgColor =
      iconColor ?? palette.value;

  dynamic iconData =
      _characteristicIcons[label] ??
          _characteristicIcons[value];

  Widget iconWidget;

  if (iconData is IconData) {
    iconWidget = Icon(
      iconData,
      size: 42,
      color: fgColor,
    );
  } else if (iconData is String &&
      iconData.endsWith('.json')) {
    iconWidget = Lottie.asset(
      iconData,
      width: 65,
      height: 65,
      fit: BoxFit.contain,
      repeat: true,
    );
  } else {
    iconWidget = Icon(
      Icons.auto_awesome,
      size: 42,
      color: fgColor,
    );
  }

  return Container(
    padding: const EdgeInsets.all(14),

    decoration: BoxDecoration(
      borderRadius:
          BorderRadius.circular(22),

      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          bgColor,
          bgColor.withOpacity(.75),
        ],
      ),

      border: Border.all(
        color: Colors.white.withOpacity(.15),
      ),

      boxShadow: [
        BoxShadow(
          color: fgColor.withOpacity(.15),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),

    child: Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [

        /// LABEL
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow:
              TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w700,
            letterSpacing: .5,
            color: fgColor,
          ),
        ),

        const SizedBox(height: 12),

        /// ICON
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white
                .withOpacity(.55),
          ),
          child: Center(
            child: iconWidget,
          ),
        ),

        const SizedBox(height: 14),

        /// VALUE
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w600,
            color: Colors.black87,
            height: 1.3,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            color: Colors.white.withOpacity(.05),
            border: Border.all(
              color:
                  Colors.white.withOpacity(.08),
            ),
          ),
          child: Text(
            'No details available yet',
            style: TextStyle(
              color:
                  Colors.white.withOpacity(.65),
              fontSize: 14,
            ),
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

          crossAxisSpacing: 12,
          mainAxisSpacing: 12,

          childAspectRatio: 0.92,
        ),

        itemBuilder: (context, index) {
          final entry = validItems[index];

          return TweenAnimationBuilder<double>(
            duration: Duration(
              milliseconds:
                  250 + (index * 60),
            ),
            tween:
                Tween(begin: 0, end: 1),
            builder:
                (context, value, child) {
              return Transform.scale(
                scale: value,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            color: Colors.white.withOpacity(.05),
            border: Border.all(
              color:
                  Colors.white.withOpacity(.08),
            ),
          ),
          child: Text(
            'No preferences added yet',
            style: TextStyle(
              color:
                  Colors.white.withOpacity(.65),
              fontSize: 14,
            ),
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
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),

        itemBuilder: (context, index) {
          final preference =
              preferences[index];

          final palette =
              _vibrantColorPalettes[
                  index %
                      _vibrantColorPalettes
                          .length];

          dynamic iconData =
              _preferenceIcons[
                  preference];

          Widget iconWidget;

          if (iconData is IconData) {
            iconWidget = Icon(
              iconData,
              size: 38,
              color: palette.value,
            );
          } else if (iconData is String &&
              iconData.endsWith('.json')) {
            iconWidget = Lottie.asset(
              iconData,
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              repeat: true,
            );
          } else {
            iconWidget = Icon(
              Icons.auto_awesome,
              size: 38,
              color: palette.value,
            );
          }

          return TweenAnimationBuilder<double>(
            duration: Duration(
              milliseconds:
                  250 + (index * 60),
            ),
            tween:
                Tween(begin: 0, end: 1),
            builder:
                (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },

            child: Container(
              padding:
                  const EdgeInsets.all(14),

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),

                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end: Alignment
                      .bottomRight,
                  colors: [
                    palette.key,
                    palette.key
                        .withOpacity(.75),
                  ],
                ),

                border: Border.all(
                  color: Colors.white
                      .withOpacity(.15),
                ),

                boxShadow: [
                  BoxShadow(
                    color: palette.value
                        .withOpacity(.15),
                    blurRadius: 10,
                    offset:
                        const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [

                  Container(
                    width: 70,
                    height: 70,
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      color: Colors.white
                          .withOpacity(
                              .55),
                    ),
                    child: Center(
                      child:
                          iconWidget,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    preference,
                    textAlign:
                        TextAlign.center,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight
                              .w600,
                      color:
                          palette.value,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

      body: ListView(
        children: [
          // Profile Header (Owner Info)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profile.imageUrls != null && profile.imageUrls!.isNotEmpty
                      ? NetworkImage(profile.imageUrls![0])
                      : null,
                  child: profile.imageUrls == null || profile.imageUrls!.isEmpty
                      ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  profile.userProfile.name ?? 'N/A',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${profile.userProfile.age?.toString() ?? 'N/A'} years old, ${profile.userProfile.occupation ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Flat in ${profile.userProfile.city ?? 'N/A'}, ${profile.userProfile.city ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () { /* Handle chat */ },
                      icon: const Icon(Icons.chat, size: 20),
                      label: const Text('Chat', style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () { /* Handle call */ },
                      icon: const Icon(Icons.call, size: 20),
                      label: const Text('Call', style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Basic Info (Owner's Info) - NOW AS A GRID
          _buildCharacteristicGrid(
            'About The Current Flatmate',
            [
              MapEntry('Name', profile.userProfile.name),
              MapEntry('Age', profile.userProfile.age?.toString()),
              MapEntry('Gender', profile.userProfile.gender),
              MapEntry('Occupation', profile.userProfile.occupation),
              MapEntry('Religion', profile.userProfile.religion),
              MapEntry('Bio', profile.userProfile.bio),
            ],
          ),

          // Habits (Owner's Habits)
          _buildCharacteristicGrid(
            'Owner\'s Habits & Lifestyle',
            [
              MapEntry('Smoking Habits', profile.userProfile.smokingHabit),
              MapEntry('Drinking Habits', profile.userProfile.drinkingHabit),
              MapEntry('Food Preference', profile.userProfile.foodPreference),
              MapEntry('Cleanliness', profile.userProfile.cleanlinessLevel),

              MapEntry('Social Preferences', profile.userProfile.socialPreferences),

              MapEntry('Pet Ownership', profile.userProfile.petOwnership),
              MapEntry('Pet Tolerance', profile.userProfile.petTolerance),

            ],
          ),

          // Flat Details - NOW CONTAINS GRID FOR SOME FIELDS
          _buildCharacteristicGrid(
            'Flat Details',
            [
              MapEntry('City', profile.userProfile.city),
              MapEntry('Area', profile.userProfile.city),
              MapEntry('Address', profile.address),
              MapEntry('Landmark', profile.landmark),
              MapEntry('Description', profile.flatDescription),
              MapEntry('Flat Type', profile.flatType),
              MapEntry('Room Type', profile.roomType),
              MapEntry('Furnished Status', profile.furnishedStatus),
              MapEntry('Available For', profile.availableFor),
              MapEntry('Availability Date', profile.availabilityDate != null
                  ? DateFormat('dd/MM/yyyy').format(profile.availabilityDate!)
                  : null),
              MapEntry('Rent Price', '₹${profile.rentPrice ?? 'N/A'}'),
              MapEntry('Deposit Amt.', '₹${profile.depositAmount ?? 'N/A'}'),
              MapEntry('Bathroom Type', profile.bathroomType),

            ],
          ),
          // Amenities - NOW AS A GRID
          _buildCharacteristicGrid('Amenities', _convertStringListToCharacteristicEntries(profile.amenities)),


          // Flatmate Preferences
          _buildCharacteristicGrid(
            'Flatmate Preferences',
            [
              MapEntry('Preferred Gender', profile.preferredGender),
              MapEntry('Preferred Age', profile.preferredAgeGroup),
              MapEntry('Preferred Occupation', profile.preferredOccupation),
            ],
          ),
          // Preferred Habits - NOW AS A GRID
          _buildCharacteristicGrid('Preferred Habits', _convertStringListToCharacteristicEntries(profile.preferredHabits)),
          // Ideal Qualities - NOW AS A GRID
          _buildCharacteristicGrid('Ideal Qualities', _convertStringListToCharacteristicEntries(profile.flatmateIdealQualities)),
          // Deal Breakers - NOW AS A GRID
          _buildCharacteristicGrid('Deal Breakers', _convertStringListToCharacteristicEntries(profile.flatmateDealBreakers)),

          // Flat Images (using the existing implementation)
          if (profile.imageUrls != null && profile.imageUrls!.isNotEmpty)
            _buildSection(
              title: 'Flat Images',
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