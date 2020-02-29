import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:random_color/random_color.dart';
import 'package:travel_app/screen/destination/detail.dart';
import 'package:travel_app/screen/foods/all_foods.dart';
import 'package:travel_app/screen/mosque/all_mosques.dart';
import 'package:travel_app/screen/mosque/detail.dart';
import 'package:travel_app/screen/result_search.dart';
import 'package:travel_app/screen/utils/custom_widget.dart';
import 'package:travel_app/screen/utils/utils.dart';
import 'package:travel_app/utils/helper.dart';
import 'package:travel_app/utils/style.dart';

import 'destination/all_destinations.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{
  ScrollController _bodyController = new ScrollController();
  bool _onTapped = false;
  final controller = new TextEditingController();
  TabController _tabController;

  List<String> _provs = [];
  List<Widget> _tabProvs= [];
  List<String> _provsCode= [];

  bool _loading = false;

  void getProv(){
    setState(() {
      _loading=true;
    });
    List<String> _provinceDummy =[];
    List<String> _prov = [];
    List<String> _provDistinct = [];
    List<String> _provsCode = [];
    Functions.province().forEach((element) {
      _provinceDummy.add(element['code']);
    });
    Stream<QuerySnapshot> getProv = Firestore.instance.collection("places").orderBy("rating",descending: true).snapshots();

    getProv.listen((event) {

      event.documents.forEach((element) { 
        _prov.add(element['province']);
      });


      _prov.forEach((element) {
        if(_provinceDummy.contains(element)){
          _provDistinct.add(element);
        }
      });
      setState(() {
        _provs.clear();
        _provs=[];
        _tabProvs.clear();
        _provsCode.clear();
      });
      Functions.province().forEach((element) {
        if(_provDistinct.contains(element['code'])){
          this._provs.add(element['name']);
          _provsCode.add(element['code']);
        }
      });
      setState(() {
        this._provsCode = _provsCode;
        this._provs = LinkedHashSet<String>.from(_provs).toList();
        _provs.forEach((element) {
          _tabProvs.add(
              Text(element)
          );

        });

        _tabController = TabController(length: _provs.length, vsync: this);

        getTabViewBody();
        _loading=false;

      });

    });

  }

  @override
  void dispose() {
    controller.dispose();
    _tabController.dispose();
    super.dispose();
  }


  void getTabViewBody(){
    List<Widget> widgets = [];
    _provsCode.forEach((element) {
        widgets.add(StreamBuilder(

          stream: Firestore.instance.collection("places").where("province",isEqualTo:element).orderBy("rating",descending: true).snapshots(),
          builder: (_,snapshot){
            if (!snapshot.hasData) return new Center(
              child: Text("Ups, no data",style: Text2Style,),
            );
            if (snapshot.data.documents.isEmpty) return new Center(
              child: Text("Ups, no data",style: Text2Style,),
            );
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.9,

              ),

              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data.documents.length<=4?snapshot.data.documents.length:4,
              padding: const EdgeInsets.only(left: 15,right: 15),
              itemBuilder: (_,i){
                return _getPlaces(snapshot.data.documents[i]);
              },
            );

          },
        ),);
    });
    setState(() {
      this.tabViewBody = widgets;
    });
  }

  List<Widget> tabViewBody=[];

  @override
  void initState() {
    super.initState();
    getProv();

    _bodyController.addListener((){
      if(_onTapped){
        setState(() {
          _bodyController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
          _onTapped=false;

        });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFedf7fa),
        body:CustomScrollView(
          controller: _bodyController,
          slivers: <Widget>[
            SliverAppBar(
              brightness: Brightness.dark,
              expandedHeight: 149,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              backgroundColor: Colors.white.withOpacity(0),
              elevation: 0,
              floating: true,
              primary: true,
              snap: true,
              flexibleSpace: _top(),
            ),
            SliverList(

            delegate: SliverChildListDelegate([
              !_loading?_best(context):Padding(
                padding: EdgeInsets.all(15),
                  child: CustomWidget.getShimmer(400, double.maxFinite)),
              _food(context),
              _mosque(context),
              ])
            ),
          ],
        )
      ),
    );
  }

  Widget _top() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF38C4FF),
              Color(0xFF0CB2FF),
              Color(0xFF38C4FF),
            ]),
      ),
      child: Container(
        child: ListView(
          padding: EdgeInsets.only(left: 25,right: 25,bottom: 20,top:25),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Helper.emptyVSpace(10.0),
            Text("DEMO",style: Text1Style,textAlign: TextAlign.center,),
            AnimatedPadding(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),

                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        spreadRadius: 2),
                  ],
                ),
                child: Center(
                  child: TextFormField(
                    onTap: (){
                      setState(() {
                        _onTapped=true;

                      });
                    },
                    controller: controller,
                    onEditingComplete: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_)=>ResultPage(result:controller.text ,)
                      ));
                    },
                    textInputAction: TextInputAction.search,
                    style: TextStyle(

                        fontFamily: FontNameDefault,
                        color: Helper.loginColor,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),

                        hintText: "DEMO",
                        hintStyle: TextStyle(color: Colors.grey[400])),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getMosques(DocumentSnapshot shot){
    final ref = FirebaseStorage.instance.ref().child(shot['image']);

    return InkWell(
    onTap: (){
      Navigator.push(context, MaterialPageRoute(
          builder: (_)=>MosquePage(shot: shot,)
      ));},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 400,
                  width: 180,
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
                      }
                      else {
                        return Center(child: CircularProgressIndicator(),);
                      }

                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: ()async{
                    GeoPoint latlong = shot['marks'];
                    Coords coords = Coords(latlong.latitude,latlong.longitude);
                    if (await MapLauncher.isMapAvailable(MapType.google)) {
                      await MapLauncher.launchMap(
                        mapType: MapType.google,
                        coords: coords,
                        title: shot['name'],
                        description: "mosque",
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF21243d),
                            Color(0xFF4d4646),
                          ]
                      ),

                    ),
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(shot['name'],style: Text2StyleMiniWhite,overflow: TextOverflow.ellipsis,),
                          Row(
                            children: <Widget>[
                              Icon(Icons.place,color: Colors.white,size: 13,),
                              Text(shot['place'],style: Text4StyleMini,overflow: TextOverflow.ellipsis,)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget _mosque(BuildContext context){
    return Container(
      height:500,
      padding: const EdgeInsets.only(top: 15,bottom: 15),

      width: double.infinity,
      child:Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 15,right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Mosques",style: Text2Style,),
                  InkWell(
                      onTap: (){
                        Navigator.push(context,MaterialPageRoute(
                            builder: (_)=>AllMosquePage()
                        ));
                      },
                      child: Text("See all",style: Text3Style,))
                ],
              ),
            ),
          ),
          Expanded(

              flex: 15,
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection("mosque").snapshots(),
                builder: (_,snapshot){
                  if (!snapshot.hasData) return new Center(
                    child: Text("Ups, no data",style: Text2Style,),
                  );
                  if (snapshot.data.documents==null) return new Center(
                    child: Text("Ups, no data",style: Text2Style,),
                  );
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:2,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 0.9,

                    ),

                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.documents.length<=4?snapshot.data.documents.length:4,
                    padding: const EdgeInsets.only(left: 15,right: 15),
                    itemBuilder: (_,i){
                      return _getMosques(snapshot.data.documents[i]);
                    },
                  );

                },
              )
          )
        ],
      ),
    );
  }
  Widget _food(BuildContext context){
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF21243d),
                Color(0xFF21243d),
              ]

          )
      ),
      height: 400,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Halal Foods",style: Text2StyleWhite,),
                  InkWell(
                      onTap: (){
                        Navigator.push(context,MaterialPageRoute(
                            builder: (_)=>AllFoodPage()
                        ));
                      },
                      child: Text("See all",style: Text3Style,))
                ],
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: StreamBuilder(
              stream: Firestore.instance.collection("foods").orderBy("rating",descending: true).snapshots(),
              builder: (_,snapshot){
                if (!snapshot.hasData) return new Center(
                  child: Text("Ups, no data",style: Text2Style,),
                );
                if (snapshot.data.documents==null) return new Center(
                  child: Text("Ups, no data",style: Text2Style,),
                );


                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.documents.length<=3?snapshot.data.documents.length:3,
                  padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
                  itemBuilder: (_,i){
                    return Functions.getData(snapshot.data.documents[i],context);
                  },
                );

              },
            ),
          )
        ],
      ),
    );
  }
  Widget _best(BuildContext context){
    return Container(
      height:570,
      padding: const EdgeInsets.only(top: 15,bottom: 15),

      width: double.infinity,
      child:Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: Divider(thickness: 1,color: Colors.blue,)),
              Expanded(child: Text("REGIONS",textAlign: TextAlign.center,style: Text3StyleMini,)),
              Expanded(child: Divider(thickness: 1,color: Colors.blue,)),
            ],
          ),
          Helper.emptyVSpace(15.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.centerLeft,
            child: TabBar(

              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.orange,
              labelPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10)
              ),
              controller: _tabController,
              tabs: _tabProvs,
            ),
          ),
          Helper.emptyVSpace(10.0),

          Expanded(

              child: Column(
                children: [

                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children:tabViewBody,
                    ),
                  ),
                  InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                          builder:(_)=>AllDestinationPage()
                        ));
                      },
                      child: Text("More ->",style: Text3Style,))
                ],
              )
          )
        ],
      ),
    );
  }
  Future<String> getImageUrl(StorageReference url)async{
    var s =  await url.getDownloadURL();
    return  s.toString();
  }
  Widget _getPlaces(DocumentSnapshot shot){

    final ref = FirebaseStorage.instance.ref().child(shot['image'][0]);
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (_)=>DestinationPage(shot: shot,)
        ));
      },
      child: Container(


        height: 400,
        width: 180,
        child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(

                  height: double.maxFinite,
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
                      }
                      else {
                        return Container();
                      }

                    },
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end:Alignment.topRight,
                          colors: [
                            RandomColor().randomColor().withOpacity(0.1),
                            RandomColor().randomColor().withOpacity(0.3),
                            RandomColor().randomColor().withOpacity(0.5),
                          ]
                      )
                  ),
                  height: double.maxFinite,
                  width: double.maxFinite,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  height: double.maxFinite,
                  width: double.maxFinite,
                ),
              ),
              Center(child: Text(shot['name'],style: Text4Style,overflow: TextOverflow.ellipsis,),)]),
      ),
    );
  }



}













