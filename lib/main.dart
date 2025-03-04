import 'package:domashni_proekt/model/issuer.dart';
import 'package:domashni_proekt/providers/auth_state_provider.dart';
import 'package:domashni_proekt/providers/issuer_data_provider.dart';
import 'package:domashni_proekt/screens/account_screen.dart';
import 'package:domashni_proekt/screens/auth/forgot_password_screen.dart';
import 'package:domashni_proekt/screens/auth/login_screen.dart';
import 'package:domashni_proekt/screens/auth/register_screen.dart';
import 'package:domashni_proekt/screens/auth/verify_email_screen.dart';
import 'package:domashni_proekt/screens/details_screen.dart';
import 'package:domashni_proekt/screens/error_screen.dart';
import 'package:domashni_proekt/screens/favorites_screen.dart';
import 'package:domashni_proekt/screens/fundamental_analysis_screen.dart';
import 'package:domashni_proekt/screens/lstm_analysis_screen.dart';
import 'package:domashni_proekt/screens/main_screen.dart';
import 'package:domashni_proekt/screens/search_screen.dart';
import 'package:domashni_proekt/screens/technical_analysis_screen.dart';
import 'package:domashni_proekt/service/auth/firebase_auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/stock_provider.dart';

void main() async {
  final authProvider = FirebaseAuthProvider();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => AuthStateProvider(authProvider)),
        ChangeNotifierProvider(create: (_) => IssuerDataProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Macedonian Stock Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/verify': (context) => const VerifyEmailScreen(),
        '/account': (context) => const AccountScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/fundamental': (context) => const FundamentalAnalysisScreen(),
        '/lstm': (context) => const LSTMAnalysisScreen(),
        '/technical': (context) => const TechnicalAnalysisScreen(),
        '/search': (context) => const SearchScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final issuer = settings.arguments as Issuer?;
          if (issuer != null) {
            return MaterialPageRoute(
              builder: (context) => DetailsScreen(issuer: issuer),
            );
          }
          return MaterialPageRoute(
            builder: (context) => ErrorScreen(
              errorMessage: "There was a problem with selecting the issuer",
              onRetry: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  ),
                );
              },
            ),
          );
        }
        return null;
      },
    );
  }
}
