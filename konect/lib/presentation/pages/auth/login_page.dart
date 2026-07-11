import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../core/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).copyWith(
      primaryColor: const Color(0xFFDC2626), // brandRed
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: const Color(0xFFDC2626), // brandRed on focus
        onSurface: const Color(0xFF000000), // text color/icon color
        onSurfaceVariant: const Color(0xFF000000), // label/hint color before focus
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: Color(0xFF000000)),
        floatingLabelStyle: const TextStyle(color: Color(0xFFDC2626)),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return const Color(0xFFDC2626);
          }
          return const Color(0xFF000000);
        }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );

    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: Color(0xFFFFFFFF), width: 1.5),
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFF000000), // Black background when unfocused
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: const TextStyle(color: Color(0xFFFFFFFF)), // White label when unfocused
      floatingLabelStyle: const TextStyle(color: Color(0xFFDC2626)),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return const Color(0xFFDC2626);
        }
        return const Color(0xFFFFFFFF); // White icon when unfocused
      }),
      border: borderStyle,
      enabledBorder: borderStyle,
      focusedBorder: borderStyle.copyWith(
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
      ),
      errorBorder: borderStyle.copyWith(
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: borderStyle.copyWith(
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to home
            Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Theme(
                data: customTheme,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Title
                      Icon(
                        Icons.people_alt,
                        size: 80,
                        color: const Color(0xFFDC2626),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: const Color(0xFF000000),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        AppConstants.appTagline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFFFFFFFF)),
                        decoration: inputDecoration.copyWith(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Color(0xFFFFFFFF)),
                        decoration: inputDecoration.copyWith(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                    // Login Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _onLogin,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Masuk'),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Register Link
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to register
                      },
                      child: const Text('Belum punya akun? Daftar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }
}
