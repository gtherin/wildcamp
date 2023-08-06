// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart' as smtp_server;

import 'package:rxdart/rxdart.dart';

import '../login/widgets.dart';
import 'image_firestore.dart';
import '../data/location.dart';

String getID(String str) {
  var withDia =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž%^';
  var withoutDia =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz__';

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }

  str = str.toLowerCase();
  str = str.replaceAll(" ", "_");

  return str;
}

Map<String, dynamic> resetFormData() {
  return {
    'email': "",
    'name': "",
    'zone': "",
    'comment': "",
    'coverImage': "white",
    'stars': "0",
    'isolation': "0h00",
    'wood': 0,
    'water': 0,
    'lat': null,
    'lng': null,
  };
}

// ignore: must_be_immutable
class DataPusher extends StatefulWidget {
  // Modify the following line
  // ignore: use_key_in_widget_constructors
  BehaviorSubject<List<Location>> locationControler;
  bool newForm = true;

  DataPusher(
      {Key? key, required this.locationControler, required this.pushData2Cloud})
      : super(key: key);
  final FutureOr<void> Function(Map<String, dynamic> formData) pushData2Cloud;

  @override
  _DataPusherState createState() => _DataPusherState();
}

class _DataPusherState extends State<DataPusher>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _controller2 = TextEditingController();
  final _controller3 = TextEditingController();
  final _controller4 = TextEditingController();
  Map<String, dynamic> _formData = resetFormData();
  bool isWood = false;
  bool isWater = false;
  double isolation = 0;
  String isolationFormat = "0h00";
  int divisions = 12;
  final UploadingImageToFirebaseStorage _imgLoader =
      UploadingImageToFirebaseStorage();

  late double _rating;

  IconData? _selectedIcon;

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  Widget buildFormField(
      String fieldLabel, String field, TextEditingController controller,
      {String helper = "",
      String regex = "",
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
          labelText: '$fieldLabel *',
          border: const OutlineInputBorder(),
          helperText: helper),
      validator: (value) {
        if ((value == null || value.isEmpty || value == "") &&
            (regex != "" && !RegExp(regex).hasMatch(value!))) {
          return 'Mauvaise syntaxe: $helper';
        }
        return null;
      },
      onChanged: (String val) {
        _formData[field] = val;
      },
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }

  Widget _ratingBar() {
    return RatingBar.builder(
      initialRating: 0,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: false,
      unratedColor: Colors.red[100],
      itemCount: 5,
      itemSize: 30.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: Colors.red[500],
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
          _formData["stars"] = _rating;
        });
      },
      updateOnDrag: true,
    );
  }

  void updateIsolation(double val) {
    isolation = val;
    int vals = (isolation * divisions) as int;
    var hours = (vals / 2).round();
    var minutes = (vals % 2) * 30;
    isolationFormat = "${hours}h$minutes";
    _formData["isolation"] = isolationFormat;
  }

  @override
  // Modify from here
  Widget build(BuildContext context) {
    super.build(context);
    if (!widget.newForm) {
      return StyledButton(
        onPressed: () async {
          setState(() {
            widget.newForm = true;
          });
        },
        child: Row(
          children: const [
            Icon(Icons.send),
            SizedBox(width: 4),
            Text('Nouveau formulaire'),
          ],
        ),
      );
    }
    //super.build(context);
    var ll = Location.currentLocation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            onChanged: () {
              setState(() {
                _formKey.currentState!.validate();
              });
            },
            key: _formKey,
            child: Column(children: [
              buildFormField("Lieu", "name", _controller2,
                  helper: "Nom caracteristique unique decrivant l'endroit"),
              const Text("Eloignement de la route"),
              Slider(
                  value: isolation,
                  onChanged: (double val) {
                    setState(() {
                      updateIsolation(val);
                    });
                  },
                  divisions: divisions,
                  label: isolationFormat),
              buildFormField(
                "Latitude (Exemple ${ll.latitude})",
                "lat",
                _controller3,
                helper:
                    "Latitude (précision maximum 6 chiffres après la virgule, 0.11m)",
                regex:
                    r"^(\+|-)?(?:90(?:(?:\.0{1,6})?)|(?:[0-9]|[1-8][0-9])(?:(?:\.[0-9]{1,6})?))$",
                keyboardType: TextInputType.number,
              ),
              buildFormField(
                "Longitude (Exemple ${ll.longitude})",
                "lng",
                _controller4,
                helper:
                    "Longitude (précision maximum 6 chiffres après la virgule, 0.11m)",
                regex:
                    r"^(\+|-)?(?:180(?:(?:\.0{1,6})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\.[0-9]{1,6})?))$",
                keyboardType: TextInputType.number,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
                  Widget>[
                IconButton(
                    onPressed: () {
                      setState(() {
                        isWood = !isWood;
                      });
                    },
                    icon: const Icon(FontAwesomeIcons.fire),
                    //icon: const Icon(Icons.nature),
                    color: (isWood ? Colors.orange[400] : Colors.grey[400]) //),
                    //color: (isWood ? Colors.brown[400] : Colors.grey[400]) //),
                    ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        isWater = !isWater;
                      });
                    },
                    icon: const Icon(FontAwesomeIcons.faucet),
                    //icon: const Icon(Icons.local_drink),
                    color: (isWater ? Colors.blue[400] : Colors.grey[400]) //),
                    ),
                const Spacer(),
                _imgLoader,
                const Spacer(),
                _ratingBar()
              ]),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      minLines: 1,
                      maxLines: 10,
                      controller: _controller,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: 'Descriptif *',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mettre une description de l\'endroit';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  StyledButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        print("Validate");
                        print(_formData);

                        _formData['email'] = firebase_auth
                            .FirebaseAuth.instance.currentUser!.email;

                        _formData["id"] = getID(_formData["name"]);
                        _formData["coverImage"] =
                            _imgLoader.getfileName(_formData);
                        _formData["comment"] = _controller.text;

                        _formData["timestamp"] =
                            DateTime.now().millisecondsSinceEpoch;
                        _formData["stars"] =
                            int.tryParse(_formData["stars"]).toString();

                        _formData["wood"] = (isWood ? 1 : 0);
                        _formData["water"] = (isWater ? 1 : 0);
                        _formData["validated"] = false;

                        _formData["lat"] = double.tryParse(_formData["lat"]);
                        _formData["lng"] = double.tryParse(_formData["lng"]);

                        print("Push form");
                        print(_formData);
                        _imgLoader.uploadImageToFirebase(_formData);
                        print("Image should have been sent");
                        await widget.pushData2Cloud(_formData);
                        print("Should be done here");

                        final loloc = Location(_formData);

                        var markers = await widget.locationControler.first;
                        markers.add(loloc);
                        print(markers);
                        widget.locationControler.sink.add(markers);
                        sendMessage();
                        widget.newForm = false;
                        setState(() {
                          _formKey.currentState!.reset();
                          _imgLoader.imageFile = null;
                          _formData = resetFormData();
                          isWater = false;
                          isWood = false;
                          _controller.clear();
                          _controller2.clear();
                          _controller3.clear();
                          _controller4.clear();
                        });
                      }
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.send),
                        SizedBox(width: 4),
                        Text('SOUMETTRE'),
                      ],
                    ),
                  ),
                ],
              )
            ]),
          ),
        ),
        // Modify from here
        const SizedBox(height: 12),
      ],
      // to here.
    );
  }

  Future<void> sendMessage() async {
    String body = "<h1>Ajout d'un nouveau site de camping sur wildcamp</h1>";

    _formData.forEach((key, value) {
      body += '<p>$key: $value</p>';
    });

    print(body);

    if (kIsWeb) {
      // running on the web!
      return;
    }
    const username = 'wildcamp@guydegnol.net';
    const password = '&crMH\$cS2piALEp';
    final smtpServer = smtp_server.SmtpServer(
      'smtp.online.net',
      port: 587,
      username: username,
      password: password,
    );

    final message = mailer.Message()
      ..from = const mailer.Address(username, 'gt')
      ..recipients.add('guydegnol@gmail.com')
      ..ccRecipients.add(_formData['email'])
      ..subject = "Ajout d'un nouveau site de camping"
      ..html = body;

    await mailer.send(message, smtpServer);
  }

  @override
  bool get wantKeepAlive => true;
}
