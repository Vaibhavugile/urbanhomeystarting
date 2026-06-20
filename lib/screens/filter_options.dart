class FilterOptions {
  // ===============================
  // LOCATION
  // ===============================

  String? desiredCity;
  String? areaPreference;

  String? placeId;

  double? latitude;
  double? longitude;

  double searchRadiusKm = 10;

  bool sortByNearest = true;

  // ===============================
  // DATES
  // ===============================

  DateTime? moveInDate;
  DateTime? availabilityDate;

  // ===============================
  // BASIC FILTERS
  // ===============================

  int? ageMin;
  int? ageMax;

  String? gender;

  String? occupation;

  // ===============================
  // FLAT FILTERS
  // ===============================

  int? rentPriceMin;
  int? rentPriceMax;

  String? flatType;

  String? roomType; // NEW

  String? furnishedStatus;

  String? bathroomType; // NEW

  String? leaseDuration; // NEW

  int? numberOfBedrooms;

  int? numberOfBathrooms;

  List<String> amenitiesDesired;

  String? availableFor;

  // ===============================
  // SEEKING FLATMATE FILTERS
  // ===============================

  int? budgetMin;
  int? budgetMax;

  // ===============================
  // MATCHING FILTERS
  // ===============================

  int? minimumMatchPercentage;

  bool verifiedOnly = false;

  bool profilesWithPhotosOnly = false;

  bool activeWithin7Days = false;
FilterOptions({
  // ===============================
  // LOCATION
  // ===============================

  this.desiredCity,
  this.areaPreference,

  this.placeId,

  this.latitude,
  this.longitude,

  this.searchRadiusKm = 10,

  this.sortByNearest = true,

  // ===============================
  // DATES
  // ===============================

  this.moveInDate,
  this.availabilityDate,

  // ===============================
  // BASIC FILTERS
  // ===============================

  this.ageMin,
  this.ageMax,

  this.gender,

  this.occupation,

  // ===============================
  // FLAT FILTERS
  // ===============================

  this.rentPriceMin,
  this.rentPriceMax,

  this.flatType,

  this.roomType,

  this.furnishedStatus,

  this.bathroomType,

  this.leaseDuration,

  this.numberOfBedrooms,

  this.numberOfBathrooms,

  this.availableFor,

  List<String>? amenitiesDesired,

  // ===============================
  // BUDGET FILTERS
  // ===============================

  this.budgetMin,
  this.budgetMax,

  // ===============================
  // MATCHING FILTERS
  // ===============================

  this.minimumMatchPercentage,

  this.verifiedOnly = false,

  this.profilesWithPhotosOnly = false,

  this.activeWithin7Days = false,
})
    : amenitiesDesired = amenitiesDesired ?? [];
 bool hasFilters() {
  return

      // ===============================
      // LOCATION
      // ===============================

      desiredCity != null ||
      areaPreference != null ||

      placeId != null ||

      latitude != null ||
      longitude != null ||

      searchRadiusKm != 10 ||

      !sortByNearest ||

      // ===============================
      // DATES
      // ===============================

      moveInDate != null ||
      availabilityDate != null ||

      // ===============================
      // BASIC FILTERS
      // ===============================

      ageMin != null ||
      ageMax != null ||

      gender != null ||

      occupation != null ||

      // ===============================
      // FLAT FILTERS
      // ===============================

      rentPriceMin != null ||
      rentPriceMax != null ||

      flatType != null ||

      roomType != null ||

      furnishedStatus != null ||

      bathroomType != null ||

      leaseDuration != null ||

      numberOfBedrooms != null ||

      numberOfBathrooms != null ||

      availableFor != null ||

      amenitiesDesired.isNotEmpty ||

      // ===============================
      // BUDGET FILTERS
      // ===============================

      budgetMin != null ||
      budgetMax != null ||

      // ===============================
      // MATCHING FILTERS
      // ===============================

      minimumMatchPercentage != null ||

      verifiedOnly ||

      profilesWithPhotosOnly ||

      activeWithin7Days;
}
void clear() {

  // ===============================
  // LOCATION
  // ===============================

  desiredCity = null;
  areaPreference = null;

  placeId = null;

  latitude = null;
  longitude = null;

  searchRadiusKm = 10;

  sortByNearest = true;

  // ===============================
  // DATES
  // ===============================

  moveInDate = null;
  availabilityDate = null;

  // ===============================
  // BASIC FILTERS
  // ===============================

  ageMin = null;
  ageMax = null;

  gender = null;

  occupation = null;

  // ===============================
  // FLAT FILTERS
  // ===============================

  rentPriceMin = null;
  rentPriceMax = null;

  flatType = null;

  roomType = null;

  furnishedStatus = null;

  bathroomType = null;

  leaseDuration = null;

  numberOfBedrooms = null;
  numberOfBathrooms = null;

  availableFor = null;

  amenitiesDesired.clear();

  // ===============================
  // BUDGET FILTERS
  // ===============================

  budgetMin = null;
  budgetMax = null;

  // ===============================
  // MATCHING FILTERS
  // ===============================

  minimumMatchPercentage = null;

  verifiedOnly = false;

  profilesWithPhotosOnly = false;

  activeWithin7Days = false;
}

 FilterOptions copyWith({
  // ===============================
  // LOCATION
  // ===============================

  String? desiredCity,
  String? areaPreference,
  String? placeId,

  double? latitude,
  double? longitude,

  double? searchRadiusKm,

  bool? sortByNearest,

  // ===============================
  // DATES
  // ===============================

  DateTime? moveInDate,
  DateTime? availabilityDate,

  // ===============================
  // BASIC FILTERS
  // ===============================

  int? ageMin,
  int? ageMax,

  String? gender,
  String? occupation,

  // ===============================
  // FLAT FILTERS
  // ===============================

  int? rentPriceMin,
  int? rentPriceMax,

  String? flatType,

  String? roomType,

  String? furnishedStatus,

  String? bathroomType,

  String? leaseDuration,

  int? numberOfBedrooms,
  int? numberOfBathrooms,

  String? availableFor,

  List<String>? amenitiesDesired,

  // ===============================
  // BUDGET FILTERS
  // ===============================

  int? budgetMin,
  int? budgetMax,

  // ===============================
  // MATCHING FILTERS
  // ===============================

  int? minimumMatchPercentage,

  bool? verifiedOnly,
  bool? profilesWithPhotosOnly,
  bool? activeWithin7Days,
}) {
 return FilterOptions(

  // ===============================
  // LOCATION
  // ===============================

  desiredCity:
      desiredCity ?? this.desiredCity,

  areaPreference:
      areaPreference ??
          this.areaPreference,

  placeId:
      placeId ?? this.placeId,

  latitude:
      latitude ?? this.latitude,

  longitude:
      longitude ?? this.longitude,

  searchRadiusKm:
      searchRadiusKm ??
          this.searchRadiusKm,

  sortByNearest:
      sortByNearest ??
          this.sortByNearest,

  // ===============================
  // DATES
  // ===============================

  moveInDate:
      moveInDate ?? this.moveInDate,

  availabilityDate:
      availabilityDate ??
          this.availabilityDate,

  // ===============================
  // BASIC FILTERS
  // ===============================

  ageMin:
      ageMin ?? this.ageMin,

  ageMax:
      ageMax ?? this.ageMax,

  gender:
      gender ?? this.gender,

  occupation:
      occupation ?? this.occupation,

  // ===============================
  // FLAT FILTERS
  // ===============================

  rentPriceMin:
      rentPriceMin ??
          this.rentPriceMin,

  rentPriceMax:
      rentPriceMax ??
          this.rentPriceMax,

  flatType:
      flatType ?? this.flatType,

  roomType:
      roomType ?? this.roomType,

  furnishedStatus:
      furnishedStatus ??
          this.furnishedStatus,

  bathroomType:
      bathroomType ??
          this.bathroomType,

  leaseDuration:
      leaseDuration ??
          this.leaseDuration,

  numberOfBedrooms:
      numberOfBedrooms ??
          this.numberOfBedrooms,

  numberOfBathrooms:
      numberOfBathrooms ??
          this.numberOfBathrooms,

  availableFor:
      availableFor ??
          this.availableFor,

  amenitiesDesired:
      amenitiesDesired ??
          List.from(
            this.amenitiesDesired,
          ),

  // ===============================
  // BUDGET FILTERS
  // ===============================

  budgetMin:
      budgetMin ?? this.budgetMin,

  budgetMax:
      budgetMax ?? this.budgetMax,

  // ===============================
  // MATCHING FILTERS
  // ===============================

  minimumMatchPercentage:
      minimumMatchPercentage ??
          this.minimumMatchPercentage,

  verifiedOnly:
      verifiedOnly ??
          this.verifiedOnly,

  profilesWithPhotosOnly:
      profilesWithPhotosOnly ??
          this.profilesWithPhotosOnly,

  activeWithin7Days:
      activeWithin7Days ??
          this.activeWithin7Days,
);
}
}