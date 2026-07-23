// lib/screens/flat_with_flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firebase Import
import 'package:firebase_auth/firebase_auth.dart';// Added Firebase Auth Import for UID and Email
import 'package:mytennat/screens/home_page.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:mytennat/data/location_data.dart'; // Adjust path as needed
import 'package:mytennat/data/user_profile.dart'; // Or the correct path to your UserProfile class
import 'package:mytennat/widgets/location_selector_widget.dart';
import '../constants/google_keys.dart';
import 'package:mytennat/widgets/premium_snackbar.dart';

// Data model to hold all the answers for the user seeking a flat
class SeekingFlatmateProfile {
  // Basic Info
  String documentId; // Added for Firestore document ID
  String? uid; // Added: To store the user ID (UID)
  UserProfile userProfile; // The new required field

  // Fields that are specific to the flatmate search
  DateTime? moveInDate;
  int? budgetMin;
  int? budgetMax;
DateTime? createdAt;
  // Flat Requirements
  String preferredFlatType;
  String preferredRoomType;
  String preferredFurnishedStatus;
  List<String> amenitiesDesired;

  // Flatmate Preferences
  String preferredFlatmateGender;
  String preferredFlatmateAge;
  String preferredOccupation;
  List<String> preferredHabits;
  List<String> idealQualities;
  List<String> dealBreakers;

  // Added: List of image URLs for the profile
  List<String>? imageUrls;
String city;
String locationName;
String placeId;

double? latitude;
double? longitude;
  SeekingFlatmateProfile({
    this.documentId = '',
    this.uid,
    required this.userProfile,
    this.moveInDate,
    this.budgetMin,
    this.budgetMax,
    this.preferredFlatType = '',
    this.preferredRoomType = '',
    this.preferredFurnishedStatus = '',
    List<String>? amenitiesDesired,
    this.preferredFlatmateGender = '',
    this.preferredFlatmateAge = '',
    this.preferredOccupation = '',
     this.createdAt,
    this.city = '',
this.locationName = '',
this.placeId = '',
this.latitude,
this.longitude,
    List<String>? preferredHabits,
    List<String>? idealQualities,
    List<String>? dealBreakers,
    List<String>? imageUrls,
  })  : amenitiesDesired = amenitiesDesired ?? const [],
        preferredHabits = preferredHabits ?? const [],
        idealQualities = idealQualities ?? const [],
        dealBreakers = dealBreakers ?? const [],
        imageUrls = imageUrls;

  // Factory constructor to create a SeekingFlatmateProfile from a map (Firestore data)
  // Factory constructor to create a SeekingFlatmateProfile from a map (Firestore data)
// Factory constructor to create a SeekingFlatmateProfile from a map (Firestore data)
  factory SeekingFlatmateProfile.fromMap(Map<String, dynamic> data, String documentId) {
    // Add this print statement to see the raw data being processed
    print('Document ID: $documentId, Raw Data: $data');

    Map<String, dynamic> flatRequirementsData = data['flatRequirements'] ?? {};
    Map<String, dynamic> flatmatePreferencesData = data['flatmatePreferences'] ?? {};
    final Map<String, dynamic>? userProfileData = data['userProfile'] as Map<String, dynamic>?;

    // Add this print statement to see the userProfileData specifically
    print('UserProfile Data: $userProfileData');

    final UserProfile profile = userProfileData != null
        ? UserProfile.fromMap(userProfileData, data['uid'] as String? ?? '')
        : UserProfile(uid: data['uid'] as String? ?? '');

    return SeekingFlatmateProfile(
      documentId: documentId,
      uid: data['uid'] as String?,
      userProfile: profile,
      moveInDate: (data['moveInDate'] as Timestamp?)?.toDate(),
      budgetMin: data['budgetMin'] is int
          ? data['budgetMin']
          : (data['budgetMin'] is String ? int.tryParse(data['budgetMin']) : null),
      budgetMax: data['budgetMax'] is int
          ? data['budgetMax']
          : (data['budgetMax'] is String ? int.tryParse(data['budgetMax']) : null),
      preferredFlatType: flatRequirementsData['preferredFlatType'] as String? ?? '',
      preferredRoomType: flatRequirementsData['preferredRoomType'] as String? ?? '',
      preferredFurnishedStatus: flatRequirementsData['preferredFurnishedStatus'] as String? ?? '',
      amenitiesDesired: List<String>.from(flatRequirementsData['amenitiesDesired'] as List? ?? []),
      preferredFlatmateGender: flatmatePreferencesData['preferredFlatmateGender'] as String? ?? '',
      preferredFlatmateAge: flatmatePreferencesData['preferredFlatmateAge'] as String? ?? '',
      preferredOccupation: flatmatePreferencesData['preferredOccupation'] as String? ?? '',
      preferredHabits: List<String>.from(flatmatePreferencesData['preferredHabits'] as List? ?? []),
      idealQualities: List<String>.from(flatmatePreferencesData['idealQualities'] as List? ?? []),
      dealBreakers: List<String>.from(flatmatePreferencesData['dealBreakers'] as List? ?? []),
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      city: data['city'] ?? '',
createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
locationName:
    data['locationName'] ?? '',

placeId:
    data['placeId'] ?? '',

latitude:
    (data['latitude'] as num?)
        ?.toDouble(),

longitude:
    (data['longitude'] as num?)
        ?.toDouble(),
    );
  }

