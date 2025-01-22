import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_state_provider.dart';
import 'login_screen.dart';
import 'search_screen.dart';
import 'verify_email_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthStateProvider>(context);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.currentUser == null) {
      return const LoginScreen();
    }

    if (!authState.currentUser!.isEmailVerified) {
      final authStateProvider =
          Provider.of<AuthStateProvider>(context, listen: false);
      authStateProvider.sendEmailVerification();
      return const VerifyEmailScreen();
    }

    return const SearchScreen();
  }
}
