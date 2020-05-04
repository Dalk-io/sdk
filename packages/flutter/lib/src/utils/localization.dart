import 'package:flutter/material.dart';

class _DalkLocalization extends DalkLocalization {
  _DalkLocalization();

  @override
  String get anErrorOccurred => 'An error as occurred';

  @override
  String get retryButton => 'Retry';
}

abstract class DalkLocalization {
  static Future<DalkLocalization> load(Locale locale) {
    return Future.value(_DalkLocalization());
  }

  static DalkLocalization of(BuildContext context) => Localizations.of<DalkLocalization>(context, DalkLocalization);

  DalkLocalization();

  String get anErrorOccurred;

  String get retryButton;
}

class DalkLocalizationDelegate extends LocalizationsDelegate {
  final List<Locale> supportedLocales;

  DalkLocalizationDelegate({this.supportedLocales = const [Locale('en')]});

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.firstWhere((l) => locale.languageCode == l.languageCode, orElse: () => null) != null;
  }

  @override
  Future<DalkLocalization> load(Locale locale) {
    return DalkLocalization.load(locale);
  }

  @override
  bool shouldReload(DalkLocalizationDelegate old) {
    return false;
  }
}
