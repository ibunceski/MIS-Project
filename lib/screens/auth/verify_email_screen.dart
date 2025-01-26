import 'package:domashni_proekt/providers/auth_state_provider.dart';
import 'package:domashni_proekt/widgets/auth/custom_button.dart';
import 'package:domashni_proekt/widgets/auth/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isRefreshing = false;

  Future<void> _refreshStatus() async {
    setState(() => _isRefreshing = true);

    try {
      final authStateProvider = context.read<AuthStateProvider>();
      await authStateProvider.reloadUser();

      if (authStateProvider.currentUser == null) {
        showCustomSnackBar(context, "Account no longer exists. Logging out...");
        _navigateToLogin();
        return;
      }

      if (authStateProvider.isEmailVerified) {
        showCustomSnackBar(context, "Email verified! Redirecting...");
        _navigateToHome();
      } else {
        showCustomSnackBar(context, "Email not verified yet.");
      }
    } catch (e) {
      showCustomSnackBar(context, e.toString());
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      final authStateProvider = context.read<AuthStateProvider>();
      await authStateProvider.sendEmailVerification();
      showCustomSnackBar(context, "Verification email sent!");
    } catch (e) {
      showCustomSnackBar(context, e.toString());
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Verify Email",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                "Verify Your Email",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "A verification email has been sent to your email address. Please check your inbox (and spam folder) to verify your email.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: "Resend Verification Email",
                onPressed: _resendVerificationEmail,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Refresh Status",
                onPressed: _refreshStatus,
                isLoading: _isRefreshing,
                backgroundColor: Colors.grey[300],
                textColor: Colors.black,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}