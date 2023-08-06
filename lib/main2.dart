import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:google_nav_bar/google_nav_bar.dart';

import 'main_map.dart';
import 'main_list.dart';
import 'main_form.dart';

import 'form/application_state.dart';
import 'data/location.dart';

import 'package:rxdart/rxdart.dart';

void main2() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

String formatLabel(String label) {
  return label;
}

class Tab {
  String label;
  Widget section;
  IconData iconData;

  Tab({required this.label, required this.section, required this.iconData});

  GButton getButton() {
    return GButton(
      icon: iconData,
      text: formatLabel(label),
    );
  }
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  List<GButton> buttons = <GButton>[];
  List<Widget> tabs = <Widget>[];

  List<Location> markers = [];

  final locationsController = BehaviorSubject<List<Location>>();

  void initLocations() async {
    await firebase_core.Firebase.initializeApp();
    Location.loadCurentPosition();

    cloud_firestore.FirebaseFirestore.instance
        .collection('formdata')
        .get()
        .then((querySnapshot) {
      for (cloud_firestore.QueryDocumentSnapshot doc in querySnapshot.docs) {
        markers.add(Location(doc.data() as Map<String, dynamic>));
        locationsController.sink.add(markers);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    print("Init the data: start -- should be called once");
    initLocations();
    // ignore: avoid_print
    print("Init the data: end -- should be called once");
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> allTabs = [
      Tab(
          label: "Autour de moi",
          section: MainMap(locationControler: locationsController),
          iconData: Icons.map_outlined),
      Tab(
          label: "Recherche",
          section: MainMap(locationControler: locationsController),
          iconData: Icons.map_outlined),
      Tab(
          label: "Nouveau formulaire",
          section: MainForm(locationControler: locationsController),
          iconData: Icons.add_location_alt_outlined),
    ];

    for (var tab in allTabs) {
      buttons.add(tab.getButton());
      tabs.add(tab.section);
    }

    double iconSize = tabs.length > 4 ? 20 : 24;
    double gap = tabs.length > 4 ? 6 : 8;
    double horizontal = tabs.length > 4 ? 15 : 18;

    return MaterialApp(
        title: 'Grodt adviser',
        theme: ThemeData(brightness: Brightness.light),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            //backgroundColor: Colors.green[700],
            body: tabs.elementAt(_selectedIndex),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                child: GNav(
                    gap: gap,
                    activeColor: Colors.white,
                    iconSize: iconSize,
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontal, vertical: 5),
                    duration: const Duration(milliseconds: 800),
                    tabBackgroundColor: Colors.green[700]!,
                    selectedIndex: _selectedIndex,
                    tabs: buttons,
                    onTabChange: _onItemTapped),
              ),
            )));

    /*
    var appBar = AppBar(
      title: const Text('Cartographie de sites de camping'),
      backgroundColor: Colors.green[700],
      bottom: const TabBar(
        tabs: [
          Tab(icon: Icon(Icons.map_outlined)),
          Tab(icon: Icon(Icons.menu)),
          Tab(icon: Icon(Icons.add_location_alt_outlined)),
        ],
      ),
    );

    var body = TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        MainMap(locationControler: locationsController),
        MainList(locationControler: locationsController),
        MainForm(locationControler: locationsController)
      ],
    );

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 3, child: Scaffold(appBar: appBar, body: body)));
  */
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }
}
