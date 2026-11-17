import 'package:material_ui/material_ui.dart';

import 'screens/dashboard/dashboard_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/storage_service.dart';

const primary = Color(0xFF16856B);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.initialize();
  runApp(NabungInApp(storage: storage));
}

class NabungInApp extends StatefulWidget {
  const NabungInApp({required this.storage, super.key});

  final StorageService storage;

  @override
  State<NabungInApp> createState() => _NabungInAppState();
}

class _NabungInAppState extends State<NabungInApp> {
  bool? _hasCompletedOnboarding;

  @override
  void initState() {
    super.initState();
    _hasCompletedOnboarding = widget.storage.hasCompletedOnboarding;
  }

  Future<bool> _completeOnboarding() async {
    final saved = await widget.storage.completeOnboarding();
    if (saved && mounted) setState(() => _hasCompletedOnboarding = true);
    return saved;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: Colors.white,
    );
    return MaterialApp(
      title: 'Nabung.in',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        useMaterial3: true,
        fontFamily: 'sans',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F8F7),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF17211E),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Color(0xFF17211E),
            fontWeight: FontWeight.w800,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF17211E),
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF17211E),
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(color: Color(0xFF687570)),
          bodyMedium: TextStyle(color: Color(0xFF687570)),
          bodySmall: TextStyle(color: Color(0xFF687570)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF6F8F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE4EAE7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE4EAE7)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: _hasCompletedOnboarding == null
          ? const _StartupScreen()
          : _hasCompletedOnboarding!
          ? DashboardScreen(storage: widget.storage)
          : OnboardingScreen(onComplete: _completeOnboarding),
    );
  }
}

// Kept as a compatibility alias for integrations that previously referenced MyApp.
class MyApp extends NabungInApp {
  const MyApp({required super.storage, super.key});
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
