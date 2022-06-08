import 'package:color_grid/const/color.dart';
import 'package:color_grid/const/theme.dart';
import 'package:color_grid/page/color_grid.dart';
import 'package:color_grid/page/published_color_grid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);


  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseAuth instance = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Map<String, dynamic> data = {};
  final List<String> gridIds = [];
  final List<Map<String,dynamic>> grids = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getFirestore();
  }

  void getFirestore() async {
    gridIds.clear();
    grids.clear();
    await firestore.collection('grids').get().then((QuerySnapshot qs) {
      for (var element in qs.docs) {
        if ((element.data() as Map<String, dynamic>)['published']) {
          gridIds.add(element.id.toString());
          grids.add(element.data() as Map<String, dynamic>);
        }
      }
      setState(() {
      });
    });
  }

  List<Widget> generateGrids() {
    if (grids.isEmpty || gridIds.isEmpty) return [const Text('Loading...')];
    List<Widget> result = [const SizedBox(height: 10,)];
    for (int i = 0; i < grids.length; i++) {
      List<Color> temp = [];
      grids[i]['colors'].forEach((k, v) {
        temp.add(Color(int.parse(v.split('(0x')[1].split(')')[0], radix: 16)).withOpacity(1));
      });
      if (grids[i]['colors'].isEmpty) temp = [Colors.transparent, Colors.transparent];
      result.add(
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PublishedColorGrid(gridIds[i].toString())));
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
                    grids[i]['name'].toString(),
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
                  'Top',
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
                height: 500,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: generateGrids(),
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
