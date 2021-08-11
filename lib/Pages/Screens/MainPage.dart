import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/Services/auth.dart';
import 'package:firebase/Services/platform_alert_dialog.dart';
import 'package:firebase/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:emoji_feedback/emoji_feedback.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'History.dart';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'SignInPage.dart';
import 'connection.dart';

int feeling = 2;
int heartRate = 0;
int spo2 = 0;
double temperature = 0;
DateTime now = DateTime.now();
String formattedDate = DateFormat('dd MMM, yyyy').format(now);
String formattedTime;
bool enableFloating = false;
String mood;

final FirebaseAuth getName = FirebaseAuth.instance;
final fireStore = FirebaseFirestore.instance;

String name, photo;
List<int> traceX = [];
AuthBase auth;
BluetoothConnection connection;

bool get isConnected => connection != null && connection.isConnected;

Future<String> createUserFireStoreGoogle(User user) async {
  String retVal = "error";
  try {
    await fireStore
        .collection("users")
        .doc(user.uid)
        .set({'name': user.displayName, 'email': user.email, 'uid': user.uid});
    retVal = "success";
  } catch (e) {
    print(e);
  }
  return retVal;
}

class MainPage extends StatefulWidget {
  final AuthBase auth;

  const MainPage({Key key, @required this.auth}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

Timer _everyMin;

class _MainPageState extends State<MainPage> {
  final ref = FirebaseDatabase.instance.reference().child("fyp");

  void initState() {
    super.initState();
    _getData();
    _everyMin = Timer.periodic(Duration(minutes: 1), (Timer t) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  void _getData() {
    ref.once().then((DataSnapshot data) {
      setState(() {
        temperature = data.value["temperature"];
        spo2 = data.value["SPO2"];
        heartRate = data.value["BPM"];
        name = getName.currentUser.displayName;
        photo = getName.currentUser.photoURL;

        if (name != null) {
          enableFloating = true;
          createUserFireStoreGoogle(getName.currentUser);
        } else if (name == "" || name == null) {
          print("this if loop is running");
          // name = FirebaseFirestore.instance.collection("users").doc(getName.currentUser.uid).collection("name").get();
          enableFloating = true;
          FirebaseFirestore.instance
              .collection('users')
              .doc(getName.currentUser.uid)
              .get()
              .then((DocumentSnapshot documentSnapshot) {
            if (documentSnapshot.exists) {
              print("exist loop is running!!!!!!!!!!!!!");
              setState(() {
                name = documentSnapshot.data()['name'].toString();
                photo =
                    "https://firebasestorage.googleapis.com/v0/b/testfyp-7f60c.appspot.com/o/avatar.jpg?alt=media&token=2e0f23de-3481-4015-9f99-4c741aa27029";
              });
            } else {
              print("else loop!!!!!! ");
              setState(() {
                enableFloating = false;
                name = "Anonymous";
                photo =
                    "https://firebasestorage.googleapis.com/v0/b/testfyp-7f60c.appspot.com/o/avatar.jpg?alt=media&token=2e0f23de-3481-4015-9f99-4c741aa27029";
              });
            }
          });
        }
      });
    });
  }

  var counterStream =
      Stream<int>.periodic(Duration(milliseconds: 100), (x) => x)
          .take(999999999);

  Future<void> _signOut() async {
    try {
      await widget.auth.signOut().then((res) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            ModalRoute.withName('/'));
        Phoenix.rebirth(context);
      });
    } catch (e) {}
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await PlatformAlertDialog(
      title: !isConnected ? 'LogOut' : 'Disconnect',
      content: 'Are you sure?',
      defaultActionText: !isConnected ? 'LogOut' : 'Disconnect',
      cancelActionText: 'Cancel',
    ).show(context);
    if (didRequestSignOut == true) {
      _signOut();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          ModalRoute.withName('/'));
      Phoenix.rebirth(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: InkWell(
          child: Icon(
            Icons.bluetooth,
            color: '#c1c2df'.toColor(),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Bluetooth()),
            );
          },
        ),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => History(
                            userID: getName.currentUser,
                          )));
            },
            child:
                Text("History", style: TextStyle(color: '#c1c2df'.toColor())),
          )
        ],
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            // child: Image.asset(
            //   'images/main.png',
            //   width: MediaQuery.of(context).size.width,
            //   height: MediaQuery.of(context).size.height,
            //   fit: BoxFit.fill,
            // )
            color: Colors.indigo,
          ),
          Container(
            height: MediaQuery.of(context).size.height / 2.75,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 12, right: 12, top: 40, bottom: 30),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 9.75,
                      width: MediaQuery.of(context).size.width / 1.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: '#7070b5'.toColor(),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                            spreadRadius: 2.0,
                            offset: Offset(
                                5.0, 2.0), // shadow direction: bottom right
                          )
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ElevatedButton(
                                onPressed: () => _confirmSignOut(context),
                                child: !isConnected
                                    ? Text(
                                        "Signout",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Text("Disconnect"),
                                style: TextButton.styleFrom(
                                  backgroundColor: '#bf4343'.toColor(),
                                ),
                              ),
                            ),
                            Flexible(
                                child: Text(
                              name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )),
                            Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage: NetworkImage("$photo"),
                                  backgroundColor: Colors.transparent,
                                ))
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$formattedDate",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: '#c1c2df'.toColor()),
                          ),
                          Text(
                            "Hello There! ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 36,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ]),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: StreamBuilder(
                stream: ref.onValue,
                builder: (context, snap) {
                  if (snap.data == null) {
                    return CircularProgressIndicator();
                  }
                  double temp =
                      snap.data.snapshot.value['Temperature'].toDouble();
                  return Container(
                    height: MediaQuery.of(context).size.height / 1.55,
                    margin: EdgeInsets.only(top: 12, right: 9, left: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 15,
                          spreadRadius: 0.0,
                          offset: Offset(
                              5.0, 5.0), // shadow direction: bottom right
                        )
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(12),
                                alignment: Alignment.center,
                                height: MediaQuery.of(context).size.height / 10,
                                child: Text(
                                  "How are you feeling today ?",
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              EmojiFeedback(onChange: (index) {
                                feeling = index;
                              }),
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 4, left: 4),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(8),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                6,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3.25,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          color: '#f2766c'.toColor(),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              blurRadius: 5,
                                              spreadRadius: 2.0,
                                              offset: Offset(5.0,
                                                  2.0), // shadow direction: bottom right
                                            )
                                          ],
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Column(
                                            children: [
                                              Container(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .heartbeat,
                                                        color:
                                                            '#fce4e2'.toColor(),
                                                      ),
                                                      Text(
                                                        "Heartrate",
                                                        style: TextStyle(
                                                            color: '#fce4e2'
                                                                .toColor(),
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "${snap.data.snapshot.value['BPM']}",
                                                      style: TextStyle(
                                                          color: '#fce4e2'
                                                              .toColor(),
                                                          fontSize: 35,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      "BPM",
                                                      style: TextStyle(
                                                          color: '#fce4e2'
                                                              .toColor(),
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(8),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                6,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3.25,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          color: '#f89659'.toColor(),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              blurRadius: 5,
                                              spreadRadius: 2.0,
                                              offset: Offset(5.0,
                                                  2.0), // shadow direction: bottom right
                                            )
                                          ],
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Column(
                                            children: [
                                              Container(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Icon(
                                                        FontAwesomeIcons.tint,
                                                        color:
                                                            '#fde0cd'.toColor(),
                                                      ),
                                                      Text(
                                                        "SPO2",
                                                        style: TextStyle(
                                                            color: '#fde0cd'
                                                                .toColor(),
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "${snap.data.snapshot.value['SPO2']}",
                                                      style: TextStyle(
                                                          color: '#fde0cd'
                                                              .toColor(),
                                                          fontSize: 35,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      "%",
                                                      style: TextStyle(
                                                          color: '#fde0cd'
                                                              .toColor(),
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(8),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                6,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3.25,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          color: '#d44a4a'.toColor(),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              blurRadius: 5,
                                              spreadRadius: 2.0,
                                              offset: Offset(5.0,
                                                  2.0), // shadow direction: bottom right
                                            )
                                          ],
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Column(
                                            children: [
                                              Container(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .temperatureLow,
                                                        color:
                                                            '#f2c9c9'.toColor(),
                                                      ),
                                                      Flexible(
                                                          child: Text(
                                                        "Temperature",
                                                        style: TextStyle(
                                                            color: '#f2c9c9'
                                                                .toColor(),
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${temp.toString()}',
                                                      style: TextStyle(
                                                          color: '#f2c9c9'
                                                              .toColor(),
                                                          fontSize: 28,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      "F",
                                                      style: TextStyle(
                                                          color: '#f2c9c9'
                                                              .toColor(),
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, right: 8),
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  height:
                                      MediaQuery.of(context).size.height / 2.5,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: '#4b57ab'.toColor(),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 5,
                                        spreadRadius: 2.0,
                                        offset: Offset(5.0,
                                            2.0), // shadow direction: bottom right
                                      )
                                    ],
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      children: [
                                        StreamBuilder(
                                            stream: counterStream,
                                            builder: (context, snap) {
                                              // int ecg = snap.data.snapshot.value;
                                              int ecg;
                                              if (isConnected) {
                                                ecg = int.parse(ecgVal
                                                    .substring(1, ecgVal.length)
                                                    .trim());

                                                traceX.add(ecg);
                                              }

                                              if (traceX.length >=
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.75) {
                                                traceX.clear();
                                                traceX.add(ecg);
                                              }
                                              return Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2.50,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .heartbeat,
                                                            color: '#c9cde6'
                                                                .toColor(),
                                                          ),
                                                          Text(
                                                            "ECG",
                                                            style: TextStyle(
                                                                color: '#c9cde6'
                                                                    .toColor(),
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                      // Center(
                                                      //   child: Text("ECG = ${ecgVal.substring(1,ecgVal.length).trim()}",style: TextStyle(color: Colors.white),),
                                                      // )
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              3.75,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20)),
                                                            color: Colors.white,
                                                          ),
                                                          child: !isConnected
                                                              ? Center(
                                                                  child:
                                                                      Container(
                                                                    color: '#4b57ab'
                                                                        .toColor(),
                                                                    height: double
                                                                        .infinity,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .bluetooth_disabled,
                                                                        size:
                                                                            50,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Oscilloscope(
                                                                  backgroundColor:
                                                                      '#4b57ab'
                                                                          .toColor(),
                                                                  traceColor:
                                                                      Colors
                                                                          .white,
                                                                  strokeWidth:
                                                                      1.5,
                                                                  yAxisMax: double.parse(traceX
                                                                      .reduce(
                                                                          (max))
                                                                      .toString()),
                                                                  yAxisMin: double.parse(traceX
                                                                      .reduce(
                                                                          (min))
                                                                      .toString()),
                                                                  dataSet:
                                                                      traceX,
                                                                ),
                                                          // double.parse(traceX.reduce((max)).toString()),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder(
          stream: ref.onValue,
          builder: (context, snap) {
            if (snap.data == null) return CircularProgressIndicator();

            List<double> avgTempList = [];
            List<int> avgSPO2List = [];
            List<int> avgBPMList = [];
            double calAvgTemp, calAvgSPO2, calAvgBPM;
            double avgTemp, avgSPO2, avgBPM;
            temperature = snap.data.snapshot.value['Temperature'].toDouble();
            spo2 = snap.data.snapshot.value['SPO2'];
            heartRate = snap.data.snapshot.value['BPM'];
            return Visibility(
              visible: enableFloating,
              child: FloatingActionButton.extended(
                label: const Text('Record'),
                backgroundColor: '#7070b5'.toColor(),
                onPressed: () {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        Future.delayed(Duration(seconds: 10), () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => History(
                                        userID: getName.currentUser,
                                      )));
                        });
                        return AlertDialog(
                          title: Text("Sit tight!"),
                          content: Text(
                              "Please make sure you do not move your finger too much while we are generating the average values"),
                          actions: [
                            CircularCountDownTimer(
                              duration: 10,
                              initialDuration: 0,
                              controller: CountDownController(),
                              width: MediaQuery.of(context).size.width / 10,
                              height: MediaQuery.of(context).size.height / 10,
                              ringColor: Colors.grey[300],
                              ringGradient: null,
                              fillColor: Colors.indigo,
                              fillGradient: null,
                              backgroundColor: null,
                              backgroundGradient: null,
                              strokeWidth: 2.0,
                              strokeCap: StrokeCap.round,
                              textStyle: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold),
                              textFormat: CountdownTextFormat.S,
                              isReverse: true,
                              isReverseAnimation: false,
                              isTimerTextShown: true,
                              autoStart: true,
                              onStart: () async {
                                avgBPMList.clear();
                                avgSPO2List.clear();
                                avgTempList.clear();

                                for (int a = 0; a < 10; a++) {
                                  await Future.delayed(Duration(seconds: 1));
                                  avgTempList.add(temperature);
                                  avgSPO2List.add(spo2);
                                  avgBPMList.add(heartRate);
                                  calAvgTemp = avgTempList
                                          .reduce((num a, num b) => a + b) /
                                      avgTempList.length;
                                  calAvgSPO2 = avgSPO2List
                                          .reduce((num a, num b) => a + b) /
                                      avgSPO2List.length;
                                  calAvgBPM = avgBPMList
                                          .reduce((num a, num b) => a + b) /
                                      avgBPMList.length;
                                }
                              },
                              onComplete: () async {
                                setState(() {
                                  now = DateTime.now();
                                });
                                formattedTime =
                                    DateFormat('dd MMM, yyyy – kk:mm')
                                        .format(now);

                                if (feeling == 0) {
                                  mood = "Terrible";
                                } else if (feeling == 1) {
                                  mood = "Bad";
                                } else if (feeling == 2) {
                                  mood = "OK";
                                } else if (feeling == 3) {
                                  mood = "Good";
                                } else if (feeling == 4) {
                                  mood = "Awesome";
                                }

                                avgTemp = roundDouble(calAvgTemp, 2);
                                avgSPO2 = roundDouble(calAvgSPO2, 2);
                                avgBPM = roundDouble(calAvgBPM, 2);
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(getName.currentUser.uid)
                                    .collection("/average")
                                    .add({
                                  'avgTemp': avgTemp,
                                  'avgSPO2': avgSPO2,
                                  'avgBPM': avgBPM,
                                  'feeling': mood,
                                  'Time': formattedTime,
                                  'created': Timestamp.now()
                                });

                                // await FirebaseFirestore.instance.collection("users").doc(getName.currentUser.uid).collection("average").doc().set({
                                //   'avgTemp' : avgTemp,
                                //   'avgSPO2' : avgSPO2,
                                //   'avgBPM' : avgBPM,
                                //
                                //
                                //
                                // });
                              },
                            )
                          ],
                        );
                      });
                },
              ),
            );
          }),
    );
  }
}

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

double roundDouble(double value, int places) {
  double mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

class Bluetooth extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: FlutterBluetoothSerial.instance.requestEnable(),
        builder: (context, future) {
          if (future.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Container(
                height: double.infinity,
                child: Center(
                  child: Icon(
                    Icons.bluetooth_disabled,
                    size: 200.0,
                    color: Colors.blue,
                  ),
                ),
              ),
            );
          } else if (future.connectionState == ConnectionState.done) {
            // return MyHomePage(title: 'Flutter Demo Home Page');
            return Proceed();
          } else {
            return Proceed();
          }
        },
        // child: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class Proceed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Connection'),
      ),
      body: SelectBondedDevicePage(
        onChatPage: (device1) {
          BluetoothDevice device = device1;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return EcgPage(
                  server: device,
                );
              },
            ),
          );
        },
      ),
    ));
  }
}

