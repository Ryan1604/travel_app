import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:travel_app/screen/destination/detail.dart';
import 'package:travel_app/screen/mosque/detail.dart';
import 'package:travel_app/utils/helper.dart';
import 'package:travel_app/utils/style.dart';

class Functions {
  static Future<String> getImageUrl(StorageReference url) async {
    var s = await url.getDownloadURL();
    return s.toString();
  }

  static Widget getData(DocumentSnapshot shot, BuildContext context,
      {isMosque = false, isPlace = false}) {
    var ref;

    if (!isPlace)
      ref = FirebaseStorage.instance.ref().child(shot['image']);
    else
      ref = FirebaseStorage.instance.ref().child(shot['image'][0]);
    String getProvince(){
      String province="";
      Functions.province().forEach((element) {
        if(shot['province']==element['code']){
          province = element['name'];
        }
      });
      return province;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: InkWell(
        onTap: () {
          if(isPlace){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_)=>DestinationPage(shot: shot,)
                ));
          } else if(isMosque){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_)=>MosquePage(shot: shot,)
                ));
          }
        },
        child: Container(
          height: isPlace?120:100,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1),
              ]),
          width: double.infinity,
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8)),
                child: Container(
                  width: 100,
                  height: double.maxFinite,
                  child: FutureBuilder(
                    future: getImageUrl(ref),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState != ConnectionState.waiting) {
                        return CachedNetworkImage(
                          imageUrl: snapshot.data.toString(),
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            shot['name'],
                            style: Text2Style,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      !isMosque
                          ? RatingBar(
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              initialRating: shot['rating'],
                              allowHalfRating: true,
                              itemSize: 12.0,
                              direction: Axis.horizontal,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 1.0),
                            )
                          : Text(
                              shot['place'],
                              style: Text2StyleGrey,
                              overflow: TextOverflow.ellipsis,
                            ),
                      isPlace?
                      Text(
                        getProvince(),
                        style: Text2StyleGrey,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ):Container(),
                      Helper.emptyVSpace(5.0),

                      Text(
                        shot['desc'],
                        style: Text2StyleGrey,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    GeoPoint latlong = shot['marks'];
                    Coords coords = Coords(latlong.latitude, latlong.longitude);
                    if (await MapLauncher.isMapAvailable(MapType.google)) {
                      await MapLauncher.launchMap(
                        mapType: MapType.google,
                        coords: coords,
                        title: shot['name'],
                        description: shot['desc'],
                      );
                    }
                  },
                  child: Icon(
                    Icons.place,
                    color: Color(0xFFEE7070),
                    size: 20,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  static List province(){
    return [
      {
        "name": "Baat Dambang",
        "code": "KH-2"
      },
      {
        "name": "Kampong Chaam",
        "code": "KH-3"
      },
      {
        "name": "Kampong Chhnang",
        "code": "KH-4"
      },
      {
        "name": "Kampong Spueu",
        "code": "KH-5"
      },
      {
        "name": "Kampong Thum",
        "code": "KH-6"
      },
      {
        "name": "Kampot",
        "code": "KH-7"
      },
      {
        "name": "Kandaal",
        "code": "KH-8"
      },
      {
        "name": "Kaoh Kong",
        "code": "KH-9"
      },
      {
        "name": "Kracheh",
        "code": "KH-10"
      },
      {
        "name": "Krong Kaeb",
        "code": "KH-23"
      },
      {
        "name": "Krong Pailin",
        "code": "KH-24"
      },
      {
        "name": "Krong Preah Sihanouk",
        "code": "KH-18"
      },
      {
        "name": "Mondol Kiri",
        "code": "KH-11"
      },
      {
        "name": "Otdar Mean Chey",
        "code": "KH-22"
      },
      {
        "name": "Phnom Penh",
        "code": "KH-12"
      },
      {
        "name": "Pousaat",
        "code": "KH-15"
      },
      {
        "name": "Preah Vihear",
        "code": "KH-13"
      },
      {
        "name": "Prey Veaeng",
        "code": "KH-14"
      },
      {
        "name": "Rotanak Kiri",
        "code": "KH-16"
      },
      {
        "name": "Siem Reab",
        "code": "KH-17"
      },
      {
        "name": "Stueng Traeng",
        "code": "KH-19"
      },
      {
        "name": "Svaay Rieng",
        "code": "KH-20"
      },
      {
        "name": "Taakaev",
        "code": "KH-21"
      }
    ];
  }
}
