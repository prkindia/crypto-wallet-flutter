import 'package:bitsbull_app/service/service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget SplashCard({var screen, String assetUrl, String text, String desc}){
  return Container(
    width: screen.width,
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/image/bitsbull_logo.png', width: screen.width/2+30,),
        Image.network(
          baseUrl+'banner/'+assetUrl,
          fit: BoxFit.fill,
          width: screen.width - 30,
        ),
        SizedBox(height:30.0),
        RobText(text, style: TextStyle(fontSize: 35.0, color:Colors.white),),
        SizedBox(height:20.0),
        RobText(
          desc,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 12.0
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}


Widget Input({String hint, TextAlign textAlign, String errorText, TextStyle style, TextStyle hintStyle, TextStyle labelStyle, TextEditingController controller, String label, Widget prefix, int max, Function onChanged, TextInputType input}){
  return TextFormField(
    controller: controller,
    keyboardType: input,
    decoration: InputDecoration(
      hintText: hint,
      labelText: label,
      // contentPadding: EdgeInsets.all(10.0),
      prefixIcon: prefix,
      hintStyle: GoogleFonts.quicksand(textStyle: hintStyle),
      labelStyle: GoogleFonts.quicksand(textStyle: labelStyle),
      errorText: errorText
    ),
    maxLength: max,
    style: GoogleFonts.quicksand(textStyle: style),
    onChanged: onChanged,
  );
}

Widget RobinCard({Widget child, double width}){
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: child
  );
}

Text RobText(String txt, {var style, var textAlign}){
  return Text(txt, style:GoogleFonts.rubik(textStyle:style), textAlign: textAlign);
}

ShapeBorder Round({double radii}){
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radii!=null?radii:15.0)
  );
}

TextStyle Common({var style}){
  return GoogleFonts.quicksand(textStyle: style);
}

BoxDecoration Box({var shape}){
  return BoxDecoration(
    borderRadius: shape,
    gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color.fromRGBO(78, 2, 251, 1), Color.fromRGBO(94,47,199, 1)]
    )
  );
}
