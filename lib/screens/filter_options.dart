// lib/screens/matching_screen.dart (or a separate filter_options.dart file)

class FilterOptions {
  // Location & Price Filters
  String? desiredCity;
  String? areaPreference; // NEW: For area preference
  DateTime? moveInDate; // NEW: For seeker's move-in date
  DateTime? availabilityDate; // NEW: For listing's availability date

  // Common filters (for age, gender that apply to the *other* user)
  int? ageMin;
  int? ageMax;
  String? gender; // Gender of the *other* user you are looking for

  // FlatListing specific filters (when a seeker is searching for a flat)
  int? rentPriceMin;
  int? rentPriceMax;
  String? flatType;
  String? furnishedStatus;
  int? numberOfBedrooms; // NEW: Number of bedrooms
  int? numberOfBathrooms; // NEW: Number of bathrooms
  List<String> amenitiesDesired;
  String? availableFor; // NEW: Who the flat is available for (male, female, couple, family)
String? placeId;

double? latitude;
double? longitude;

double searchRadiusKm = 10;

bool sortByNearest = true;

int? minimumMatchPercentage;

bool verifiedOnly = false;

bool profilesWithPhotosOnly = false;

bool activeWithin7Days = false;
  // SeekingFlatmate specific filters (when a lister is searching for a flatmate)
  int? budgetMin;
  int? budgetMax;

  // Lifestyle & Habit Filters (for mutual compatibility)
  // These are more granular and can be selected by the user in the filter screen
  // And then applied to the habits/preferences of the *other* profile.
  String? cleanlinessLevel; // NEW: e.g., 'Very Clean', 'Moderately Clean'
  String? socialHabits; // NEW: e.g., 'Very Social', 'Introvert'
  // String? noiseLevel; // NEW: e.g., 'Quiet', 'Moderate'
  String? smokingHabit; // NEW: e.g., 'Non-Smoker', 'Social Smoker'
  String? drinkingHabit; // NEW: e.g., 'Non-Drinker', 'Social Drinker'
  String? foodPreference; // NEW: e.g., 'Vegetarian', 'Non-Vegetarian'
  String? petOwnership; // NEW: e.g., 'Has Pets', 'No Pets'
  String? petTolerance; // NEW: e.g., 'Pet-Friendly', 'Not Pet-Friendly'
  // String? workSchedule; // NEW: e.g., '9-5', 'Flexible'
  // String? sleepingSchedule; // NEW: e.g., 'Early Riser', 'Night Owl'
  // String? visitorsPolicy; // NEW: e.g., 'Guests Welcome', 'Occasional Guests'
  // String? guestsOvernightPolicy; // NEW: e.g., 'Allowed', 'Not Allowed'
  String? occupation; // NEW: for matching occupation directly

  // Keep these generic lists for other preferences if needed, but for direct Firestore queries,
  // granular fields are often easier to manage.
  List<String> selectedIdealQualities;
  List<String> selectedDealBreakers;

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

  this.furnishedStatus,

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
  // LIFESTYLE FILTERS
  // ===============================

  this.cleanlinessLevel,

  this.socialHabits,

  this.smokingHabit,

  this.drinkingHabit,

  this.foodPreference,

  this.petOwnership,

  this.petTolerance,

  // ===============================
  // COMPATIBILITY FILTERS
  // ===============================

  this.minimumMatchPercentage,

  this.verifiedOnly = false,

  this.profilesWithPhotosOnly = false,

  this.activeWithin7Days = false,

  List<String>? selectedIdealQualities,

