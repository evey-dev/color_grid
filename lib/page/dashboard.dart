import 'package:color_grid/const/color.dart';
import 'package:color_grid/const/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseAuth instance = FirebaseAuth.instance;



  @override
  Widget build(BuildContext context) {
    // print(instance.currentUser);
    String username = instance.currentUser?.displayName ?? '';
    return NeumorphicTheme(
      themeMode: ThemeMode.light,
      theme: const NeumorphicThemeData(
        appBarTheme: NeumorphicAppBarThemeData(
          buttonStyle: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
          textStyle: TextStyle(color: Colors.black54),
          iconTheme: IconThemeData(color: Colors.black54, size: 30),
        ),
        depth: 4,
        intensity: 1,
      ),
      child: MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: backgroundColor),
        //0xFFDCDCDC
        home: Scaffold(
          appBar: NeumorphicAppBar(
            color: backgroundColor,
            title: Text(username),
            actions: <Widget>[
              NeumorphicButton(
                minDistance: 1,
                style: circleButtonStyle,
                child: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView(
            children: const [

            ],
          ),
        ),
      ),
    );
    // return MaterialApp(
    //   theme: ThemeData(scaffoldBackgroundColor: background),
    //   //0xFFDCDCDC
    //   home: Scaffold(
    //     appBar: NeumorphicAppBar(
    //       title: Text("App bar"),
    //       actions: <Widget>[
    //         NeumorphicButton(
    //           child: Icon(Icons.add),
    //           onPressed: () {},
    //         ),
    //       ],
    //     ),
    //     body: Container()
    //   ),
    // );
  }
}
