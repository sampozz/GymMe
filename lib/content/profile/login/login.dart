import 'package:dima_project/content/profile/login/forgot_pwd.dart';
import 'package:dima_project/content/profile/login/register.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
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
    return Image.asset('assets/logo.png', width: 300, height: 300);
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            "Sign In",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Enter valid email and password to continue",
            style: TextStyle(fontSize: 16, color: Colors.black38),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email_outlined),
              prefixIconColor: Colors.black26,
              labelText: "Email address",
              hintStyle: TextStyle(color: Colors.black26),
              labelStyle: TextStyle(color: Colors.black26),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1.0),
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            validator: (value) => _validateMandatory(value),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_outline),
              prefixIconColor: Colors.black26,
              labelText: "Password",
              hintStyle: TextStyle(color: Colors.black26),
              labelStyle: TextStyle(color: Colors.black26),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1.0),
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            obscureText: true,
            validator: (value) => _validateMandatory(value),
          ),
          if (_invalidUser)
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                "Invalid email or password",
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _onForgotPressed(),
                child: Text('Forgot Password?'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(50),
                    blurRadius: 50.0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
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
                const Expanded(
                  child: Divider(color: Colors.black38, height: 50),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "Or Continue with",
                    style: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(color: Colors.black38, height: 50),
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
              child: ElevatedButton.icon(
                label: const Text("Google"),
                icon: Image.asset('assets/google.png', width: 24, height: 24),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Color.fromARGB(255, 242, 242, 242),
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
            Text("Don't have an account?"),
            TextButton(
              onPressed: () => _navigateToSignUp(),
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 1, child: _buildLoginHeader()),
          Expanded(flex: 2, child: _buildLoginForm()),
          _buildFooter(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool useMobileLayout = MediaQuery.of(context).size.width < 600;
    final screenHeight = MediaQuery.of(context).size.height;

    if (useMobileLayout) {
      return Scaffold(backgroundColor: Colors.white, body: _buildLoginScreen());
    } else {
      return Scaffold(
        body: Center(
          child: SizedBox(
            width: 500,
            height: screenHeight * 0.9,
            child: Card(elevation: 0, child: _buildLoginScreen()),
          ),
        ),
      );
    }
  }
}
