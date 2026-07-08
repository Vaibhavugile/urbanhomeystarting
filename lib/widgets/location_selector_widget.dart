import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

class LocationResult {
  final String? city;
  final String? address;
  final String? placeId;
  final double? latitude;
  final double? longitude;

  const LocationResult({
    this.city,
    this.address,
    this.placeId,
    this.latitude,
    this.longitude,
  });
}

class LocationSelectorWidget extends StatefulWidget {
  final String googleApiKey;

  final String? initialCity;
  final String? initialAddress;
  final Function(LocationResult) onLocationSelected;

  const LocationSelectorWidget({
    super.key,
    required this.googleApiKey,
    required this.onLocationSelected,
    this.initialCity,
    this.initialAddress,
    
  });

  @override
  State<LocationSelectorWidget> createState() =>
      _LocationSelectorWidgetState();
}

class _LocationSelectorWidgetState
    extends State<LocationSelectorWidget> {
  late TextEditingController _addressController;

  String? _selectedCity;

  double? _latitude;
  double? _longitude;

  String? _placeId;
  final List<String> _cities = [
    'Bangalore',
    'Mumbai',
    'Delhi',
    'Pune',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Ahmedabad',
    'Jaipur',
    'Lucknow',
    'Chandigarh',
    'Indore',
    'Bhopal',
    'Nagpur',
    'Surat',
    'Vadodara',
    'Patna',
    'Kochi',
    'Coimbatore',
    'Mysore',
  ];
final FocusNode _addressFocusNode = FocusNode();
 @override
void initState() {
  super.initState();

  _selectedCity =
      widget.initialCity != null &&
              widget.initialCity!.isNotEmpty
          ? widget.initialCity
          : null;

  _addressController = TextEditingController(
    text: widget.initialAddress ?? '',
  );

  _addressController.addListener(
    _handleAddressTextChanged,
  );
}

@override
void dispose() {
  _addressController.removeListener(
    _handleAddressTextChanged,
  );

  _addressController.dispose();

  super.dispose();
}
void _handleAddressTextChanged() {
  // User changed/cleared the selected Google address.
  // Do not change _addressController.text here.

  if (_addressController.text.isEmpty) {
    if (_latitude == null &&
        _longitude == null &&
        _placeId == null) {
      return;
    }

    setState(() {
      _latitude = null;
      _longitude = null;
      _placeId = null;
    });
  } else {
    // Refresh widgets that depend on controller.text,
    // such as your selected-location preview.
    if (mounted) {
      setState(() {});
    }
  }
}
  void _notifyParent() {
    widget.onLocationSelected(
      LocationResult(
        city: _selectedCity,
        address: _addressController.text,
        placeId: _placeId,
        latitude: _latitude,
        longitude: _longitude,
      ),
    );
  }

@override
Widget build(BuildContext context) {
  final isKeyboardOpen =
    MediaQuery.of(context).viewInsets.bottom > 0;
  return Container(
    padding: const EdgeInsets.all(20),

    decoration: BoxDecoration(
      color: kCardColor,

      borderRadius: BorderRadius.circular(28),

      border: Border.all(
        color: kBorderColor,
      ),

      boxShadow: [
        BoxShadow(
          color: kPrimaryColor.withOpacity(.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),

   child: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [


        /// HEADER
        Row(
          children: [

            Container(
              width: 42,
              height: 42,

              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: kPrimaryGradient,
              ),

              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    "Property Location",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kDarkText,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    "Select city and search your flat location",
                    style: TextStyle(
                      fontSize: 13,
                      color: kMediumText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
if (_selectedCity == null)
  Container(
    margin: const EdgeInsets.only(
      bottom: 12,
    ),

    padding: const EdgeInsets.all(12),

    decoration: BoxDecoration(
      color: Colors.amber.shade50,
      borderRadius:
          BorderRadius.circular(12),

      border: Border.all(
        color: Colors.amber.shade200,
      ),
    ),

    child: Row(
      children: [

        Icon(
          Icons.info_outline,
          color: Colors.amber.shade700,
          size: 18,
        ),

        const SizedBox(width: 8),

        const Expanded(
          child: Text(
            "Select a city before searching a location",
          ),
        ),
      ],
    ),
  ),
        /// LOCATION ROW
        Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    /// CITY
    const Text(
      "City",
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: kDarkText,
      ),
    ),

    const SizedBox(height: 8),

    InkWell(
  borderRadius: BorderRadius.circular(18),

  onTap: () async {

    final city =
        await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,

      builder: (_) {

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [

              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Choose City",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ..._cities.map(
                (city) => ListTile(

                  leading: const Icon(
                    Icons.location_city_rounded,
                    color: kPrimaryColor,
                  ),

                  title: Text(city),

                  trailing:
                      city == _selectedCity
                          ? const Icon(
                              Icons.check_circle,
                              color: kPrimaryColor,
                            )
                          : null,

                  onTap: () {

                    Navigator.pop(
                      context,
                      city,
                    );

                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (city == null) return;

    setState(() {

      _selectedCity = city;

      _addressController.clear();

      _latitude = null;

      _longitude = null;

      _placeId = null;

    });

  },

  child: Container(

    padding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 18,
    ),

    decoration: BoxDecoration(

      color: Colors.white,

      borderRadius:
          BorderRadius.circular(18),

      border: Border.all(
        color: kBorderColor,
      ),

    ),

    child: Row(

      children: [

        const Icon(
          Icons.location_city_rounded,
          color: kPrimaryColor,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            _selectedCity ??
                "Select City",
            style: TextStyle(
              fontSize: 15,
              color: _selectedCity == null
                  ? kMediumText
                  : kDarkText,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        const Icon(
          Icons.keyboard_arrow_down,
        ),
      ],
    ),
  ),
),

    const SizedBox(height: 22),

    /// ADDRESS
    const Text(
      "Search Address",
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: kDarkText,
      ),
    ),

    const SizedBox(height: 8),

    GooglePlaceAutoCompleteTextField(
  textEditingController: _addressController,

  focusNode: _addressFocusNode,

  googleAPIKey:
          'AIzaSyBK82kg-QdV1TdTrOoC3-jvbSstRhz1wZ0',

  debounceTime: 600,

  isLatLngRequired: true,

  countries: const ["in"],

  // Disable package clear button.
  // We use our own reliable clear button below.
  isCrossBtnShown: false,

  inputDecoration: InputDecoration(
    hintText: _selectedCity == null
        ? "Select city first"
        : "Search in $_selectedCity",

    hintStyle: const TextStyle(
      color: kMediumText,
    ),

    prefixIcon: Container(
      margin: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: kPrimaryGradient,
      ),
      child: const Icon(
        Icons.search_rounded,
        color: Colors.white,
        size: 18,
      ),
    ),

    // ============================================================
    // CUSTOM CLEAR BUTTON
    // ============================================================

    suffixIcon: ValueListenableBuilder<TextEditingValue>(
      valueListenable: _addressController,
      builder: (context, value, child) {
        if (value.text.isEmpty) {
          return const SizedBox.shrink();
        }

        return IconButton(
          tooltip: "Clear location",
          icon: const Icon(
            Icons.close_rounded,
            color: kMediumText,
          ),
          onPressed: () {
            // Close keyboard.
            _addressFocusNode.unfocus();
            FocusManager.instance.primaryFocus?.unfocus();

            // Clear the TextField immediately.
            _addressController.clear();

            setState(() {
              _latitude = null;
              _longitude = null;
              _placeId = null;
            });

            // Tell parent that selected address was cleared.
            _notifyParent();
          },
        );
      },
    ),

    filled: true,
    fillColor: kCardColor,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 18,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: kBorderColor,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: kPrimaryColor,
        width: 2,
      ),
    ),
  ),

  // ============================================================
  // USER CLICKS A GOOGLE SUGGESTION
  // ============================================================

  itemClick: (Prediction prediction) {
  final selectedAddress =
      prediction.description ?? '';

  // The package already manages the text controller.
  // Do not update controller text inside setState().
  _addressController.value = TextEditingValue(
    text: selectedAddress,
    selection: TextSelection.collapsed(
      offset: selectedAddress.length,
    ),
  );

  _placeId = prediction.placeId;

  // Hide keyboard after the suggestion tap has completed.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    FocusManager.instance.primaryFocus?.unfocus();
  });
},

  // ============================================================
  // GOOGLE RETURNS LATITUDE / LONGITUDE
  // ============================================================

  getPlaceDetailWithLatLng: (Prediction prediction) {
    setState(() {
      _latitude = double.tryParse(
        prediction.lat ?? '',
      );

      _longitude = double.tryParse(
        prediction.lng ?? '',
      );

      _placeId = prediction.placeId;
    });

    _notifyParent();

    // Hide keyboard again after location details are returned.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _addressFocusNode.unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
    });
  },

  seperatedBuilder: const Divider(),

  itemBuilder: (
    context,
    index,
    Prediction prediction,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimaryColor.withOpacity(.10),
            ),
            child: const Icon(
              Icons.location_on,
              color: kPrimaryColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              prediction.description ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  },
),
  ],
),

        const SizedBox(height: 12),
        if (_addressController.text.isNotEmpty)
  Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      gradient: kPrimaryGradient,
      borderRadius: BorderRadius.circular(20),
    ),

    child: Row(
      children: [

        const Icon(
          Icons.location_on_rounded,
          color: Colors.white,
          size: 28,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                _selectedCity ??
                    "Selected Location",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _addressController.text,
                maxLines: 3,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
  // if (_latitude != null &&
  //   _longitude != null)
  // Container(
  //   width: double.infinity,
  //   margin: const EdgeInsets.only(
  //     bottom: 12,
  //   ),

  //   padding: const EdgeInsets.symmetric(
  //     horizontal: 16,
  //     vertical: 12,
  //   ),

  //   decoration: BoxDecoration(
  //     color: kPrimaryColor.withOpacity(.08),

  //     borderRadius:
  //         BorderRadius.circular(16),

  //     border: Border.all(
  //       color: kPrimaryColor.withOpacity(.15),
  //     ),
  //   ),

  //   child: Row(
  //     children: [

  //       Container(
  //         width: 36,
  //         height: 36,

  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           color: kPrimaryColor.withOpacity(.12),
  //         ),

  //         child: const Icon(
  //           Icons.gps_fixed,
  //           size: 18,
  //           color: kPrimaryColor,
  //         ),
  //       ),

  //       const SizedBox(width: 12),

  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment:
  //               CrossAxisAlignment.start,
  //           children: [

  //             const Text(
  //               "Coordinates",
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight:
  //                     FontWeight.w600,
  //                 color: kMediumText,
  //               ),
  //             ),

  //             const SizedBox(height: 2),

  //             Text(
  //               "${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}",
  //               style: const TextStyle(
  //                 fontSize: 13,
  //                 fontWeight:
  //                     FontWeight.w700,
  //                 color: kDarkText,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   ),
  // ),
  if (_latitude != null &&
    _longitude != null &&
    !isKeyboardOpen)
  Container(
    height: 140,
    margin: const EdgeInsets.only(
      bottom: 12,
    ),

    decoration: BoxDecoration(
      borderRadius:
          BorderRadius.circular(20),

      boxShadow: [
        BoxShadow(
          color:
              kPrimaryColor.withOpacity(.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),

    child: ClipRRect(
      borderRadius:
          BorderRadius.circular(20),

      child: GoogleMap(
         zoomGesturesEnabled: true,
  scrollGesturesEnabled: false,
        zoomControlsEnabled: false,

        myLocationButtonEnabled: false,

        compassEnabled: false,

        initialCameraPosition:
            CameraPosition(
          target: LatLng(
            _latitude!,
            _longitude!,
          ),
          zoom: 15,
        ),

        markers: {
          Marker(
            markerId:
                const MarkerId(
              'selected_location',
            ),

            position: LatLng(
              _latitude!,
              _longitude!,
            ),
          ),
        },
      ),
    ),
  ),

        Text(
          "Choose city and search the exact locality of your flat",
          style: TextStyle(
            fontSize: 12,
            color: kMediumText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  ),
  );
}
}