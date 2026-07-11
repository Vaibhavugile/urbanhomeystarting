// lib/screens/flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mytennat/screens/home_page.dart';
import 'package:mytennat/data/location_data.dart'; // Adjust path as needed
import 'package:mytennat/data/user_profile.dart'; // Or the correct path to your UserProfile class
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/location_selector_widget.dart';
import '../constants/google_keys.dart';
// Data model to hold all the answers for the user listing a flat
class FlatListingProfile {
  String documentId; // Added: To store the Firestore document ID
  String? uid; // Added: To store the user ID (UID)
  UserProfile userProfile; // The new required field

  
  String flatType;
  String roomType;
  String furnishedStatus;
  String availableFor;
  DateTime? availabilityDate;
  int? rentPrice;
  int? depositAmount;
  String bathroomType;
  // String balconyAvailability;
  // String parkingAvailability;
  List<String> amenities;
 String? leaseDuration;
  String city;

String locationName;

String placeId;

double? latitude;

double? longitude;
  String flatDescription;
String? currentOccupants;
  // Flatmate Preferences
  String preferredGender;
  String preferredAgeGroup;
  String preferredOccupation;
  List<String> preferredHabits;
  List<String> flatmateIdealQualities;
  List<String> flatmateDealBreakers;

  // Added: List of image URLs for the flat
  List<String>? imageUrls;

  FlatListingProfile({
    this.documentId = '',
    this.uid,
    required this.userProfile,
    this.flatType = '',
    this.roomType = '',
    this.currentOccupants = '',
    this.furnishedStatus = '',
    this.availableFor = '',
    this.availabilityDate,
    this.rentPrice,
    this.depositAmount,
    this.bathroomType = '',
    this.leaseDuration = '',
    List<String>? amenities,
   this.city = '',
this.locationName = '',
this.placeId = '',
this.latitude,
this.longitude,
    this.flatDescription = '',
    this.preferredGender = '',
    this.preferredAgeGroup = '',
    this.preferredOccupation = '',
    List<String>? preferredHabits,
    List<String>? flatmateIdealQualities,
    List<String>? flatmateDealBreakers,
    List<String>? imageUrls,
  })  : amenities = amenities ?? const [],
        preferredHabits = preferredHabits ?? const [],
        flatmateIdealQualities = flatmateIdealQualities ?? const [],
        flatmateDealBreakers = flatmateDealBreakers ?? const [],
        imageUrls = imageUrls;

  factory FlatListingProfile.fromMap(Map<String, dynamic> data, String documentId) {
    // Add this print statement to see the raw data being processed
    print('Document ID: $documentId, Raw Data: $data');

    Map<String, dynamic> flatmatePreferences = {
  'preferredFlatmateGender': data['preferredFlatmateGender'],
  'preferredFlatmateAge': data['preferredFlatmateAge'],
  'preferredOccupation': data['preferredOccupation'],
  'preferredHabits': data['preferredHabits'],
  'idealQualities': data['idealQualities'],
  'dealBreakers': data['dealBreakers'],
};
    final Map<String, dynamic>? userProfileData = data['userProfile'] as Map<String, dynamic>?;

    // Add this print statement to see the userProfileData specifically
    print('UserProfile Data: $userProfileData');

    // Change this part to handle missing data gracefully instead of throwing an error.
    final UserProfile profile = userProfileData != null
        ? UserProfile.fromMap(userProfileData, data['uid'] as String? ?? '')
        : UserProfile(uid: data['uid'] as String? ?? '');

    return FlatListingProfile(
      documentId: documentId,
      uid: data['uid'] as String? ?? '', // Added null-aware operator for safety
      userProfile: profile, // Use the safely created profile object
     flatType: data['flatType'] ?? '',
roomType: data['roomType'] ?? '',
furnishedStatus: data['furnishedStatus'] ?? '',
availableFor: data['availableFor'] ?? '',
currentOccupants: data['currentOccupants'] ?? '',
leaseDuration:
    data['leaseDuration'],
availabilityDate: data['availabilityDate'] is Timestamp
    ? (data['availabilityDate'] as Timestamp).toDate()
    : null,

rentPrice: data['rentPrice'] is int
    ? data['rentPrice']
    : int.tryParse(data['rentPrice']?.toString() ?? ''),

depositAmount: data['depositAmount'] is int
    ? data['depositAmount']
    : int.tryParse(data['depositAmount']?.toString() ?? ''),

bathroomType: data['bathroomType'] ?? '',

amenities: List<String>.from(data['amenities'] ?? []),

city: data['city'] ?? '',

locationName:
    data['locationName'] ?? '',

placeId:
    data['placeId'] ?? '',

latitude:
    data['latitude'] != null
        ? (data['latitude'] as num)
            .toDouble()
        : null,

longitude:
    data['longitude'] != null
        ? (data['longitude'] as num)
            .toDouble()
        : null,

flatDescription: data['flatDescription'] ?? '',
      preferredGender: flatmatePreferences['preferredFlatmateGender'] ?? '',
      preferredAgeGroup: flatmatePreferences['preferredFlatmateAge'] ?? '',
      preferredOccupation: flatmatePreferences['preferredOccupation'] ?? '',
      preferredHabits: List<String>.from(flatmatePreferences['preferredHabits'] ?? []),
      flatmateIdealQualities: List<String>.from(flatmatePreferences['idealQualities'] ?? []),
      flatmateDealBreakers: List<String>.from(flatmatePreferences['dealBreakers'] ?? []),
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  // Method to convert the object to a map for Firestore
  // In your FlatListingProfile class
  Map<String, dynamic> toMap() {
    return {
       'uid': uid ?? userProfile.uid,
      'userProfile': userProfile.toMap(), // Saves all basic user info and habits

      // Fields specific to the flat listing
      'userType': 'flat_listing',
      'documentId': documentId,
      'rentPrice': rentPrice,
      'depositAmount': depositAmount,
      'flatType': flatType,
      'roomType': roomType,
      'furnishedStatus': furnishedStatus,
      'availableFor': availableFor,
      'leaseDuration':
    leaseDuration,
      'availabilityDate': availabilityDate != null ? Timestamp.fromDate(availabilityDate!) : null,
      'amenities': amenities,
      'currentOccupants': currentOccupants,
      'city': city,

'locationName': locationName,

'placeId': placeId,

'latitude': latitude,

'longitude': longitude,
      'flatDescription': flatDescription,
'imageUrls': imageUrls,
      // Flatmate preferences
      'preferredFlatmateGender': preferredGender,
      'preferredFlatmateAge': preferredAgeGroup,
      'preferredOccupation': preferredOccupation,
      'idealQualities': flatmateIdealQualities,
      'dealBreakers': flatmateDealBreakers,

      // Any other fields you want at the top level
      'isProfileComplete': true,
    };
  }

  @override
  String toString() {
    return 'FlatListingProfile(\n'
        '  documentId: $documentId,\n'
        '  uid: $uid,\n'
        '  userProfile: ${userProfile.toString()},\n'
        '  flatType: $flatType,\n'
        '  roomType: $roomType,\n'
        '  furnishedStatus: $furnishedStatus,\n'
        '  availableFor: $availableFor,\n'
        '  availabilityDate: $availabilityDate,\n'
        '  rentPrice: $rentPrice,\n'
        '  depositAmount: $depositAmount,\n'
        '  bathroomType: $bathroomType,\n'
        '  amenities: $amenities,\n'
       '  city: $city,\n'
        '  locationName: $locationName,\n'
        '  placeId: $placeId,\n'
        '  latitude: $latitude,\n'
        '  longitude: $longitude,\n'
        '  flatDescription: $flatDescription,\n'
        '  preferredGender: $preferredGender,\n'
        '  preferredAgeGroup: $preferredAgeGroup,\n'
        '  preferredOccupation: $preferredOccupation,\n'
        '  preferredHabits: $preferredHabits,\n'
        '  flatmateIdealQualities: $flatmateIdealQualities,\n'
        '  dealBreakers: $flatmateDealBreakers,\n'
        '  imageUrls: $imageUrls,\n'
        ')';
  }
}// Stateful Widget for Single Choice Questions
class SingleChoiceQuestionWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Function(String) onSelected;
  final bool isCard;
  final String? initialValue;
final bool compactMode;
  const SingleChoiceQuestionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.onSelected,
    this.isCard = false,
    this.initialValue,
      this.compactMode = false,
  });

  @override
  State<SingleChoiceQuestionWidget> createState() =>
      _SingleChoiceQuestionWidgetState();
}