String ecgVal = '';

class EcgPage extends StatefulWidget {
  final BluetoothDevice server;

  const EcgPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Value {
  String value;

  _Value(this.value);
}

class _ChatPage extends State<EcgPage> {
  List<_Value> values = List<_Value>();
  String _messageBuffer = '';

  bool isConnecting = true;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((e) {
      print('Cannot connect, exception occurred');
      print(e);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List list = values.map((_message) {
      return Container(
        child: Text(
            (text) {
              if (text.length == 5) {
                ecgVal = text;
              }
              // else if(text.length >5){
              //   ecgVal = text.substring(text.length -5,text.length);
              //   if(ecgVal.contains('E')){
              //     ecgVal = '00000';
              //   }
              // }

              return text;
            }(_message.value.trim()),
            style: TextStyle(color: Colors.black)),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: (isConnecting
              ? Text('Connecting  to ' + widget.server.name + '...')
              : isConnected
                  ? Text('Live  with ' + widget.server.name)
                  : Text('log with ' + widget.server.name))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("${ecgVal.substring(1, ecgVal.length).trim()}"),
            Text("connected!"),
            Text("${ecgVal.length}"),
            FlatButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainPage(
                                auth: auth,
                              )));
                },
                child: Text("Main Page")),
            // FlatButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage(auth: auth,)));}, child: Text("Main Page")),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;
    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        values.add(
          _Value(
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}
