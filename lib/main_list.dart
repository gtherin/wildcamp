import 'package:flutter/material.dart';
import 'bubble.dart';

import 'data/location.dart';
import 'package:rxdart/rxdart.dart';

/// This is the stateful widget that the main application instantiates.
// ignore: must_be_immutable
class MainList extends StatefulWidget {
  BehaviorSubject<List<Location>> locationControler;

  MainList({Key? key, required this.locationControler}) : super(key: key);

  @override
  State<MainList> createState() => _MainListState();
}

/// This is the private State class that goes with MainList.
class _MainListState extends State<MainList> {
  //with AutomaticKeepAliveClientMixin {
  final List<Bubble> _menus = [];

  void initMenu(List<Location> locations) {
    _menus.clear();
    for (var element in locations) {
      _menus.add(Bubble(location: element, style: "Static", selector: false));
    }
  }

  @override
  void initState() {
    super.initState();
    widget.locationControler.stream.listen((locations) {
      setState(() {
        initMenu(locations);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _menus,
      ),
    ));
  }

  //@override
  //bool get wantKeepAlive => true;
}
