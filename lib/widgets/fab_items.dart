import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thrill/rest/rest_url.dart';

class FABBottomAppBarItem {
  FABBottomAppBarItem({this.iconData, this.text});

  IconData? iconData;
  String? text;
}

class FABBottomAppBar extends StatefulWidget {
  FABBottomAppBar({
    this.items,
    this.centerItemText,
    this.height: 60.0,
    this.iconSize: 24.0,
    this.backgroundColor,
    this.color,
    this.selectedColor,
    this.notchedShape,
    this.onTabSelected,
  }) {
    assert(this.items!.length == 2 || this.items!.length == 4);
  }

  List<FABBottomAppBarItem>? items;
  String? centerItemText;
  double height;
  double iconSize;
  Color? backgroundColor;
  Color? color;
  Color? selectedColor;
  NotchedShape? notchedShape;
  ValueChanged<int>? onTabSelected;

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
  int _selectedIndex = 0;

  _updateIndex(int index) {
    widget.onTabSelected!(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items!.length, (int index) {
      return _buildTabItem(
        item: widget.items![index],
        index: index,
        onPressed: _updateIndex,
      );
    });
    items.insert(items.length >> 1, _buildMiddleTabItem());

    return BottomAppBar(
      shape: widget.notchedShape,
      notchMargin: 20.0,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
            Color(0xff145158),Color(0xff193542),Color(0xff1A2C41)
          ])),),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items,
        ),
      ],)
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: widget.iconSize),
            Text(
              widget.centerItemText ?? '',
              style: TextStyle(color: widget.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    FABBottomAppBarItem? item,
    int? index,
    ValueChanged<int>? onPressed,
  }) {
    Color? color =
        _selectedIndex == index ? widget.selectedColor : widget.color;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed!(index!),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(item!.iconData, color: color, size: widget.iconSize),
                Text(
                  item.text!,
                  style: TextStyle(color: color),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
