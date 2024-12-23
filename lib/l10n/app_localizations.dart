import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Snake Game',
      'startGame': 'Start Game',
      'gameOver': 'Game Over!',
      // Add other translations
    },
    'es': {
      'appTitle': 'Juego de Serpiente',
      'startGame': 'Iniciar Juego',
      'gameOver': '¡Juego Terminado!',
      // Add other translations
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get startGame => _localizedValues[locale.languageCode]!['startGame']!;
  String get gameOver => _localizedValues[locale.languageCode]!['gameOver']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}