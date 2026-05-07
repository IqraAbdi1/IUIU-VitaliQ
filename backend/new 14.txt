import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/scenario.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/category_detail_screen.dart';
import 'screens/scenario_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
// import 'services/import_scenarios.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter(ScenarioAdapter());

  await Hive.openBox<Scenario>('scenarios');
  // await importScenariosToHive();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..setTheme(isDarkMode),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// --------------------
// Router declared outside widget to avoid rebuilds
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) {
        final categoryId = state.pathParameters['id']!;
        return CategoryDetailScreen(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/scenario/:id',
      builder: (context, state) {
        final scenarioId = state.pathParameters['id']!;
        return ScenarioDetailScreen(scenarioId: scenarioId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          title: 'Aweytak',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            fontFamily: 'Cairo',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
            fontFamily: 'Cairo',
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.dark(
              surface: const Color(0xFF121212),
              primary: Colors.green,
              secondary: Colors.orange,
            ),
            cardColor: const Color(0xFF1E1E1E),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white70),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
            highlightColor: Colors.orange.withAlpha(77),
          ),
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          locale: Locale(languageProvider.language.toLowerCase()),
          builder: (context, child) {
            return Directionality(
              textDirection: languageProvider.isArabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            );
          },
        );
      },
    );
  }
}
