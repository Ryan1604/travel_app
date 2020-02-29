import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:travel_app/screen/utils/utils.dart';
import 'package:travel_app/utils/helper.dart';
import 'package:travel_app/utils/style.dart';

class DestinationPage extends StatefulWidget {
  final DocumentSnapshot shot;

  const DestinationPage({Key key, this.shot}) : super(key: key);

  @override
  _DestinationPageState createState() => _DestinationPageState(this.shot);
}

class _DestinationPageState extends State<DestinationPage> {
  _DestinationPageState(this.shot);
  final DocumentSnapshot shot;

  static Future<String> getImageUrl(StorageReference url) async {
    var s = await url.getDownloadURL();
    return s.toString();
  }
  var _current = 0;
  MediaQueryData query ;
  List<Widget> _cards = [];
  bool _loading=false;

  String getProvince(){
    String province="";
    Functions.province().forEach((element) {
      if(shot['province']==element['code']){
        province = element['name'];
      }
    });
    return province;
  }

  void getCarousel()async{
    setState(() {
      _loading=true;
    });
    for(var i=0;i<shot['image'].length;i++){
      final ref =
      FirebaseStorage.instance.ref().child(shot['image'][i]);
      _cards.add(
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
          )
      );

    }
    setState(() {
      _loading=false;
    });
  }

  List<Widget> getCarouselButton(){
    List<Widget> _rows=[];
    for(var i=0;i<shot['image'].length;i++) {
      _rows.add(
          Container(
            width: _current==i?50.0:20,
            height: 5.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: _current == i ? Color.fromRGBO(255, 255, 255, 1) : Color
                    .fromRGBO(255, 255, 255, 0.4)
            ),
          )
      );
    }
    return _rows;
  }
  @override
  void initState() {
    super.initState();
    getCarousel();
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
                  !_loading?CarouselSlider(
                    enableInfiniteScroll: _cards.length>1?true:false,
                    items: _cards,
                    height: double.maxFinite,
                    viewportFraction: 1.0,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    autoPlay: true,
                    initialPage: _current,
                    autoPlayAnimationDuration: Duration(seconds: 1),
                    pauseAutoPlayOnTouch: Duration(seconds: 5),
                    aspectRatio: query.size.aspectRatio,
                    autoPlayInterval: Duration(seconds: 5),
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() {
                        _current = index;
                        print(_current);
                      });
                    },

                  ):CircularProgressIndicator(),

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
                          RatingBar(
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

                            itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                          ),
                          Helper.emptyVSpace(10.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Icon(Icons.place,color: Colors.white,size: 20,),
                              Helper.emptyHSpace(5.0),

                              Text(getProvince(),style: Text4StyleCarousel,overflow: TextOverflow.ellipsis,),
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
