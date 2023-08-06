import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../login/authentication.dart';
import '../login/widgets.dart';
import 'image_firestore.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        // Add from here
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = [];
          for (final document in snapshot.docs) {
            _guestBookMessages.add(
              GuestBookMessage(
                name: document.data()['name'] as String,
                message: document.data()['text'] as String,
              ),
            );
          }
          notifyListeners();
        });
        // to here.
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        // Add from here
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
        // to here.
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  // Add from here
  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;
  // to here.

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> verifyEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }

      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  Future<void> registerAccount(
      String email,
      String displayName,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<DocumentReference> addMessageToGuestBook(
      String message, Map<String, dynamic> formData) {
    /*
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }*/

    Map<String, dynamic> data = {
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'isolation': formData["isolation"],
      'zone': message,
      'comment': formData["comment"],
    };

    return FirebaseFirestore.instance
        .collection('guestbook')
        //.doc(formData["name"])
        .add(data);
  }
}

class GuestBookMessage {
  GuestBookMessage({required this.name, required this.message});
  final String name;
  final String message;
}

class GuestBook extends StatefulWidget {
  // Modify the following line
  // ignore: use_key_in_widget_constructors
  const GuestBook({required this.addMessage, required this.messages});
  final FutureOr<void> Function(String message, Map<String, dynamic> formData)
      addMessage;
  final List<GuestBookMessage> messages; // new

  @override
  _GuestBookState createState() => _GuestBookState();
}

class _GuestBookState extends State<GuestBook> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _controller = TextEditingController();
  final Map<String, dynamic> _formData = {
    'email': "gt@guydegnol.net",
    'name': "ezgzegze",
    'zone': null,
    'comment': null,
    'coverImage': "white",
    'stars': null,
    'isolation': null,
    'wood': false,
    'water': false,
    'lat': null,
    'lng': null,
  };
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

  Widget getResources() {
    return Row(children: [
      const Text('Bois: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
      Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: isWood,
          onChanged: (bool? value) {
            setState(() {
              isWood = value!;
            });
            _formData["wood"] = value;
          }),
      const Text('Eau: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
      Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: isWater,
          onChanged: (bool? value) {
            setState(() {
              isWater = value!;
            });
            _formData["water"] = value;
          })
    ]);
  }

  Widget buildFormField(String fieldLabel, String field,
      {String helper = "", String regex = ""}) {
    return TextFormField(
      decoration: InputDecoration(
          labelText: '$fieldLabel *',
          border: const OutlineInputBorder(),
          helperText: helper),
      validator: (String? value) {
        return null; /*(RegExp(regex).hasMatch(value))
            ? 'Bad syntax'
            : null*/
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

  Widget _ratingBar(int mode) {
    return RatingBar.builder(
      initialRating: 0,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      unratedColor: Colors.amber.withAlpha(50),
      itemCount: 5,
      itemSize: 50.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: Colors.amber,
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

  @override
  // Modify from here
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(children: [
              buildFormField("Lieu", "name",
                  helper: "Nom caracteristique unique decrivant l'endroit"),
              const Text("Eloignement de la route"),
              Slider(
                  value: isolation,
                  onChanged: (double val) {
                    setState(() {
                      isolation = val;
                      int vals = (isolation * divisions) as int;
                      _formData["isolation"] = val;
                      var hours = (vals / 2).round();
                      var minutes = (vals % 2) * 30;
                      isolationFormat = "${hours}h$minutes";
                    });
                  },
                  divisions: divisions,
                  label: isolationFormat),
              buildFormField(
                "Latitude",
                "lat",
                helper: "Latitude (precision 6 chiffres)",
                regex:
                    r"^(\+|-)?(?:90(?:(?:\.0{1,6})?)|(?:[0-9]|[1-8][0-9])(?:(?:\.[0-9]{1,6})?))$",
              ),
              buildFormField(
                "Longitude",
                "lng",
                helper: "Longitude (precision 6 chiffres)",
                regex:
                    r"^(\+|-)?(?:180(?:(?:\.0{1,6})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\.[0-9]{1,6})?))$",
              ),
              _ratingBar(1),
              const SizedBox(height: 8.0),
              getResources(),
              _imgLoader,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      minLines: 1,
                      maxLines: 10,
                      controller: _controller,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: 'Descriptif',
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
                        //sendMessage();
                        _imgLoader.uploadImageToFirebase(_formData);
                        await widget.addMessage(_controller.text, _formData);
                        _controller.clear();
                      }
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.send),
                        SizedBox(width: 4),
                        Text('SEND'),
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
        for (var message in widget.messages)
          Paragraph('${message.name}: ${message.message}'),
        const SizedBox(height: 8),
      ],
      // to here.
    );
  }
}
