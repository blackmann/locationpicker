class LocalizationItem {
  String languageCode;
  String nearBy;
  String findingPlace;
  String noResultsFound;
  String unnamedLocation;
  String tapToSelectLocation;
  String searchHint;

  LocalizationItem({
    this.languageCode = 'en_us',
    this.nearBy = 'Nearby Places',
    this.findingPlace = 'Finding place...',
    this.noResultsFound = 'No results found',
    this.unnamedLocation = 'Unnamed location',
    this.tapToSelectLocation = 'Tap to select this location',
    this.searchHint = 'Search place',
  });
}
