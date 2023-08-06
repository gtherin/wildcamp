import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class Stars extends StatelessWidget {
  String stars;
  int wood;
  int water;

  Stars(
      {Key? key, required this.stars, required this.wood, required this.water})
      : super(key: key);

  Widget getStar(double top, double left, int num, {String wantedIcon = ""}) {
    int itars = int.parse(stars);

    Widget iconn = const Icon(Icons.star);
    Color? color = Colors.red[500];
    if (wantedIcon == "wood") {
      //iconn = const Icon(Icons.nature);
      iconn = const Icon(FontAwesomeIcons.fire);
      //color = (wood == 1 ? Colors.brown[400] : Colors.grey[400]);
      color = (wood == 1 ? Colors.orange[400] : Colors.grey[400]);
    } else if (wantedIcon == "water") {
      iconn = const Icon(FontAwesomeIcons.faucet);
      //iconn = const Icon(Icons.local_drink);
      color = (water == 1 ? Colors.blue[500] : Colors.grey[400]);
    } else if (num >= itars) {
      color = Colors.grey[400];
      iconn = const Icon(Icons.star_border);
    }

    return Positioned(
      child: Container(
        width: 10,
        height: 10,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: IconButton(onPressed: () => {}, icon: iconn, color: color),
      ),
      top: top,
      left: left,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bigCircle = Container(
      width: 100.0,
      height: 100.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );

    return Material(
      color: Colors.white,
      child: Center(
        child: Stack(
          children: <Widget>[
            bigCircle,
            getStar(20, 16, 0),
            getStar(20, 60, 1),
            getStar(33, 38, 2),
            getStar(50, 60, 3),
            getStar(50, 16, 4),
            getStar(10, 38, 4, wantedIcon: "wood"),
            getStar(55, 38, 4, wantedIcon: "water"),
          ],
        ),
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData iconData;

  const CircleButton({Key? key, required this.onTap, required this.iconData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 50.0;

    return InkResponse(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: Colors.black,
        ),
      ),
    );
  }
}
