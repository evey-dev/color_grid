import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_grid/page/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../const/color.dart';
import '../const/theme.dart';
import 'color_grid.dart';
import 'home.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;


  final FirebaseAuth instance = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Map<String, dynamic> data = {};
  final List<String> userGridIds = [];

  @override
  void initState() {
    super.initState();
    getFirestoreInstance();
  }

  void getFirestoreInstance() async {
    await firestore
        .collection('users')
        .doc(instance.currentUser?.uid.toString())
        .get()
        .then((value) {
      if (value.exists) {
        data = value.data()!;
      }
      userGridIds.clear();
      data['grids'].forEach((e) => userGridIds.add(e as String));
      setState(() {
      });
    });
  }

  static const List<Widget> _widgetOptions = <Widget>[
    Home(),
    Dashboard(),
    Text(
      'Index 2: School',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String username = instance.currentUser?.displayName ?? '';

    return NeumorphicTheme(
      themeMode: ThemeMode.light,
      theme: const NeumorphicThemeData(
        appBarTheme: NeumorphicAppBarThemeData(
          buttonStyle: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
        ),
        depth: 4,
        intensity: 1,
      ),
      child: Scaffold(
        bottomNavigationBar: Neumorphic(
          style: containerStyle.copyWith(borderRadius: 0),
          child: BottomNavigationBar(
            backgroundColor: backgroundColor,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined),label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.settings_outlined),label: 'Settings'),
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: greyTextColor,
            selectedItemColor: mainTextColor,
            onTap: _onItemTapped,
          ),
        ),
        appBar: AppBar(
          toolbarHeight: 80,
          // color: backgroundColor,
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
            child: Neumorphic(
              style: containerStyle.copyWith(
                  boxShape:
                  NeumorphicBoxShape.roundRect(BorderRadius.circular(50))),
              child: Container(
                  color: backgroundColor,
                  child: Image.asset('assets/grid.png')),
            ),
          ),
          title: NeumorphicText(
            username,
            style: textStyle.copyWith(),
            textStyle: NeumorphicTextStyle(fontSize: 25),
          ),
          backgroundColor: backgroundColor,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: NeumorphicButton(
                minDistance: 1,
                style: circleButtonStyle,
                child: const Icon(Icons.add, color: mainTextColor),
                onPressed: () async {
                  DocumentReference docRef =
                  await firestore.collection('grids').add({
                    'name': 'Unnamed Grid',
                    'userid': instance.currentUser?.uid,
                    'colors': {},
                    'published': false
                  });
                  firestore
                      .collection('users')
                      .doc(instance.currentUser?.uid.toString())
                      .update({
                    'grids': FieldValue.arrayUnion([docRef.id.toString()])
                  });
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ColorGrid(docRef.id.toString()))).then((value) {setState(() {});});
                },
              ),
            ),

          ],
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
      ),
    );

  }
}