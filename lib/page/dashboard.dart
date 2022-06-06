import 'package:color_grid/const/color.dart';
import 'package:color_grid/const/theme.dart';
import 'package:color_grid/page/color_grid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
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
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          // color: backgroundColor,
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
            child: Neumorphic(
              style: containerStyle.copyWith(boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(50))),
              child: Container(color: backgroundColor,child: Image.asset('assets/grid.png')),
            ),
          ),
          title: NeumorphicText(username, style: textStyle.copyWith(), textStyle: NeumorphicTextStyle(fontSize: 25),),
          backgroundColor: backgroundColor,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: NeumorphicButton(
                minDistance: 1,
                style: circleButtonStyle,
                child: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ColorGrid()));
                },
              ),
            ),
          ],
        ),

        ),
      );
  }
}
