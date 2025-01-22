import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_state_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isRefreshing = false;

  Future<void> _refreshStatus() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final authStateProvider =
          Provider.of<AuthStateProvider>(context, listen: false);
      await authStateProvider.reloadUser();

      if (authStateProvider.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Account no longer exists. Logging out...")),
        );

        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      if (authStateProvider.isEmailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email verified! Redirecting...")),
        );

        Navigator.of(context).pushReplacementNamed('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email not verified yet.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "A verification email has been sent to your email address. Please check your inbox (and spam folder) to verify your email.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final authStateProvider =
                      Provider.of<AuthStateProvider>(context, listen: false);
                  await authStateProvider.sendEmailVerification();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Verification email sent!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text("Resend Verification Email"),
            ),
            const SizedBox(height: 20),
            _isRefreshing
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _refreshStatus,
                    child: const Text("Refresh Status"),
                  ),
          ],
        ),
      ),
    );
  }
}
