import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/screen/destination/all_destinations.dart';
import 'package:travel_app/screen/foods/all_foods.dart';
import 'package:travel_app/screen/mosque/all_mosques.dart';
import 'package:travel_app/screen/utils/utils.dart';
import 'package:travel_app/utils/style.dart';

class ResultPage extends StatefulWidget {
  final String result;

  const ResultPage({Key key, this.result}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState(this.result);
}

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin{
  _ResultPageState(this.result);
  final String result;

  TabController tabController;

  List<DocumentSnapshot> listPlaces = [];
  List<DocumentSnapshot> listMosques = [];
  List<DocumentSnapshot> listFoods = [];


  void getData(){
    Stream<QuerySnapshot> streamPlaces = Firestore.instance.collection("places").snapshots();
    streamPlaces.listen((event) {
      event.documents.forEach((element) {
        if(element['name'].toString().toLowerCase().contains(result.toLowerCase())){
          setState(() {
            listPlaces.add(element);
          });
        }
      });
    });
    Stream<QuerySnapshot> streamFoods = Firestore.instance.collection("foods").snapshots();
    streamFoods.listen((event) {
      event.documents.forEach((element) {
        if(element['name'].toString().toLowerCase().contains(result.toLowerCase())){
          print(element['name']);

          setState(() {
            listFoods.add(element);
          });
        }
      });
    });
    Stream<QuerySnapshot> streamMosques = Firestore.instance.collection("mosque").snapshots();
    streamMosques.listen((event) {
      event.documents.forEach((element) {
        if(element['name'].toString().toLowerCase().contains(result.toLowerCase())){
          setState(() {
            listMosques.add(element);
          });
        }
      });
    });

  }



  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 3, vsync: this);
    getData();
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Result - $result",overflow: TextOverflow.ellipsis,),
          backgroundColor: Color(0xFF38C4FF),
          elevation: 0,
        ),
        body: Column(

          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                color: Color(0xFF38C4FF),
                child: TabBar(
                  indicatorColor: Color(0xFF21243d),
                  labelPadding:  EdgeInsets.symmetric(vertical: 20),

                  controller: tabController,
                    tabs: <Widget>[
                      Text("Destination (${listPlaces.length})"),
                      Text("Food (${listFoods.length})"),
                      Text("Mosque (${listMosques.length})"),
                    ],),
              ),
            ),
            Expanded(
              flex: 12,
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller:tabController,
                children: <Widget>[
                  _best(),
                  _food(),
                  _mosque(),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _best(){
    return Container(
      height: double.maxFinite,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("All destination contains \"$result\"",style: Text2Style,overflow: TextOverflow.ellipsis,),
                InkWell(
                    onTap: (){
                      Navigator.push(context,MaterialPageRoute(
                          builder: (_)=>AllDestinationPage(result: result,)
                      ));
                    },
                    child: Text("See all",style: Text3Style,))
              ],
            ),
          ),
          Expanded(
            child:ListView.builder(
              shrinkWrap: true,
              itemCount: listPlaces.length,
              padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
              itemBuilder: (_,i){
                return Functions.getData(listPlaces[i],context,isPlace: true);
              },
            )
          )
        ],
      ),
    );
  }

  Widget _food(){
    return Container(
      height: 400,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("All food contains \"$result\"",style: Text2Style,overflow: TextOverflow.ellipsis,),
                InkWell(
                    onTap: (){
                      Navigator.push(context,MaterialPageRoute(
                          builder: (_)=>AllFoodPage(result: result,)
                      ));
                    },
                    child: Text("See all",style: Text3Style,))
              ],
            ),
          ),
          Expanded(
            child:ListView.builder(
              shrinkWrap: true,

              itemCount: listFoods.length,
              padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
              itemBuilder: (_,i){
                return Functions.getData(listFoods[i],context);
              },
            ),
          )
        ],
      ),
    );
  }
  Widget _mosque(){
    return Container(
      height: 400,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("All mosque contains \"$result\"",style: Text2Style,overflow: TextOverflow.ellipsis,),
                InkWell(
                    onTap: (){
                      Navigator.push(context,MaterialPageRoute(
                          builder: (_)=>AllMosquePage(result: result,)
                      ));
                    },
                    child: Text("See all",style: Text3Style,))
              ],
            ),
          ),
          Expanded(
            child:ListView.builder(
              shrinkWrap: true,

              itemCount: listMosques.length,
              padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
              itemBuilder: (_,i){
                return Functions.getData(listMosques[i],context,isMosque: true);
              },
            ),
          )
        ],
      ),
    );
  }
}
