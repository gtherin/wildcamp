// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:transparent_image/transparent_image.dart';

import 'package:location/location.dart' as current_location;

// https://medium.com/flutterdevs/location-in-flutter-27ca6fa1126c

LatLng getInitLatLng() {
  return const LatLng(68.14, 13.45);
}

Future<LatLng> getCurrentPosition() async {
  current_location.Location location = current_location.Location();

  bool _serviceEnabled;
  current_location.PermissionStatus _permissionGranted;
  //current_location.LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return getInitLatLng();
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == current_location.PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != current_location.PermissionStatus.granted) {
      return getDefaultLatLng();
    }
  }

  var locData = await location.getLocation();

  return LatLng(locData.latitude!, locData.longitude!);
}

LatLng getDefaultLatLng() {
  return const LatLng(68.14, 13.45);
}

/*
clocations.LocationData _currentPosition = clocations.Location().getLocation();
clocations.Address address = clocations.Geocoder.local
    .findAddressesFromCoordinates(clocations.Coordinates(
        _currentPosition.latitude, _currentPosition.longitude));
Future<String> getCurentAddress() async {
  return "${address.first.addressLine}";
}
*/

// ignore: must_be_immutable
class Location {
  static late LatLng currentLocation;

  static void loadCurentPosition() async {
    currentLocation = getDefaultLatLng();
    getCurrentPosition().then((value) {
      currentLocation = value;
    });
    print("loadCurentPosition");
    print(currentLocation);
  }

  Location(Map<String, dynamic> json) {
    id = json.putIfAbsent("id", () => "") as String;
    name = json.putIfAbsent("name", () => "") as String;

    zone = json.putIfAbsent("zone", () => "") as String;

    comment = json.putIfAbsent("comment", () => "") as String;
    pinType = json.putIfAbsent("pinType", () => "") as String;
    stars = json.putIfAbsent("stars", () => "0") as String;
    isolation = json.putIfAbsent("isolation", () => "") as String;
    validated = json.putIfAbsent("validated", () => false) as bool;

    if (json.containsKey("wood")) {
      wood = json["wood"];
    }

    if (json.containsKey("water")) {
      water = json["water"];
    }

    location = LatLng(json['lat'], json['lng']);
    labelColor = Colors.blueAccent;

    print("Location contructor");
    print(json);

    coverImage = const CircularProgressIndicator();

    final ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child(json['coverImage']);

    ref.getDownloadURL().then((url) {
      coverImage = FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: url,
      );
    });
  }

  late String name;
  late String zone;
  late String comment;
  late String pinType;
  late String stars;
  late String isolation;

  late Widget coverImage;
  late String id;
  late bool validated;

  int wood = 0;
  int water = 0;

  Color labelColor = Colors.blueAccent;
  LatLng location = getInitLatLng();
  BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
}
