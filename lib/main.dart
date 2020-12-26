import 'dart:async';

import 'package:bitsbull_app/elements/elements.dart';
import 'package:bitsbull_app/pages/login.dart';
import 'package:bitsbull_app/pages/register.dart';
import 'package:bitsbull_app/security/setpin.dart';
import 'package:bitsbull_app/service/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:bitsbull_app/app/bitsbull.dart';
void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BitsBull',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: Bitsbull(),
      home: Bitsbull(),
    );
  }
}

class Bitsbull extends StatefulWidget {
  Bitsbull({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Bitsbull> {

  bool isRegistrationPending = false;
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  PageController pageController = PageController(initialPage: 0);
  Timer tim;

  @override
  void initState(){
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
      await save(key:'FINGERDATA', data:'false');
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
            "Please authenticate for login to BitsBull wallet",
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    isAuthenticated
        ? print('User is authenticated!')
        : print('User is not authenticated.');

    if (isAuthenticated) {
      Timer(Duration(milliseconds:1000), (){
        pageController.dispose();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainBitsBull()
          )
        );
      });

    }
  }


  init() async {
    var isLogged = await getSaved(key:BUSER);

    if(isLogged != null){
      var isPinSet = await getSaved(key:PIN);
      var isFingerSet = await getSaved(key:FINGER);
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
        if(isFingerSet == 'true'){
          if(await _isBiometricAvailable()){
            await _getListOfBiometricTypes();
            await _authenticateUser();
          }
        }
        else {
          Timer(Duration(seconds:2), (){
            showDialog(
              context:context,
              builder:(BuildContext context){
                return Dialog(
                  insetAnimationDuration: Duration(milliseconds:100),
                  insetAnimationCurve: Curves.easeIn,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  child:Container(
                    height: MediaQuery.of(context).size.height / 3,
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/image/pass.png', width: MediaQuery.of(context).size.width/3,),
                        Text(
                          "Input Pin",
                          style: TextStyle(fontSize: 22),
                        ),
                        SizedBox(height: 10.0,),
                        Input(
                          textAlign: TextAlign.center,
                          max: 4,
                          hint: "Enter Pin",
                          onChanged: (val) async {
                            if(val == isPinSet){
                              // cancel(context);
                              FocusScope.of(context).unfocus();
                              cancel(context);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => MainBitsBull()
                                )
                              );
                            }
                          },
                          input: TextInputType.number
                        )
                      ],
                    )
                  )
                );
              }
            );
          });
        }
      }
    }

    var pg = await getSaved(key:'page');
    var dta = await getSaved(key:'data');
    if(pg != null && dta != null){
      setState(() {
        isRegistrationPending = true;
      });
    }
    else{
      setState(() {
        isRegistrationPending = false;
      });
    }
    print(isRegistrationPending);

    setState(() {
      tim = Timer.periodic(Duration(milliseconds: 2900), (timer) {
        if(pageController.positions.isNotEmpty){
          if(pageController.page == 3.0) {
            pageController.animateToPage(0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn
            );
          }
          else{
            pageController.nextPage(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    print("Dispose Called");
    tim?.cancel();
    pageController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[400],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PageView(
                scrollDirection: Axis.horizontal,
                controller: pageController,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SplashCard(
                    screen:screen,
                    assetUrl:'banner4.png',
                    text: "BitsBull Wallet",
                    desc: "Bitsbull gives users an access to multi asset\nDigital Wallet to add and spend their funds",
                  ),
                  SplashCard(
                    screen:screen,
                    assetUrl:'banner1.png',
                    text: "About",
                    desc: "Founded with a focus on trust, security and reliability, our goal has always been to create a safe and accessible place to trade and invest in cryptocurrency such as Bitcoin.",
                  ),
                  SplashCard(
                    screen:screen,
                    assetUrl:'banner2.png',
                    text: "Vision",
                    desc: "Our vision is to be a trusted partner for our clients and a respected leader in crypto asset management.",
                  ),
                  SplashCard(
                    screen:screen,
                    assetUrl:'banner3.png',
                    text: "Mission",
                    desc: "Our mission is to add value with active portfolio management to help our clients reach their long-term financial goals. We achieve this through our investment strategies, adhering to our values and investment principles, and offering employees a challenging and rewarding place to build a career.",
                  ),
                ],
              )
            ),
            

            SizedBox(height:30.0),

            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children:[
                  !isRegistrationPending ? SizedBox()
                  : Text(
                    "Pending registration",
                    style:TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                      backgroundColor: Colors.amber,
                    )
                  ) ,
                  FlatButton(
                    minWidth: screen.width-35.0,
                    onPressed:(){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Register()
                        )
                      );
                    },
                    child: Text("Create an Account"),
                    color:Colors.white,
                    shape:RoundedRectangleBorder(
                      borderRadius:BorderRadius.circular(10.0)
                    )
                  ),
                  FlatButton(
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.grey[100]
                      ),
                    ),
                    onPressed:(){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Login()
                        )
                      );
                    },
                    color:Colors.transparent
                  )
                ]
              ),
            )
          ],
        ),
      ),
    );
  }
}
