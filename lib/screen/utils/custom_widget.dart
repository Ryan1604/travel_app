import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app/utils/helper.dart';


class CustomWidget{
  static Widget getShimmer(double height, double width, {Color color= Colors.grey,bool single=false,EdgeInsets padding=EdgeInsets.zero}){
    return Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.white,
        child: Padding(
          padding: padding,
          child: Container(
            height: height, width: width,

            decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)
            ),
            padding: EdgeInsets.all(15),
            child: !single? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 100,
                  height:25,
                  color: Colors.black,
                ),
                Helper.emptyVSpace(10.0),
                Container(
                  width: double.infinity,
                  height:15,
                  color: Colors.black,
                ),
                Helper.emptyVSpace(10.0),
                Container(
                  width: double.infinity,
                  height:15,
                  color: Colors.black,
                ),
              ],
            ):Container(
              width: double.infinity,
              height:15,
              color: Colors.black,
            ),
          ),
        )
    );
  }


}

class ShadowText extends StatelessWidget {
  ShadowText(this.data, { this.style }) : assert(data != null);

  final String data;
  final TextStyle style;

  Widget build(BuildContext context) {
    return new ClipRect(
      child: new Stack(
        children: [
          new Positioned(
            top: 3.0,
            left: 3.0,
            child: new Text(
              data,
              style: style.copyWith(color: Colors.black.withOpacity(0.4)),
            ),
          ),
          new Text(data, style: style),
        ],
      ),
    );
  }
}