  // Method to convert the object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userType': 'seeking_flatmate',
      'userProfile': userProfile.toMap(),
      'moveInDate': moveInDate != null ? Timestamp.fromDate(moveInDate!) : null,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'city': city,
      'createdAt': createdAt != null
    ? Timestamp.fromDate(createdAt!)
    : FieldValue.serverTimestamp(),

'locationName': locationName,

'placeId': placeId,

'latitude': latitude,

'longitude': longitude,
      'flatRequirements': {
        'preferredFlatType': preferredFlatType,
        'preferredRoomType': preferredRoomType,
        'preferredFurnishedStatus': preferredFurnishedStatus,
        'amenitiesDesired': amenitiesDesired,
      },
      'flatmatePreferences': {
        'preferredFlatmateGender': preferredFlatmateGender,
        'preferredFlatmateAge': preferredFlatmateAge,
        'preferredOccupation': preferredOccupation,
        'preferredHabits': preferredHabits,
        'idealQualities': idealQualities,
        'dealBreakers': dealBreakers,
      },
      'imageUrls': imageUrls,
    };
  }
}


// Stateful Widget for Single Choice Questions
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
    if (_selectedOption == option) return;

    setState(() {
      _selectedOption = option;
    });

    HapticFeedback.selectionClick();

    widget.onSelected(option);
  }

  Widget _buildQuestionHeader() {
    final hasSubtitle = widget.subtitle.trim().isNotEmpty;

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
              Icons.tune_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

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
    final bool isSelected = _selectedOption == option;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectOption(option),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(
              minHeight: 62,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFF5F3FF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? _primary : _border,
                width: isSelected ? 1.6 : 1,
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 26,
                  height: 26,
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
                    color: isSelected ? null : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : const Color(0xFFCBD5E1),
                      width: 1.8,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('selected'),
                            color: Colors.white,
                            size: 16,
                          )
                        : const SizedBox(
                            key: ValueKey('unselected'),
                          ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 15.5,
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

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isSelected ? 1 : 0,
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 2,
        bottom: 12,
      ),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: widget.options.length,
      itemBuilder: (context, index) {
        return _buildOption(widget.options[index]);
      },
    );
  }
  Widget _buildCompactOptions() {
  return Column(
    children: widget.options.map((option) {
      return _buildOption(option);
    }).toList(),
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

                const SizedBox(height: 16),

if (widget.compactMode)
  _buildCompactOptions()
else
  Expanded(
    child: _buildOptions(),
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

    if (widget.initialValues != oldWidget.initialValues) {
      _selectedOptions = List<String>.from(
        widget.initialValues,
      );
    }
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });

    HapticFeedback.selectionClick();

    widget.onSelected(
      List<String>.from(_selectedOptions),
    );
  }

  Widget _buildQuestionHeader() {
    final bool hasSubtitle =
        widget.subtitle.trim().isNotEmpty;

    final int selectedCount = _selectedOptions.length;

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
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

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

                const SizedBox(height: 10),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: selectedCount > 0
                        ? const Color(0xFFF5F3FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selectedCount > 0
                          ? _primary.withOpacity(.18)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selectedCount > 0
                            ? Icons.check_circle_rounded
                            : Icons.touch_app_outlined,
                        size: 15,
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
                          fontSize: 12,
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
            minHeight: 50,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
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
                    width: 1.7,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
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

  Widget _buildOptions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(
            top: 2,
            bottom: 14,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.options.map((option) {
                return _buildOption(option);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
  Widget _buildCompactOptions() {
  return Align(
    alignment: Alignment.topLeft,
    child: Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.options.map((option) {
        return _buildOption(option);
      }).toList(),
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

                const SizedBox(height: 16),

if (widget.compactMode)
  _buildCompactOptions()
else
  Expanded(
    child: _buildOptions(),
  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FlatWithFlatmateProfileScreen extends StatefulWidget {
  final String? initialPhoneNumber;

  // NEW
  final SeekingFlatmateProfile? existingProfile;

  const FlatWithFlatmateProfileScreen({
    super.key,
    this.initialPhoneNumber,
    this.existingProfile,
  });

  @override
  State<FlatWithFlatmateProfileScreen> createState() =>
      _FlatWithFlatmateProfileScreenState();
}

class _FlatWithFlatmateProfileScreenState
    extends State<FlatWithFlatmateProfileScreen> {
  final PageController _pageController = PageController();

  late final SeekingFlatmateProfile _seekingFlatmateProfile;
  int _currentPage = 0;
  bool _isSubmitting = false; // Added for loading indicator

  // Change _pages from late final to a getter
  List<Widget> get _pages => _buildPages();

  // Declare TextEditingControllers for all text input fields
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _occupationController;
  late TextEditingController _currentLocationController;
  late TextEditingController _desiredCityController;
  late TextEditingController _budgetMinController;
  late TextEditingController _budgetMaxController;
  late TextEditingController _areaPreferenceController;
  late TextEditingController _bioController;

  // Define sections for progress tracking and navigation
final List<Map<String, dynamic>> _sections = [
  {
    'title': 'Location & Budget',
    'startPage': 0,
    'endPage': 3,
  },

  {
    'title': 'Flat Requirements',
    'startPage': 4,
    'endPage': 7,
  },

  {
    'title': 'Flatmate Preferences',
    'startPage': 8,
    'endPage': 8,
  },
];

  String _getCurrentSectionTitle() {
    for (var section in _sections) {
      if (_currentPage >= section['startPage'] &&
          _currentPage <= section['endPage']) {
        return section['title'];
      }
    }
    return 'Unknown Section'; // Default title if no section matches
  }
String _getCurrentStepText() {
  for (var section in _sections) {
    if (_currentPage >= section['startPage'] &&
        _currentPage <= section['endPage']) {

      final currentStep =
          _currentPage - section['startPage'] + 1;

      final totalSteps =
          section['endPage'] - section['startPage'] + 1;

      return 'Step $currentStep of $totalSteps';
    }
  }

  return '';
}
  double _getCurrentSectionProgress() {
    for (var section in _sections) {
      if (_currentPage >= section['startPage'] &&
          _currentPage <= section['endPage']) {
        final int pagesInSection =
            (section['endPage'] as int) - (section['startPage'] as int) + 1;
        final int currentPageInSection =
            _currentPage - (section['startPage'] as int);
        return (currentPageInSection + 1) / pagesInSection;
      }
    }
    // Return 0.0 or a sensible default if the current page is not in any defined section
    return 0.0;
  }
  @override
  void initState() {
    super.initState();
    final String? currentUserUid =
    FirebaseAuth.instance.currentUser?.uid;

_seekingFlatmateProfile =
    widget.existingProfile ??
    SeekingFlatmateProfile(
      userProfile: UserProfile(
        uid: currentUserUid!,
      ),
    );
    // Initialize controllers with current profile values
    // if (widget.initialPhoneNumber != null) {
    //   _seekingFlatmateProfile.phoneNumber = widget.initialPhoneNumber; // ADD THIS LINE
    // }
    // _nameController = TextEditingController(text: _seekingFlatmateProfile.name);
    // _ageController = TextEditingController(
    //     text: _seekingFlatmateProfile.age?.toString() ?? '');
    // _occupationController =
    //     TextEditingController(text: _seekingFlatmateProfile.occupation);
    // _currentLocationController =
    //     TextEditingController(text: _seekingFlatmateProfile.currentLocation);
    // _desiredCityController =
    //     TextEditingController(text: _seekingFlatmateProfile.desiredCity);
    _budgetMinController = TextEditingController(
        text: _seekingFlatmateProfile.budgetMin?.toString() ?? '');
    _budgetMaxController = TextEditingController(
        text: _seekingFlatmateProfile.budgetMax?.toString() ?? '');
    // _areaPreferenceController =
    //     TextEditingController(text: _seekingFlatmateProfile.areaPreference);
    // _bioController = TextEditingController(text: _seekingFlatmateProfile.bio);

    // Add listeners to update the profile model as text changes
    // _nameController.addListener(() {
    //   _seekingFlatmateProfile.name = _nameController.text;
    // });
    // _ageController.addListener(() {
    //   _seekingFlatmateProfile.age = int.tryParse(_ageController.text);
    // });
    // _occupationController.addListener(() {
    //   _seekingFlatmateProfile.occupation = _occupationController.text;
    // });
    // _currentLocationController.addListener(() {
    //   _seekingFlatmateProfile.currentLocation = _currentLocationController.text;
    // });
    // _desiredCityController.addListener(() {
    //   _seekingFlatmateProfile.desiredCity = _desiredCityController.text;
    // });
    _budgetMinController.addListener(() {
      _seekingFlatmateProfile.budgetMin =
          int.tryParse(_budgetMinController.text);
    });
    _budgetMaxController.addListener(() {
      _seekingFlatmateProfile.budgetMax =
          int.tryParse(_budgetMaxController.text);
    });
    // _areaPreferenceController.addListener(() {
    //   _seekingFlatmateProfile.areaPreference = _areaPreferenceController.text;
    // });
    // _bioController.addListener(() {
    //   _seekingFlatmateProfile.bio = _bioController.text;
    // });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _currentLocationController.dispose();
    _desiredCityController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _areaPreferenceController.dispose();
    _bioController.dispose();
    _pageController.dispose();
    super.dispose();
  }

Future<bool> _showExitDialog() async {
  const Color primary = Color(0xFF7C3AED);
  const Color secondary = Color(0xFFEC4899);

  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: "",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, __) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return ScaleTransition(
        scale: Tween<double>(
          begin: .85,
          end: 1,
        ).animate(curved),
        child: FadeTransition(
          opacity: animation,
          child: AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: 360,
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Premium Icon
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          primary,
                          secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(.25),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Exit Profile Setup?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "If you exit now, your current progress won't be saved.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [

                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 55),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text(
                            "Stay",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                primary,
                                secondary,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(.30),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text(
                              "Exit",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
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
          ),
        ),
      );
    },
  );

  return result ?? false;
}
  // --- Common Question Builders ---
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
  final bool isMultiline = maxLines == null || maxLines > 1;

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
              // ------------------------------
              // COMPACT QUESTION HEADER
              // ------------------------------

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

              // ------------------------------
              // PREMIUM TEXT FIELD
              // ------------------------------

              Container(
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

                  minLines: isMultiline ? 4 : 1,

                  textInputAction: isMultiline
                      ? TextInputAction.newline
                      : TextInputAction.done,

                  keyboardAppearance: Brightness.light,

                  cursorColor: primary,

                  cursorWidth: 1.8,

                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),

                  decoration: InputDecoration(
                    hintText: hintText,

                    hintMaxLines: isMultiline ? 3 : 1,

                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14.5,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),

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
                          ),

                    suffixIcon: suffixIcon,

                    filled: true,

                    fillColor: Colors.white,

                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isMultiline ? 16 : 14,
                      vertical: isMultiline ? 16 : 15,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: borderColor,
                        width: 1,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: primary,
                        width: 1.7,
                      ),
                    ),

                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.2,
                      ),
                    ),

                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.7,
                      ),
                    ),
                  ),

                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ),

              // ------------------------------
              // MULTILINE HELPER
              // ------------------------------

              if (isMultiline)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 4,
                    right: 4,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome_outlined,
                        size: 15,
                        color: primary,
                      ),

                      const SizedBox(width: 7),

                      const Expanded(
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

  final double screenWidth =
      MediaQuery.sizeOf(context).width;

  final double horizontalPadding =
      screenWidth >= 700 ? 32 : 18;

  return StatefulBuilder(
    builder: (context, setLocalState) {
      Future<void> pickDate() async {
        FocusManager.instance.primaryFocus?.unfocus();

        HapticFeedback.selectionClick();

        final DateTime now = DateTime.now();

        final DateTime pickerInitialDate =
            selectedDate ?? initialDate ?? now;

        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: pickerInitialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          helpText: 'SELECT DATE',
          cancelText: 'Cancel',
          confirmText: 'Done',
          builder: (context, child) {
            final ThemeData baseTheme = Theme.of(context);

            return Theme(
              data: baseTheme.copyWith(
                colorScheme: const ColorScheme.light(
                  primary: primary,
                  onPrimary: Colors.white,
                  secondary: secondary,
                  surface: Colors.white,
                  onSurface: textPrimary,
                ),
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 8,
                  headerBackgroundColor:
                      const Color(0xFFF5F3FF),
                  headerForegroundColor: textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  dayShape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  todayBorder: const BorderSide(
                    color: primary,
                    width: 1.2,
                  ),
                  todayForegroundColor:
                      const WidgetStatePropertyAll(primary),
                  cancelButtonStyle: TextButton.styleFrom(
                    foregroundColor: textSecondary,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  confirmButtonStyle: TextButton.styleFrom(
                    foregroundColor: primary,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked == null) return;

        setLocalState(() {
          selectedDate = picked;
        });

        HapticFeedback.lightImpact();

        onDateSelected(picked);
      }

      Widget buildHeader() {
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
                child: const Icon(
                  Icons.event_available_rounded,
                  size: 21,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
        );
      }

      Widget buildDateCard() {
        final bool hasSelectedDate = selectedDate != null;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: pickDate,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 74,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: hasSelectedDate
                    ? const Color(0xFFF5F3FF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasSelectedDate
                      ? primary
                      : borderColor,
                  width: hasSelectedDate ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hasSelectedDate
                        ? primary.withOpacity(.09)
                        : Colors.black.withOpacity(.025),
                    blurRadius: hasSelectedDate ? 14 : 9,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: hasSelectedDate
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primary,
                                secondary,
                              ],
                            )
                          : null,
                      color: hasSelectedDate
                          ? null
                          : const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      hasSelectedDate
                          ? Icons.event_available_rounded
                          : Icons.calendar_month_outlined,
                      color: hasSelectedDate
                          ? Colors.white
                          : primary,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasSelectedDate
                              ? 'Selected date'
                              : 'Choose a date',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: hasSelectedDate
                                ? primary
                                : textSecondary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          hasSelectedDate
                              ? DateFormat('dd MMM yyyy')
                                  .format(selectedDate!)
                              : 'Tap to open calendar',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: hasSelectedDate
                                ? textPrimary
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: hasSelectedDate
                          ? Colors.white
                          : const Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasSelectedDate
                            ? primary.withOpacity(.15)
                            : borderColor,
                      ),
                    ),
                    child: Icon(
                      hasSelectedDate
                          ? Icons.edit_calendar_rounded
                          : Icons.chevron_right_rounded,
                      size: 19,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      Widget buildHelper() {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: primary.withOpacity(.08),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
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
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }

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
                  buildHeader(),

                  const SizedBox(height: 16),

                  buildDateCard(),

                  const SizedBox(height: 12),

                  buildHelper(),
                ],
              ),
            ),
          ),
        ),
      );
    },
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // 1. PREFERRED FLATMATE GENDER
              // ============================================================

              SingleChoiceQuestionWidget(
                title:
                    "Preferred Flatmate Gender",
                subtitle:
                    "",
                options: const [
                  'Male',
                  'Female',
                  'No preference',
                  'Other',
                ],
                compactMode: true,
                onSelected: (value) {
                  setState(() {
                    _seekingFlatmateProfile
                        .preferredFlatmateGender = value;
                  });
                },
                initialValue:
                    _seekingFlatmateProfile
                        .preferredFlatmateGender,
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
                    _seekingFlatmateProfile
                        .preferredFlatmateAge = value;
                  });
                },
                initialValue:
                    _seekingFlatmateProfile
                        .preferredFlatmateAge,
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
                    _seekingFlatmateProfile
                        .preferredOccupation = value;
                  });
                },
                initialValue:
                    _seekingFlatmateProfile
                        .preferredOccupation,
              ),

              const SizedBox(height: 24),

              // ============================================================
              // 4. PREFERRED HABITS
              // ============================================================

              MultiChoiceQuestionWidget(
                title:
                    "Preferred Habits",
                subtitle:
                    "Select all that apply.",
                options: const [
                  'Non-smoker',
                  'Non-drinker',
                  'Vegetarian',
                  'Neat',
                  
                  'Social',
                  'Respectful',
                  
                  'Pet-friendly',
                ],
                compactMode: true,
                onSelected: (selected) {
                  setState(() {
                    _seekingFlatmateProfile.preferredHabits =
                        List<String>.from(selected);
                  });
                },
                initialValues:
                    _seekingFlatmateProfile.preferredHabits,
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
                    _seekingFlatmateProfile.idealQualities =
                        List<String>.from(selected);
                  });
                },
                initialValues:
                    _seekingFlatmateProfile.idealQualities,
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
              //       _seekingFlatmateProfile.dealBreakers =
              //           List<String>.from(selected);
              //     });
              //   },
              //   initialValues:
              //       _seekingFlatmateProfile.dealBreakers,
              // ),

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
      // --- Section 1: Your Basic Info (Pages 0-10) ---
      // Page 0: Name
      // _buildTextQuestion(
      //   title: "What's your name?",
      //   subtitle: "This will be visible to potential flatmates/owners.",
      //   hintText: "Enter your name",
      //   controller: _nameController,
      // ),

      // Page 1: Age
      // _buildTextQuestion(
      //   title: "How old are you?",
      //   subtitle: "This helps flatmates/owners understand your age group.",
      //   hintText: "e.g., 25",
      //   keyboardType: TextInputType.number,
      //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      //   controller: _ageController,
      // ),

      // Page 2: Gender
      // SingleChoiceQuestionWidget(
      //   title: "What's your gender?",
      //   subtitle: "This helps potential flatmates/owners relate to you.",
      //   options: ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.gender = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.gender,
      // ),
      // TextFormField(
      //   initialValue: _seekingFlatmateProfile.phoneNumber, // Set the initial value
      //   decoration: InputDecoration(
      //     labelText: 'Phone Number',
      //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      //     prefixIcon: const Icon(Icons.phone),
      //   ),
      //   keyboardType: TextInputType.phone,
      //   readOnly: true, // Consider making it read-only if it's auto-filled
      //   onChanged: (value) {
      //     _seekingFlatmateProfile.phoneNumber = value; // Update the profile on change (if not read-only)
      //   },
      //   // You can add validators if needed
      // ),

      // Page 3: Occupation
      // _buildTextQuestion(
      //   title: "What do you do for a living?",
      //   subtitle: "Share your profession or student status.",
      //   hintText: "e.g., Software Engineer, Student, Freelancer",
      //   controller: _occupationController,
      // ),
      // SingleChoiceQuestionWidget(
      //   title: "What's your Religion?",
      //   subtitle: "This helps potential flatmates relate to you.",
      //   options: ['Hindu', 'Muslim', 'Christian','Sikh','Buddhism','Prefer not to say'],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.religion = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.religion,
      // ),


      // Page 4: Current Location
      // _buildTextQuestion(
      //   title: "Where are you currently located?",
      //   subtitle: "This helps us understand your current city/area.",
      //   hintText: "e.g., Pune, Mumbai",
      //   controller: _currentLocationController,
      // ),

      // Page 5: Desired City
      // _buildCitySelectionQuestion(
      //   title: "Which city are you looking for a flat/flatmate in?",
      //   subtitle: "This helps us filter relevant listings for you.",
      //   onCitySelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.desiredCity = value;
      //       // Clear area preference when city changes
      //       _seekingFlatmateProfile.areaPreference = '';
      //       _areaPreferenceController.clear();
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.desiredCity,
      //   cities: maharashtraLocations.keys.toList(),
      // ),
      //
      // _buildAreaSelectionQuestion(
      //   title: "What are your preferred areas/localities?",
      //   subtitle: "Select preferred areas within ${(_seekingFlatmateProfile.desiredCity.isNotEmpty ? _seekingFlatmateProfile.desiredCity : 'the selected city')}.",
      //   onAreaSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.areaPreference = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.areaPreference,
      //   areas: maharashtraLocations[_seekingFlatmateProfile.desiredCity] ?? [], // Dynamically load areas
      //   selectedCity: _seekingFlatmateProfile.desiredCity, // Pass selected city to enable/disable
      // ),
