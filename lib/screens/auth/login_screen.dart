import 'package:domashni_proekt/providers/auth_state_provider.dart';
import 'package:domashni_proekt/service/auth/auth_exceptions.dart';
import 'package:domashni_proekt/widgets/auth/custom_button.dart';
import 'package:domashni_proekt/widgets/auth/custom_snackbar.dart';
import 'package:domashni_proekt/widgets/auth/custom_text_field.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    print("LoginScreen initialized");
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    print("LoginScreen disposed");
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  Future<void> _login() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        showCustomSnackBar(context, "No internet connection");
      }
      return;
    }

    if (!isValidEmail(_emailController.text.trim())) {
      if (mounted) {
        showCustomSnackBar(context, "Please enter a valid email address");
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("Attempting login...");
      final authState = context.read<AuthStateProvider>();

      await authState.logIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (authState.currentUser != null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/");
        }
      }
    } on InvalidCredentialsAuthException {
      print("InvalidCredentialsAuthException caught. Mounted: $mounted");
      if (mounted) {
        print("Context is valid. Showing SnackBar.");
        showCustomSnackBar(context, "Incorrect credentials");
      } else {
        print("Context is invalid. SnackBar cannot be shown.");
      }
    } on GenericAuthException {
      print("Generic auth exception caught");
      if (mounted) {
        showCustomSnackBar(context, "An error occurred");
      }
    } catch (e) {
      print("Unexpected error: $e");
      if (mounted) {
        showCustomSnackBar(context, "An unexpected error occurred");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, "/register");
  }

  void _navigateToForgot() {
    Navigator.pushReplacementNamed(context, "/forgot-password");
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthStateProvider>();
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please sign in to continue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade800,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Login',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _navigateToRegister,
                  child: Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
                TextButton(
                  onPressed: _navigateToForgot,
                  child: Text(
                    "Forgot your password?",
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}