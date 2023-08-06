import 'dart:async';
import 'package:flutter/material.dart';

class TimerButton extends StatefulWidget {
  const TimerButton({Key? key}) : super(key: key);

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<TimerButton> {
  int secondsRemaining = 30;
  bool enableResend = false;
  Timer? timer;

  @override
  initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const TextField(),
        const SizedBox(height: 10),
        ElevatedButton(
          child: const Text('Soumettre'),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue)),
          onPressed: () {
            //submission code here
          },
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          child: const Text('Soumettre'),
          onPressed: enableResend ? _resendCode : null,
        ),
        Text(
          'after $secondsRemaining seconds',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ],
    );
  }

  void _resendCode() {
    //other code here
    setState(() {
      secondsRemaining = 30;
      enableResend = false;
    });
  }

  @override
  dispose() {
    timer!.cancel();
    super.dispose();
  }
}
