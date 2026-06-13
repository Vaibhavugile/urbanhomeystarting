import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

class SelectedPlace {
  final String name;
  final String placeId;
  final double latitude;
  final double longitude;

  SelectedPlace({
    required this.name,
    required this.placeId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'placeId': placeId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class GooglePlacesMultiSelectWidget extends StatefulWidget {
  final Function(List<SelectedPlace>) onChanged;
  final List<SelectedPlace>? initialPlaces;

  const GooglePlacesMultiSelectWidget({
    super.key,
    required this.onChanged,
    this.initialPlaces,
  });

  @override
  State<GooglePlacesMultiSelectWidget> createState() =>
      _GooglePlacesMultiSelectWidgetState();
}

class _GooglePlacesMultiSelectWidgetState
    extends State<GooglePlacesMultiSelectWidget> {
  late FlutterGooglePlacesSdk _places;

  final TextEditingController _searchController =
      TextEditingController();

  List<AutocompletePrediction> _predictions = [];

  List<SelectedPlace> _selectedPlaces = [];

  @override
  void initState() {
    super.initState();

    _places = FlutterGooglePlacesSdk(
      "YOUR_API_KEY",
    );

    if (widget.initialPlaces != null) {
      _selectedPlaces =
          List.from(widget.initialPlaces!);
    }
  }

  Future<void> _searchPlaces(
      String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    try {
      final result =
          await _places.findAutocompletePredictions(
        query,
        countries: ["IN"],
      );

      setState(() {
        _predictions = result.predictions;
      });
    } catch (e) {
      debugPrint(
        "Places search error: $e",
      );
    }
  }

  Future<void> _selectPlace(
      AutocompletePrediction prediction) async {
    try {
      final details =
          await _places.fetchPlace(
        prediction.placeId,
        fields: [
          PlaceField.Name,
          PlaceField.Location,
        ],
      );

      final place = details.place;

      if (place == null ||
          place.latLng == null) {
        return;
      }

      final alreadyExists =
          _selectedPlaces.any(
        (e) =>
            e.placeId ==
            prediction.placeId,
      );

      if (alreadyExists) {
        return;
      }

      final selectedPlace =
          SelectedPlace(
        name:
            place.name ??
                prediction.primaryText,
        placeId:
            prediction.placeId,
        latitude:
            place.latLng!.lat,
        longitude:
            place.latLng!.lng,
      );

      setState(() {
        _selectedPlaces.add(
          selectedPlace,
        );

        _predictions.clear();

        _searchController.clear();
      });

      widget.onChanged(
        _selectedPlaces,
      );
    } catch (e) {
      debugPrint(
        "Place detail error: $e",
      );
    }
  }

  void _removePlace(
      SelectedPlace place) {
    setState(() {
      _selectedPlaces.remove(place);
    });

    widget.onChanged(
      _selectedPlaces,
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        TextField(
          controller:
              _searchController,
          onChanged:
              _searchPlaces,
          decoration:
              InputDecoration(
            hintText:
                "Search area, locality or landmark",
            prefixIcon:
                const Icon(
              Icons.location_on,
              color:
                  Color(0xFF6A1B9A),
            ),
            filled: true,
            fillColor:
                Colors.grey.shade100,
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      18),
              borderSide:
                  BorderSide.none,
            ),
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        if (_selectedPlaces
            .isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _selectedPlaces
                    .map(
                      (place) =>
                          Chip(
                        label: Text(
                          place.name,
                        ),
                        deleteIcon:
                            const Icon(
                          Icons.close,
                          size: 18,
                        ),
                        onDeleted:
                            () =>
                                _removePlace(
                          place,
                        ),
                        backgroundColor:
                            const Color(
                          0xFF6A1B9A,
                        ).withOpacity(
                                .08),
                      ),
                    )
                    .toList(),
          ),

        if (_predictions
            .isNotEmpty)
          Container(
            margin:
                const EdgeInsets.only(
              top: 12,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                      16),
              boxShadow: [
                BoxShadow(
                  color: Colors
                      .black
                      .withOpacity(
                          .08),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount:
                  _predictions.length,
              separatorBuilder:
                  (_, __) =>
                      Divider(
                height: 1,
                color: Colors
                    .grey
                    .shade200,
              ),
              itemBuilder:
                  (context,
                      index) {
                final prediction =
                    _predictions[
                        index];

                return ListTile(
                  leading:
                      const Icon(
                    Icons
                        .location_on,
                    color: Color(
                      0xFFAD1457,
                    ),
                  ),
                  title: Text(
                    prediction
                        .primaryText,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                  ),
                  subtitle: Text(
                    prediction
                        .secondaryText,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                  ),
                  onTap:
                      () =>
                          _selectPlace(
                    prediction,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}