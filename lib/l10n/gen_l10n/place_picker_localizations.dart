
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'place_picker_localizations_ar.dart';
import 'place_picker_localizations_en.dart';

/// Callers can lookup localized strings with an instance of PlacePickerLocalization returned
/// by `PlacePickerLocalization.of(context)`.
///
/// Applications need to include `PlacePickerLocalization.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'gen_l10n/place_picker_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: PlacePickerLocalization.localizationsDelegates,
///   supportedLocales: PlacePickerLocalization.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the PlacePickerLocalization.supportedLocales
/// property.
abstract class PlacePickerLocalization {
  PlacePickerLocalization(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static PlacePickerLocalization? of(BuildContext context) {
    return Localizations.of<PlacePickerLocalization>(context, PlacePickerLocalization);
  }

  static const LocalizationsDelegate<PlacePickerLocalization> delegate = _PlacePickerLocalizationDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('en', 'US')
  ];

  /// No description provided for @nearBy.
  ///
  /// In en, this message translates to:
  /// **'Nearby Places'**
  String get nearBy;

  /// No description provided for @findingPlace.
  ///
  /// In en, this message translates to:
  /// **'Finding place...'**
  String get findingPlace;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @unnamedLocation.
  ///
  /// In en, this message translates to:
  /// **'Unnamed location'**
  String get unnamedLocation;

  /// No description provided for @tapToSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap to select this location'**
  String get tapToSelectLocation;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search place'**
  String get searchHint;

  /// No description provided for @languageCode.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get languageCode;
}

class _PlacePickerLocalizationDelegate extends LocalizationsDelegate<PlacePickerLocalization> {
  const _PlacePickerLocalizationDelegate();

  @override
  Future<PlacePickerLocalization> load(Locale locale) {
    return SynchronousFuture<PlacePickerLocalization>(lookupPlacePickerLocalization(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_PlacePickerLocalizationDelegate old) => false;
}

PlacePickerLocalization lookupPlacePickerLocalization(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en': {
  switch (locale.countryCode) {
    case 'US': return PlacePickerLocalizationEnUs();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return PlacePickerLocalizationAr();
    case 'en': return PlacePickerLocalizationEn();
  }

  throw FlutterError(
    'PlacePickerLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
