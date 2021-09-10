


import 'place_picker_localizations.dart';

/// The translations for English (`en`).
class PlacePickerLocalizationEn extends PlacePickerLocalization {
  PlacePickerLocalizationEn([String locale = 'en']) : super(locale);

  @override
  String get nearBy => 'Nearby Places';

  @override
  String get findingPlace => 'Finding place...';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get unnamedLocation => 'Unnamed location';

  @override
  String get tapToSelectLocation => 'Tap to select this location';

  @override
  String get searchHint => 'Search place';

  @override
  String get languageCode => 'en';
}

/// The translations for English, as used in the United States (`en_US`).
class PlacePickerLocalizationEnUs extends PlacePickerLocalizationEn {
  PlacePickerLocalizationEnUs(): super('en_US');

  @override
  String get nearBy => 'Nearby Places';

  @override
  String get findingPlace => 'Finding place...';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get unnamedLocation => 'Unnamed location';

  @override
  String get tapToSelectLocation => 'Tap to select this location';

  @override
  String get searchHint => 'Search place';

  @override
  String get languageCode => 'en_us';
}