LocationSelectorWidget(
  googleApiKey:'AIzaSyBK82kg-QdV1TdTrOoC3-jvbSstRhz1wZ0',

  initialCity: _seekingFlatmateProfile.city,
  initialAddress: _seekingFlatmateProfile.locationName,

  onLocationSelected: (location) {
    setState(() {
      _seekingFlatmateProfile.city =
          location.city ?? '';

      _seekingFlatmateProfile.locationName =
          location.address ?? '';

      _seekingFlatmateProfile.placeId =
          location.placeId ?? '';

      _seekingFlatmateProfile.latitude =
          location.latitude;

      _seekingFlatmateProfile.longitude =
          location.longitude;
    });
  },
),
      // Page 6: Move-in Date
      _buildDateQuestion(
        title: "Move-in Date",
        subtitle: "",
        onDateSelected: (date) {
          setState(() {
            _seekingFlatmateProfile.moveInDate = date;
          });
        },
        initialDate: _seekingFlatmateProfile.moveInDate,
      ),

      // Page 7: Budget Min
      _buildTextQuestion(
        title: "Minimum Budget",
        subtitle: "",
        hintText: "e.g., 8000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _budgetMinController,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('₹', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      ),

      // Page 8: Budget Max
      _buildTextQuestion(
        title: "Maximum Budget",
        subtitle: "",
        hintText: "e.g., 15000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _budgetMaxController,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('₹', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      ),

      // Page 9: Area Preference

      // Page 10: Bio
      // _buildTextQuestion(
      //   title: "Tell us a bit about yourself.",
      //   subtitle:
      //   "Share something interesting! This helps others get to know you.",
      //   hintText: "e.g., I'm a quiet person who loves reading...",
      //   controller: _bioController,
      //   maxLines: 5,
      // ),

      // --- Section 2: Your Habits (Pages 11-24) ---
      // Page 11: Cleanliness
      // SingleChoiceQuestionWidget(
      //   title: "How clean are you?",
      //   subtitle: "Be honest! This helps manage expectations.",
      //   options: [
      //     'Very Tidy',
      //     'Moderately Tidy',
      //     'Flexible',
      //     'Can be messy at times'
      //   ],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.cleanliness = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.cleanliness,
      // ),

      // Page 12: Social Habits
      // SingleChoiceQuestionWidget(
      //   title: "What are your social habits?",
      //   subtitle: "Do you enjoy social gatherings or prefer quiet?",
      //   options: ['Social & outgoing', 'Occasional gatherings', 'Quiet & private', 'Flexible'],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.socialHabits = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.socialHabits,
      // ),

      // Page 13: Work Schedule
      // SingleChoiceQuestionWidget(
      //   title: "What's your typical work/study schedule?",
      //   subtitle: "This helps in understanding common space usage.",
      //   options: [
      //     '9-5 Office hours',
      //     'Freelance/Flexible hours',
      //     'Night shifts',
      //     'Student schedule',
      //     'Mixed'
      //   ],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.workSchedule = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.workSchedule,
      // ),

      // Page 14: Noise Level
      // SingleChoiceQuestionWidget(
      //   title: "What's your preferred noise level in a flat?",
      //   subtitle: "How quiet or lively do you like the home to be?",
      //   options: ['Very quiet', 'Moderate noise', 'Lively', 'Flexible'],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.noiseLevel = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.noiseLevel,
      // ),

      // Page 15: Smoking Habits
      // SingleChoiceQuestionWidget(
      //   title: "What are your smoking habits?",
      //   subtitle: "This helps in matching with compatible flatmates.",
      //   options: ['Never', 'Occasionally', 'Socially', 'Regularly'],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.smokingHabits = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.smokingHabits,
      // ),

      // Page 16: Drinking Habits
      // SingleChoiceQuestionWidget(
      //   title: "What are your drinking habits?",
      //   subtitle: "Are you a non-drinker, social drinker, or regular drinker?",
      //   options: ['Never', 'Occasionally', 'Socially', 'Regularly'],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.drinkingHabits = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.drinkingHabits,
      // ),

      // Page 17: Food Preference
      // SingleChoiceQuestionWidget(
      //   title: "What is your food preference?",
      //   subtitle: "Any specific dietary habits or restrictions?",
      //   options: [
      //     'Vegetarian',
      //     'Non-Vegetarian',
      //     'Vegan',
      //     'Eggetarian',
      //     'Jain',
      //     'Other'
      //   ],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.foodPreference = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.foodPreference,
      // ),
      //
      // // Page 18: Guests Frequency
      // SingleChoiceQuestionWidget(
      //   title: "How often do you have guests over?",
      //   subtitle: "This helps manage expectations with flatmates/owners.",
      //   options: [
      //     'Frequently (1-2 times/week)',
      //     'Occasionally (1-2 times/month)',
      //     'Rarely',
      //     'Never'
      //   ],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.guestsFrequency = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.guestsFrequency,
      // ),

      // Page 19: Visitors Policy
      // SingleChoiceQuestionWidget(
      //   title: "What's your policy on visitors staying overnight?",
      //   subtitle: "How often do you expect to have guests stay overnight?",
      //   options: ['Frequently', 'Occasionally', 'Rarely', 'Never'],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.guestsOvernightPolicy = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.guestsOvernightPolicy,
      // ),

      // SingleChoiceQuestionWidget(
      //   title: "What's your policy on visitors?",
      //   subtitle: "How often do you plan to have guests over?",
      //   options: ['Frequent visitors', 'Occasional visitors', 'Rarely have visitors', 'No visitors'],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.visitorsPolicy = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.visitorsPolicy,
      // ),

      // Page 20: Pet Ownership
      // SingleChoiceQuestionWidget(
      //   title: "Do you currently own pets?",
      //   subtitle: "Are you bringing any furry friends?",
      //   options: ['Yes', 'No', 'Planning to get one'],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.petOwnership = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.petOwnership,
      // ),

      // Page 21: Pet Tolerance
      // SingleChoiceQuestionWidget(
      //   title: "What's your tolerance for flatmates/owners with pets?",
      //   subtitle: "Are you comfortable living with pets?",
      //   options: [
      //     'Comfortable with pets',
      //     'Tolerant of pets',
      //     'Prefer no pets',
      //     'Allergic to pets'
      //   ],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.petTolerance = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.petTolerance,
      // ),

      // Page 22: Sleeping Schedule
      // SingleChoiceQuestionWidget(
      //   title: "What's your typical sleeping schedule?",
      //   subtitle: "Are you an early bird or a night owl?",
      //   options: ['Early riser', 'Night Owl', 'Flexible', 'Irregular'],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.sleepingSchedule = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.sleepingSchedule,
      // ),

      // Page 23: Sharing Common Spaces
      // SingleChoiceQuestionWidget(
      //   title: "How do you prefer sharing common spaces?",
      //   subtitle: "Do you like to share everything or prefer separate items?",
      //   options: [
      //     'Share everything',
      //     'Share some items',
      //     'Prefer separate items',
      //     'Flexible'
      //   ],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.sharingCommonSpaces = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.sharingCommonSpaces,
      // ),

      // Page 24: Personal Space vs Socialization
      // SingleChoiceQuestionWidget(
      //   title: "How do you balance personal space and socialization?",
      //   subtitle:
      //   "Do you value quiet personal time or enjoy interactive common spaces?",
      //   options: [
      //     'Value personal space highly',
      //     'Enjoy a balance',
      //     'Prefer more socialization',
      //     'Flexible'
      //   ],
      //   onSelected: (value) {
      //     setState(() {
      //       _seekingFlatmateProfile.personalSpaceVsSocialization = value;
      //     });
      //   },
      //   initialValue: _seekingFlatmateProfile.personalSpaceVsSocialization,
      // ),

      // --- Section 3: Flat Requirements (Pages 25-27) ---
      // Page 25: Preferred Flat Type
      SingleChoiceQuestionWidget(
        title: "Preferred Property Type",
        subtitle: "",
        options: ['Studio Apartment', '1BHK', '2BHK', '3BHK', '4BHK+', 'Any'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.preferredFlatType = value;
          });
        },
        initialValue: _seekingFlatmateProfile.preferredFlatType,
      ),
      SingleChoiceQuestionWidget(
        title: "Occupancy Type",
        subtitle: "",
        options: ['Single Occupancy', 'Double Occupancy', 'Triple Occupancy', 'Any'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.preferredRoomType = value;
          });
        },
        initialValue: _seekingFlatmateProfile.preferredRoomType,
      ),

      // Page 26: Preferred Furnished Status
      SingleChoiceQuestionWidget(
        title: "Furnishing Status",
        subtitle: "",
        options: ['Furnished', 'Semi-furnished', 'Unfurnished'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.preferredFurnishedStatus = value;
          });
        },
        initialValue: _seekingFlatmateProfile.preferredFurnishedStatus,
      ),

      // Page 27: Amenities Desired (Multi-choice)
      MultiChoiceQuestionWidget(
        title: "Required Facilities",
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
            _seekingFlatmateProfile.amenitiesDesired = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.amenitiesDesired,
      ),

      // --- Section 4: Flatmate Preferences (Pages 28-33) ---
      // Page 28: Preferred Flatmate Gender
     _buildFlatmatePreferencesPage(),
    ];
  }
