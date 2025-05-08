import 'package:dima_project/content/profile/login/login.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  void _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? res = await context.read<UserProvider>().signUp(
      _emailController.text,
      _passwordController.text,
      _fullNameController.text,
    );

    if (res == null) {
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _errorMessage = res;
        _isLoading = false;
      });
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const Login(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
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
    return Image.asset('assets/logo.png', width: 300, height: 220);
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Enter your information to continue",
            style: TextStyle(fontSize: 16, color: Colors.black38),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _fullNameController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person_2_outlined),
              prefixIconColor: Colors.black26,
              labelText: "Full name",
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
          const SizedBox(height: 20),
          Text(
            'By signing up, you agree to our Terms of Service and Privacy Policy',
            style: TextStyle(color: Colors.black38),
          ),
          const SizedBox(height: 20),
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
                onPressed: () => _signUp(),
                child: const Text("Create Account"),
              ),
            ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 14),
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
            Text("Already have an Account?"),
            OutlinedButton(
              onPressed: () => _navigateToLogin(),
              child: const Text("Sign In"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterScreenContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(children: [_buildLoginHeader(), _buildLoginForm()]),
      ),
    );
  }

  Widget _buildLoginScreen() {
    return Column(
      children: [
        Expanded(child: _buildRegisterScreenContent()),
        _buildFooter(),
      ],
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
