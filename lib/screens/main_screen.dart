import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_state_provider.dart';
import 'auth/login_screen.dart';
import 'search_screen.dart';
import 'auth/verify_email_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthStateProvider>();

    if (authState.isLoading) {
      return _buildLoadingScreen();
    }

    if (authState.currentUser == null) {
      return const LoginScreen();
    }

    if (!authState.currentUser!.isEmailVerified) {
      _sendEmailVerification(context);
      return const VerifyEmailScreen();
    }

    return const SearchScreen();
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _sendEmailVerification(BuildContext context) {
    final authStateProvider = context.read<AuthStateProvider>();
    authStateProvider.sendEmailVerification();
  }
}