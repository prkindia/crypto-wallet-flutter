import 'dart:async';

import 'package:bitsbull_app/elements/elements.dart';
import 'package:bitsbull_app/app/bitsbull.dart';
import 'package:bitsbull_app/producers/producers.dart';
import 'package:bitsbull_app/service/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class SetPin extends StatefulWidget {
  @override
  _SetPinState createState() => _SetPinState();
}

class _SetPinState extends State<SetPin>{

  String pin;
  bool showLoad = false;
  bool hide = false;

  bool fingerAuthenticated = false;
  bool timerOn = false;
  String tim = "0";

  PageController pageController = PageController(initialPage: 0);
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;

    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return isAvailable;

    isAvailable
        ? print('Biometric is available!')
        : print('Biometric is unavailable.');
    if(!isAvailable){
      await save(key:FINGER, data:'false');
    }
    return isAvailable;
  }

  Future<void> _getListOfBiometricTypes() async {
    List<BiometricType> listOfBiometrics;
    try {
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    print(listOfBiometrics);
  }

  Future<void> _authenticateUser() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason:
            "Please authenticate to have finger lock login to BitsBull wallet",
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e.code);
      toast("Too many failed attempts", color:Colors.red);
      setState(() {
        timerOn = true;
        tim = "30";
      });
      Timer.periodic(Duration(seconds: 1), (timer) {
        var now = int.parse(tim);
        setState(() {
          tim = (now-1).toString();
        });
        if(now == 1){
          setState(() {
            timerOn = false;
          });
          timer.cancel();
        }
      });
      print(e);
    }

    if (!mounted) return;

    isAuthenticated
        ? print('User is authenticated!')
        : print('User is not authenticated.');

    if (isAuthenticated) {
      setState(() {
        fingerAuthenticated = true;
        showLoad = true;
      });

      await save(key:FINGER, data:'true');

      Timer(Duration(milliseconds:1000), (){
        cancel(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainBitsBull()
          )
        );
      });

    }
  }

  init() async {
    var isPinSet = await getSaved(key:PIN);
    var isFingerSet = await getSaved(key:PIN);

    if(isPinSet != null){
      pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn
      );
    }
  }

  @override
  Widget build(BuildContext context){
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromRGBO(78, 2, 251, 1), Color.fromRGBO(94,47,199, 1)]
          )
        ),
        height: screen.height,
        width: screen.width,
        alignment: Alignment.center,
        child: PageView(
          allowImplicitScrolling: true,
          controller:pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Container(
              alignment: Alignment.center,
              child: PinView(screen:screen),
            ),
            Container(
              alignment: Alignment.center,
              child: FingerView(screen:screen)
            )
          ]
        )
      )
    );
  }

  Widget PinView({var screen}){
    return Stack(
      children:[
        RobinCard(
          width: screen.width - 20,
          child: Container(
            padding: EdgeInsets.only(top:85.0, right:20.0, left: 20.0),
            width: screen.width-20,
            alignment: Alignment.center,
            child: Column(
              children:[
                Image.asset('assets/image/pass.png', width: screen.width/2,),
                SizedBox(height:35.0),
                Input(
                  max: 4,
                  input: TextInputType.number,
                  hint: "SET 4 DIGIT PIN",
                  onChanged: (val){
                    setState(() {
                      pin = val;
                    });
                  },
                  textAlign: TextAlign.center
                ),
                FlatButton.icon(
                  icon:Icon(Icons.check_circle_outline_outlined),
                  label: Text("Set"),
                  disabledTextColor: Colors.grey[600],
                  textColor: Colors.white,
                  disabledColor: Colors.grey[200],
                  color: Colors.green,
                  minWidth: screen.width-40.0,
                  shape: RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(15.0)
                  ),
                  onPressed: pin ==null || pin.trim() == "" || pin.length != 4 || hide ? null : () async {
                    setState(() {
                      showLoad = true;
                      hide = true;
                    });
                    FocusScope.of(context).unfocus();
                    await save(key:PIN, data: pin);
                    Timer(Duration(seconds:2), (){
                      setState(() {
                        showLoad = false;
                        hide = false;
                      });
                      toast("Pin Set Successful", color:Colors.green);
                      pageController.nextPage(
                        duration:Duration(milliseconds:500),
                        curve:Curves.easeIn
                      );
                    });
                  },
                ),
                !showLoad ? SizedBox() : 
                SizedBox(
                  width:30.0,
                  height:30.0,
                  child: CircularProgressIndicator(
                    backgroundColor:Colors.green
                  )
                )
              ]
            )
          )
        ),
        Positioned(
          top:20,
          right:0,
          left:0,
          child: Padding(
            padding: EdgeInsets.only(top:40.0, right: 20.0, left: 20.0),
            child: Container(
              width: screen.width-40,
              height: 40.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:Colors.black,
                boxShadow: [
                  BoxShadow(
                    color:Colors.grey[700],
                    blurRadius:10.0
                  )
                ]
              ),
              child: Text("Set Pin",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              )
            )
          )
        )
      ]
    );
  }

  Widget FingerView({var screen}){
    
    return Stack(
      children:[
        RobinCard(
          width: screen.width - 20,
          child: Container(
            padding: EdgeInsets.only(top:130.0, right:20.0, left: 20.0),
            width: screen.width-20,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Image.asset(!fingerAuthenticated ? 'assets/image/finger_lock.png' : 'assets/image/finger.png', width: screen.width/2,),
                SizedBox(height:20.0),
                Text(
                  "Touch ID",
                  style: TextStyle(
                    fontSize: 30.0
                  ),
                ),
                SizedBox(height:10.0),
                Text(
                  "",
                  style: TextStyle(
                    fontSize: 30.0
                  ),
                ),
                SizedBox(height:35.0),
                FlatButton.icon(
                  icon:Icon(
                    fingerAuthenticated ? Icons.check_outlined : Icons.fingerprint_outlined
                  ),
                  label: Text(
                    fingerAuthenticated ? "Authenticated" : (timerOn ? "Wait for "+tim+" seconds" : "Click To Verify")
                  ),
                  disabledTextColor: Colors.white,
                  textColor: Colors.white,
                  disabledColor: Colors.green,
                  color: Colors.blue[800],
                  minWidth: screen.width-40.0,
                  shape: RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(15.0)
                  ),
                  onPressed: fingerAuthenticated || timerOn ? null : () async {
                    if (await _isBiometricAvailable()) {
                      await _getListOfBiometricTypes();
                      await _authenticateUser();
                    }
                  },
                ),
                FlatButton(
                  onPressed: () async {
                    await save(key:FINGER, data: 'false');
                    cancel(context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => MainBitsBull()
                      )
                    );
                  },
                  child: Text("Skip"),
                ),
                !showLoad ? SizedBox() : 
                SizedBox(
                  width:30.0,
                  height:30.0,
                  child: CircularProgressIndicator(
                    backgroundColor:Colors.green
                  )
                )
              ]
            )
          )
        ),
        Positioned(
          top:20,
          right:0,
          left:0,
          child: Padding(
            padding: EdgeInsets.only(top:40.0, right: 20.0, left: 20.0),
            child: Container(
              width: screen.width-40,
              height: 40.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:Colors.black,
                boxShadow: [
                  BoxShadow(
                    color:Colors.grey[700],
                    blurRadius:10.0
                  )
                ]
              ),
              child: Text("Set Touch ID",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              )
            )
          )
        )
      ]
    );
  }

}