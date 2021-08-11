import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase/Services/Validators.dart';
import 'package:firebase/Services/auth.dart';
import 'package:firebase/Services/platform_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  final AuthBase auth;
  const SignUpScreen({Key key,@required this.auth}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up screen",style: TextStyle(color: Colors.white),),
        elevation: 2.0,
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 20,
            child: EmailSignInForm(
              auth: auth,
            ),
        ),
      ),
    );
  }
}

enum EmailSignInFormType{signIn,register}
bool hidePasswordText = true;
bool hideConfirmPasswordText = true;
bool hideIcon = false;
bool hideIconConfirm = false;
class EmailSignInForm extends StatefulWidget with EmailandPasswordValidators{

  final AuthBase auth;

  EmailSignInForm({Key key,@required this.auth}) : super(key: key);
  @override
  _EmailSignInFormState createState() => _EmailSignInFormState();
}
class _EmailSignInFormState extends State<EmailSignInForm> {
  final FirebaseAuth getName = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();
  final TextEditingController _ConfirmPasswordEditingController = TextEditingController();
  final TextEditingController _OTPController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String get _email => _emailEditingController.text;
  String get _password => _passwordEditingController.text;
  String get _name => _nameController.text;

  bool _submited = false;
  bool _isLoading = false;
  bool _OTP = false;
  void _submit() async{
    setState(() {
      _submited = true;
      _isLoading = true;
    });
    try {
        await widget.auth.CreateUserWithEmailandPassword(_email, _password);

         if(_name != null){
        await fireStore.collection("users").doc(getName.currentUser.uid).set({
          'name' : _name,
          'email': _email,
          'uid': getName.currentUser.uid

        });
         }
        Navigator.of(context).pop();

    }catch(e){
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

  @override
  Widget build(BuildContext context) {

    bool submitButtonEnable = widget.emailValidator.isValid(_email) && widget.passValidator.isValid(_password) && !_isLoading && _OTPController.text.isNotEmpty && verifyOTP() && _passwordEditingController.text == _ConfirmPasswordEditingController.text;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailTextField(),
            SizedBox(height: 8.0),
            _buildNameField(),
            SizedBox(height: 8.0),
            _buildPasswordTextField(),
            SizedBox(height: 8.0),
            _buildConfirmPassField(),
            SizedBox(height: 8.0),
            _buildVerifyOTPTextField(),
            SizedBox(height: 8.0),
            _buildCreateAnAccountButton(submitButtonEnable),
            SizedBox(height: 8.0),
            _buildAlreadyHaveButton(context),
          ],
        ),
      ),
    );
  }



















  TextField _buildNameField() {
    return TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "Name",
            //
          ),
          textInputAction: TextInputAction.done,
          onChanged: (name) => _updateSetState(),
        );
  }

  TextField _buildConfirmPassField() {
    return TextField(

        controller: _ConfirmPasswordEditingController,
        decoration: InputDecoration(
            labelText: "Confirm Password",
            errorText: _ConfirmPasswordEditingController.text != _passwordEditingController.text && _passwordEditingController.text.isNotEmpty ?"Password doesn\'t match" :null,
            enabled: _isLoading == false,
            suffixIcon: InkWell(onTap: _updateConfirmButtonState ,child:Icon(hideIconConfirm ? Icons.visibility_off: Icons.visibility), ),
        ),
      textInputAction: TextInputAction.next,
      obscureText: hideConfirmPasswordText? true:false,
      onChanged: (confirmpass) => _updateSetState(),
      onEditingComplete: _submit
    );
  }

  TextField _buildVerifyOTPTextField() {
    return TextField(
            controller: _OTPController,
            decoration: InputDecoration(
                labelText: "enter OTP (press send OTP)",
                enabled: _isLoading == false && _OTP ==  true,
                //
            ),
            textInputAction: TextInputAction.done,
            onChanged: (otp) => _updateSetState(),
            onEditingComplete: _submit,
            keyboardType: TextInputType.number,
          );
  }

  TextButton _buildAlreadyHaveButton(BuildContext context) {
    return TextButton(
        child: Text("Already have an account?"),
        onPressed:()=> Navigator.of(context).pop() ,
      );
  }

  ElevatedButton _buildCreateAnAccountButton(bool submitButtonEnable) {
    return ElevatedButton(

            child: Text("Create an Account",style: TextStyle(fontSize: 25,color: Colors.white),),
            onPressed: submitButtonEnable? _submit: null,
            style: ButtonStyle( backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.indigo;
                }
                return null; // Use the component's default.
              },
            ),
            ),
          );
  }

  TextField _buildPasswordTextField() {
    bool showErrorText = _submited && !widget.passValidator.isValid(_password);
    return TextField(
            controller: _passwordEditingController,
            decoration: InputDecoration(
            labelText: "Password",
            errorText:  showErrorText?  widget.invalidPasswordErrorText:null,
                enabled: _isLoading == false,
              suffixIcon: InkWell(onTap: _updateButtonState ,child:Icon(hideIcon ? Icons.visibility_off: Icons.visibility), )
              // suffixIcon:  TextButton( child: Icon(hideText ? Icons.visibility: Icons.visibility_off),),
          ),
          textInputAction: TextInputAction.next,

          obscureText: hidePasswordText? true:false,
          onChanged: (password) => _updateSetState(),
          onEditingComplete: _submit,
        );
  }

  TextField _buildEmailTextField() {
    bool showErrorText = _submited && !widget.emailValidator.isValid(_email);
    return TextField(
          controller: _emailEditingController,
          decoration: InputDecoration(
            labelText: "Email",
            hintText: "example: abc@abc.com",
            errorText: showErrorText? widget.invalidEmailErrorText: null,
            enabled: _isLoading == false ,
            suffixIcon: TextButton(child: Text('Send OTP'),onPressed: sendOtp,),
          ),
          onChanged: (email) => _updateSetState(),
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        );
  }

  void _updateSetState() {
    setState(() {

    });
  }

  void sendOtp()async{

    ///Accessing the EmailAuth class from the package
    EmailAuth.sessionName = "Sample";
    ///a boolean value will be returned if the OTP is sent successfully

      var data = await EmailAuth.sendOtp(
          receiverMail: _emailEditingController.text);

    if(data){
      final snackBar = SnackBar(content: Text('OTP has been sent. Please check your email!'));
       ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _OTP = true;
      _updateSetState();
    }else{
      final snackBar = SnackBar(content: Text('OTP sending failed!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
  ///create a bool method to validate if the OTP is true
  bool verifyOTP(){
    var res =  EmailAuth.validate(receiverMail:  _emailEditingController.text, userOTP: _OTPController.text);//pass in the OTP typed in
    if(res){return true;}
    else {return false;}
  }

  void _updateButtonState() {
    setState(() {
      hideIcon = !hideIcon;
      hidePasswordText = !hidePasswordText;
    });
  }
  void _updateConfirmButtonState() {
    setState(() {
      hideIconConfirm = !hideIconConfirm;
      hideConfirmPasswordText = !hideConfirmPasswordText;
    });
  }
}
