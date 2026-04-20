import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'register_screen.dart';

// The login screen allows users to enter their email and password to authenticate with Firebase. It also provides a link to the registration screen for new users. Error messages are displayed if authentication fails, and a loading state is shown while the login request is in progress.
class LoginScreen extends StatefulWidget 
{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _submitting = false;
  bool _obscurePassword = true;
  String? _error;

// The dispose method is overridden to clean up the controllers and focus node when the widget is removed from the widget tree, preventing memory leaks.
  @override
  void dispose() 
  {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

// The _submit method is responsible for validating the form, sending the login request to the AuthService, and handling the response. It updates the UI to show a loading state while the request is in progress and displays any error messages if the login fails.
  Future<void> _submit() async 
  {
    // Validate the form fields before attempting to log in. If validation fails, the method returns early without making a login request.
    if (!_formKey.currentState!.validate()) 
    {
      return; // Form is not valid, do not proceed with login
    }

    setState(() 
    {
      _submitting = true;
      _error = null;
    });

// The login method of the AuthService is called with the email and password from the form. The result is an error message if the login fails, or null if it succeeds.
    final error = await AuthService.instance.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

// After the login attempt, the state is updated to reflect that the submission is no longer in progress. If there was an error, it is stored in the _error variable to be displayed in the UI. The mounted check ensures that the widget is still part of the widget tree before attempting to update the state, preventing potential errors if the user navigates away from the screen during the login process.
    if (!mounted) 
    {
      return;
    }

    // Update the state to reflect the result of the login attempt. If there was an error, it will be displayed in the UI. If the login was successful, the user will be navigated to the home screen (handled by the AuthService).
    setState(() 
    {
      _submitting = false;
      _error = error;
    });
  }

// The build method constructs the UI for the login screen, including form fields for email and password, a submit button, and a link to the registration screen. It also displays any error messages that occur during login and shows a loading indicator while the login request is being processed.
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFDCEEFD), Color(0xFFEAF3FF)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(Icons.water_drop, size: 40, color: Color(0xFF1565C0)),
                            const SizedBox(height: 8),
                            const Text(
                              'Tank Master Login',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) {
                                if (!_submitting) {
                                  _submit();
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  ),
                                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(_error!, style: const TextStyle(color: Colors.red)),
                              ),
                            FilledButton(
                              onPressed: _submitting ? null : _submit,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_submitting) ...[
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  Text(_submitting ? 'Signing In...' : 'Login'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _submitting
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => const RegisterScreen(),
                                        ),
                                      );
                                    },
                              child: const Text('Create a new account'),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Demo login: demo@tankmaster.com / demo1234',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
