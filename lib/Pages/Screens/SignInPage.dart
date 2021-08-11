import 'package:firebase/Services/Validators.dart';
import 'package:firebase/Services/auth.dart';
import 'package:firebase/Services/platform_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../Services/Buttons.dart';
import 'MainPage.dart';
import 'SignUpPage.dart';


class checkUser extends StatelessWidget {
  final AuthBase auth;

  const checkUser( {Key key,@required this.auth}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return StreamBuilder<giveUser>(
      stream: auth.onAuthStateChanged,
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.active){
          giveUser user = snapshot.data;
          if(user == null){
            return UI(
              auth: auth,
            );
          }
          return MainPage(
            auth: auth,
          );

        }else{
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

}



class UI extends StatefulWidget  with EmailandPasswordValidators{
  final AuthBase auth;
   UI({Key key,@required this.auth}) : super(key: key);
  @override
  _UIState createState() => _UIState();
}
class _UIState extends State<UI> {
  Future<void> _signinannonymously() async{
    try {
      await widget.auth.signInAnonymously();
    } catch(e){
      print(e.toString());
    }
  }
  Future<void> _signInWithGoogle() async{
    try {
      await widget.auth.signInWithGoogle();
    } catch(e){
      print(e.toString());
    }
  }
  Auth auth;
  User user;
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();
  String get _email => _emailEditingController.text;
  String get _password => _passwordEditingController.text;
  bool _submited = false;
  bool _isLoading = false;
  void _submit() async{
    setState(() {
      _submited = true;
      _isLoading = true;
    });
    try {
        await widget.auth.SignInWithEmailandPassword(_email, _password);
        Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (context,) =>MainPage(auth: auth,),fullscreenDialog: true));

      Navigator.of(context).pop();
    } catch(e){
      PlatformAlertDialog(
        title: 'Sign in Failed!',
        content: e.code,
        defaultActionText: 'OK',

      ).show(context);
    } finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _SignInWithEmail(BuildContext context){
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context,) =>SignUpScreen(auth: widget.auth,),fullscreenDialog: true),
    );
  }
  @override
  Widget build(BuildContext context) {
    bool submitButtonEnable = widget.emailValidator.isValid(_email) && widget.passValidator.isValid(_password) && !_isLoading;
    bool showErrorText = _submited && !widget.passValidator.isValid(_password);
    bool showErrorText2 = _submited && !widget.emailValidator.isValid(_email);
    return Scaffold(

      body: SafeArea(

        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: '#2e368e'.toColor(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 200,
                    width: 200,
                    child: Center(child: Image.asset("images/logo.png"))),
                SizedBox(height: 48,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2,
                    color: '#5754a1'.toColor(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(

                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8,right: 8),
                            child: TextField(
                              controller: _emailEditingController,
                              style: TextStyle(color: Colors.white70),
                              decoration: InputDecoration(
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: '#9b94c6'.toColor()),
                                  hintStyle: TextStyle(color: '#9b94c6'.toColor()),
                                  hintText: "example: abc@abc.com",
                                  errorText: showErrorText2? widget.invalidEmailErrorText: null,
                                  enabled: _isLoading == false
                              ),
                              onChanged: (email) => _updateSetState(),
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          SizedBox(height: 8,),
                          Padding(
                            padding: const EdgeInsets.only(left: 8,right: 8),
                            child: TextField(
                              controller: _passwordEditingController,
                              style: TextStyle(color: Colors.white70),
                              decoration: InputDecoration(
                                  labelText: "Password",
                                  labelStyle: TextStyle(color: '#9b94c6'.toColor()),
                                  errorText:  showErrorText?  widget.invalidPasswordErrorText:null,
                                suffixIcon: InkWell(onTap: _updateButtonState ,child:Icon(hideIcon ? Icons.visibility_off: Icons.visibility,color: '#9b94c6'.toColor(),)),
                                  enabled: _isLoading == false
                              ),
                              textInputAction: TextInputAction.done,
                              obscureText: hidePasswordText? true:false,
                              onChanged: (password) => _updateSetState(),
                              onEditingComplete: _submit,
                            ),
                          ),
                          SizedBox(height: 16 ,),
                          ElevatedButton(
                            child: Text("Sign In",style: TextStyle(fontSize: 25,color: Colors.white),),
                            onPressed: submitButtonEnable? _submit: null,
                            style: submitButtonEnable? ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return '#2a2e75'.toColor();
                                }
                                return  '#2a2e75'.toColor(); // Use the component's default.
                              },
                            ),
                            ):ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return '#5754a1'.toColor();
                                  }
                                  return  '#5754a1'.toColor(); // Use the component's default.
                                },
                              ),
                            ) ,
                          ),
                          SizedBox(height: 8,),
                          TextButton(

                            child: Text("Create a new account!",style: TextStyle(color: Colors.white),),
                            onPressed: ()=>_SignInWithEmail(context) ,
                          ),
                          SizedBox(height: 8,),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(child: Text("Or",style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w500))),

                SizedBox(height: 8,),
                SignInButton(
                  text: "Login with Google",
                  imagePath: 'images/google-logo.png',
                  textColor: Colors.black87,
                  color: Colors.white,
                  onPressed: _signInWithGoogle,
                ),
                SizedBox(height: 8,),
                CustomButton(
                  color: Colors.blueGrey,
                  child: Text("Login annonymously",style: TextStyle(color: Colors.white,fontSize: 15.0,fontWeight: FontWeight.bold),),
                  onPressed: _signinannonymously,
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
  void _updateSetState() {
    setState(() {

    });
  }
  void _updateButtonState() {
    setState(() {
      hideIcon = !hideIcon;
      hidePasswordText = !hidePasswordText;
    });
  }
}
