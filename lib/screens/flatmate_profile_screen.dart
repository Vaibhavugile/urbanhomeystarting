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
  String address;
  String landmark;
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
    this.address = '',
    this.landmark = '',
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

address: data['address'] ?? '',

landmark: data['landmark'] ?? '',

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
      'address': address,
      'landmark': landmark,
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
        '  address: $address,\n'
        '  landmark: $landmark,\n'
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

  const SingleChoiceQuestionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.onSelected,
    this.isCard = false,
    this.initialValue,
  });

  @override
  State<SingleChoiceQuestionWidget> createState() =>
      _SingleChoiceQuestionWidgetState();
}

class _SingleChoiceQuestionWidgetState
    extends State<SingleChoiceQuestionWidget> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialValue;
  }

  @override
  void didUpdateWidget(
      covariant SingleChoiceQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialValue !=
            oldWidget.initialValue &&
        widget.initialValue != _selectedOption) {
      _selectedOption = widget.initialValue;
    }
  }

  Widget _buildPremiumOptions() {
    return SingleChildScrollView(
      child: Column(
        children: widget.options.map((option) {
          final isSelected =
              _selectedOption == option;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedOption = option;
              });

              widget.onSelected(option);
            },
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 250,
              ),
              margin:
                  const EdgeInsets.only(bottom: 14),
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(24),

                gradient: isSelected
                    ? const LinearGradient(
                        begin:
                            Alignment.topLeft,
                        end: Alignment
                            .bottomRight,
                        colors: [
                          Color(0xFF7C3AED),
                          Color(0xFF9333EA),
                          Color(0xFFEC4899),
                        ],
                      )
                    : null,

                color: isSelected
                    ? null
                    : Colors.white,

                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(
                          0xFFE5E7EB),
                  width: 1.5,
                ),

                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(
                                0xFF7C3AED)
                            .withOpacity(.25)
                        : Colors.black
                            .withOpacity(.05),
                    blurRadius: 20,
                    offset:
                        const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 250,
                    ),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : Colors
                              .transparent,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : const Color(
                                0xFFD1D5DB),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Color(
                                0xFF7C3AED),
                          )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(
                                0xFF111827),
                        fontWeight:
                            FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(.04),
                  blurRadius: 20,
                  offset:
                      const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style:
                      const TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  widget.subtitle,
                  style:
                      const TextStyle(
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

          Expanded(
            child: _buildPremiumOptions(),
          ),
        ],
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

  const MultiChoiceQuestionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.onSelected,
    this.initialValues = const [],
  });

  @override
  State<MultiChoiceQuestionWidget>
      createState() =>
          _MultiChoiceQuestionWidgetState();
}

