import 'package:flutter/material.dart';
import 'data/location.dart';
import 'stars.dart';

class Bubble extends StatefulWidget {
  final Location location;
  final String style;
  final bool selector;

  const Bubble(
      {Key? key,
      required this.location,
      required this.style,
      required this.selector})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> {
  bool selected = false;
  bool showFirstContainer = true;

  List<Widget> getTextZone() {
    var textZone = <Widget>[
      Text(widget.location.name,
          style: TextStyle(fontSize: 14, color: widget.location.labelColor)),
      Text(
          '(${widget.location.location.latitude.toStringAsFixed(4)}, ${widget.location.location.longitude.toStringAsFixed(4)})',
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
      Text(
        widget.location.comment.toString(),
        style: const TextStyle(fontSize: 11, color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
    ];

    return textZone;
  }

  Widget getRow(Stars stars) {
    List<Widget> textZone = getTextZone();

    Row row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.only(left: 10),
          child: ClipOval(child: widget.location.coverImage),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: textZone,
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [stars],
            ),
          ),
        ),
      ],
    );

    Container container = Container(
      margin: const EdgeInsets.all(20),
      height: 100,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                blurRadius: 20,
                offset: Offset.zero,
                color: Colors.grey.withOpacity(0.5))
          ]),
      child: row,
    );

    Widget bubble = Center(
        child: Align(alignment: Alignment.bottomCenter, child: container));

    Widget animated = GestureDetector(
        onTap: () {
          setState(() {
            showFirstContainer = !showFirstContainer;
          });
        },
        child: Container(
          child: bubble,
        ));
    return animated;
  }

  Widget getPage(Stars stars) {
    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Text(
                      widget.location.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.location.labelColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${widget.location.zone})',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.location.labelColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ]),
                ),
                Text(
                    'Coordonnées: (${widget.location.location.latitude.toStringAsFixed(6)}, ${widget.location.location.longitude.toStringAsFixed(6)})',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          stars,
        ],
      ),
    );

    Color? color = Colors.grey[300];
    Widget buttonSection = SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(
              color, Icons.create, 'EDIT'), // "Icons.done" when over
          _buildButtonColumn(color, Icons.share, 'SHARE'),
          _buildButtonColumn(color, Icons.close, 'CLOSE'),
        ],
      ),
    );

    Widget textSection = Container(
      padding: const EdgeInsets.all(32),
      child: Column(children: [
        Text(
          widget.location.comment,
          softWrap: true,
        ),
        Text('A ${widget.location.isolation} de marche',
            style: const TextStyle(fontSize: 12, color: Colors.grey))
      ]),
    );

    Decoration decoration = BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              blurRadius: 20,
              offset: Offset.zero,
              color: Colors.grey.withOpacity(0.5))
        ]);

    List<Widget> children = [buttonSection];
    children.add(SizedBox(
      child: widget.location.coverImage,
      height: 300,
      width: 600,
    ));
    children.addAll([
      titleSection,
      textSection,
    ]);

    Container containerExp = Container(
      margin: const EdgeInsets.all(20),
      height: 600,
      decoration: decoration,
      child: ListView(
        children: children,
      ),
    );

    Widget bubbleExp = Center(
        child: Align(alignment: Alignment.bottomCenter, child: containerExp));
    Widget animatedExp = GestureDetector(
        onTap: () {
          setState(() {
            showFirstContainer = !showFirstContainer;
          });
        },
        child: Container(
          child: bubbleExp,
        ));
    return animatedExp;
  }

  @override
  Widget build(BuildContext context) {
    selected = widget.selector;

    Stars stars = Stars(
        stars: widget.location.stars,
        wood: widget.location.wood,
        water: widget.location.water);

    Widget animated = getRow(stars);
    Widget animatedExp = getPage(stars);
    Widget animSwitch = AnimatedSwitcher(
      duration: const Duration(milliseconds: 2000),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(child: child, scale: animation);
      },
      child: showFirstContainer ? animated : animatedExp,
    );

    if (widget.style == "Animated") {
      return AnimatedPositioned(
        bottom: selected ? 0 : -150,
        right: 0,
        left: 0,
        duration: const Duration(milliseconds: 200),
        child: animSwitch,
      );
    }

    return animSwitch;
  }

  Row _buildButtonColumn(Color? color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
