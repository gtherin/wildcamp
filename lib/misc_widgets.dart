import 'package:flutter/material.dart';

class WaitingWidget extends StatefulWidget {
  const WaitingWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WaitingWidget();
}

class _WaitingWidget extends State<WaitingWidget> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = const <Widget>[
      SizedBox(
        child: CircularProgressIndicator(),
        width: 60,
        height: 60,
      ),
    ];

    return Material(child: Stack(children: children));
  }
}

class SomethingWentWrong extends StatefulWidget {
  const SomethingWentWrong({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SomethingWentWrongState();
}

class _SomethingWentWrongState extends State<SomethingWentWrong> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = const <Widget>[
      Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 60,
      ),
      Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('Erreurs'),
      )
    ];

    return Material(child: Stack(children: children));
  }
}
