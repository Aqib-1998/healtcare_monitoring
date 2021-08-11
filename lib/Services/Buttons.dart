import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  final Widget child;
  final Color color;
  final double borderRadius ;
  final double height;
  final VoidCallback onPressed;

  const CustomButton({Key key, this.color: Colors.black, this.borderRadius: 4,this.height:50.0, this.onPressed, this.child}) : super(key: key);


  @override
  Widget build(BuildContext context) {
         return Padding(
           padding: const EdgeInsets.only(left: 10,right: 10),
           child: SizedBox(
             height: height,
             child: RaisedButton(
        child: child,
        onPressed: onPressed,
        color: color,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius))
        ),

        ),
           ),
         );
  }
}

class SignInButton extends CustomButton
{
  SignInButton({
    @required String text,
    Color color,
    @required String imagePath,
    Color textColor,
    VoidCallback onPressed,
  }):super(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(imagePath),
        Text(text,style: TextStyle(color: textColor,fontSize: 15.0,fontWeight: FontWeight.bold),),
        Opacity(child: Image.asset(imagePath),opacity: 0.0,),
      ],
    ),
    color: color,
    onPressed: onPressed,
  );

}
