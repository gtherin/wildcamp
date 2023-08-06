import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;

import 'main_map.dart';
import 'main_list.dart';
import 'main_form.dart';

import 'form/application_state.dart';
import 'data/location.dart';

import 'package:rxdart/rxdart.dart';

void main() async {
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

class _MainAppState extends State<MainApp> {
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
  }
}
