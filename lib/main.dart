import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Pages/Screens/SignInPage.dart';
import 'Services/auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FYP',
        theme: ThemeData(
          primarySwatch: Colors.grey,
          primaryColor: Colors.grey,
          primaryColorLight: Colors.grey,

        ),
        home: AnimatedSplashScreen(
            duration: 1500,
            splash: "images/logo.png",
            nextScreen: Phoenix(child: LoginPage(),),
            splashIconSize: 200,
            animationDuration: Duration(seconds: 1),
            splashTransition: SplashTransition.fadeTransition,
            backgroundColor: '#2e368e'.toCustomColor()
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: checkUser(

          auth: Auth(),
        )
    );
  }
}
extension ColorExtension on String {
  toCustomColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}