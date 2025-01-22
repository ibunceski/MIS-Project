import 'package:domashni_proekt/providers/auth_state_provider.dart';
import 'package:domashni_proekt/providers/issuer_data_provider.dart';
import 'package:domashni_proekt/screens/main_screen.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
