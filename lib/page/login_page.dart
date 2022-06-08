import 'package:color_grid/const/theme.dart';
import 'package:color_grid/page/home.dart';
import 'package:color_grid/page/navigation.dart';
import 'package:color_grid/page/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _passwordVisible;
  final FirebaseAuth instance = FirebaseAuth.instance;

  String _emailAddress = '';
  String _password = '';
  String? _passwordError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeumorphicText(
                'Color Grid',
                textAlign: TextAlign.center,
                textStyle: NeumorphicTextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.w900
                ),
                style: titleTextStyle,
              ),
              const SizedBox(
                height: 20,
              ),
              // Image.asset('grid.png'),
              const SizedBox(
                height: 20,
              ),
              Neumorphic(
                style: textFieldStyle,
                child: TextField(
                  cursorColor: Colors.black,
                  onChanged: (value) => _emailAddress = value,
                  decoration: textFieldDecoration.copyWith(
                    hintText: 'Email',
                  ),
                ),
              ),
              Visibility(
                visible: _emailError != null,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    _emailError ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Neumorphic(
                style: textFieldStyle,
                child: TextField(
                  cursorColor: Colors.black,
                  onChanged: (value) => _password = value,
                  obscureText: !_passwordVisible,
                  decoration: textFieldDecoration.copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_outlined,
                        color: Colors.black,
                        // size: 1,
                      ),
                      onPressed: () {
                        _passwordVisible = !_passwordVisible;
                        setState(() {});
                      },
                    ),
                    hintText: 'Password',
                    contentPadding: const EdgeInsets.only(left: 10, top: 15),
                  ),
                ),
              ),
              Visibility(
                visible: _passwordError != null,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    _passwordError ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              NeumorphicButton(
                onPressed: () async {
                  _emailError = null;
                  _passwordError = null;
                  if (_emailAddress.isEmpty) _emailError = 'Please enter an email';
                  if (_password.isEmpty) _passwordError = 'Please enter a password';
                  if (!(_emailError == null && _passwordError == null)) {
                    setState(() {
                    });
                    return;
                  }
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailAddress,
                      password: _password,
                    );
                  } on FirebaseAuthException catch (e) {
                    print (e.code);
                    switch (e.code) {
                      case 'wrong-password':
                        _passwordError = 'Incorrect password';
                        break;
                      case 'user-not-found':
                        _emailError = 'This email does not exist.';
                        break;
                      case 'invalid-email':
                        _emailError = 'This email is invalid';
                        break;
                    }
                    setState(() {});
                    return;
                  } catch (e) {
                    print(e);
                    return;
                  }
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Navigation()));
                },
                minDistance: 1,
                style: buttonStyle,
                padding: const EdgeInsets.all(12.0),
                child: const Text(
                    'Log In'
                  // color: ,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 15),
                  children: <TextSpan>[
                    TextSpan(text: 'Don\'t have an account? ', style: defaultTextStyle),
                    TextSpan(
                        text: 'Sign Up',
                        style: linkTextStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (c, a1, a2) => const SignupPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                final tween = Tween(begin: begin, end: end);
                                final offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 250),
                              reverseTransitionDuration: const Duration(milliseconds: 150),
                            ),);
                          }),
                    const TextSpan(text: '\n'),
                    TextSpan(
                        text: 'Forgot Password',
                        style: linkTextStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print('Forgot Password');
                          }),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
