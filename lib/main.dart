import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/menu_screen.dart';
import 'services/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await DatabaseHelper.instance.database;
  
  final prefs = await SharedPreferences.getInstance();
  final String languageCode = prefs.getString('languageCode') ?? 'en';
  
  runApp(MyApp(initialLocale: Locale(languageCode)));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  
  const MyApp({super.key, required this.initialLocale});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _currentLocale;

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.initialLocale;
  }

  void updateLocale(Locale newLocale) {
    setState(() => _currentLocale = newLocale);
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setString('languageCode', newLocale.languageCode)
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: MenuScreen(onLocaleChange: updateLocale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('en'),
        Locale('si'),
        Locale('ta'),
      ],
      locale: _currentLocale,
    );
  }
}