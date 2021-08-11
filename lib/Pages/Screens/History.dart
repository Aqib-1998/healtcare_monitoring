import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


class History extends StatefulWidget {
  final User userID ;

  const History({Key key, @required this.userID}) : super(key: key);
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  Future getData ()async{
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore.collection("users").doc(widget.userID.uid).collection("average").orderBy('created',descending: true).get();
    return qn.docs;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 30),),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
      ),
      body: Container(
        child: FutureBuilder(
          future: getData(),
          builder: (_,snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator());
            }
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator());
            }
            if(snapshot.data.length == 0){
              return Center(child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Flexible(child: Text("Please press Record button to measure the average values for your vital signs. In case you do not have record button, please sign-in using Google account or via Email",style: TextStyle(fontSize: 17),),),
              ),);
            }
            else{
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (_,index){
                      return Card(
                        color: Colors.white70,
                        elevation: 5,

                        child: ListTile(


                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Text("Feeling =   ${snapshot.data[index].data()["feeling"].toString()}",style: TextStyle(color: Colors.black),),
                              Text("D/T =   ${snapshot.data[index].data()["Time"].toString()}",style: TextStyle(color: Colors.black),),
                            ],
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("BPM =  ${snapshot.data[index].data()["avgBPM"].toString()}",style: TextStyle(color: Colors.black),),
                              Text("SPO2 =  ${snapshot.data[index].data()["avgSPO2"].toString()}",style: TextStyle(color: Colors.black),),
                              Text("Temp =  ${snapshot.data[index].data()["avgTemp"].toString()}",style: TextStyle(color: Colors.black),),

                            ],
                          )

                        ),
                      );

                });
            }

          },
        )

    ),

    );
  }
}
