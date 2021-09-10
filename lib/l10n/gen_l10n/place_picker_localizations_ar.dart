


import 'place_picker_localizations.dart';

/// The translations for Arabic (`ar`).
class PlacePickerLocalizationAr extends PlacePickerLocalization {
  PlacePickerLocalizationAr([String locale = 'ar']) : super(locale);

  @override
  String get nearBy => 'الأماكن القريبة';

  @override
  String get findingPlace => 'البحث عن المكان...';

  @override
  String get noResultsFound => 'لا يوجد نتائج';

  @override
  String get unnamedLocation => 'مكان غير معروف';

  @override
  String get tapToSelectLocation => 'إضغط لاختيار هذا المكان';

  @override
  String get searchHint => 'عن ماذا تبحث';

  @override
  String get languageCode => 'ar';
}