class _SingleChoiceQuestionWidgetState
    extends State<SingleChoiceQuestionWidget> {
  String? _selectedOption;

  static const Color _primary = Color(0xFF7C3AED);
  static const Color _secondary = Color(0xFFEC4899);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();

    _selectedOption = widget.initialValue;
  }

  @override
  void didUpdateWidget(
    covariant SingleChoiceQuestionWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _selectedOption) {
      _selectedOption = widget.initialValue;
    }
  }

  void _selectOption(String option) {
    if (_selectedOption == option) {
      return;
    }

    setState(() {
      _selectedOption = option;
    });

    HapticFeedback.selectionClick();

    widget.onSelected(option);
  }

  Widget _buildQuestionHeader() {
    final bool hasSubtitle =
        widget.subtitle.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEEF2F7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QUESTION ICON

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _primary,
                  _secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          // TITLE + SUBTITLE

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: _textPrimary,
                  ),
                ),

                if (hasSubtitle) ...[
                  const SizedBox(height: 5),

                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String option) {
    final bool isSelected =
        _selectedOption == option;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectOption(option),
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 56,
          ),
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF5F3FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: isSelected
                  ? _primary
                  : _border,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? _primary.withOpacity(.10)
                    : Colors.black.withOpacity(.025),
                blurRadius: isSelected ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // RADIO INDICATOR

              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _primary,
                            _secondary,
                          ],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFCBD5E1),
                    width: 1.7,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _primary.withOpacity(.18),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          key: ValueKey('selected'),
                          color: Colors.white,
                          size: 15,
                        )
                      : const SizedBox(
                          key: ValueKey('unselected'),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // OPTION TEXT

              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.3,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: isSelected
                        ? _primary
                        : _textPrimary,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // RIGHT SELECTED INDICATOR

              AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 180,
                ),
                child: isSelected
                    ? Container(
                        key: const ValueKey(
                          'selected_indicator',
                        ),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _primary.withOpacity(.12),
                          ),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: _primary,
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey(
                          'empty_indicator',
                        ),
                        width: 28,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumOptions() {
  final Widget optionsContent = Column(
    children: widget.options.map((option) {
      return _buildOption(option);
    }).toList(),
  );

  if (widget.compactMode) {
    return optionsContent;
  }

  return Scrollbar(
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(
        top: 2,
        bottom: 16,
      ),
      child: optionsContent,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final double screenWidth =
        MediaQuery.sizeOf(context).width;

    final double horizontalPadding =
        screenWidth >= 700 ? 32 : 18;

    return SafeArea(
      top: false,
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 680,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionHeader(),

                const SizedBox(height: 16),

               if (widget.compactMode)
  _buildPremiumOptions()
else
  Expanded(
    child: _buildPremiumOptions(),
  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// Stateful Widget for Multi Choice Questions
class MultiChoiceQuestionWidget
    extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Function(List<String>)
      onSelected;
  final List<String> initialValues;
final bool compactMode;
  const MultiChoiceQuestionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.onSelected,
    this.initialValues = const [],
     this.compactMode = false,
  });

  @override
  State<MultiChoiceQuestionWidget>
      createState() =>
          _MultiChoiceQuestionWidgetState();
}

class _MultiChoiceQuestionWidgetState
    extends State<MultiChoiceQuestionWidget> {
  late List<String> _selectedOptions;

  static const Color _primary = Color(0xFF7C3AED);
  static const Color _secondary = Color(0xFFEC4899);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();

    _selectedOptions = List<String>.from(
      widget.initialValues,
    );
  }

  @override
  void didUpdateWidget(
    covariant MultiChoiceQuestionWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    // Compare list CONTENT instead of only list identity.
    if (!_sameValues(
      widget.initialValues,
      oldWidget.initialValues,
    )) {
      _selectedOptions = List<String>.from(
        widget.initialValues,
      );
    }
  }

  bool _sameValues(
    List<String> first,
    List<String> second,
  ) {
    if (first.length != second.length) {
      return false;
    }

    for (int i = 0; i < first.length; i++) {
      if (first[i] != second[i]) {
        return false;
      }
    }

    return true;
  }

  void _toggleOption(String option) {
    final bool isSelected =
        _selectedOptions.contains(option);

    setState(() {
      if (isSelected) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });

    HapticFeedback.selectionClick();

    // Send a COPY to the parent.
    widget.onSelected(
      List<String>.from(_selectedOptions),
    );
  }

  Widget _buildQuestionHeader() {
    final bool hasSubtitle =
        widget.subtitle.trim().isNotEmpty;

    final int selectedCount =
        _selectedOptions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEEF2F7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _primary,
                  _secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          // TITLE / SUBTITLE / SELECTED COUNT

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: _textPrimary,
                  ),
                ),

                if (hasSubtitle) ...[
                  const SizedBox(height: 5),

                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      color: _textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 9),

                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selectedCount > 0
                        ? const Color(0xFFF5F3FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selectedCount > 0
                          ? _primary.withOpacity(.15)
                          : _border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selectedCount > 0
                            ? Icons.check_circle_rounded
                            : Icons.touch_app_outlined,
                        size: 14,
                        color: selectedCount > 0
                            ? _primary
                            : _textSecondary,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        selectedCount == 0
                            ? 'Select all that apply'
                            : '$selectedCount selected',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: selectedCount > 0
                              ? _primary
                              : _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String option) {
    final bool isSelected =
        _selectedOptions.contains(option);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleOption(option),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(
            minHeight: 48,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF5F3FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? _primary
                  : _border,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? _primary.withOpacity(.09)
                    : Colors.black.withOpacity(.025),
                blurRadius: isSelected ? 12 : 7,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SELECTION INDICATOR

              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _primary,
                            _secondary,
                          ],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFCBD5E1),
                    width: 1.6,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          key: ValueKey('selected'),
                          color: Colors.white,
                          size: 14,
                        )
                      : const SizedBox(
                          key: ValueKey('unselected'),
                        ),
                ),
              ),

              const SizedBox(width: 9),

              // OPTION TEXT

              Flexible(
                child: Text(
                  option,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: isSelected
                        ? _primary
                        : _textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumOptions() {
  final Widget optionsContent = Align(
    alignment: Alignment.topLeft,
    child: Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.options.map((option) {
        return _buildOption(option);
      }).toList(),
    ),
  );

  if (widget.compactMode) {
    return optionsContent;
  }

  return Scrollbar(
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(
        top: 2,
        bottom: 16,
      ),
      child: optionsContent,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final double screenWidth =
        MediaQuery.sizeOf(context).width;

    final double horizontalPadding =
        screenWidth >= 700 ? 32 : 18;

    return SafeArea(
      top: false,
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 680,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionHeader(),

                const SizedBox(height: 16),

                if (widget.compactMode)
  _buildPremiumOptions()
else
  Expanded(
    child: _buildPremiumOptions(),
  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FlatmateProfileScreen extends StatefulWidget {
  final String? initialPhoneNumber;
  const FlatmateProfileScreen({super.key,this.initialPhoneNumber});

  @override
  State<FlatmateProfileScreen> createState() => _FlatmateProfileScreenState();
}

class _FlatmateProfileScreenState extends State<FlatmateProfileScreen> {

  final PageController _pageController = PageController();
  final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  late final FlatListingProfile _flatListingProfile;
  final ImagePicker _picker = ImagePicker();

List<File> _selectedFlatImages = [];
bool _isUploadingImages = false;
  int _currentPage = 0;
  bool _isSubmitting = false; // Added for loading indicator

  // Change _pages from late final to a getter
  List<Widget> get _pages => _buildPages();

  // Declare TextEditingControllers for all text input fields
  late TextEditingController _ownerNameController;
 // late TextEditingController _ownerAgeController;
  late TextEditingController _ownerOccupationController;
  late TextEditingController _ownerBioController;
  late TextEditingController _desiredCityController;
  late TextEditingController _areaPreferenceController;
  late TextEditingController _rentPriceController;
  late TextEditingController _depositAmountController;
  
  late TextEditingController _flatDescriptionController;

  // Define your sections - UPDATED
final List<Map<String, dynamic>> _sections = [
  {
    'title': 'Property Details',
    'icon': Icons.home_work_rounded,
    'startPage': 0,
    'endPage': 13,
  },
  {
    'title': 'Flatmate Preferences',
    'icon': Icons.people_alt_rounded,
    'startPage': 14,
    'endPage': 14,
  },
];

  String _getCurrentSectionTitle() {
    for (var section in _sections) {
      if (_currentPage >= section['startPage'] && _currentPage <= section['endPage']) {
        return section['title'];
      }
    }
    return '';
  }
IconData _getCurrentSectionIcon() {
  for (final section in _sections) {
    if (_currentPage >= section['startPage'] &&
        _currentPage <= section['endPage']) {
      return section['icon'];
    }
  }

  return Icons.dashboard_rounded;
}
  double _getCurrentSectionProgress() {
  for (final section in _sections) {
    if (_currentPage >= section['startPage'] &&
        _currentPage <= section['endPage']) {

      final start =
          section['startPage'] as int;

      final end =
          section['endPage'] as int;

      final totalPages =
          end - start + 1;

      final current =
          _currentPage - start + 1;

      return current / totalPages;
    }
  }

  return 0;
}

  // Method to check if the current page's input is valid
  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0: // Owner Name
        return _ownerNameController.text.isNotEmpty;
      // case 1: // Owner Age
      //   final age = int.tryParse(_ownerAgeController.text);
      //   return age != null && age >= 18 && age <= 99;
      // case 2: // Owner Gender
      //   return _flatListingProfile.ownerGender.isNotEmpty;
      case 3: // Owner Occupation
        return _ownerOccupationController.text.isNotEmpty;
      // case 3: // Owner Occupation
      //   return _flatListingProfile.ownerReligion.isNotEmpty;
      case 4: // Owner Bio
        return _ownerBioController.text.isNotEmpty;
      case 5: // Desired City (Flat Location)
        return _desiredCityController.text.isNotEmpty;
      case 6: // Area Preference
        return _areaPreferenceController.text.isNotEmpty;
      // case 7: // Smoking Habits
      //   return _flatListingProfile.smokingHabit.isNotEmpty;
      // case 8: // Drinking Habits
      //   return _flatListingProfile.drinkingHabit.isNotEmpty;
      // case 9: // Food Preference
      //   return _flatListingProfile.foodPreference.isNotEmpty;
      // case 10: // Cleanliness Level
      //   return _flatListingProfile.cleanlinessLevel.isNotEmpty;
    // case 11: // Noise Level
    //   return _flatListingProfile.noiseLevel.isNotEmpty;
    //   case 12: // Social Habits
    //     return _flatListingProfile.socialPreferences.isNotEmpty;
    // case 13: // Visitors policy
    //   return _flatListingProfile.visitorsPolicy.isNotEmpty;
    //   case 14: // Pet ownership
    //     return _flatListingProfile.petOwnership.isNotEmpty;
    //   case 15: // Pet tolerance
    //     return _flatListingProfile.petTolerance.isNotEmpty;
    // case 16: // Sleeping schedule
    //   return _flatListingProfile.sleepingSchedule.isNotEmpty;
    // case 17: // Work schedule
    //   return _flatListingProfile.workSchedule.isNotEmpty;
    // case 18: // Sharing Common Spaces
    //   return _flatListingProfile.sharingCommonSpaces.isNotEmpty;
    // case 19: // Guests Policy for Overnight Stays
    //   return _flatListingProfile.guestsOvernightPolicy.isNotEmpty;
    // case 20: // Personal Space
    //   return _flatListingProfile.personalSpaceVsSocialization.isNotEmpty;
      case 21: // Flat Type
        return _flatListingProfile.flatType.isNotEmpty;
      case 21: // Flat Type
        return _flatListingProfile.roomType.isNotEmpty;

      case 22: // Furnished Status
        return _flatListingProfile.furnishedStatus.isNotEmpty;
      case 23: // Available For
        return _flatListingProfile.availableFor.isNotEmpty;
      case 24: // Availability Date
        return _flatListingProfile.availabilityDate != null;
      case 25: // Rent Price
        return _flatListingProfile.rentPrice != null && _flatListingProfile.rentPrice! > 0;
      case 26: // Deposit Amount
        return _flatListingProfile.depositAmount != null && _flatListingProfile.depositAmount! >= 0;
      case 27: // Bathroom Type
        return _flatListingProfile.bathroomType.isNotEmpty;

      case 30: // Amenities
        return _flatListingProfile.amenities.isNotEmpty; // At least one amenity selected
     
      case 33: // Flat Description
        return _flatDescriptionController.text.isNotEmpty;
      case 34: // Preferred Flatmate Gender
        return _flatListingProfile.preferredGender.isNotEmpty;
      case 35: // Preferred Flatmate Age Group
        return _flatListingProfile.preferredAgeGroup.isNotEmpty;
      case 36: // Preferred Flatmate Occupation
        return _flatListingProfile.preferredOccupation.isNotEmpty;
      case 37: // Preferred Flatmate Habits
        return _flatListingProfile.preferredHabits.isNotEmpty;
      case 38: // Ideal Qualities in a Flatmate
        return _flatListingProfile.flatmateIdealQualities.isNotEmpty;
      case 39: // Deal Breakers
        return _flatListingProfile.flatmateDealBreakers.isNotEmpty;
      default:
        return true; // Fallback for pages not explicitly handled
    }
  }


  @override
  void initState() {
    super.initState();
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    _flatListingProfile = FlatListingProfile(
      userProfile: UserProfile(uid: currentUserUid!),
    );
    // Initialize controllers
    // with current profile values
    // if (widget.initialPhoneNumber != null) {
    //   _flatListingProfile.ownerPhonenumber = widget.initialPhoneNumber; // ADD THIS LINE
    // }
    // _ownerNameController = TextEditingController(text: _flatListingProfile.ownerName);
    //_ownerAgeController = TextEditingController(text: _flatListingProfile.ownerAge?.toString() ?? '');
    // _ownerOccupationController = TextEditingController(text: _flatListingProfile.ownerOccupation);
    // _ownerBioController = TextEditingController(text: _flatListingProfile.ownerBio);
    // _desiredCityController = TextEditingController(text: _flatListingProfile.desiredCity);
    // _areaPreferenceController = TextEditingController(text: _flatListingProfile.areaPreference);
    _rentPriceController = TextEditingController(text: _flatListingProfile.rentPrice?.toString() ?? '');
    _depositAmountController = TextEditingController(text: _flatListingProfile.depositAmount?.toString() ?? '');
    _flatDescriptionController = TextEditingController(text: _flatListingProfile.flatDescription);


    // Add listeners to update the profile model as text changes
    // _ownerNameController.addListener(() {
    //   _flatListingProfile.ownerName = _ownerNameController.text;
    //   setState(() {}); // Trigger rebuild to update button state
    // });
    // _ownerAgeController.addListener(() {
    //  // _flatListingProfile.ownerAge = int.tryParse(_ownerAgeController.text);
    //   setState(() {}); // Trigger rebuild to update button state
    // });
    // _ownerOccupationController.addListener(() {
    //   _flatListingProfile.ownerOccupation = _ownerOccupationController.text;
    //   setState(() {});
    // });
    // _ownerBioController.addListener(() {
    //   _flatListingProfile.ownerBio = _ownerBioController.text;
    //   setState(() {});
    // });
    // _desiredCityController.addListener(() {
    //   _flatListingProfile.desiredCity = _desiredCityController.text;
    //   setState(() {});
    // });
    // _areaPreferenceController.addListener(() {
    //   _flatListingProfile.areaPreference = _areaPreferenceController.text;
    //   setState(() {});
    // });
    _rentPriceController.addListener(() {
      _flatListingProfile.rentPrice = int.tryParse(_rentPriceController.text);
      setState(() {});
    });
    _depositAmountController.addListener(() {
      _flatListingProfile.depositAmount = int.tryParse(_depositAmountController.text);
      setState(() {});
    });
    _flatDescriptionController.addListener(() {
      _flatListingProfile.flatDescription = _flatDescriptionController.text;
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _ownerNameController.dispose();
    //_ownerAgeController.dispose();
    _ownerOccupationController.dispose();
    _ownerBioController.dispose();
    _desiredCityController.dispose();
    _areaPreferenceController.dispose();
    _rentPriceController.dispose();
    _depositAmountController.dispose();
    _flatDescriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

Future<void> _pickFlatImages() async {
  try {
    final List<XFile> images =
        await _picker.pickMultiImage(
      imageQuality: 80,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedFlatImages.addAll(
          images.map(
            (e) => File(e.path),
          ),
        );
      });
    }
  } catch (e) {
    debugPrint(
      'Error selecting images: $e',
    );
  }
}
void _removeFlatImage(int index) {
  setState(() {
    _selectedFlatImages.removeAt(index);
  });
}
Future<List<String>> _uploadFlatImages() async {
  List<String> uploadedUrls = [];

  try {
    for (File image in _selectedFlatImages) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('flat_images')
          .child(fileName);

      await storageRef.putFile(image);

      final downloadUrl =
          await storageRef.getDownloadURL();

      uploadedUrls.add(downloadUrl);
    }

    return uploadedUrls;
  } catch (e) {
    debugPrint(
      'Image Upload Error: $e',
    );

    return [];
  }
}
  // --- Common Question Builders ---

Widget _buildFlatImagesQuestion() {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Add Property Photos",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "Listings with photos receive significantly more interest from potential tenants.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 30),

        GestureDetector(
          onTap: _pickFlatImages,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF6A1B9A),
                width: 2,
              ),
              color: const Color(0xFFF8F4FF),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 60,
                  color: Color(0xFF6A1B9A),
                ),

                SizedBox(height: 12),

                Text(
                  "Upload Flat Photos",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  "Tap to select multiple photos",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        if (_selectedFlatImages.isNotEmpty)
          Expanded(
            child: GridView.builder(
              itemCount: _selectedFlatImages.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(18),
                      child: Image.file(
                        _selectedFlatImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          _removeFlatImage(index);
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.all(6),
                          decoration:
                              const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    ),
  );
}
Widget _buildTextQuestion({
  required String title,
  required String subtitle,
  required String hintText,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  int? maxLines = 1,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  const Color primary = Color(0xFF7C3AED);
  const Color secondary = Color(0xFFEC4899);
  const Color textPrimary = Color(0xFF111827);
  const Color textSecondary = Color(0xFF64748B);
  const Color borderColor = Color(0xFFE2E8F0);

  final bool hasSubtitle = subtitle.trim().isNotEmpty;

  final bool isMultiline =
      maxLines == null || maxLines > 1;

  // Prevents minLines > maxLines assertion.
  final int? effectiveMinLines = isMultiline
      ? (maxLines == null
          ? 4
          : maxLines!.clamp(2, 4).toInt())
      : 1;

  final double screenWidth =
      MediaQuery.sizeOf(context).width;

  final double horizontalPadding =
      screenWidth >= 700 ? 32 : 18;

  return SafeArea(
    top: false,
    bottom: false,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 680,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // PREMIUM COMPACT HEADER
              // ============================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFEEF2F7),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.035),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ICON

                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primary,
                            secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        isMultiline
                            ? Icons.notes_rounded
                            : Icons.edit_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // TITLE + SUBTITLE

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: textPrimary,
                            ),
                          ),

                          if (hasSubtitle) ...[
                            const SizedBox(height: 5),

                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ============================================================
              // PREMIUM INPUT FIELD
              // ============================================================

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.025),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,

                  keyboardType: keyboardType,

                  inputFormatters: inputFormatters,

                  maxLines: maxLines,

                  minLines: effectiveMinLines,

                  keyboardAppearance: Brightness.light,

                  cursorColor: primary,

                  cursorWidth: 1.8,

                  textInputAction: isMultiline
                      ? TextInputAction.newline
                      : TextInputAction.done,

                  textAlignVertical: isMultiline
                      ? TextAlignVertical.top
                      : TextAlignVertical.center,

                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),

                  decoration: InputDecoration(
                    hintText: hintText,

                    hintMaxLines:
                        isMultiline ? 3 : 1,

                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14.5,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),

                    // Multiline fields look cleaner without
                    // an icon floating vertically in the middle.

                    prefixIcon: isMultiline
                        ? null
                        : prefixIcon ??
                            const Icon(
                              Icons.edit_outlined,
                              color: primary,
                              size: 21,
                            ),

                    prefixIconConstraints: isMultiline
                        ? null
                        : const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),

                    suffixIcon: suffixIcon,

                    filled: true,

                    fillColor: Colors.white,

                    contentPadding: EdgeInsets.symmetric(
                      horizontal:
                          isMultiline ? 16 : 14,
                      vertical:
                          isMultiline ? 16 : 14,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: borderColor,
                        width: 1,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: primary,
                        width: 1.7,
                      ),
                    ),

                    errorBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.2,
                      ),
                    ),

                    focusedErrorBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.7,
                      ),
                    ),
                  ),

                  onTapOutside: (_) {
                    FocusManager
                        .instance.primaryFocus
                        ?.unfocus();
                  },
                ),
              ),

              // ============================================================
              // MULTILINE HELPER
              // ============================================================

              if (isMultiline) ...[
                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primary.withOpacity(.08),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        size: 16,
                        color: primary,
                      ),

                      SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          'Add useful details to help others understand your preferences better.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildDateQuestion({
  required String title,
  required String subtitle,
  required Function(DateTime?) onDateSelected,
  DateTime? initialDate,
}) {
  const Color primary = Color(0xFF7C3AED);
  const Color secondary = Color(0xFFEC4899);
  const Color textPrimary = Color(0xFF111827);
  const Color textSecondary = Color(0xFF64748B);
  const Color borderColor = Color(0xFFE2E8F0);

  final bool hasSubtitle = subtitle.trim().isNotEmpty;

  DateTime? selectedDate = initialDate;

  return StatefulBuilder(
    builder: (context, setLocalState) {
      final double screenWidth =
          MediaQuery.sizeOf(context).width;

      final double horizontalPadding =
          screenWidth >= 700 ? 32 : 18;

      final bool hasSelectedDate =
          selectedDate != null;

      Future<void> pickDate() async {
        FocusManager.instance.primaryFocus?.unfocus();

        HapticFeedback.selectionClick();

        final DateTime now = DateTime.now();

        final DateTime pickerInitialDate =
            selectedDate ?? now;

        final DateTime? picked =
            await showDatePicker(
          context: context,
          initialDate: pickerInitialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          helpText: 'SELECT DATE',
          cancelText: 'Cancel',
          confirmText: 'Done',
          builder: (context, child) {
            final ThemeData baseTheme =
                Theme.of(context);

            return Theme(
              data: baseTheme.copyWith(
                colorScheme:
                    const ColorScheme.light(
                  primary: primary,
                  onPrimary: Colors.white,
                  secondary: secondary,
                  surface: Colors.white,
                  onSurface: textPrimary,
                ),
                datePickerTheme:
                    DatePickerThemeData(
                  backgroundColor: Colors.white,
                  surfaceTintColor:
                      Colors.transparent,
                  elevation: 8,
                  headerBackgroundColor:
                      const Color(0xFFF5F3FF),
                  headerForegroundColor:
                      textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  todayBorder:
                      const BorderSide(
                    color: primary,
                    width: 1.2,
                  ),
                  todayForegroundColor:
                      const WidgetStatePropertyAll(
                    primary,
                  ),
                  cancelButtonStyle:
                      TextButton.styleFrom(
                    foregroundColor:
                        textSecondary,
                    textStyle:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  confirmButtonStyle:
                      TextButton.styleFrom(
                    foregroundColor: primary,
                    textStyle:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked == null) {
          return;
        }

        setLocalState(() {
          selectedDate = picked;
        });

        HapticFeedback.lightImpact();

        onDateSelected(picked);
      }

      return SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 680,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // PREMIUM COMPACT HEADER
                  // ==========================================

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            const Color(0xFFEEF2F7),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(.035),
                          blurRadius: 16,
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
                          width: 42,
                          height: 42,
                          decoration:
                              BoxDecoration(
                            gradient:
                                const LinearGradient(
                              begin:
                                  Alignment.topLeft,
                              end: Alignment
                                  .bottomRight,
                              colors: [
                                primary,
                                secondary,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              13,
                            ),
                          ),
                          child: const Icon(
                            Icons
                                .event_available_rounded,
                            color: Colors.white,
                            size: 21,
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
                                title,
                                style:
                                    const TextStyle(
                                  fontSize: 20,
                                  height: 1.2,
                                  fontWeight:
                                      FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: textPrimary,
                                ),
                              ),

                              if (hasSubtitle) ...[
                                const SizedBox(
                                  height: 5,
                                ),

                                Text(
                                  subtitle,
                                  style:
                                      const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    fontWeight:
                                        FontWeight.w400,
                                    color:
                                        textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==========================================
                  // PREMIUM DATE SELECTOR
                  // ==========================================

                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: pickDate,
                      borderRadius:
                          BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 220,
                        ),
                        curve:
                            Curves.easeOutCubic,
                        width: double.infinity,
                        constraints:
                            const BoxConstraints(
                          minHeight: 72,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: hasSelectedDate
                              ? const Color(
                                  0xFFF5F3FF,
                                )
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                          border: Border.all(
                            color: hasSelectedDate
                                ? primary
                                : borderColor,
                            width:
                                hasSelectedDate
                                    ? 1.5
                                    : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: hasSelectedDate
                                  ? primary
                                      .withOpacity(.09)
                                  : Colors.black
                                      .withOpacity(
                                        .025,
                                      ),
                              blurRadius:
                                  hasSelectedDate
                                      ? 14
                                      : 9,
                              offset:
                                  const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds: 220,
                              ),
                              width: 46,
                              height: 46,
                              decoration:
                                  BoxDecoration(
                                gradient:
                                    hasSelectedDate
                                        ? const LinearGradient(
                                            begin:
                                                Alignment.topLeft,
                                            end:
                                                Alignment.bottomRight,
                                            colors: [
                                              primary,
                                              secondary,
                                            ],
                                          )
                                        : null,
                                color: hasSelectedDate
                                    ? null
                                    : const Color(
                                        0xFFF5F3FF,
                                      ),
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                              ),
                              child: Icon(
                                hasSelectedDate
                                    ? Icons
                                        .event_available_rounded
                                    : Icons
                                        .calendar_month_outlined,
                                color: hasSelectedDate
                                    ? Colors.white
                                    : primary,
                                size: 22,
                              ),
                            ),

                            const SizedBox(width: 13),

                            Expanded(
                              child: Column(
                                mainAxisSize:
                                    MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    hasSelectedDate
                                        ? 'Selected date'
                                        : 'Availability Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.2,
                                      fontWeight:
                                          FontWeight.w600,
                                      color:
                                          hasSelectedDate
                                              ? primary
                                              : textSecondary,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    hasSelectedDate
                                        ? DateFormat(
                                            'dd MMM yyyy',
                                          ).format(
                                            selectedDate!,
                                          )
                                        : 'Tap to select a date',
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.25,
                                      fontWeight:
                                          FontWeight.w700,
                                      color:
                                          hasSelectedDate
                                              ? textPrimary
                                              : const Color(
                                                  0xFF94A3B8,
                                                ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds: 220,
                              ),
                              width: 34,
                              height: 34,
                              decoration:
                                  BoxDecoration(
                                color: hasSelectedDate
                                    ? Colors.white
                                    : const Color(
                                        0xFFF8FAFC,
                                      ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: hasSelectedDate
                                      ? primary.withOpacity(
                                          .15,
                                        )
                                      : borderColor,
                                ),
                              ),
                              child: Icon(
                                hasSelectedDate
                                    ? Icons
                                        .edit_calendar_rounded
                                    : Icons
                                        .chevron_right_rounded,
                                color: primary,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==========================================
                  // COMPACT HELPER CARD
                  // ==========================================

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFF8F7FF),
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            primary.withOpacity(.08),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons
                              .auto_awesome_outlined,
                          color: primary,
                          size: 16,
                        ),

                        SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            'Choose an accurate move-in or availability date to improve your matches.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              fontWeight:
                                  FontWeight.w500,
                              color:
                                  textSecondary,
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
        ),
      );
    },
  );
}

Widget _buildAreaSelectionQuestion({
  required String title,
  required String subtitle,
  required Function(String) onAreaSelected,
  required List<String> areas,
  String? initialValue,
  required String selectedCity,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // HEADER CARD

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color:
                      Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: initialValue == '' ||
                    !areas.contains(
                        initialValue)
                ? null
                : initialValue,

            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,

              prefixIcon: Container(
                margin:
                    const EdgeInsets.all(12),
                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFF7C3AED),
                      Color(0xFFEC4899),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                ),
              ),

              hintText:
                  selectedCity.isNotEmpty
                      ? "Choose Area"
                      : "Select City First",

              hintStyle:
                  const TextStyle(
                color:
                    Color(0xFF9CA3AF),
                fontWeight:
                    FontWeight.w500,
              ),

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        24),
                borderSide:
                    BorderSide.none,
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        24),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xFFE5E7EB),
                ),
              ),

              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        24),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xFF7C3AED),
                  width: 2,
                ),
              ),
            ),

            dropdownColor:
                Colors.white,

            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF7C3AED),
            ),

            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),

            items: areas.map((area) {
              return DropdownMenuItem(
                value: area,
                child: Text(area),
              );
            }).toList(),

            onChanged:
                selectedCity.isNotEmpty
                    ? (value) {
                        if (value !=
                            null) {
                          onAreaSelected(
                              value);
                        }
                      }
                    : null,

            isExpanded: true,
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding:
              const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                const Color(0xFFF5F3FF),
            borderRadius:
                BorderRadius.circular(
                    16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color:
                    Color(0xFF7C3AED),
                size: 18,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  selectedCity.isEmpty
                      ? "Please select a city before choosing an area."
                      : "Selecting the correct area improves listing visibility.",
                  style:
                      const TextStyle(
                    fontSize: 13,
                    color: Color(
                        0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  Widget _buildCitySelectionQuestion({
  required String title,
  required String subtitle,
  required Function(String) onCitySelected,
  required List<String> cities,
  String? initialValue,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // HEADER CARD

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color:
                      Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // CITY DROPDOWN

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: initialValue == ''
                ? null
                : initialValue,

            isExpanded: true,

            dropdownColor: Colors.white,

            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF7C3AED),
              size: 28,
            ),

            style: const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
              color:
                  Color(0xFF111827),
            ),

            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,

              hintText:
                  "Choose Your City",

              hintStyle:
                  const TextStyle(
                color:
                    Color(0xFF9CA3AF),
                fontWeight:
                    FontWeight.w500,
              ),

              prefixIcon: Container(
                margin:
                    const EdgeInsets.all(12),
                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFF7C3AED),
                      Color(0xFFEC4899),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: Colors.white,
                ),
              ),

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        24),
                borderSide:
                    BorderSide.none,
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        24),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xFFE5E7EB),
                ),
              ),

              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        24),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xFF7C3AED),
                  width: 2,
                ),
              ),
            ),

            items: cities.map((city) {
              return DropdownMenuItem<
                  String>(
                value: city,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(
                          0xFF7C3AED),
                      size: 18,
                    ),
                    const SizedBox(
                        width: 10),
                    Text(city),
                  ],
                ),
              );
            }).toList(),

            onChanged: (value) {
              if (value != null) {
                onCitySelected(value);
              }
            },
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding:
              const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                const Color(0xFFF5F3FF),
            borderRadius:
                BorderRadius.circular(
                    16),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.location_searching,
                color:
                    Color(0xFF7C3AED),
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Choose the city where you want to find a flat, room, or flatmate.",
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  // --- Page Definitions ---
Widget _buildFlatmatePreferencesPage() {
  final double screenWidth =
      MediaQuery.sizeOf(context).width;

  final double horizontalPadding =
      screenWidth >= 700 ? 32 : 0;

  return SafeArea(
    top: false,
    bottom: false,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 760,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            4,
            horizontalPadding,
            32,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ============================================================
              // 1. PREFERRED FLATMATE GENDER
              // ============================================================

              SingleChoiceQuestionWidget(
                title:
                    "Preferred Flatmate Gender",
                subtitle:
                    "This helps in finding a compatible match.",
                options: const [
                  'Male',
                  'Female',
                  'No preference',
                  'Other',
                ],
                compactMode: true,
                onSelected: (value) {
                  setState(() {
                    _flatListingProfile.preferredGender =
                        value;
                  });
                },
                initialValue:
                    _flatListingProfile.preferredGender,
              ),

              const SizedBox(height: 24),

              // ============================================================
              // 2. PREFERRED FLATMATE AGE GROUP
              // ============================================================

              SingleChoiceQuestionWidget(
                title:
                    "Preferred Age Group",
                subtitle:
                    "",
                options: const [
                  '18-24',
                  '25-30',
                  '30-40',
                  '40+',
                  'No preference',
                ],
                compactMode: true,
                onSelected: (value) {
                  setState(() {
                    _flatListingProfile.preferredAgeGroup =
                        value;
                  });
                },
                initialValue:
                    _flatListingProfile.preferredAgeGroup,
              ),

              const SizedBox(height: 24),

              // ============================================================
              // 3. PREFERRED FLATMATE OCCUPATION
              // ============================================================

              SingleChoiceQuestionWidget(
                title:
                    "Preferred Occupation",
                subtitle:
                    "",
                options: const [
                  'Student',
                  'Working Professional',
                  'No preference',
                ],
                compactMode: true,
                onSelected: (value) {
                  setState(() {
                    _flatListingProfile.preferredOccupation =
                        value;
                  });
                },
                initialValue:
                    _flatListingProfile.preferredOccupation,
              ),

              const SizedBox(height: 24),

              // ============================================================
              // 4. PREFERRED FLATMATE HABITS
              // ============================================================

              MultiChoiceQuestionWidget(
                title:
                    "Prederred Habits",
                subtitle:
                    "Select all that apply.",
                options: const [
                  'Non-smoker',
                  'Non-drinker',
                  'Vegetarian',
                  'Quiet',
                  'Social',
                  'Respectful',
                  'Pet-friendly',
                ],
                compactMode: true,
                onSelected: (selected) {
                  setState(() {
                    _flatListingProfile.preferredHabits =
                        List<String>.from(selected);
                  });
                },
                initialValues:
                    _flatListingProfile.preferredHabits,
              ),

              const SizedBox(height: 24),

              // ============================================================
              // 5. IDEAL QUALITIES
              // ============================================================

              MultiChoiceQuestionWidget(
                title:
                    "Preferred Qualities",
                subtitle:
                    "",
                options: const [
                  'Respectful',
                  'Neat',
                  'Communicative',
                  'Friendly',
                  'Responsible',
                  'Quiet',
                  'Social',
                  'Independent',
                ],
                compactMode: true,
                onSelected: (selected) {
                  setState(() {
                    _flatListingProfile
                            .flatmateIdealQualities =
                        List<String>.from(selected);
                  });
                },
                initialValues:
                    _flatListingProfile
                        .flatmateIdealQualities,
              ),

              const SizedBox(height: 24),

              // ============================================================
              // 6. DEAL BREAKERS
              // ============================================================

              // MultiChoiceQuestionWidget(
              //   title:
              //       "Any deal breakers for a flatmate?",
              //   subtitle:
              //       "Things you absolutely cannot tolerate.",
              //   options: const [
              //     'Excessive Noise',
              //     'Untidiness',
              //     'Frequent Parties',
              //     'Smoking Indoors',
              //     'Unpaid Bills',
              //     'Lack of Communication',
              //     'Pets (if not allowed)',
              //     'Late Night Guests',
              //     'Drugs',
              //     'Disrespectful behavior',
              //   ],
              //   compactMode: true,
              //   onSelected: (selected) {
              //     setState(() {
              //       _flatListingProfile
              //               .flatmateDealBreakers =
              //           List<String>.from(selected);
              //     });
              //   },
              //   initialValues:
              //       _flatListingProfile
              //           .flatmateDealBreakers,
              // ),

              // Extra bottom breathing room so the last
              // options are not visually attached to footer.

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
}
  List<Widget> _buildPages() {
    return [
     


      // --- Section 3: Flat Details (Pages 21-33) ---
      // Page 21: Flat Type
      SingleChoiceQuestionWidget(
        title: "Property Type",
        subtitle: "",
        options: ['Studio Apartment', '1BHK', '2BHK', '3BHK', '4BHK+', 'Other'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.flatType = value;
          });
        },
        initialValue: _flatListingProfile.flatType,
      ),
      SingleChoiceQuestionWidget(
        title: "Occupancy Type",
        subtitle: "",
        options: ['Single Occupancy', 'Double Occupancy', 'Triple Occupancy', 'Other'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.roomType = value;
          });
        },
        initialValue: _flatListingProfile.roomType,
      ),

      // Page 22: Furnished Status
      SingleChoiceQuestionWidget(
        title: "Furnishing Status",
        subtitle: "",
        options: ['Furnished', 'Semi-furnished', 'Unfurnished'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.furnishedStatus = value;
          });
        },
        initialValue: _flatListingProfile.furnishedStatus,
      ),
      SingleChoiceQuestionWidget(
  title: "Current Occupants",
  subtitle: "",
  options: [
    'Just Me',
    '2 People',
    '3 People',
    '4 People',
    '5+ People',
  ],
  onSelected: (value) {
    setState(() {
      _flatListingProfile.currentOccupants = value;
    });
  },
  initialValue: _flatListingProfile.currentOccupants,
),
SingleChoiceQuestionWidget(
  title: "Pending Lease Duration",
  subtitle: "",
  options: [
    '1 Month',
    '2 Months',
    '3 Months',
    '4 Months',
    '5 Months',
    '6 Months',
    '7 Months',
    '8 Months',
    '9 Months',
    '10 Months',
    '11 Months',
    '1 Year',
    'More than 1 Year',
    'Flexible',
  ],
  onSelected: (value) {
    setState(() {
      _flatListingProfile.leaseDuration = value;
    });
  },
  initialValue: _flatListingProfile.leaseDuration,
),

