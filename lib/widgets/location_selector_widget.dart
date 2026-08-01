import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../screens/location_search_screen.dart';
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
double? _selectedCityLatitude;
double? _selectedCityLongitude;

static const int _searchRadiusMeters = 100000; // 100 km
  double? _latitude;
  double? _longitude;

  String? _placeId;
  final Map<String, LatLng> _cityCoordinates = {
  'Bangalore': const LatLng(12.9716, 77.5946),
  'Mumbai': const LatLng(19.0760, 72.8777),
  'Delhi': const LatLng(28.6139, 77.2090),
  'Pune': const LatLng(18.5204, 73.8567),
  'Hyderabad': const LatLng(17.3850, 78.4867),
  'Chennai': const LatLng(13.0827, 80.2707),
  'Kolkata': const LatLng(22.5726, 88.3639),
  'Ahmedabad': const LatLng(23.0225, 72.5714),
  'Jaipur': const LatLng(26.9124, 75.7873),
  'Lucknow': const LatLng(26.8467, 80.9462),
  'Chandigarh': const LatLng(30.7333, 76.7794),
  'Indore': const LatLng(22.7196, 75.8577),
  'Bhopal': const LatLng(23.2599, 77.4126),
  'Nagpur': const LatLng(21.1458, 79.0882),
  'Surat': const LatLng(21.1702, 72.8311),
  'Vadodara': const LatLng(22.3072, 73.1812),
  'Patna': const LatLng(25.5941, 85.1376),
  'Kochi': const LatLng(9.9312, 76.2673),
  'Coimbatore': const LatLng(11.0168, 76.9558),
  'Mysore': const LatLng(12.2958, 76.6394),
};
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

  if (_selectedCity != null) {
    final coordinates =
        _cityCoordinates[_selectedCity];

    _selectedCityLatitude =
        coordinates?.latitude;

    _selectedCityLongitude =
        coordinates?.longitude;
  }

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

  _addressFocusNode.dispose();
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
double _calculateDistanceKm(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double earthRadiusKm = 6371.0;

  final double dLat =
      (lat2 - lat1) * math.pi / 180;

  final double dLon =
      (lon2 - lon1) * math.pi / 180;

  final double a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);

  final double c = 2 *
      math.atan2(
        math.sqrt(a),
        math.sqrt(1 - a),
      );

  return earthRadiusKm * c;
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

final LatLng? cityCoordinates =
    _cityCoordinates[city];

setState(() {
  _selectedCity = city;

  _selectedCityLatitude =
      cityCoordinates?.latitude;

  _selectedCityLongitude =
      cityCoordinates?.longitude;

  _addressController.clear();

  _latitude = null;
  _longitude = null;
  _placeId = null;
});

// Give focus to address search after city selection.
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;

  _addressFocusNode.requestFocus();
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

   InkWell(
  borderRadius: BorderRadius.circular(18),
  onTap: () async {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a city first."),
        ),
      );
      return;
    }

    final LocationSearchResult? result =
    await Navigator.push<LocationSearchResult>(
  context,
  MaterialPageRoute(
    builder: (_) => LocationSearchScreen(
      city: _selectedCity!,
      cityLatitude: _selectedCityLatitude!,
      cityLongitude: _selectedCityLongitude!,
      searchRadiusMeters: _searchRadiusMeters,
    ),
  ),
);

if (result == null) return;

setState(() {
  _addressController.text = result.address;
  _latitude = result.latitude;
  _longitude = result.longitude;
  _placeId = result.placeId;
});

_notifyParent();
  },
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 18,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kBorderColor),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.search_rounded,
          color: kPrimaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _addressController.text.isEmpty
                ? (_selectedCity == null
                    ? "Select city first"
                    : "Search in $_selectedCity")
                : _addressController.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _addressController.text.isEmpty
                  ? kMediumText
                  : kDarkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Icon(Icons.chevron_right),
      ],
    ),
  ),
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