void _nextPage() {
  FocusScope.of(context).unfocus();

  // Location
  if (_currentPage == 0) {
    if (_seekingFlatmateProfile.locationName.trim().isEmpty ||
        _seekingFlatmateProfile.placeId.trim().isEmpty ||
        _seekingFlatmateProfile.latitude == null ||
        _seekingFlatmateProfile.longitude == null) {
      PremiumSnackbar.error(
        context,
        title: "Location Required",
        message: "Please select your preferred location.",
      );
      return;
    }
  }

  // Minimum Budget
  if (_currentPage == 2) {
    if (_seekingFlatmateProfile.budgetMin == null ||
        _seekingFlatmateProfile.budgetMin! <= 0) {
      PremiumSnackbar.error(
        context,
        title: "Minimum Budget Required",
        message: "Please enter your minimum budget.",
      );
      return;
    }
  }

  // Maximum Budget
  if (_currentPage == 3) {
    if (_seekingFlatmateProfile.budgetMax == null ||
        _seekingFlatmateProfile.budgetMax! <= 0) {
      PremiumSnackbar.error(
        context,
        title: "Maximum Budget Required",
        message: "Please enter your maximum budget.",
      );
      return;
    }

    if (_seekingFlatmateProfile.budgetMin != null &&
        _seekingFlatmateProfile.budgetMax! <
            _seekingFlatmateProfile.budgetMin!) {
      PremiumSnackbar.error(
        context,
        title: "Invalid Budget Range",
        message: "Maximum budget cannot be less than minimum budget.",
      );
      return;
    }
  }

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
            Container(
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
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final section = _sections[index];

                  final bool isCurrentSection =
                      _currentPage >=
                              section['startPage'] &&
                          _currentPage <=
                              section['endPage'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);

                      _pageController.jumpToPage(
                        section['startPage'] as int,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 250,
                      ),
                      margin:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),
                      padding:
                          const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                                24),

                        gradient: isCurrentSection
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF7C3AED),
                                  Color(0xFF9333EA),
                                  Color(0xFFEC4899),
                                ],
                              )
                            : null,

                        color: isCurrentSection
                            ? null
                            : Colors.white,

                        border: Border.all(
                          color: isCurrentSection
                              ? Colors.transparent
                              : const Color(
                                  0xFFE5E7EB),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: isCurrentSection
                                ? const Color(
                                        0xFF7C3AED)
                                    .withOpacity(.25)
                                : Colors.black
                                    .withOpacity(.05),
                            blurRadius: 18,
                            offset:
                                const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration:
                                BoxDecoration(
                              color:
                                  isCurrentSection
                                      ? Colors.white
                                      : const Color(
                                          0xFFF3F4F6),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      isCurrentSection
                                          ? const Color(
                                              0xFF7C3AED)
                                          : const Color(
                                              0xFF6B7280),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  section['title'],
                                  style:
                                      TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    color:
                                        isCurrentSection
                                            ? Colors
                                                .white
                                            : const Color(
                                                0xFF111827),
                                  ),
                                ),

                                const SizedBox(
                                    height: 4),

                                Text(
                                  "Pages ${section['startPage'] + 1} - ${section['endPage'] + 1}",
                                  style:
                                      TextStyle(
                                    color:
                                        isCurrentSection
                                            ? Colors
                                                .white70
                                            : const Color(
                                                0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (isCurrentSection)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            )
                          else
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Color(
                                  0xFF7C3AED),
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
  // --- Firebase Integration Method ---
  Future<void> _submitProfileToFirebase() async {
  // Prevent double taps / duplicate submissions.
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
    // 1. FETCH MAIN USER DOCUMENT
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

    // ============================================================
    // SAFE HABITS MAP
    // ============================================================

    final dynamic rawHabits = mainUserData['habits'];

    final Map<String, dynamic> habits =
        rawHabits is Map
            ? Map<String, dynamic>.from(rawHabits)
            : <String, dynamic>{};

    // ============================================================
    // 2. CREATE CURRENT USER PROFILE SNAPSHOT
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
    // 3. UPDATE SEEKING PROFILE WITH CURRENT USER DATA
    // ============================================================

    _seekingFlatmateProfile.userProfile = userProfile;
    _seekingFlatmateProfile.uid = user.uid;

    // ============================================================
    // 4. CONVERT TO FIRESTORE MAP
    // ============================================================

    final Map<String, dynamic> profileData =
        _seekingFlatmateProfile.toMap();

    final CollectionReference
        seekingFlatmateProfilesCollection =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('seekingFlatmateProfiles');

    // ============================================================
    // 5. CREATE OR UPDATE PROFILE
    // ============================================================

    final bool isCreating =
        _seekingFlatmateProfile.documentId.isEmpty;

    if (isCreating) {
      profileData['createdAt'] =
          FieldValue.serverTimestamp();

      profileData['lastUpdated'] =
          FieldValue.serverTimestamp();

      final DocumentReference newDocRef =
          await seekingFlatmateProfilesCollection
              .add(profileData);

      _seekingFlatmateProfile.documentId =
          newDocRef.id;
    } else {
      profileData['lastUpdated'] =
          FieldValue.serverTimestamp();

      // Never overwrite original creation time.
      profileData.remove('createdAt');

      await seekingFlatmateProfilesCollection
          .doc(_seekingFlatmateProfile.documentId)
          .update(profileData);
    }

    if (!mounted) return;

    // ============================================================
    // 6. PREMIUM SUCCESS SNACKBAR
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
                            ? 'Profile Created'
                            : 'Profile Updated',
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        isCreating
                            ? 'Your flatmate profile is now ready to discover compatible matches.'
                            : 'Your flatmate profile changes have been saved successfully.',
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

    // Give the floating SnackBar enough time to appear before
    // replacing this route.
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
      'Error submitting seeking flatmate profile: $e',
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
                        'Unable to Save Profile',
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
      });
    }
  }
}

  void _submitProfile() {
    print('Submitting Seeking Flatmate Profile:');
    print(_seekingFlatmateProfile.toString());
    _submitProfileToFirebase();
  }