LocationSelectorWidget(
  googleApiKey:'AIzaSyBK82kg-QdV1TdTrOoC3-jvbSstRhz1wZ0',

  initialCity: _flatListingProfile.city,
  initialAddress: _flatListingProfile.locationName,

  onLocationSelected: (location) {
    setState(() {
      _flatListingProfile.city =
          location.city ?? '';

      _flatListingProfile.locationName =
          location.address ?? '';

      _flatListingProfile.placeId =
          location.placeId ?? '';

      _flatListingProfile.latitude =
          location.latitude;

      _flatListingProfile.longitude =
          location.longitude;
    });
  },
),
_buildFlatImagesQuestion(),


      // Page 23: Available For
      // SingleChoiceQuestionWidget(
      //   title: "Who is the flat available for?",
      //   subtitle: "Select the preferred gender/group.",
      //   options: ['Boys', 'Girls', 'Couples', 'Anyone'],
      //   onSelected: (value) {
      //     setState(() {
      //       _flatListingProfile.availableFor = value;
      //     });
      //   },
      //   initialValue: _flatListingProfile.availableFor,
      // ),

      // Page 24: Availability Date
      _buildDateQuestion(
        title: "Availabe From",
        subtitle: "",
        onDateSelected: (date) {
          setState(() {
            _flatListingProfile.availabilityDate = date;
          });
        },
        initialDate: _flatListingProfile.availabilityDate,
      ),

      // Page 25: Rent Price
      _buildTextQuestion(
        title: "Monthly Rent",
        subtitle: "",
        hintText: "e.g., 12000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _rentPriceController,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('₹', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      ),

      // Page 26: Deposit Amount
      _buildTextQuestion(
        title: "Security Deposit",
        subtitle: "",
        hintText: "e.g., 24000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _depositAmountController,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('₹', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      ),

      // Page 27: Bathroom Type
      SingleChoiceQuestionWidget(
        title: "Washroom Type",
        subtitle: "",
        options: ['Attached Washroom', 'Shared Washroom'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.bathroomType = value;
          });
        },
        initialValue: _flatListingProfile.bathroomType,
      ),

      // Page 28: Balcony Availability
      // SingleChoiceQuestionWidget(
      //   title: "Does the flat have a balcony?",
      //   subtitle: "Yes, No, or Specific Room.",
      //   options: ['Yes', 'No', 'Only in living room', 'Only in bedroom'],
      //   onSelected: (value) {
      //     setState(() {
      //       _flatListingProfile.balconyAvailability = value;
      //     });
      //   },
      //   initialValue: _flatListingProfile.balconyAvailability,
      // ),

      // Page 29: Parking Availability
      // SingleChoiceQuestionWidget(
      //   title: "Is parking available?",
      //   subtitle: "For car, two-wheeler, or both.",
      //   options: ['Yes, for Car', 'Yes, for Two-wheeler', 'Both', 'No'],
      //   onSelected: (value) {
      //     setState(() {
      //       _flatListingProfile.parkingAvailability = value;
      //     });
      //   },
      //   initialValue: _flatListingProfile.parkingAvailability,
      // ),

      // Page 30: Amenities (Multi-choice)
      MultiChoiceQuestionWidget(
        title: "Flat Facilities",
        subtitle: "",
        options: [
          'Wi-Fi',
          'AC',
          'Geyser',
          'Washing Machine',
          'Refrigerator',
          'Microwave',
          'Maid Service',
          'Cook',
          
        ],
        onSelected: (selected) {
          setState(() {
            _flatListingProfile.amenities = selected;
          });
        },
        initialValues: _flatListingProfile.amenities,
      ),

      
    

      // Page 33: Flat Description
      // _buildTextQuestion(
      //   title: "Describe your flat.",
      //   subtitle: "Highlight key features, vibe, and what makes it a great place.",
      //   hintText: "e.g., Spacious 2BHK with great sunlight, friendly neighborhood...",
      //   controller: _flatDescriptionController,
      //   maxLines: 5,
      // ),

      // --- Section 4: Flatmate Preferences (Pages 34-39) ---
      // Page 34: Preferred Flatmate Gender
      // ============================================================