class _MultiChoiceQuestionWidgetState
    extends State<
        MultiChoiceQuestionWidget> {
  late List<String>
      _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List.from(
      widget.initialValues,
    );
  }

  @override
  void didUpdateWidget(
      covariant MultiChoiceQuestionWidget
          oldWidget) {
    super.didUpdateWidget(
        oldWidget);

    if (widget.initialValues !=
        oldWidget.initialValues) {
      _selectedOptions =
          List.from(
              widget.initialValues);
    }
  }

  @override
  Widget build(
      BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.all(
                    22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                      28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(.04),
                  blurRadius: 20,
                  offset:
                      const Offset(
                          0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  widget.title,
                  style:
                      const TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.w800,
                    color: Color(
                        0xFF111827),
                  ),
                ),

                const SizedBox(
                    height: 10),

                Text(
                  widget.subtitle,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    color: Color(
                        0xFF6B7280),
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                    height: 12),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF3F4F6,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                                12),
                  ),
                  child: Text(
                    "${_selectedOptions.length} selected",
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .w600,
                      color: Color(
                          0xFF7C3AED),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child:
                SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.options
                    .map((option) {
                  final isSelected =
                      _selectedOptions
                          .contains(
                              option);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedOptions
                              .remove(
                                  option);
                        } else {
                          _selectedOptions
                              .add(
                                  option);
                        }

                        widget
                            .onSelected(
                          _selectedOptions,
                        );
                      });
                    },
                    child:
                        AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds:
                            250,
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            16,
                        vertical: 14,
                      ),
                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),

                        gradient:
                            isSelected
                                ? const LinearGradient(
                                    begin:
                                        Alignment.topLeft,
                                    end:
                                        Alignment.bottomRight,
                                    colors: [
                                      Color(
                                          0xFF7C3AED),
                                      Color(
                                          0xFF9333EA),
                                      Color(
                                          0xFFEC4899),
                                    ],
                                  )
                                : null,

                        color:
                            isSelected
                                ? null
                                : Colors
                                    .white,

                        border:
                            Border.all(
                          color: isSelected
                              ? Colors
                                  .transparent
                              : const Color(
                                  0xFFE5E7EB),
                          width: 1.5,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(
                                        0xFF7C3AED)
                                    .withOpacity(
                                        .25)
                                : Colors
                                    .black
                                    .withOpacity(
                                        .04),
                            blurRadius:
                                18,
                            offset:
                                const Offset(
                                    0,
                                    8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds:
                                  250,
                            ),
                            width: 22,
                            height: 22,
                            decoration:
                                BoxDecoration(
                              shape: BoxShape
                                  .circle,
                              color:
                                  isSelected
                                      ? Colors
                                          .white
                                      : Colors
                                          .transparent,
                              border:
                                  Border
                                      .all(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(
                                        0xFFD1D5DB),
                                width:
                                    2,
                              ),
                            ),
                            child:
                                isSelected
                                    ? const Icon(
                                        Icons
                                            .check,
                                        size:
                                            14,
                                        color:
                                            Color(0xFF7C3AED),
                                      )
                                    : null,
                          ),

                          const SizedBox(
                              width:
                                  10),

                          Text(
                            option,
                            style:
                                TextStyle(
                              color:
                                  isSelected
                                      ? Colors
                                          .white
                                      : const Color(
                                          0xFF111827),
                              fontWeight:
                                  FontWeight
                                      .w600,
                              fontSize:
                                  14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
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
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;
  late TextEditingController _flatDescriptionController;

  // Define your sections - UPDATED
  final List<Map<String, dynamic>> _sections = [
    {'title': 'About You', 'startPage': 0, 'endPage': 7},             // 9 fields (Pages 0-8)
    {'title': 'Your Habits', 'startPage': 8, 'endPage': 14},          // 7 fields (Pages 9-15)
    {'title': 'Flat Details', 'startPage': 15, 'endPage': 26},        // 12 fields (Pages 16-27)
    {'title': 'Flatmate Preferences', 'startPage': 27, 'endPage': 32},// 6 fields (Pages 28-33)
    {'title': 'Upload Images', 'startPage': 33, 'endPage': 34},       // 1 field (Page 34)
  ];

  String _getCurrentSectionTitle() {
    for (var section in _sections) {
      if (_currentPage >= section['startPage'] && _currentPage <= section['endPage']) {
        return section['title'];
      }
    }
    return '';
  }

  double _getCurrentSectionProgress() {
    for (var section in _sections) {
      if (_currentPage >= section['startPage'] && _currentPage <= section['endPage']) {
        final int pagesInSection = (section['endPage'] as int) - (section['startPage'] as int) + 1; // Explicit cast to int
        final int currentPageInSection = _currentPage - (section['startPage'] as int); // Explicit cast to int
        return (currentPageInSection + 1) / pagesInSection;
      }
    }
    return 0.0;
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
      case 31: // Address
        return _addressController.text.isNotEmpty;
      case 32: // Landmark (optional, so always valid if we don't enforce it)
        return true;
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
    _addressController = TextEditingController(text: _flatListingProfile.address);
    _landmarkController = TextEditingController(text: _flatListingProfile.landmark);
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
    _addressController.addListener(() {
      _flatListingProfile.address = _addressController.text;
      setState(() {});
    });
    _landmarkController.addListener(() {
      _flatListingProfile.landmark = _landmarkController.text;
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
    _addressController.dispose();
    _landmarkController.dispose();
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
          "Add Flat Photos",
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
  TextInputType keyboardType =
      TextInputType.text,
  List<TextInputFormatter>?
      inputFormatters,
  int? maxLines = 1,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return Padding(
    padding:
        const EdgeInsets.symmetric(
      horizontal: 24,
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // HEADER CARD

        Container(
          padding:
              const EdgeInsets.all(
                  22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
                    28),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(.04),
                blurRadius: 20,
                offset:
                    const Offset(
                        0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.w800,
                  color: Color(
                      0xFF111827),
                ),
              ),

              const SizedBox(
                  height: 10),

              Text(
                subtitle,
                style:
                    const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(
                      0xFF6B7280),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // TEXT FIELD CARD

        Container(
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
                    24),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(.05),
                blurRadius: 18,
                offset:
                    const Offset(
                        0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType:
                keyboardType,
            inputFormatters:
                inputFormatters,
            maxLines: maxLines,
            cursorColor:
                const Color(
              0xFF7C3AED,
            ),
            style:
                const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w500,
              color:
                  Color(0xFF111827),
            ),
            decoration:
                InputDecoration(
              hintText: hintText,

              hintStyle:
                  const TextStyle(
                color:
                    Color(0xFF9CA3AF),
                fontWeight:
                    FontWeight.w500,
              ),

              prefixIcon:
                  prefixIcon ??
                      const Icon(
                    Icons
                        .edit_rounded,
                    color: Color(
                        0xFF7C3AED),
                  ),

              suffixIcon:
                  suffixIcon,

              filled: true,
              fillColor:
                  Colors.white,

              contentPadding:
                  EdgeInsets.symmetric(
                horizontal: 20,
                vertical:
                    maxLines == 1
                        ? 18
                        : 22,
              ),

              border:
                  OutlineInputBorder(
                borderRadius:
    BorderRadius.circular(24),
                borderSide:
                    BorderSide.none,
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                            24),
                borderSide:
                    const BorderSide(
                  color: Color(
                      0xFFE5E7EB),
                  width: 1.2,
                ),
              ),

              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                            24),
                borderSide:
                    const BorderSide(
                  color: Color(
                      0xFF7C3AED),
                  width: 2,
                ),
              ),
            ),
          ),
        ),

        if (maxLines != null &&
            maxLines > 1)
          const Padding(
            padding:
                EdgeInsets.only(
              top: 12,
            ),
            child: Text(
              "Write a clear and detailed description to get better matches.",
              style: TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF6B7280),
              ),
            ),
          ),
      ],
    ),
  );
}

  Widget _buildDateQuestion({
  required String title,
  required String subtitle,
  required Function(DateTime?) onDateSelected,
  DateTime? initialDate,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      DateTime? selectedDate = initialDate;

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
              padding:
                  const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                        28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(.04),
                    blurRadius: 20,
                    offset:
                        const Offset(
                            0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.w800,
                      color: Color(
                          0xFF111827),
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(
                          0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () async {
                final picked =
                    await showDatePicker(
                  context: context,
                  initialDate:
                      selectedDate ??
                          DateTime.now(),
                  firstDate:
                      DateTime(2020),
                  lastDate:
                      DateTime(2100),
                  builder:
                      (context, child) {
                    return Theme(
                      data: Theme.of(
                              context)
                          .copyWith(
                        colorScheme:
                            const ColorScheme
                                .light(
                          primary:
                              Color(
                                  0xFF7C3AED),
                          secondary:
                              Color(
                                  0xFFEC4899),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  setState(() {
                    selectedDate =
                        picked;
                  });

                  onDateSelected(
                    picked,
                  );
                }
              },

              child: AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 250,
                ),
                padding:
                    const EdgeInsets.all(
                        20),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(
                              24),
                  border: Border.all(
                    color:
                        selectedDate !=
                                null
                            ? const Color(
                                0xFF7C3AED)
                            : const Color(
                                0xFFE5E7EB),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors
                          .black
                          .withOpacity(
                              .05),
                      blurRadius: 18,
                      offset:
                          const Offset(
                              0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(
                                0xFF7C3AED),
                            Color(
                                0xFFEC4899),
                          ],
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                                    16),
                      ),
                      child: const Icon(
                        Icons
                            .calendar_month_rounded,
                        color:
                            Colors.white,
                      ),
                    ),

                    const SizedBox(
                        width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            "Selected Date",
                            style:
                                TextStyle(
                              fontSize:
                                  13,
                              color: Color(
                                  0xFF6B7280),
                            ),
                          ),

                          const SizedBox(
                              height:
                                  4),

                          Text(
                            selectedDate ==
                                    null
                                ? "Tap to choose a date"
                                : DateFormat(
                                    'dd MMM yyyy')
                                .format(
                                    selectedDate!),
                            style:
                                TextStyle(
                              fontSize:
                                  17,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color: selectedDate ==
                                      null
                                  ? const Color(
                                      0xFF9CA3AF)
                                  : const Color(
                                      0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons
                          .arrow_forward_ios_rounded,
                      size: 18,
                      color: Color(
                          0xFF7C3AED),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding:
                  const EdgeInsets.all(
                      14),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF5F3FF,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                            16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons
                        .lightbulb_outline_rounded,
                    color: Color(
                        0xFF7C3AED),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Choose an accurate move-in or availability date to get better matches.",
                      style:
                          TextStyle(
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

  List<Widget> _buildPages() {
    return [
     


      // --- Section 3: Flat Details (Pages 21-33) ---
      // Page 21: Flat Type
      SingleChoiceQuestionWidget(
        title: "What type of flat are you listing?",
        subtitle: "Studio, 1BHK, 2BHK, etc.",
        options: ['Studio Apartment', '1BHK', '2BHK', '3BHK', '4BHK+', 'Other'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.flatType = value;
          });
        },
        initialValue: _flatListingProfile.flatType,
      ),
      SingleChoiceQuestionWidget(
        title: "What type of flat are you listing?",
        subtitle: "single, double, triple, etc.",
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
        title: "Is the flat furnished, semi-furnished, or unfurnished?",
        subtitle: "Specify what's included in the flat.",
        options: ['Furnished', 'Semi-furnished', 'Unfurnished'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.furnishedStatus = value;
          });
        },
        initialValue: _flatListingProfile.furnishedStatus,
      ),
      SingleChoiceQuestionWidget(
  title: "How many people are currently staying in the flat?",
  subtitle: "Exclude the new tenant you're looking for.",
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
  title: "What is the minimum lease duration?",
  subtitle: "Select how long a tenant is expected to stay.",
  options: [
    '1 Month',
    '2 Months',
    '3 Months',
    '6 Months',
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
_buildFlatImagesQuestion(),


      // Page 23: Available For
      SingleChoiceQuestionWidget(
        title: "Who is the flat available for?",
        subtitle: "Select the preferred gender/group.",
        options: ['Boys', 'Girls', 'Couples', 'Anyone'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.availableFor = value;
          });
        },
        initialValue: _flatListingProfile.availableFor,
      ),

      // Page 24: Availability Date
      _buildDateQuestion(
        title: "When is the flat available from?",
        subtitle: "Approximate date works best.",
        onDateSelected: (date) {
          setState(() {
            _flatListingProfile.availabilityDate = date;
          });
        },
        initialDate: _flatListingProfile.availabilityDate,
      ),

      // Page 25: Rent Price
      _buildTextQuestion(
        title: "What is the monthly rent for the flat/room?",
        subtitle: "Enter the rent amount in ₹.",
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
        title: "What is the security deposit amount?",
        subtitle: "Enter the deposit amount in ₹.",
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
        title: "What kind of bathroom is available?",
        subtitle: "Attached to the room or shared?",
        options: ['Attached Bathroom', 'Shared Bathroom'],
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
        title: "What amenities are available in the flat?",
        subtitle: "Select all that apply.",
        options: [
          'Wi-Fi',
          'AC',
          'Geyser',
          'Washing Machine',
          'Refrigerator',
          'Microwave',
          'Maid Service',
          'Cook',
          'Gym',
          'Swimming Pool',
          'Power Backup',
          'Security'
        ],
        onSelected: (selected) {
          setState(() {
            _flatListingProfile.amenities = selected;
          });
        },
        initialValues: _flatListingProfile.amenities,
      ),

      // Page 31: Address
      _buildTextQuestion(
        title: "What is the full address of the flat?",
        subtitle: "Include Building/Society Name, Street, Locality.",
        hintText: "Enter full address",
        controller: _addressController,
        maxLines: 3,
      ),

      // Page 32: Landmark
      _buildTextQuestion(
        title: "Add a nearby landmark (optional).",
        subtitle: "Helps in easy navigation.",
        hintText: "e.g., Near D-Mart, Beside XYZ Cafe",
        controller: _landmarkController,
      ),

      // Page 33: Flat Description
      _buildTextQuestion(
        title: "Describe your flat.",
        subtitle: "Highlight key features, vibe, and what makes it a great place.",
        hintText: "e.g., Spacious 2BHK with great sunlight, friendly neighborhood...",
        controller: _flatDescriptionController,
        maxLines: 5,
      ),

      // --- Section 4: Flatmate Preferences (Pages 34-39) ---
      // Page 34: Preferred Flatmate Gender
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate gender?",
        subtitle: "This helps in finding a compatible match.",
        options: ['Male', 'Female', 'No preference', 'Other'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.preferredGender = value;
          });
        },
        initialValue: _flatListingProfile.preferredGender,
      ),

      // Page 35: Preferred Flatmate Age Group
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate age group?",
        subtitle: "This helps in finding a compatible match.",
        options: ['18-24', '25-30', '30-40', '40+', 'No preference'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.preferredAgeGroup = value;
          });
        },
        initialValue: _flatListingProfile.preferredAgeGroup,
      ),

      // Page 36: Preferred Flatmate Occupation
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate occupation type?",
        subtitle: "Student, working professional, or no preference?",
        options: ['Student', 'Working Professional', 'Both', 'No preference'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.preferredOccupation = value;
          });
        },
        initialValue: _flatListingProfile.preferredOccupation,
      ),

      // Page 37: Preferred Flatmate Habits (Multi-choice)
      MultiChoiceQuestionWidget(
        title: "What habits do you prefer in a flatmate?",
        subtitle: "Select all that apply.",
        options: [
          'Non-smoker',
          'Non-drinker',
          'Vegetarian',
          'Tidy',
          'Quiet',
          'Social',
          'Respectful',
          'Financially responsible',
          'Pet-friendly'
        ],
        onSelected: (selected) {
          setState(() {
            _flatListingProfile.preferredHabits = selected;
          });
        },
        initialValues: _flatListingProfile.preferredHabits,
      ),

      // Page 38: Ideal Qualities in a Flatmate (Multi-choice)
      MultiChoiceQuestionWidget(
        title: "What qualities do you desire in a flatmate?",
        subtitle: "Select qualities you look for.",
        options: [
          'Respectful',
          'Tidy',
          'Communicative',
          'Friendly',
          'Responsible',
          'Quiet',
          'Social',
          'Independent',
          'Shares chores',
          'Financially stable'
        ],
        onSelected: (selected) {
          setState(() {
            _flatListingProfile.flatmateIdealQualities = selected;
          });
        },
        initialValues: _flatListingProfile.flatmateIdealQualities,
      ),

      // Page 39: Deal Breakers (Multi-choice)
      MultiChoiceQuestionWidget(
        title: "Any deal breakers for a flatmate?",
        subtitle: "Things you absolutely cannot tolerate.",
        options: [
          'Excessive Noise',
          'Untidiness',
          'Frequent Parties',
          'Smoking Indoors',
          'Unpaid Bills',
          'Lack of Communication',
          'Pets (if not allowed)',
          'Late Night Guests',
          'Drugs',
          'Disrespectful behavior'
        ],
        onSelected: (selected) {
          setState(() {
            _flatListingProfile.flatmateDealBreakers = selected;
          });
        },
        initialValues: _flatListingProfile.flatmateDealBreakers,
      ),
    ];
  }

  void _nextPage() {
    // Removed the _isCurrentPageValid() check and SnackBar for
    // allowing progression without strict validation at each step,
    // as per the user's request "do not make anything compulsory".
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Jump to Section',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Colors.grey),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  final bool isCurrentSection = _currentPage >= section['startPage'] && _currentPage <= section['endPage'];
                  return ListTile(
                    title: Text(
                      section['title'],
                      style: TextStyle(
                        fontWeight: isCurrentSection ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentSection ? Colors.redAccent : Colors.black,
                      ),
                    ),
                    trailing: isCurrentSection
                        ? const Icon(Icons.arrow_forward_ios, color: Colors.redAccent, size: 18)
                        : null,
                    onTap: () {
                      Navigator.pop(context); // Close the bottom sheet
                      _pageController.jumpToPage(section['startPage'] as int); // Jump to the start of the selected section
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }


  // --- Firebase Integration Method ---
  // In your _FlatmateProfileScreenState class
  Future<void> _submitProfileToFirebase() async {
    setState(() {
      _isSubmitting = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit your profile.')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    try {
      // 1. Fetch the main user document to get the top-level user profile data
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw 'Main user profile not found. Please create your main profile first.';
      }

      final Map<String, dynamic> mainUserData = userDoc.data() as Map<String, dynamic>;

      // 2. Manually create the userProfile object from the fetched top-level data
      // This correctly mirrors the structure you have in your database
      final userProfile = UserProfile(
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
        imageUrls: (mainUserData['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        // Handle habits which is a nested map
        smokingHabit: mainUserData['habits']?['smoking'] ?? '',
        drinkingHabit: mainUserData['habits']?['drinking'] ?? '',
        foodPreference: mainUserData['habits']?['food'] ?? '',
        cleanlinessLevel: mainUserData['habits']?['cleanliness'] ?? '',
        socialPreferences: mainUserData['habits']?['socialPreferences'] ?? '',
        petOwnership: mainUserData['habits']?['petOwnership'] ?? '',
        petTolerance: mainUserData['habits']?['petTolerance'] ?? '',
        guestsFrequency: mainUserData['habits']?['guestsFrequency'] ?? '',
      );
setState(() {
  _isUploadingImages = true;
});

List<String> uploadedImageUrls = [];

if (_selectedFlatImages.isNotEmpty) {
  uploadedImageUrls =
      await _uploadFlatImages();
}

setState(() {
  _isUploadingImages = false;
});
      // 3. Create the FlatListingProfile object, combining the fetched userProfile
      // with the flat listing-specific data from the controllers
      final FlatListingProfile flatListingProfile = FlatListingProfile(
        uid: user.uid,
        userProfile: userProfile,
        rentPrice: int.tryParse(_rentPriceController.text),
        depositAmount: int.tryParse(_depositAmountController.text),
        address: _addressController.text,
        landmark: _landmarkController.text,
        flatDescription: _flatDescriptionController.text,
        flatType: _flatListingProfile.flatType,
        roomType: _flatListingProfile.roomType,
        imageUrls: uploadedImageUrls,
        currentOccupants:
    _flatListingProfile.currentOccupants,

leaseDuration:
    _flatListingProfile.leaseDuration,
        bathroomType: _flatListingProfile.bathroomType,
        furnishedStatus: _flatListingProfile.furnishedStatus,
        availableFor: _flatListingProfile.availableFor,
        preferredGender: _flatListingProfile.preferredGender,
        preferredAgeGroup: _flatListingProfile.preferredAgeGroup,
        preferredOccupation: _flatListingProfile.preferredOccupation,
        amenities: _flatListingProfile.amenities,
        flatmateIdealQualities: _flatListingProfile.flatmateIdealQualities,
        flatmateDealBreakers: _flatListingProfile.flatmateDealBreakers,
      );

      // 4. Convert the complete FlatListingProfile object to a map using your toMap() method
      final Map<String, dynamic> profileData = flatListingProfile.toMap();

      final CollectionReference flatListingsCollection =
      FirebaseFirestore.instance.collection('users').doc(user.uid).collection('flatListings');

      // 5. Save the data to the subcollection
      if (flatListingProfile.documentId.isEmpty) {
        // New document
        profileData['createdAt'] = FieldValue.serverTimestamp();
        profileData['lastUpdated'] = FieldValue.serverTimestamp();
        DocumentReference newDocRef = await flatListingsCollection.add(profileData);
        flatListingProfile.documentId = newDocRef.id;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New Flat Listing Profile Created Successfully!')),
        );
      } else {
        // Existing document
        profileData['lastUpdated'] = FieldValue.serverTimestamp();
        profileData.remove('createdAt');
        await flatListingsCollection.doc(flatListingProfile.documentId).update(profileData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flat Listing Profile Updated Successfully!')),
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }

    } catch (e) {
      print('Error submitting flat listing profile to Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit profile: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }


  void _submitProfile() {
    print('Submitting Flat Listing Profile:');
    print(_flatListingProfile.toString());
    _submitProfileToFirebase();
  }

  @override
Widget build(BuildContext context) {
  final progress =
      (_currentPage + 1) / _pages.length;

  final currentSectionIndex = _sections.indexOf(
        _sections.firstWhere(
          (s) =>
              _currentPage >= s['startPage'] &&
              _currentPage <= s['endPage'],
        ),
      ) +
      1;

  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),

    body: Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              // ===========================
              // PREMIUM HEADER
              // ===========================

              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(32),
                  gradient:
                      const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7C3AED),
                      Color(0xFF9333EA),
                      Color(0xFFEC4899),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF7C3AED,
                      ).withOpacity(.25),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (_currentPage > 0)
                          GestureDetector(
                            onTap: _previousPage,
                            child: Container(
                              padding:
                                  const EdgeInsets.all(
                                      10),
                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .white24,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            14),
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .arrow_back_ios_new,
                                color:
                                    Colors.white,
                                size: 18,
                              ),
                            ),
                          ),

                        if (_currentPage > 0)
                          const SizedBox(
                              width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Text(
                                "Create Listing",
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

                              const SizedBox(
                                  height: 4),

                              Text(
                                "Section $currentSectionIndex of ${_sections.length}",
                                style:
                                    const TextStyle(
                                  color: Colors
                                      .white70,
                                  fontSize:
                                      13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap:
                              _showSectionsBottomSheet,
                          child: Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .white24,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          30),
                            ),
                            child:
                                const Row(
                              children: [
                                Icon(
                                  Icons
                                      .grid_view_rounded,
                                  color: Colors
                                      .white,
                                  size: 16,
                                ),
                                SizedBox(
                                    width: 6),
                                Text(
                                  "Sections",
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        _getCurrentSectionTitle(),
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        "${(progress * 100).toInt()}% Complete",
                        style:
                            const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                              100),
                      child:
                          LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor:
                            Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===========================
              // PAGE CONTENT
              // ===========================

              Expanded(
                child: PageView.builder(
                  controller:
                      _pageController,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      _pages.length,
                  onPageChanged:
                      (int page) {
                    setState(() {
                      _currentPage =
                          page;
                    });
                  },
                  itemBuilder:
                      (context, index) {
                    return _pages[index];
                  },
                ),
              ),

              // ===========================
              // PREMIUM FOOTER BUTTONS
              // ===========================

              Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  24,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 58,
                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      18),
                          border: Border.all(
                            color: Colors
                                .grey
                                .shade300,
                          ),
                        ),
                        child:
                            TextButton(
                          onPressed:
                              _currentPage >
                                      0
                                  ? _previousPage
                                  : null,
                          child:
                              const Text(
                            "Back",
                            style:
                                TextStyle(
                              color: Color(
                                  0xFF111827),
                              fontWeight:
                                  FontWeight
                                      .w700,
                              fontSize:
                                  16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                        width: 14),

                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 58,
                        decoration:
                            BoxDecoration(
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
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF7C3AED,
                              ).withOpacity(
                                  .25),
                              blurRadius:
                                  20,
                              offset:
                                  const Offset(
                                      0,
                                      10),
                            ),
                          ],
                        ),
                        child:
                            ElevatedButton(
                          onPressed:
                              _nextPage,
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
                            _currentPage ==
                                    _pages
                                            .length -
                                        1
                                ? "Publish Listing"
                                : "Continue",
                            style:
                                const TextStyle(
                              color: Colors
                                  .white,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              fontSize:
                                  16,
                            ),
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

        // ===========================
        // LOADING OVERLAY
        // ===========================

        if (_isSubmitting)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.all(
                        24),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(24),
                ),
                child: const Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(
                          0xFF7C3AED),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Publishing Listing...",
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
}