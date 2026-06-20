// lib/screens/filter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:mytennat/screens/filter_options.dart'; // Make sure this path is correct
import 'package:intl/intl.dart'; // For date formatting
import 'package:mytennat/data/location_data.dart'; // Import the new location data

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

class FilterScreen extends StatefulWidget {
  final FilterOptions initialFilters;
  final bool isSeekingFlatmate; // To determine which filters to show/apply
  final ValueChanged<FilterOptions> onFiltersChanged; // Callback for changes

  const FilterScreen({
    super.key,
    required this.initialFilters,
    required this.isSeekingFlatmate,
    required this.onFiltersChanged,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {

  late FilterOptions _filters;

  // ===============================
  // CONTROLLERS
  // ===============================

  final TextEditingController _occupationController =
      TextEditingController();

  // ===============================
  // SLIDERS
  // ===============================

  late RangeValues _ageRange;

  late RangeValues _budgetRange;

  // ===============================
  // DATES
  // ===============================

  String _moveInDateText = '';

  String _availabilityDateText = '';

  // ===============================
  // DROPDOWN OPTIONS
  // ===============================

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Any',
  ];

  final List<String> _flatTypes = [
    'Studio Apartment',
    '1BHK',
    '2BHK',
    '3BHK',
    '4BHK+',
    'Other',
  ];

  final List<String> _roomTypes = [
    'Single Occupancy',
    'Double Occupancy',
    'Triple Occupancy',
    'Other',
  ];

  final List<String> _furnishedStatuses = [
    'Furnished',
    'Semi-furnished',
    'Unfurnished',
  ];

  final List<String> _bathroomTypes = [
    'Attached Bathroom',
    'Shared Bathroom',
  ];

  final List<String> _leaseDurations = [
    '1 Month',
    '2 Months',
    '3 Months',
    '6 Months',
    '11 Months',
    '1 Year',
    'More than 1 Year',
    'Flexible',
  ];

  final List<String> _availableForOptions = [
    'Boys',
    'Girls',
    'Couples',
    'Anyone',
  ];

  // ===============================
  // LOCATION
  // ===============================

  late List<String> _cities;

  late List<String> _areas;

  final List<double> _radiusOptions = [
    3,
    5,
    10,
    20,
    50,
  ];

  // ===============================
  // AMENITIES
  // ===============================

  final List<String> _amenitiesOptions = [
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
    'Security',
  ];
@override
void initState() {
  super.initState();

  _filters = widget.initialFilters.copyWith();

  // ===============================
  // CONTROLLERS
  // ===============================

  _occupationController.text =
      _filters.occupation ?? '';

  // ===============================
  // RANGE VALUES
  // ===============================

  _ageRange = RangeValues(
    _filters.ageMin?.toDouble() ?? 18,
    _filters.ageMax?.toDouble() ?? 60,
  );

  _budgetRange = RangeValues(
    _filters.budgetMin?.toDouble() ?? 0,
    _filters.budgetMax?.toDouble() ?? 50000,
  );

  // ===============================
  // DATE DISPLAY
  // ===============================

  if (_filters.moveInDate != null) {
    _moveInDateText = DateFormat(
      'dd/MM/yyyy',
    ).format(_filters.moveInDate!);
  }

  if (_filters.availabilityDate != null) {
    _availabilityDateText = DateFormat(
      'dd/MM/yyyy',
    ).format(_filters.availabilityDate!);
  }

  // ===============================
  // LOCATION
  // ===============================

  _cities = [
    'Any',
    ...maharashtraLocations.keys.toList(),
  ];

  _areas = _getAreasForCity(
    _filters.desiredCity,
  );
}
  // Helper method to get areas for a given city
  List<String> _getAreasForCity(String? city) {
    if (city == null || city == 'Any' || !maharashtraLocations.containsKey(city)) {
      return ['Any']; // Return only 'Any' if no specific city or 'Any' is selected
    }
    return ['Any'] + maharashtraLocations[city]!; // Add 'Any' option to specific city areas
  }

  @override
void dispose() {
  _occupationController.dispose();

  super.dispose();
}
Future<void> _selectDate(
  BuildContext context,
  bool isMoveInDate,
) async {
  final DateTime? picked =
      await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(
      DateTime.now().year + 5,
    ),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: kPrimaryColor,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked == null) return;

  setState(() {
    if (isMoveInDate) {
      _filters.moveInDate = picked;

      _moveInDateText =
          DateFormat('dd/MM/yyyy')
              .format(picked);
    } else {
      _filters.availabilityDate =
          picked;

      _availabilityDateText =
          DateFormat('dd/MM/yyyy')
              .format(picked);
    }
  });
}

void _applyFilters() {
  _filters.occupation =
      _occupationController.text.trim().isEmpty
          ? null
          : _occupationController.text.trim();

  widget.onFiltersChanged(_filters);
}

void _clearAllFilters() {
  setState(() {
    _filters.clear();

    _occupationController.clear();

    _moveInDateText = '';

    _availabilityDateText = '';

    // Reset sliders

    _ageRange =
        const RangeValues(18, 60);

    _budgetRange =
        const RangeValues(
      0,
      50000,
    );

    // Optional legacy fields

    _filters.desiredCity = null;

    _filters.areaPreference = null;
  });

  widget.onFiltersChanged(_filters);
}

  // NOTE: This method is defined but not called in filter_screen.dart.
  // The Firebase error you showed in the screenshot is likely from your data fetching logic.
  // This method would typically be used to show a SnackBar for client-side validation errors,
  // not for backend/Firestore errors like the one you observed.
  void _showErrorSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: kErrorColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 0,
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  elevation: 0,
  scrolledUnderElevation: 0,
  backgroundColor: Colors.transparent,

  leading: IconButton(
    icon: const Icon(
      Icons.arrow_back_ios_rounded,
      color: Colors.white,
      size: 20,
    ),
    onPressed: () => Navigator.pop(context),
  ),

  title: const Text(
    'Filters',
    style: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
  ),

  centerTitle: false,

  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: kPrimaryGradient,
    ),
  ),

  actions: [
    Padding(
      padding: const EdgeInsets.only(
        right: 12,
      ),
      child: TextButton(
        onPressed: _clearAllFilters,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
        ),
        child: const Text(
          'Reset',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  ],
),
     body: Container(
  color: kBackgroundColor,
  child: Column(
    children: [

      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [


              // Location Section
              _buildFilterSection(
  title: '📍 Location',
  children: [

    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kLightGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kBorderColor,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: kPrimaryColor,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              _filters.placeId ?? 'Select Location',
              style: TextStyle(
                color: _filters.placeId == null
                    ? kMediumText
                    : kDarkText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              // Open Location Selector
            },
            icon: const Icon(
              Icons.edit_location_alt_rounded,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    ),

    const SizedBox(height: 20),

    Text(
      'Search Radius',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: kDarkText,
      ),
    ),

    const SizedBox(height: 12),

    Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _radiusOptions.map((radius) {

        final selected =
            _filters.searchRadiusKm == radius;

        return ChoiceChip(
          label: Text(
            '${radius.toInt()} KM',
          ),
          selected: selected,
          onSelected: (_) {
            setState(() {
              _filters.searchRadiusKm =
                  radius;
            });
          },
          selectedColor: kPrimaryColor,
          labelStyle: TextStyle(
            color: selected
                ? Colors.white
                : kMediumText,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: kLightGrey,
          side: BorderSide(
            color: selected
                ? kPrimaryColor
                : kBorderColor,
          ),
        );
      }).toList(),
    ),

    const SizedBox(height: 20),

    SwitchListTile(
      value: _filters.sortByNearest,
      activeColor: kPrimaryColor,
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Sort Nearest First',
      ),
      subtitle: const Text(
        'Show closest matches first',
      ),
      onChanged: (value) {
        setState(() {
          _filters.sortByNearest = value;
        });
      },
    ),
  ],
),

              // Budget Section
const SizedBox(height: 24),

_buildFilterSection(
  title: '💰 Budget',
  children: [

    if (widget.isSeekingFlatmate) ...[

      _buildRangeSliderFilter(
        label: 'Budget Range',
        currentRange: _budgetRange,
        onRangeChanged: (newRange) {
          setState(() {
            _budgetRange = newRange;

            _filters.budgetMin =
                newRange.start.round();

            _filters.budgetMax =
                newRange.end.round();
          });
        },
        min: 0,
        max: 100000,
        divisions: 20,
        icon: Icons.account_balance_wallet_rounded,
        prefixText: '₹',
      ),

    ] else ...[

      _buildRangeSliderFilter(
        label: 'Rent Range',
        currentRange: RangeValues(
          (_filters.rentPriceMin ?? 0)
              .toDouble(),
          (_filters.rentPriceMax ?? 50000)
              .toDouble(),
        ),
        onRangeChanged: (newRange) {
          setState(() {

            _filters.rentPriceMin =
                newRange.start.round();

            _filters.rentPriceMax =
                newRange.end.round();

          });
        },
        min: 0,
        max: 100000,
        divisions: 20,
        icon: Icons.currency_rupee_rounded,
        prefixText: '₹',
      ),
    ],
  ],
),
              // Property Details Section
const SizedBox(height: 24),

_buildFilterSection(
  title: '🏠 Property Details',
  children: [

    _buildDropdownFilter(
      label: 'Flat Type',
      value: _filters.flatType,
      items: _flatTypes,
      onChanged: (value) {
        setState(() {
          _filters.flatType = value;
        });
      },
    ),

    _buildDropdownFilter(
      label: 'Room Type',
      value: _filters.roomType,
      items: _roomTypes,
      onChanged: (value) {
        setState(() {
          _filters.roomType = value;
        });
      },
    ),

    _buildDropdownFilter(
      label: 'Furnished Status',
      value: _filters.furnishedStatus,
      items: _furnishedStatuses,
      onChanged: (value) {
        setState(() {
          _filters.furnishedStatus = value;
        });
      },
    ),

    _buildDropdownFilter(
      label: 'Bathroom Type',
      value: _filters.bathroomType,
      items: _bathroomTypes,
      onChanged: (value) {
        setState(() {
          _filters.bathroomType = value;
        });
      },
    ),

    _buildDropdownFilter(
      label: 'Lease Duration',
      value: _filters.leaseDuration,
      items: _leaseDurations,
      onChanged: (value) {
        setState(() {
          _filters.leaseDuration = value;
        });
      },
    ),
  ],
),
              // Available For Section
const SizedBox(height: 24),

_buildFilterSection(
  title: '👥 Available For',
  children: [
    _buildDropdownFilter(
      label: 'Available For',
      value: _filters.availableFor,
      items: _availableForOptions,
      onChanged: (value) {
        setState(() {
          _filters.availableFor = value;
        });
      },
    ),
  ],
),
              // Amenities Section
const SizedBox(height: 24),

_buildFilterSection(
  title: '✨ Amenities',
  children: [

    _FilterChipGroup(
      title: 'Select Amenities',
      availableItems: _amenitiesOptions,
      selectedItems:
          _filters.amenitiesDesired,
      onSelectionChanged: (
        selected,
      ) {
        setState(() {
          _filters.amenitiesDesired =
              selected;
        });
      },
    ),
  ],
),
  const SizedBox(height: 24),
            // Profile Quality Section
_buildFilterSection(
  title: '✅ Profile Quality',
  children: [

    SwitchListTile(
      value: _filters.verifiedOnly,
      activeColor: kPrimaryColor,
      title: const Text(
        'Verified Profiles Only',
      ),
      subtitle: const Text(
        'Show only verified users',
      ),
      onChanged: (value) {
        setState(() {
          _filters.verifiedOnly = value;
        });
      },
    ),

    SwitchListTile(
      value: _filters.profilesWithPhotosOnly,
      activeColor: kPrimaryColor,
      title: const Text(
        'Profiles With Photos',
      ),
      subtitle: const Text(
        'Hide profiles without photos',
      ),
      onChanged: (value) {
        setState(() {
          _filters.profilesWithPhotosOnly =
              value;
        });
      },
    ),

    SwitchListTile(
      value: _filters.activeWithin7Days,
      activeColor: kPrimaryColor,
      title: const Text(
        'Recently Active',
      ),
      subtitle: const Text(
        'Active in last 7 days',
      ),
      onChanged: (value) {
        setState(() {
          _filters.activeWithin7Days =
              value;
        });
      },
    ),
  ],
),
            ],
          ),
        ),
      ),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardColor,
          border: Border(
            top: BorderSide(
              color: kBorderColor,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: kPrimaryGradient,
                  borderRadius:
                      BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
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

  // Helper widget to build consistent filter sections
  Widget _buildFilterSection({
  required String title,
  required List<Widget> children,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(
      bottom: 20,
    ),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: kCardColor,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: kBorderColor,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(
            0.04,
          ),
          blurRadius: 20,
          offset: const Offset(
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

        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kDarkText,
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        ...children,
      ],
    ),
  );
}

  Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: kDarkText,
      letterSpacing: -0.2,
    ),
  );
}

