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
//import 'services/import_scenarios.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.registerAdapter(ScenarioAdapter());

  await Hive.openBox<Scenario>('scenarios');

  //await importScenariosToHive();

  // Load theme preference before running app
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final themeProvider = ThemeProvider();
            themeProvider.setTheme(isDarkMode);
            return themeProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final languageProvider = Provider.of<LanguageProvider>(context);
        final themeProvider = Provider.of<ThemeProvider>(context);

        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const SplashScreen(),
            ),
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
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

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
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
            scaffoldBackgroundColor: const Color(
              0xFF121212,
            ), // Dark gray, not pitch black
            colorScheme: ColorScheme.dark(
              surface: const Color(0xFF121212),
              primary: Colors.green,
              secondary: Colors.orange,
            ),
            cardColor: const Color(0xFF1E1E1E), // Slightly lighter cards
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white70), // Softer white text
              bodyMedium: TextStyle(color: Colors.white70),
            ),
            highlightColor: Colors.orange.withAlpha(
              77,
            ), // ~30% opacity (255 * 0.3 = 76.5)
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
