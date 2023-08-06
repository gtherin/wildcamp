import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../login/authentication.dart';
import '../login/widgets.dart';
import '../data/location.dart';
import 'form/application_state.dart';
import 'form/guest_book.dart';

import 'package:rxdart/rxdart.dart';

// ignore: must_be_immutable
class MainForm extends StatelessWidget {
  BehaviorSubject<List<Location>> locationControler;

  MainForm({Key? key, required this.locationControler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const SizedBox(height: 8),
        const Header("Ajout d'un nouveau site de camping"),
        const SizedBox(height: 8),
        Consumer<ApplicationState>(
          builder: (context, appState, _) => Authentication(
            email: appState.email,
            loginState: appState.loginState,
            startLoginFlow: appState.startLoginFlow,
            verifyEmail: appState.verifyEmail,
            signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
            cancelRegistration: appState.cancelRegistration,
            registerAccount: appState.registerAccount,
            signOut: appState.signOut,
          ),
        ),
        const SizedBox(height: 8),
        Consumer<ApplicationState>(
          builder: (context, appState, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (appState.loginState == ApplicationLoginState.loggedIn) ...[
                const Divider(
                  height: 8,
                  thickness: 1,
                  indent: 8,
                  endIndent: 8,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                DataPusher(
                  locationControler: locationControler,
                  pushData2Cloud: (_formData) =>
                      appState.pushData2Cloud(_formData),
                ),
                const Divider(
                  height: 8,
                  thickness: 1,
                  indent: 8,
                  endIndent: 8,
                  color: Colors.grey,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
