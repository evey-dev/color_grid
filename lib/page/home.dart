import 'package:color_grid/const/color.dart';
import 'package:color_grid/const/theme.dart';
import 'package:color_grid/page/color_grid.dart';
import 'package:color_grid/page/published_color_grid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);


  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth instance = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Map<String, dynamic> data = {};
  final List<String> userGridIds = [];
  final List<String> userPublishedIds = [];
  final List<Map<String,dynamic>> userGrids = [];
  final List<Map<String,dynamic>> userPublished = [];

  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();

  @override
  void initState() {
    super.initState();
    getFirestore();
  }

  void getFirestore() async {
    userGridIds.clear();
    userGrids.clear();
    userPublished.clear();
    userPublishedIds.clear();
    await firestore.collection('users').doc(instance.currentUser?.uid.toString()).get().then((value) {
      if (value.exists) {
        data = value.data()!;
      }
      userGridIds.clear();
      data['grids'].forEach((e) => userGridIds.add(e as String));
      data['published'].forEach((e) => userPublishedIds.add(e as String));
      userGridIds.sort();
      userPublishedIds.sort();
      setState(() {
      });
    });
    await firestore.collection('grids').get().then((QuerySnapshot qs) {
      for (var element in qs.docs) {
        if (!userGridIds.contains(element.id.toString()) && !userPublishedIds.contains(element.id.toString())) continue;
        if ((element.data() as Map<String, dynamic>)['published'] == false) {
          userGrids.add(element.data() as Map<String, dynamic>);
        }
        else {
          userPublished.add(element.data() as Map<String, dynamic>);
        }
      }
      setState(() {
      });
    });
  }

  List<Widget> generateGrids() {
    if (userGrids.isEmpty || userGridIds.isEmpty) return [];
    List<Widget> result = [const SizedBox(height: 10,)];
    for (int i = 0; i < userGrids.length; i++) {
      List<Color> temp = [];
      userGrids[i]['colors'].forEach((k, v) {
        temp.add(Color(int.parse(v.split('(0x')[1].split(')')[0], radix: 16)).withOpacity(1));
      });
      if (userGrids[i]['colors'].isEmpty) temp = [Colors.transparent, Colors.transparent];
      if (temp.length == 1) {
        userGrids[i]['colors'].forEach((k, v) {
          temp.add(Color(int.parse(v.split('(0x')[1].split(')')[0], radix: 16)).withOpacity(1));
        });
      }
      result.add(
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ColorGrid(userGridIds[i].toString())));
          },
          child: Neumorphic (
            style: buttonStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: temp),
                      ),
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.transparent, Colors.black.withOpacity(.2)], begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        padding: const EdgeInsets.only(right: 10, top: 5),
                        onPressed: () {},
                        icon: Icon(Icons.share, color: Colors.white.withOpacity(.9),size: 25,),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    userGrids[i]['name'].toString(),
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: greyTextColor, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      );
      result.add(const SizedBox(height: 10,));
    }
    return result;
  }

  List<Widget> generatePublished() {
    if (userPublished.isEmpty || userPublishedIds.isEmpty) return [];
    List<Widget> result = [const SizedBox(height: 10,)];
    for (int i = 0; i < userPublished.length; i++) {
      List<Color> temp = [];
      userPublished[i]['colors'].forEach((k, v) {
        temp.add(Color(int.parse(v.split('(0x')[1].split(')')[0], radix: 16)).withOpacity(1));
      });
      if (userPublished[i]['colors'].isEmpty) temp = [Colors.transparent, Colors.transparent];
      result.add(
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PublishedColorGrid(userPublishedIds[i].toString())));
          },
          child: Neumorphic (
            style: buttonStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: temp),
                      ),
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.transparent, Colors.black.withOpacity(.2)], begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        padding: const EdgeInsets.only(right: 10, top: 5),
                        onPressed: () {},
                        icon: Icon(Icons.share, color: Colors.white.withOpacity(.9),size: 25,),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    userPublished[i]['name'].toString(),
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: greyTextColor, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      );
      result.add(const SizedBox(height: 10,));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  'Drafts',
                  style: TextStyle(fontSize: 30, color: greyTextColor),
                ),
                IconButton(
                  onPressed: () {
                    getFirestore();
                  },
                  icon: const Icon(Icons.refresh, color: greyTextColor,),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Neumorphic(
              padding: const EdgeInsets.only(left: 10, right: 10),
              style: textFieldStyle,
              child: SizedBox(
                height: 200,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _scrollController1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: generateGrids(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40,),
            Row(
              children: [
                const Text(
                  'Published',
                  style: TextStyle(fontSize: 30, color: greyTextColor),
                ),
                IconButton(
                  onPressed: () {
                    getFirestore();
                  },
                  icon: const Icon(Icons.refresh, color: greyTextColor,),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Neumorphic(
              padding: const EdgeInsets.only(left: 10, right: 10),
              style: textFieldStyle,
              child: SizedBox(
                height: 200,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _scrollController2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: generatePublished(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
