import 'package:flutter/material.dart';
import '../l10n/gen_l10n/place_picker_localizations.dart';

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
  factory LocalizationItem.of(BuildContext context) {
    var localizations = PlacePickerLocalization.of(context);
    if (localizations == null) return LocalizationItem();
    return LocalizationItem(
      languageCode: localizations.languageCode,
      nearBy: localizations.nearBy,
      findingPlace: localizations.findingPlace,
      noResultsFound: localizations.noResultsFound,
      unnamedLocation: localizations.unnamedLocation,
      tapToSelectLocation: localizations.tapToSelectLocation,
      searchHint: localizations.searchHint,
    );
  }
}
