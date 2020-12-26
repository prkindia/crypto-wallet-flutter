import 'dart:async';
import 'dart:convert';
import 'package:bitsbull_app/producers/producers.dart';
import 'package:bitsbull_app/security/setpin.dart';
import 'package:bitsbull_app/service/storage.dart';
import 'package:flutter/material.dart';
import 'package:bitsbull_app/service/service.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final emailController = TextEditingController();
  final _passwordController = TextEditingController();
  PageController pageController = PageController(initialPage: 0);

  String emailText;
  bool error = false;
  bool showLoad = false;
  String name;
  String pass;
  
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon:Icon(Icons.arrow_back_ios_outlined, color:Colors.black)
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Container(
          padding: EdgeInsets.only(top:130.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey[100], Colors.blue[900]]
            )
          ),
          height: screen.height,
          width: screen.width,
          child: Stack(
            children:[
              PageView(
                allowImplicitScrolling: true,
                controller:pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  EnterEmail(screen:screen)
                ]
              ),
            ]
          )
        )
      )
    );
  }


  Widget EnterEmail({var screen}){
    return Container(
      width: screen.width,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: EdgeInsets.all(25.0),
              width:screen.width - 20,
              child: Column(
                children:[
                  Image.asset('assets/image/Template_4/credit.png', width: screen.width/3,),
                  SizedBox(height:20.0),
                  Text(
                    "Login to your account",
                    style: TextStyle(fontSize: 22),
                  ),
                  SizedBox(height:10.0),
                  Text(
                    "Enter login credentials for your account",
                    style: TextStyle(fontSize: 12, color:Colors.grey[700]),
                  ),
                  SizedBox(height:10.0),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "you@example.com",
                      labelText: "Email Address",
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                    onChanged: (val) async {
                      setState(() {
                        emailText = val;
                      });
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      hintText: "",
                      labelText: "Password",
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                    onChanged: (val) async {
                      setState(() {
                        pass = val;
                      });
                    },
                  ),
                  SizedBox(height:20.0),
                  showLoad ? SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.redAccent,
                    )
                  ):SizedBox()
                ]
              )
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Column(
              children:[
                FlatButton(
                  minWidth: screen.width - 40.0,
                  shape: RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(15.0)
                  ),
                  disabledTextColor: Colors.black,
                  child: Text(
                    "Login",
                  ),
                  splashColor: Colors.white,
                  onPressed: emailText == null || emailText.trim() == "" || pass == null || pass.trim() == "" || error ? null : () async {
                    setState(() {
                      error = true;
                    });
                    FocusScope.of(context).unfocus();
                    print(emailText);
                    setState(() {
                      showLoad = true;
                    });
                    var data = {'username' : emailText, 'password' : pass};
                    var resp = await getLogin(data);
                    print(resp);
                    if(resp['error'] != null){
                      toast(resp['error'], color: Colors.red);    
                      setState(() {
                        showLoad = false;
                        error = false;
                      });
                      return;                  
                    }
                    setState(() {
                      showLoad = false;
                      error = false;
                    });
                    toast("Authentication successful");
                    await saveLog(data:resp);

                    var isLogged = await getSaved(key:BUSER);
                    if(isLogged != null){
                      var isPinSet = await getSaved(key:"PINDATA");
                      var isFingerSet = await getSaved(key:"FINGER");
                      if(isPinSet == null || isFingerSet == null){
                        Timer(Duration(seconds:2), (){
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => SetPin()
                            )
                          );
                        });
                        return;
                      }
                      else{
                        Timer(Duration(seconds:2), (){
                          // Navigator.of(context).pushReplacement(
                          //   MaterialPageRoute(
                          //     builder: (context) => FingerScan();
                          //   )
                          // )
                        });
                      }
                    }

                  },
                  textColor: Colors.white,
                  color:Colors.black
                )
              ]
            ),
          )
        ],
      ),
    );
  }
}