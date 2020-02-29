import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/screen/utils/utils.dart';
import 'package:travel_app/utils/style.dart';

class AllMosquePage extends StatefulWidget {
  final String result;

  const AllMosquePage({Key key, this.result}) : super(key: key);

  @override
  _AllMosquePageState createState() => _AllMosquePageState();
}

class _AllMosquePageState extends State<AllMosquePage> {
  final controller = TextEditingController();
  var _filter = "";
  @override
  void initState() {
    super.initState();
    if(widget.result!=null){
      _filter = widget.result;
      controller.text = widget.result;
    }
    controller.addListener(() {
      setState(() {
        _filter = controller.text;
      });
    });
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Mosques"),
          backgroundColor: Color(0xFF38C4FF),

        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                    hintText: "Search Mosque..."
                ),
              ),
            ),
            Expanded(
              child:StreamBuilder(
                stream:Firestore.instance.collection("mosque").snapshots(),
                builder: (_,snapshot){
                  if (!snapshot.hasData) return new Center(
                    child: Text("Ups, no data",style: Text2Style,),
                  );
                  if (snapshot.data.documents==null) return new Center(
                    child: Text("Ups, no data",style: Text2Style,),
                  );


                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.documents.length,
                    padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
                    itemBuilder: (_,i){
                      return _filter.toLowerCase()==""||_filter.toLowerCase().isEmpty?Functions.getData(snapshot.data.documents[i],context,isMosque: true)
                          : snapshot.data.documents[i]['name'].toString().toLowerCase().contains(_filter.toLowerCase())? Functions.getData(snapshot.data.documents[i],context,isMosque: true)
                          :Container();
                    },
                  );

                },
              ),
            )
          ],
        ),
      ),
    );
  }




}