@override
Widget build(BuildContext context) {
  const Color primary = Color(0xFF7C3AED);
  const Color secondary = Color(0xFFEC4899);
  const Color textPrimary = Color(0xFF111827);
  const Color textSecondary = Color(0xFF64748B);
  const Color borderColor = Color(0xFFE2E8F0);
  const Color backgroundColor = Color(0xFFF8FAFC);

  final Size screenSize = MediaQuery.sizeOf(context);

  final bool isTablet = screenSize.width >= 700;

  final double horizontalPadding =
      isTablet ? 32 : 16;

  final double progress =
      _pages.isEmpty
          ? 0
          : ((_currentPage + 1) / _pages.length)
              .clamp(0.0, 1.0);

  final bool isFirstPage = _currentPage == 0;

  final bool isLastPage =
      _currentPage == _pages.length - 1;

  return PopScope(
  canPop: false,
  onPopInvoked: (didPop) async {
    if (didPop) return;

    final shouldExit = await _showExitDialog();

    if (shouldExit && mounted) {
      Navigator.of(context).pop();
    }
  },
  child: Scaffold(
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
                            blurRadius: 24,
                            offset:
                                const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // =================================================
                          // TOP NAVIGATION ROW
                          // =================================================

                          SizedBox(
                            height: 42,
                            child: Row(
                              children: [
                                // LEFT BUTTON

                                AnimatedSwitcher(
                                  duration: const Duration(
                                    milliseconds: 200,
                                  ),
                                  child: !isFirstPage
                                      ? Material(
                                          key: const ValueKey(
                                            'back_button',
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
                                            'home_icon',
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
                                          ),
                                          child:
                                              const Icon(
                                            Icons
                                                .person_search_rounded,
                                            color:
                                                Colors.white,
                                            size: 21,
                                          ),
                                        ),
                                ),

                                const SizedBox(width: 10),

                                // TITLE

                                const Expanded(
                                  child: Text(
                                    'Find Flatmate',
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      height: 1.1,
                                      fontWeight:
                                          FontWeight.w800,
                                      letterSpacing: -.3,
                                    ),
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
                                              .withOpacity(
                                            .14,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons
                                                .grid_view_rounded,
                                            size: 17,
                                            color:
                                                Colors.white,
                                          ),

                                          if (screenSize.width >=
                                              370) ...[
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            const Text(
                                              'Sections',
                                              style:
                                                  TextStyle(
                                                color:
                                                    Colors.white,
                                                fontSize: 13,
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

                          const SizedBox(height: 13),

                          // =================================================
                          // SECTION INFORMATION
                          // =================================================

                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withOpacity(.96),
                              borderRadius:
                                  BorderRadius.circular(17),
                              border: Border.all(
                                color: Colors.white
                                    .withOpacity(.65),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    // SECTION ICON

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
                                            .tune_rounded,
                                        size: 19,
                                        color: primary,
                                      ),
                                    ),

                                    const SizedBox(width: 11),

                                    // SECTION NAME + STEP

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
                                              fontSize: 17,
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
                                            _getCurrentStepText(),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              color:
                                                  textSecondary,
                                              fontSize: 12,
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

                                    // PERCENTAGE BADGE

                                    Container(
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
                                      ),
                                      child: Text(
                                        '${(progress * 100).round()}%',
                                        style:
                                            const TextStyle(
                                          color: primary,
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 11),

                                // PROGRESS BAR

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(50),
                                  child:
                                      LinearProgressIndicator(
                                    minHeight: 6,
                                    value: progress,
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
              // QUESTION PAGES
              // ============================================================

              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 760,
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: _pages.length,
                      onPageChanged: (page) {
                        if (!mounted) return;

                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        return KeyedSubtree(
                          key: ValueKey(
                            'question_page_$index',
                          ),
                          child: _pages[index],
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ============================================================
              // PREMIUM BOTTOM ACTION BAR
              // ============================================================

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(.98),
                  border: const Border(
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
                                onPressed: isFirstPage
                                    ? null
                                    : _previousPage,
                                style:
                                    OutlinedButton.styleFrom(
                                  padding:
                                      EdgeInsets.zero,
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

                            // CONTINUE BUTTON

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
                                      Color(0xFF7C3AED),
                                      Color(0xFF9333EA),
                                      Color(0xFFEC4899),
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
                                      _isSubmitting
                                          ? null
                                          : _nextPage,
                                  style: ElevatedButton
                                      .styleFrom(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 18,
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
                                              ? 'Finish Setup'
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
                                                .check_circle_outline_rounded
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
        // PREMIUM SUBMISSION LOADER
        // ================================================================

        if (_isSubmitting)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.42),
              child: Center(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 32),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(.12),
                        blurRadius: 30,
                        offset:
                            const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: primary,
                        ),
                      ),

                      SizedBox(height: 16),

                      Text(
                        'Saving your preferences...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Please wait a moment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12.5,
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