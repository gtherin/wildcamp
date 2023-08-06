import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'data/location.dart';
import 'bubble.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:rxdart/rxdart.dart';

// ignore: must_be_immutable
class MainMap extends StatefulWidget {
  BehaviorSubject<List<Location>> locationControler;

  MainMap({Key? key, required this.locationControler}) : super(key: key);

  String selected = "";
  int counter = 0;
  int markerCounter = 0;

  @override
  State<StatefulWidget> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  //with AutomaticKeepAliveClientMixin {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final List<Bubble> _menus = [];
  String googleAPIKey = "AIzaSyDitQ8QTd6RLr0BYgm-LlTxPpF2rOthn0M";
  List<Location> _locations = [];

  @override
  void initState() {
    super.initState();
    widget.locationControler.stream.listen((number) {
      setState(() {
        _locations = number;
        if (!kIsWeb) {
          resetState();
        }
      });
    });
  }

  void resetState() async {
    _menus.clear();
    _markers.clear();

    for (var cLocation in _locations) {
      bool selector = cLocation.name == widget.selected;

      final menu =
          Bubble(location: cLocation, style: "Animated", selector: selector);

      var icon = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange); //cLocation.icon
      if (cLocation.validated) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      }

      final marker = Marker(
          markerId: MarkerId(cLocation.name),
          position: cLocation.location,
          icon: icon,
          infoWindow: InfoWindow(title: cLocation.name),
          onTap: () {
            widget.markerCounter += 1;
            setState(() {
              widget.selected = cLocation.name;
              resetState();
            });
          });

      _markers.add(marker);
      _menus.add(menu);
    }
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    CameraPosition initialLocation = const CameraPosition(
        zoom: 6, bearing: 30, tilt: 0, target: LatLng(68.14, 13.45));

    var gmap = GoogleMap(
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: false,
      mapType: MapType.normal,
      markers: _markers,
      onCameraMove: (CameraPosition cameraPosition) {
        // ignore: avoid_print
        print("Camera zoom: $cameraPosition.zoom");
      },
      initialCameraPosition: initialLocation,
      onMapCreated: onMapCreated,
    );
    List<Widget> children = <Widget>[gmap] + _menus;

    return Scaffold(body: Stack(children: children));
  }

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    resetState();
  }

  //@override
  //bool get wantKeepAlive => true;
}
