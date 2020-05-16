import 'package:flutter/material.dart';

/// English Dalk translations
class EnDalkLocalization extends DalkLocalization {
  EnDalkLocalization();

  @override
  String get anErrorOccurred => 'An error as occurred';

  @override
  String get retryButton => 'Retry';
}

/// Abstract class to manage translation under the SDK
/// {@tool snippet}
///
/// For example to provide a translation for French :
///
/// ```dart
/// class FrDalkLocalization extends DalkLocalization {
///   FrDalkLocalization();
///
///   @override
///   String get anErrorOccurred => 'Une erreur est survenue';
///
///   @override
///   String get retryButton => 'Ré essayer';
/// }
/// ```
/// {@end-tool}
///
/// See also:
/// [DalkLocalizationDelegate] to setup localization for Dalk
abstract class DalkLocalization {
  static DalkLocalization of(BuildContext context) =>
      Localizations.of<DalkLocalization>(context, DalkLocalization);

  const DalkLocalization();

  String get anErrorOccurred;

  String get retryButton;
}

final LoadLocalization _loadLocale = (_) {
  return Future.value(EnDalkLocalization());
};

/// Callback to load a localization from a locale
typedef LoadLocalization = Future<DalkLocalization> Function(Locale locale);

/// Localization delegate manage Dalk translations
///
/// Default usage:
///
/// MaterialApp(
///    title: 'Dalk.io demo',
///    theme: ThemeData(
///       primarySwatch: Colors.green,
///    ),
///    localizationsDelegates: [DalkLocalizationDelegate()],
///)
///
/// See also:
/// [LoadLocalization] signature to load localization
/// [DalkLocalization] abstract class to extends supported language
class DalkLocalizationDelegate extends LocalizationsDelegate {
  final List<Locale> supportedLocales;
  final LoadLocalization loadLocalization;

  /// Create new [DalkLocalizationDelegate] to provide translations to Dalk UI components
  ///
  /// [supportedLocales] supported locale for Dalk UI component, optional, default to Locale('en')
  ///
  /// [loadLocalization] callback to load the localization, optional, useful if you have custom language support
  ///
  /// See also:
  /// [LoadLocalization] signature to load localization
  /// [DalkLocalization] abstract class to extends supported language
  DalkLocalizationDelegate(
      {LoadLocalization loadLocalization,
      this.supportedLocales = const [Locale('en')]})
      : loadLocalization = loadLocalization ?? _loadLocale;

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.firstWhere(
            (l) => locale.languageCode == l.languageCode,
            orElse: () => null) !=
        null;
  }

  @override
  Future<DalkLocalization> load(Locale locale) {
    return loadLocalization(locale);
  }

  @override
  bool shouldReload(DalkLocalizationDelegate old) {
    return false;
  }
}
