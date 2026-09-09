import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/sensor_provider.dart';
import 'providers/gallery_provider.dart';
import 'providers/chat_provider.dart';
import 'services/api_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_shell.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const VerdaticaApp());
}

class VerdaticaApp extends StatefulWidget {
  const VerdaticaApp({super.key});

  @override
  State<VerdaticaApp> createState() => _VerdaticaAppState();
}

class _VerdaticaAppState extends State<VerdaticaApp> {
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    // Set up global 401 auto-logout handler
    ApiService.onUnauthorized = () {
      _authProvider.logout();
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<SensorProvider>(create: (_) => SensorProvider()),
        ChangeNotifierProvider<GalleryProvider>(create: (_) => GalleryProvider()),
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Verdatica',
        debugShowCheckedModeBanner: false,
        theme: VerdaticaTheme.theme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainShell(),
        },
      ),
    );
  }
}
