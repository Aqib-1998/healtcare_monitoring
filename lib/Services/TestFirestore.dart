import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> temp(String temperature)async{
  CollectionReference tempo = FirebaseFirestore.instance.collection('temperature');
  tempo.add({"temp": temperature});
  return;
}