// SECTION 4: FLATMATE PREFERENCES
// 6 questions combined into one scrollable page
// ============================================================

_buildFlatmatePreferencesPage(),
    ];
  }

  void _nextPage() {
  FocusScope.of(context).unfocus();

  if (_currentPage < _pages.length - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  } else {
    _submitProfile();
  }
}

void _previousPage() {
  FocusScope.of(context).unfocus();

  if (_currentPage > 0) {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
}

  // --- Method to show sections bottom sheet ---
 void _showSectionsBottomSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * .55,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Drag Handle
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7C3AED),
                          Color(0xFFEC4899),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.dashboard_customize_rounded,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 16),

                  const Expanded(
                    child: Text(
                      "Jump to Section",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final section =
                      _sections[index];

                  final bool isCurrentSection =
                      _currentPage >=
                              section['startPage']
                          &&
                          _currentPage <=
                              section['endPage'];

                  final IconData icon =
                      section['icon'] ??
                          Icons.folder_open;

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);

                      _pageController.jumpToPage(
                        section['startPage']
                            as int,
                      );
                    },
                    child: AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 250,
                      ),
                      margin:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),
                      padding:
                          const EdgeInsets.all(
                        18,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),
                        gradient:
                            isCurrentSection
                                ? const LinearGradient(
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
                                  )
                                : null,
                        color:
                            isCurrentSection
                                ? null
                                : Colors.white,
                        border: Border.all(
                          color:
                              isCurrentSection
                                  ? Colors
                                      .transparent
                                  : const Color(
                                      0xFFE5E7EB,
                                    ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isCurrentSection
                                    ? const Color(
                                        0xFF7C3AED,
                                      ).withOpacity(
                                        .25,
                                      )
                                    : Colors
                                        .black
                                        .withOpacity(
                                        .05,
                                      ),
                            blurRadius: 18,
                            offset:
                                const Offset(
                              0,
                              8,
                            ),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration:
                                BoxDecoration(
                              color:
                                  isCurrentSection
                                      ? Colors
                                          .white
                                      : const Color(
                                          0xFFF3F4F6,
                                        ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                14,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color:
                                  isCurrentSection
                                      ? const Color(
                                          0xFF7C3AED,
                                        )
                                      : const Color(
                                          0xFF6B7280,
                                        ),
                            ),
                          ),

                          const SizedBox(
                            width: 16,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  section[
                                      'title'],
                                  style:
                                      TextStyle(
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    color:
                                        isCurrentSection
                                            ? Colors
                                                .white
                                            : const Color(
                                                0xFF111827,
                                              ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  "Pages ${section['startPage'] + 1} - ${section['endPage'] + 1}",
                                  style:
                                      TextStyle(
                                    color:
                                        isCurrentSection
                                            ? Colors
                                                .white70
                                            : const Color(
                                                0xFF6B7280,
                                              ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (isCurrentSection)
                            const Icon(
                              Icons
                                  .check_circle,
                              color:
                                  Colors.white,
                            )
                          else
                            const Icon(
                              Icons
                                  .arrow_forward_ios,
                              size: 16,
                              color: Color(
                                0xFF7C3AED,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

Future<void> _submitProfileToFirebase() async {
  // Prevent duplicate submissions.
  if (_isSubmitting) return;

  if (mounted) {
    setState(() {
      _isSubmitting = true;
    });
  }

  final user = FirebaseAuth.instance.currentUser;

  // ============================================================
  // USER NOT LOGGED IN
  // ============================================================

  if (user == null) {
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.all(16),
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 4),
          content: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFECACA),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.10),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Row(
              children: [
                _PremiumSnackBarIcon(
                  icon: Icons.login_rounded,
                  gradientColors: [
                    Color(0xFFEF4444),
                    Color(0xFFF97316),
                  ],
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please log in to submit your profile.',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

    return;
  }

  try {
    // ============================================================
    // 1. FETCH MAIN USER PROFILE
    // ============================================================

    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (!userDoc.exists || userDoc.data() == null) {
      throw Exception(
        'Main user profile not found. Please create your main profile first.',
      );
    }

    final Map<String, dynamic> mainUserData =
        userDoc.data() as Map<String, dynamic>;

    final dynamic habitsData = mainUserData['habits'];

    final Map<String, dynamic> habits =
        habitsData is Map
            ? Map<String, dynamic>.from(habitsData)
            : <String, dynamic>{};

    // ============================================================
    // 2. CREATE USER PROFILE SNAPSHOT
    // ============================================================

    final UserProfile userProfile = UserProfile(
      uid: user.uid,
      name: mainUserData['name'] ?? '',
      age: mainUserData['age'],
      gender: mainUserData['gender'] ?? '',
      profilePhotoUrl: mainUserData['profilePhotoUrl'],
      city: mainUserData['city'] ?? '',
      phoneNumber: mainUserData['phoneNumber'],
      occupation: mainUserData['occupation'],
      religion: mainUserData['religion'],
      bio: mainUserData['bio'],
      imageUrls:
          (mainUserData['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      smokingHabit: habits['smoking'] ?? '',
      drinkingHabit: habits['drinking'] ?? '',
      foodPreference: habits['food'] ?? '',
      cleanlinessLevel: habits['cleanliness'] ?? '',
      socialPreferences:
          habits['socialPreferences'] ?? '',
      petOwnership: habits['petOwnership'] ?? '',
      petTolerance: habits['petTolerance'] ?? '',
      guestsFrequency: habits['guestsFrequency'] ?? '',
    );

    // ============================================================
    // 3. UPLOAD FLAT IMAGES
    // ============================================================

    List<String> uploadedImageUrls = [];

    if (_selectedFlatImages.isNotEmpty) {
      if (mounted) {
        setState(() {
          _isUploadingImages = true;
        });
      }

      try {
        uploadedImageUrls =
            await _uploadFlatImages();
      } finally {
        if (mounted) {
          setState(() {
            _isUploadingImages = false;
          });
        }
      }
    }

    // ============================================================
    // 4. CREATE FLAT LISTING PROFILE
    // ============================================================

    final FlatListingProfile flatListingProfile =
        FlatListingProfile(
      uid: user.uid,
      userProfile: userProfile,

      rentPrice:
          int.tryParse(_rentPriceController.text.trim()),

      depositAmount:
          int.tryParse(
            _depositAmountController.text.trim(),
          ),

      city: _flatListingProfile.city,
      locationName: _flatListingProfile.locationName,
      placeId: _flatListingProfile.placeId,
      latitude: _flatListingProfile.latitude,
      longitude: _flatListingProfile.longitude,

      flatDescription:
          _flatDescriptionController.text.trim(),

      flatType: _flatListingProfile.flatType,
      roomType: _flatListingProfile.roomType,

      imageUrls: uploadedImageUrls,

      currentOccupants:
          _flatListingProfile.currentOccupants,

      leaseDuration:
          _flatListingProfile.leaseDuration,

      bathroomType:
          _flatListingProfile.bathroomType,

      furnishedStatus:
          _flatListingProfile.furnishedStatus,

      availableFor:
          _flatListingProfile.availableFor,

      preferredGender:
          _flatListingProfile.preferredGender,

      preferredAgeGroup:
          _flatListingProfile.preferredAgeGroup,

      preferredOccupation:
          _flatListingProfile.preferredOccupation,

      amenities:
          _flatListingProfile.amenities,

      flatmateIdealQualities:
          _flatListingProfile.flatmateIdealQualities,

      flatmateDealBreakers:
          _flatListingProfile.flatmateDealBreakers,
    );

    // ============================================================
    // 5. CONVERT PROFILE TO FIRESTORE MAP
    // ============================================================

    final Map<String, dynamic> profileData =
        flatListingProfile.toMap();

    final CollectionReference flatListingsCollection =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('flatListings');

    // ============================================================
    // 6. CREATE OR UPDATE PROFILE
    // ============================================================

    final bool isCreating =
        flatListingProfile.documentId.isEmpty;

    if (isCreating) {
      profileData['createdAt'] =
          FieldValue.serverTimestamp();

      profileData['lastUpdated'] =
          FieldValue.serverTimestamp();

      final DocumentReference newDocRef =
          await flatListingsCollection.add(profileData);

      flatListingProfile.documentId =
          newDocRef.id;
    } else {
      profileData['lastUpdated'] =
          FieldValue.serverTimestamp();

      profileData.remove('createdAt');

      await flatListingsCollection
          .doc(flatListingProfile.documentId)
          .update(profileData);
    }

    if (!mounted) return;

    // ============================================================
    // 7. PREMIUM SUCCESS SNACKBAR
    // ============================================================

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.all(16),
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 3),
          content: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE9D5FF),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED)
                      .withOpacity(.15),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const _PremiumSnackBarIcon(
                  icon: Icons.check_rounded,
                  gradientColors: [
                    Color(0xFF7C3AED),
                    Color(0xFFEC4899),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCreating
                            ? 'Listing Created'
                            : 'Listing Updated',
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        isCreating
                            ? 'Your flat listing has been created successfully.'
                            : 'Your flat listing changes have been saved successfully.',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
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

    // Allow floating SnackBar to be visible before navigation.
    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint(
      'Error submitting flat listing profile: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    if (!mounted) return;

    // ============================================================
    // PREMIUM ERROR SNACKBAR
    // ============================================================

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.all(16),
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 5),
          content: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFECACA),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444)
                      .withOpacity(.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const _PremiumSnackBarIcon(
                  icon: Icons.close_rounded,
                  gradientColors: [
                    Color(0xFFEF4444),
                    Color(0xFFF97316),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unable to Save Listing',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        e.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
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
  } finally {
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isUploadingImages = false;
      });
    }
  }
}


  void _submitProfile() {
    print('Submitting Flat Listing Profile:');
    print(_flatListingProfile.toString());
    _submitProfileToFirebase();
  }

@override
Widget build(BuildContext context) {
  const Color primary = Color(0xFF7C3AED);
  const Color secondary = Color(0xFFEC4899);
  const Color textPrimary = Color(0xFF111827);
  const Color textSecondary = Color(0xFF64748B);
  const Color backgroundColor = Color(0xFFF8FAFC);

  final Size screenSize = MediaQuery.sizeOf(context);

  final bool isTablet = screenSize.width >= 700;

  final double horizontalPadding =
      isTablet ? 32 : 16;

  final bool hasPages = _pages.isNotEmpty;

  final double progress = hasPages
      ? ((_currentPage + 1) / _pages.length)
          .clamp(0.0, 1.0)
          .toDouble()
      : 0.0;

  final bool isFirstPage =
      !hasPages || _currentPage == 0;

  final bool isLastPage =
      hasPages && _currentPage == _pages.length - 1;

  int currentSectionIndex = 1;

  if (_sections.isNotEmpty) {
    final int foundSectionIndex =
        _sections.indexWhere(
      (section) {
        final int startPage =
            section['startPage'] as int;

        final int endPage =
            section['endPage'] as int;

        return _currentPage >= startPage &&
            _currentPage <= endPage;
      },
    );

    if (foundSectionIndex >= 0) {
      currentSectionIndex =
          foundSectionIndex + 1;
    }
  }

  return Scaffold(
    backgroundColor: backgroundColor,

    body: Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              // ============================================================
              // PREMIUM COMPACT HEADER
              // ============================================================

              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  10,
                  horizontalPadding,
                  0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 760,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        14,
                        12,
                        14,
                        14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6D28D9),
                            primary,
                            Color(0xFF9333EA),
                            secondary,
                          ],
                          stops: [
                            0.0,
                            0.38,
                            0.72,
                            1.0,
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                primary.withOpacity(.18),
                            blurRadius: 22,
                            offset:
                                const Offset(0, 9),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // =================================================
                          // TOP ROW
                          // =================================================

                          SizedBox(
                            height: 42,
                            child: Row(
                              children: [
                                // BACK / LISTING ICON

                                AnimatedSwitcher(
                                  duration: const Duration(
                                    milliseconds: 180,
                                  ),
                                  child: !isFirstPage
                                      ? Material(
                                          key: const ValueKey(
                                            'header_back',
                                          ),
                                          color:
                                              Colors.transparent,
                                          child: InkWell(
                                            onTap:
                                                _previousPage,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              13,
                                            ),
                                            child: Container(
                                              width: 42,
                                              height: 42,
                                              decoration:
                                                  BoxDecoration(
                                                color: Colors
                                                    .white
                                                    .withOpacity(
                                                  .14,
                                                ),
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                  13,
                                                ),
                                                border:
                                                    Border.all(
                                                  color: Colors
                                                      .white
                                                      .withOpacity(
                                                    .14,
                                                  ),
                                                ),
                                              ),
                                              child:
                                                  const Icon(
                                                Icons
                                                    .arrow_back_ios_new_rounded,
                                                color:
                                                    Colors.white,
                                                size: 17,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          key: const ValueKey(
                                            'listing_icon',
                                          ),
                                          width: 42,
                                          height: 42,
                                          decoration:
                                              BoxDecoration(
                                            color: Colors.white
                                                .withOpacity(
                                              .14,
                                            ),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              13,
                                            ),
                                            border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(
                                                .14,
                                              ),
                                            ),
                                          ),
                                          child:
                                              const Icon(
                                            Icons
                                                .add_home_work_rounded,
                                            color:
                                                Colors.white,
                                            size: 21,
                                          ),
                                        ),
                                ),

                                const SizedBox(width: 10),

                                // TITLE + SECTION COUNT

                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Create Listing',
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 19,
                                          height: 1.1,
                                          fontWeight:
                                              FontWeight.w800,
                                          letterSpacing: -.3,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        'Section $currentSectionIndex of ${_sections.length}',
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(.74),
                                          fontSize: 11.5,
                                          height: 1.1,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // SECTIONS BUTTON

                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap:
                                        _showSectionsBottomSheet,
                                    borderRadius:
                                        BorderRadius.circular(
                                      13,
                                    ),
                                    child: Container(
                                      height: 40,
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 11,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: Colors.white
                                            .withOpacity(.14),
                                        borderRadius:
                                            BorderRadius
                                                .circular(13),
                                        border: Border.all(
                                          color: Colors.white
                                              .withOpacity(.14),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons
                                                .grid_view_rounded,
                                            color:
                                                Colors.white,
                                            size: 17,
                                          ),

                                          if (screenSize.width >=
                                              390) ...[
                                            const SizedBox(
                                              width: 6,
                                            ),

                                            const Text(
                                              'Sections',
                                              style:
                                                  TextStyle(
                                                color:
                                                    Colors.white,
                                                fontSize: 12.5,
                                                fontWeight:
                                                    FontWeight
                                                        .w700,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // =================================================
                          // CURRENT SECTION CARD
                          // =================================================

                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withOpacity(.96),
                              borderRadius:
                                  BorderRadius.circular(17),
                              border: Border.all(
                                color: Colors.white
                                    .withOpacity(.60),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF5F3FF,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(
                                          11,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons
                                            .home_work_outlined,
                                        color: primary,
                                        size: 19,
                                      ),
                                    ),

                                    const SizedBox(width: 11),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            _getCurrentSectionTitle(),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              color:
                                                  textPrimary,
                                              fontSize: 16.5,
                                              height: 1.15,
                                              fontWeight:
                                                  FontWeight
                                                      .w800,
                                              letterSpacing:
                                                  -.2,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 3,
                                          ),

                                          Text(
                                            'Question ${_currentPage + 1} of ${_pages.length}',
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              color:
                                                  textSecondary,
                                              fontSize: 11.5,
                                              height: 1.2,
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: const Color(
                                          0xFFF5F3FF,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(
                                          20,
                                        ),
                                        border: Border.all(
                                          color: primary
                                              .withOpacity(.10),
                                        ),
                                      ),
                                      child: Text(
                                        '${(progress * 100).round()}%',
                                        style:
                                            const TextStyle(
                                          color: primary,
                                          fontSize: 11.5,
                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // PROGRESS BAR

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(100),
                                  child:
                                      LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 6,
                                    backgroundColor:
                                        const Color(
                                      0xFFEDE9FE,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<
                                            Color>(
                                      primary,
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
                ),
              ),

              const SizedBox(height: 14),

              // ============================================================
              // PAGE CONTENT
              // ============================================================

              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 760,
                    ),
                    child: hasPages
                        ? PageView.builder(
                            controller:
                                _pageController,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: _pages.length,
                            onPageChanged: (int page) {
                              if (!mounted) {
                                return;
                              }

                              setState(() {
                                _currentPage = page;
                              });
                            },
                            itemBuilder:
                                (context, index) {
                              return KeyedSubtree(
                                key: ValueKey(
                                  'listing_page_$index',
                                ),
                                child: _pages[index],
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              'No listing questions available.',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              // ============================================================
              // PREMIUM COMPACT FOOTER
              // ============================================================

              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFEFF2F6),
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      10,
                      horizontalPadding,
                      12,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 680,
                        ),
                        child: Row(
                          children: [
                            // BACK BUTTON

                            AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 200,
                              ),
                              width:
                                  isFirstPage ? 52 : 104,
                              height: 52,
                              child: OutlinedButton(
                                onPressed:
                                    isFirstPage || _isSubmitting
                                        ? null
                                        : _previousPage,
                                style:
                                    OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  foregroundColor: primary,
                                  disabledForegroundColor:
                                      const Color(
                                    0xFFCBD5E1,
                                  ),
                                  backgroundColor:
                                      Colors.white,
                                  disabledBackgroundColor:
                                      const Color(
                                    0xFFF8FAFC,
                                  ),
                                  side: BorderSide(
                                    color: isFirstPage
                                        ? const Color(
                                            0xFFE2E8F0,
                                          )
                                        : primary.withOpacity(
                                            .28,
                                          ),
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),
                                  ),
                                ),
                                child: isFirstPage
                                    ? const Icon(
                                        Icons
                                            .arrow_back_rounded,
                                        size: 20,
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Icon(
                                            Icons
                                                .arrow_back_rounded,
                                            size: 18,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Back',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // CONTINUE / PUBLISH BUTTON

                            Expanded(
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient:
                                      const LinearGradient(
                                    begin:
                                        Alignment.centerLeft,
                                    end:
                                        Alignment.centerRight,
                                    colors: [
                                      primary,
                                      Color(0xFF9333EA),
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
                                          .withOpacity(.20),
                                      blurRadius: 16,
                                      offset:
                                          const Offset(0, 7),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      _isSubmitting || !hasPages
                                          ? null
                                          : _nextPage,
                                  style: ElevatedButton
                                      .styleFrom(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 16,
                                    ),
                                    backgroundColor:
                                        Colors.transparent,
                                    disabledBackgroundColor:
                                        Colors.transparent,
                                    shadowColor:
                                        Colors.transparent,
                                    foregroundColor:
                                        Colors.white,
                                    disabledForegroundColor:
                                        Colors.white70,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        16,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          isLastPage
                                              ? 'Publish Listing'
                                              : 'Continue',
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                          style:
                                              const TextStyle(
                                            fontSize: 15.5,
                                            fontWeight:
                                                FontWeight
                                                    .w800,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 7),

                                      Icon(
                                        isLastPage
                                            ? Icons
                                                .publish_rounded
                                            : Icons
                                                .arrow_forward_rounded,
                                        size: 19,
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
                ),
              ),
            ],
          ),
        ),

        // ================================================================
        // PREMIUM LOADING OVERLAY
        // ================================================================

        if (_isSubmitting)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.42),
              child: Center(
                child: Container(
                  width: screenSize.width < 400
                      ? screenSize.width - 64
                      : 330,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(.14),
                        blurRadius: 32,
                        offset:
                            const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: primary,
                        ),
                      ),

                      SizedBox(height: 16),

                      Text(
                        'Publishing Listing...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Please keep the app open while your listing is saved.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
}
class _PremiumSnackBarIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;

  const _PremiumSnackBarIcon({
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 21,
      ),
    );
  }
}