InputDecoration _buildInputDecoration(
  String labelText, {
  IconData? icon,
}) {
  return InputDecoration(
    labelText: labelText,

    labelStyle: const TextStyle(
      color: kMediumText,
      fontWeight: FontWeight.w500,
    ),

   

    prefixIconConstraints:
        const BoxConstraints(
      minWidth: 48,
    ),

    prefixIcon: icon != null
        ? Icon(
            icon,
            color: kPrimaryColor,
            size: 20,
          )
        : null,

    filled: true,

    fillColor: kLightGrey,

    contentPadding:
        const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 18,
    ),

    border: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(16),
      borderSide: BorderSide(
        color: kBorderColor,
        width: 1,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: kPrimaryColor,
        width: 2,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: kErrorColor,
      ),
    ),

    focusedErrorBorder:
        OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: kErrorColor,
        width: 2,
      ),
    ),

    hintStyle: const TextStyle(
      color: kLightText,
    ),
  );
}

 Widget _buildDropdownFilter({
  required String label,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 18,
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: kDarkText,
          ),
        ),

        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          value: value,

          decoration:
              _buildInputDecoration(
            label,
          ),

          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: kDarkText,
                  fontSize: 15,
                ),
              ),
            );
          }).toList(),

          onChanged: onChanged,

          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: kPrimaryColor,
            size: 24,
          ),

          style: const TextStyle(
            color: kDarkText,
            fontSize: 15,
          ),

          dropdownColor: kCardColor,

          borderRadius:
              BorderRadius.circular(
            16,
          ),

          isExpanded: true,
        ),
      ],
    ),
  );
}
Widget _buildRangeSliderFilter({
  required String label,
  required RangeValues currentRange,
  required ValueChanged<RangeValues>
      onRangeChanged,
  required double min,
  required double max,
  int divisions = 1,
  IconData? icon,
  String? prefixText,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 18,
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: kDarkText,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: kLightGrey,
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
          child: Row(
            children: [

              if (icon != null)
                Icon(
                  icon,
                  color: kPrimaryColor,
                  size: 20,
                ),

              if (icon != null)
                const SizedBox(width: 10),

              SizedBox(
                width: 70,
                child: Text(
                  '${prefixText ?? ''}${currentRange.start.round()}',
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    color: kDarkText,
                  ),
                ),
              ),

              Expanded(
                child: SliderTheme(
                  data:
                      SliderTheme.of(
                    context,
                  ).copyWith(
                    activeTrackColor:
                        kPrimaryColor,

                    inactiveTrackColor:
                        kBorderColor,

                    thumbColor:
                        kPrimaryColor,

                    overlayColor:
                        kPrimaryColor
                            .withOpacity(
                      0.12,
                    ),

                    trackHeight: 5,

                    thumbShape:
                        const RoundSliderThumbShape(
                      enabledThumbRadius:
                          10,
                    ),

                    overlayShape:
                        const RoundSliderOverlayShape(
                      overlayRadius:
                          20,
                    ),

                    valueIndicatorColor:
                        kPrimaryColor,

                    valueIndicatorTextStyle:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),
                  ),
                  child: RangeSlider(
                    values: currentRange,
                    min: min,
                    max: max,
                    divisions: divisions,
                    labels: RangeLabels(
                      '${prefixText ?? ''}${currentRange.start.round()}',
                      '${prefixText ?? ''}${currentRange.end.round()}',
                    ),
                    onChanged:
                        onRangeChanged,
                  ),
                ),
              ),

              SizedBox(
                width: 70,
                child: Text(
                  '${prefixText ?? ''}${currentRange.end.round()}',
                  textAlign:
                      TextAlign.right,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    color: kDarkText,
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

Widget _buildTextField({
  required TextEditingController controller,
  required String labelText,
  required ValueChanged<String> onChanged,
  TextInputType keyboardType =
      TextInputType.text,
  List<TextInputFormatter>?
      inputFormatters,
  IconData? icon,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 18,
    ),
    child: TextFormField(
      controller: controller,

      decoration:
          _buildInputDecoration(
        labelText,
        icon: icon,
      ),

      keyboardType: keyboardType,

      inputFormatters:
          inputFormatters,

      onChanged: onChanged,

      style: const TextStyle(
        color: kDarkText,
        fontSize: 15,
        fontWeight:
            FontWeight.w500,
      ),

      cursorColor:
          kPrimaryColor,
    ),
  );
}
Widget _buildNumberField({
  required TextEditingController controller,
  required String labelText,
  required ValueChanged<String> onChanged,
  IconData? icon,
}) {
  return _buildTextField(
    controller: controller,
    labelText: labelText,
    onChanged: onChanged,
    keyboardType:
        TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter
          .digitsOnly,
    ],
    icon: icon,
  );
}
Widget _buildDateSelection({
  required String labelText,
  required String displayDate,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 18,
    ),
    child: InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(
        16,
      ),

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: kLightGrey,

          borderRadius:
              BorderRadius.circular(
            16,
          ),

          border: Border.all(
            color: kBorderColor,
          ),
        ),
        child: Row(
          children: [

            const Icon(
              Icons
                  .calendar_today_rounded,
              color: kPrimaryColor,
              size: 20,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [

                  Text(
                    labelText,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          kMediumText,
                      fontWeight:
                          FontWeight
                              .w500,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    displayDate
                            .isNotEmpty
                        ? displayDate
                        : 'Select Date',
                    style:
                        TextStyle(
                      color:
                          displayDate
                                  .isNotEmpty
                              ? kDarkText
                              : kLightText,
                      fontSize: 15,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons
                  .arrow_forward_ios_rounded,
              size: 16,
              color: kMediumText,
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _FilterChipGroup extends StatefulWidget {
  final String title;
  final List<String> availableItems;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectionChanged;

  const _FilterChipGroup({
    super.key,
    required this.title,
    required this.availableItems,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  State<_FilterChipGroup> createState() =>
      _FilterChipGroupState();
}

class _FilterChipGroupState
    extends State<_FilterChipGroup> {

  late List<String>
      _localSelectedItems;

  @override
  void initState() {
    super.initState();

    _localSelectedItems =
        List.from(
      widget.selectedItems,
    );
  }

  @override
  void didUpdateWidget(
    covariant _FilterChipGroup
        oldWidget,
  ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (widget.selectedItems !=
        oldWidget.selectedItems) {
      _localSelectedItems =
          List.from(
        widget.selectedItems,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
              color: kDarkText,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget
                .availableItems
                .map((item) {

              final isSelected =
                  _localSelectedItems
                      .contains(
                item,
              );

              return GestureDetector(
                onTap: () {
                  setState(() {

                    if (isSelected) {
                      _localSelectedItems
                          .remove(
                        item,
                      );
                    } else {
                      _localSelectedItems
                          .add(
                        item,
                      );
                    }

                    widget
                        .onSelectionChanged(
                      _localSelectedItems,
                    );
                  });
                },

                child: AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 200,
                  ),

                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  decoration:
                      BoxDecoration(

                    gradient:
                        isSelected
                            ? kPrimaryGradient
                            : null,

                    color:
                        isSelected
                            ? null
                            : kLightGrey,

                    borderRadius:
                        BorderRadius
                            .circular(
                      30,
                    ),

                    border: Border.all(
                      color:
                          isSelected
                              ? Colors
                                  .transparent
                              : kBorderColor,
                    ),

                    boxShadow:
                        isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      kPrimaryColor
                                          .withOpacity(
                                    0.20,
                                  ),
                                  blurRadius:
                                      12,
                                  offset:
                                      const Offset(
                                    0,
                                    4,
                                  ),
                                ),
                              ]
                            : [],
                  ),

                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [

                      if (isSelected)
                        const Padding(
                          padding:
                              EdgeInsets.only(
                            right: 6,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color:
                                Colors.white,
                            size: 16,
                          ),
                        ),

                      Text(
                        item,
                        style:
                            TextStyle(
                          color:
                              isSelected
                                  ? Colors
                                      .white
                                  : kDarkText,

                          fontWeight:
                              FontWeight
                                  .w600,

                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}