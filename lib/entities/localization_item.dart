class LocalizationItem {
  final String languageCode;
  final String nearBy;
  final String findingPlace;
  final String noResultsFound;
  final String unnamedLocation;
  final String tapToSelectLocation;
  final String searchHint;

  const LocalizationItem({
    this.languageCode = 'en_us',
    this.nearBy = 'Nearby Places',
    this.findingPlace = 'Finding place...',
    this.noResultsFound = 'No results found',
    this.unnamedLocation = 'Unnamed location',
    this.tapToSelectLocation = 'Tap to select this location',
    this.searchHint = "Search place",
  });
}
