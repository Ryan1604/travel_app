import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:travel_app/utils/helper.dart';
import 'package:travel_app/utils/style.dart';

class MosquePage extends StatefulWidget {
  final DocumentSnapshot shot;

  const MosquePage({Key key, this.shot}) : super(key: key);

  @override
  _MosquePageState createState() => _MosquePageState(this.shot);
}

class _MosquePageState extends State<MosquePage> {
  _MosquePageState(this.shot);
  final DocumentSnapshot shot;

  static Future<String> getImageUrl(StorageReference url) async {
    var s = await url.getDownloadURL();
    return s.toString();
  }
  MediaQueryData query ;


  var ref ;



  @override
  void initState() {
    super.initState();
    ref = FirebaseStorage.instance.ref().child(shot['image']);
  }


  @override
  Widget build(BuildContext context) {
    query = MediaQuery.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            actions: <Widget>[
              IconButton(
                onPressed: ()async{
                  GeoPoint latlong = shot['marks'];
                  Coords coords = Coords(latlong.latitude,latlong.longitude);
                  if (await MapLauncher.isMapAvailable(MapType.google)) {
                    await MapLauncher.launchMap(
                      mapType: MapType.google,
                      coords: coords,
                      title: shot['name'],
                      description: "place",
                    );
                  }
                },
                icon: Icon(Icons.map,color: Colors.white,size: 30,),

              )
            ],
            backgroundColor: Colors.black,
            expandedHeight: 470,

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 500,
                        width: double.maxFinite,
                        child: FutureBuilder(
                          future: getImageUrl(ref),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.waiting) {
                              return CachedNetworkImage(
                                imageUrl:snapshot.data.toString(),
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
                      Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.5),
                                ]
                            )
                        ),
                      ),
                    ],
                  ),

                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: <Widget>[
                          Text(shot['name'],style: Text1StyleBig,overflow: TextOverflow.ellipsis,),
                          Helper.emptyVSpace(10.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Icon(Icons.place,color: Colors.white,size: 20,),
                              Helper.emptyHSpace(5.0),

                              Text(shot['place'],style: Text4StyleCarousel,overflow: TextOverflow.ellipsis,),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _information()
            ]),
          )
        ],
      ),
    );
  }

  Widget _information(){
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
      children: <Widget>[
        Text("Information",style: Text5Style,),
        Helper.emptyVSpace(10.0),
        Text(shot['desc'],style: Text5StyleDesc,),
      ],
    );
  }
}
