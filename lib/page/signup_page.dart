import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_grid/page/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:color_grid/const/theme.dart';

import 'navigation.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late bool _passwordVisible;
  final FirebaseAuth instance = FirebaseAuth.instance;

  String _emailAddress = '';
  String _username = '';
  String _password = '';
  String? _usernameError;
  String? _passwordError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      resizeToAvoidBottomInset: false,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: NeumorphicFloatingActionButton(
          child: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          style: buttonStyle.copyWith(boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(50))),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeumorphicText(
                'Welcome!',
                textAlign: TextAlign.center,
                textStyle: NeumorphicTextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900
                ),
                style: titleTextStyle,
              ),
              const SizedBox(
                height: 40,
              ),
              Neumorphic(
                style: textFieldStyle,
                child: TextField(
                  cursorColor: Colors.black,
                  onChanged: (value) => _username = value,
                  decoration: textFieldDecoration.copyWith(
                    hintText: 'Username',
                  ),
                ),
              ),
              Visibility(
                visible: _usernameError != null,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    _usernameError ?? '',
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
                  )
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
                  _usernameError = null;
                  if (_emailAddress.isEmpty) _emailError = 'Please enter an email';
                  if (_password.isEmpty) _passwordError = 'Please enter a password';
                  if (_username.isEmpty) _usernameError = 'Please enter a username';
                  if (!(_emailError == null && _passwordError == null && _usernameError == null)) {
                    setState(() {
                    });
                    return;
                  }
                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailAddress,
                      password: _password,
                    );
                  } on FirebaseAuthException catch (e) {
                    switch (e.code) {
                      case 'weak-password':
                        _passwordError = 'The password provided is too weak.';
                        break;
                      case 'email-already-in-use':
                        _emailError = 'The account already exists for that email.';
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
                  await instance.currentUser?.updateDisplayName(_username);
                  print(instance.currentUser?.displayName);
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Navigation()), (route) => false);
                  FirebaseFirestore.instance.collection('users').doc(instance.currentUser?.uid).set({'grids': [], 'published': []});
                },
                minDistance: 1,
                style: circleButtonStyle,
                padding: const EdgeInsets.all(12.0),
                child: const Text(
                    'Sign Up'
                  // color: ,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}