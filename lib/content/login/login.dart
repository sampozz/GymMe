import 'package:gymme/content/login/forgot_pwd.dart';
import 'package:gymme/content/login/register.dart';
import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _invalidUser = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  void _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    User? res = await Provider.of<UserProvider>(
      context,
      listen: false,
    ).signIn(_emailController.text, _passwordController.text);

    if (res == null) {
      setState(() {
        _isLoading = false;
        _invalidUser = true;
      });
    } else {
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    final res = await context.read<UserProvider>().signInWithGoogle();

    if (res == null) {
      setState(() {
        _isGoogleLoading = false;
      });
    } else {
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const Register(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _onForgotPressed() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const ForgotPwd(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  String? _validateMandatory(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  Widget _buildLoginHeader() {
    // check if the theme is dark or light
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return isDarkTheme
        ? Image.asset('assets/logo_dark.png', width: 250, height: 160)
        : Image.asset('assets/logo_light.png', width: 250, height: 160);
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            "Sign In",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Enter valid email and password to continue",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email_outlined),
              prefixIconColor: Theme.of(context).colorScheme.outline,
              labelText: "Email address",
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            validator: (value) => _validateMandatory(value),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _signIn(),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline),
              prefixIconColor: Theme.of(context).colorScheme.outline,
              labelText: "Password",
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            obscureText: true,
            validator: (value) => _validateMandatory(value),
          ),
          if (_invalidUser)
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                "Invalid email or password",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Theme.of(context).colorScheme.tertiary,
                ),
                onPressed: () => _onForgotPressed(),
                child: Text('Forgot Password?'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                style: TextButton.styleFrom(
                  elevation: 0,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onPressed: () => _signIn(),
                child: const Text("Login"),
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: 250,
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Theme.of(context).colorScheme.outline,
                    height: 50,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "Or Continue with",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Theme.of(context).colorScheme.outline,
                    height: 50,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (_isGoogleLoading)
            const CircularProgressIndicator()
          else
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton.icon(
                label: const Text("Google"),
                icon: Image.asset('assets/google.png', width: 24, height: 24),
                style: TextButton.styleFrom(
                  elevation: 0,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  backgroundColor: Theme.of(context).colorScheme.surfaceDim,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onPressed: () => _signInWithGoogle(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.tertiary,
              ),
              onPressed: () => _navigateToSignUp(),
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginScreenContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Column(children: [_buildLoginHeader(), _buildLoginForm()]),
      ),
    );
  }

  Widget _buildLoginScreen() {
    return Column(
      children: [Expanded(child: _buildLoginScreenContent()), _buildFooter()],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool useMobileLayout = MediaQuery.of(context).size.width < 600;
    final screenHeight = MediaQuery.of(context).size.height;

    if (useMobileLayout) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        body: _buildLoginScreen(),
      );
    } else {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        body: Center(
          child: SizedBox(
            width: 500,
            height: screenHeight * 0.9,
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              child: _buildLoginScreen(),
            ),
          ),
        ),
      );
    }
  }
}
