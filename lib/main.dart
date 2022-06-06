
import 'package:color_grid/const/color.dart';
import 'package:color_grid/page/dashboard.dart';
import 'package:color_grid/page/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  final FirebaseAuth instance = FirebaseAuth.instance;

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: [SystemUiOverlay.top]);
    if (instance.currentUser == null) {
      return MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: backgroundColor),
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      );
    }
    else {
      return MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: backgroundColor),
        debugShowCheckedModeBanner: false,
        home: const Dashboard(),
      );
    }
  }
}