  List<String>? selectedDealBreakers,
})  : amenitiesDesired = amenitiesDesired ?? [],
      selectedIdealQualities =
          selectedIdealQualities ?? [],
      selectedDealBreakers =
          selectedDealBreakers ?? [];
  bool hasFilters() {
  return

      // Location
      desiredCity != null ||
      areaPreference != null ||
      placeId != null ||
      latitude != null ||
      longitude != null ||
      searchRadiusKm != 10 ||
      !sortByNearest ||

      // Dates
      moveInDate != null ||
      availabilityDate != null ||

      // Basic
      ageMin != null ||
      ageMax != null ||
      gender != null ||
      occupation != null ||

      // Flat
      rentPriceMin != null ||
      rentPriceMax != null ||
      flatType != null ||
      furnishedStatus != null ||
      numberOfBedrooms != null ||
      numberOfBathrooms != null ||
      availableFor != null ||
      amenitiesDesired.isNotEmpty ||

      // Budget
      budgetMin != null ||
      budgetMax != null ||

      // Lifestyle
      cleanlinessLevel != null ||
      socialHabits != null ||
      smokingHabit != null ||
      drinkingHabit != null ||
      foodPreference != null ||
      petOwnership != null ||
      petTolerance != null ||

      // Compatibility
      minimumMatchPercentage != null ||
      verifiedOnly ||
      profilesWithPhotosOnly ||
      activeWithin7Days ||
      selectedIdealQualities.isNotEmpty ||
      selectedDealBreakers.isNotEmpty;
}

  void clear() {

  // Location
  desiredCity = null;
  areaPreference = null;

  placeId = null;

  latitude = null;
  longitude = null;

  searchRadiusKm = 10;

  sortByNearest = true;

  // Dates
  moveInDate = null;
  availabilityDate = null;

  // Basic
  ageMin = null;
  ageMax = null;

  gender = null;
  occupation = null;

  // Flat
  rentPriceMin = null;
  rentPriceMax = null;

  flatType = null;
  furnishedStatus = null;

  numberOfBedrooms = null;
  numberOfBathrooms = null;

  availableFor = null;

  amenitiesDesired.clear();

  // Budget
  budgetMin = null;
  budgetMax = null;

  // Lifestyle
  cleanlinessLevel = null;
  socialHabits = null;

  smokingHabit = null;
  drinkingHabit = null;

  foodPreference = null;

  petOwnership = null;
  petTolerance = null;

  // Compatibility
  minimumMatchPercentage = null;

  verifiedOnly = false;

  profilesWithPhotosOnly = false;

  activeWithin7Days = false;

  selectedIdealQualities.clear();
  selectedDealBreakers.clear();
}

  FilterOptions copyWith({
  // Location
  String? desiredCity,
  String? areaPreference,
  String? placeId,

  double? latitude,
  double? longitude,

  double? searchRadiusKm,

  bool? sortByNearest,

  // Dates
  DateTime? moveInDate,
  DateTime? availabilityDate,

  // Basic
  int? ageMin,
  int? ageMax,
  String? gender,
  String? occupation,

  // Flat Filters
  int? rentPriceMin,
  int? rentPriceMax,

  String? flatType,
  String? furnishedStatus,

  int? numberOfBedrooms,
  int? numberOfBathrooms,

  String? availableFor,

  List<String>? amenitiesDesired,

  // Budget
  int? budgetMin,
  int? budgetMax,

  // Lifestyle
  String? cleanlinessLevel,
  String? socialHabits,

  String? smokingHabit,
  String? drinkingHabit,

  String? foodPreference,

  String? petOwnership,
  String? petTolerance,

  // Compatibility
  int? minimumMatchPercentage,

  bool? verifiedOnly,
  bool? profilesWithPhotosOnly,
  bool? activeWithin7Days,

  List<String>? selectedIdealQualities,
  List<String>? selectedDealBreakers,
}) {
  return FilterOptions(

    // Location
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

    // Dates
    moveInDate:
        moveInDate ?? this.moveInDate,

    availabilityDate:
        availabilityDate ??
            this.availabilityDate,

    // Basic
    ageMin:
        ageMin ?? this.ageMin,

    ageMax:
        ageMax ?? this.ageMax,

    gender:
        gender ?? this.gender,

    occupation:
        occupation ?? this.occupation,

    // Flat Filters
    rentPriceMin:
        rentPriceMin ??
            this.rentPriceMin,

    rentPriceMax:
        rentPriceMax ??
            this.rentPriceMax,

    flatType:
        flatType ?? this.flatType,

    furnishedStatus:
        furnishedStatus ??
            this.furnishedStatus,

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

    // Budget
    budgetMin:
        budgetMin ?? this.budgetMin,

    budgetMax:
        budgetMax ?? this.budgetMax,

    // Lifestyle
    cleanlinessLevel:
        cleanlinessLevel ??
            this.cleanlinessLevel,

    socialHabits:
        socialHabits ??
            this.socialHabits,

    smokingHabit:
        smokingHabit ??
            this.smokingHabit,

    drinkingHabit:
        drinkingHabit ??
            this.drinkingHabit,

    foodPreference:
        foodPreference ??
            this.foodPreference,

    petOwnership:
        petOwnership ??
            this.petOwnership,

    petTolerance:
        petTolerance ??
            this.petTolerance,

    // Compatibility
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

    selectedIdealQualities:
        selectedIdealQualities ??
            List.from(
              this.selectedIdealQualities,
            ),

    selectedDealBreakers:
        selectedDealBreakers ??
            List.from(
              this.selectedDealBreakers,
            ),
  );
}
}