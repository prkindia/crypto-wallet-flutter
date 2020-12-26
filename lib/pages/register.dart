import 'dart:async';
import 'dart:convert';
import 'package:bitsbull_app/app/bitsbull.dart';
import 'package:bitsbull_app/elements/elements.dart';
import 'package:bitsbull_app/producers/producers.dart';
import 'package:bitsbull_app/service/storage.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:bitsbull_app/service/service.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:bitsbull_app/security/setpin.dart';


class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = MaskedTextController(mask: "00000-00000");
  final _passwordController = TextEditingController();

  String emailText;
  bool error = false;
  bool verified = false;
  bool showLoad = false;
  String name;
  String phone;
  String pass;
  String confPass;
  String code = "91";
  String otpCode;

  int count = 30;

  PageController pageController = PageController(initialPage: 0);
  bool isResend = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    var page = await getSaved(key:'page');
    if(page !=null){
      var enc = await getSaved(key:'data');
      var data = jsonDecode(enc);
      if(page == "1"){
        setState(() {
          emailController.text = data['email'];
          emailText = data['email'];
        });
      }
      else if(page == "2"){
        setState(() {
          emailText = data['email'];
          emailController.text = data['email'];
          _nameController.text = data['name'];
          name = data['name'];
          pass = data['password'];
          phone = data['phone'];
          _passwordController.text = data['password'];
          _phoneController.text = data['phone'];
          otpCode = data['otp'];
          if(otpCode == null){
            pageController.jumpToPage(int.parse("1"));
          }
        });
      }
      pageController.jumpToPage(int.parse(page));
    }
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
            if(pageController.page == 0.0){
              Navigator.pop(context);
            }
            else{
              pageController.previousPage(
                duration: Duration(
                  milliseconds: 500,
                ),
                curve: Curves.easeIn
              );
            }
          },
          icon:Icon(Icons.arrow_back_ios_outlined, color:Colors.black)
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if(pageController.page == 0.0){
            return true;
          }
          else{
            pageController.previousPage(
              duration: Duration(
                milliseconds: 500,
              ),
              curve: Curves.easeIn
            );
            return false;
          }
        },
        child: Container(
          padding: EdgeInsets.only(top:130.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.fromRGBO(78, 2, 251, 1), Color.fromRGBO(94,47,199, 1)]
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
                  EnterEmail(screen:screen),
                  EnterInfo(screen:screen),
                  EnterCode(screen: screen)
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
                  Image.asset('assets/image/Template_3/deals_layout/cardMenu.png', width: screen.width/3,),
                  SizedBox(height:20.0),
                  Text(
                    "Enter your email address",
                    style: TextStyle(fontSize: 22),
                  ),
                  SizedBox(height:10.0),
                  Text(
                    "Email address is used for login, to identify unique users",
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
                        error = false;
                      });
                      //   if(val != null && val.trim() != ""){
                      //     setState(() {
                      //       showLoad = true;
                      //     });
                      //     var resp = await postMe(data:{'data' : {'email': val}, 'check': 'email'});
                      //     setState(() {
                      //       showLoad = false;
                      //     });
                      //     // print(resp.data);
                      //     if(resp.data != null){
                      //       setState(() {
                      //         error = true;
                      //       });
                      //     }
                      //     else{
                      //       setState(() {
                      //         error = false;
                      //       });
                      //     }
                      //   }
                      // },
                    }
                  ),
                  SizedBox(height:20.0),
                  !error ? (showLoad ? SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.redAccent,
                    )
                  )
                  : emailText == null || emailText.trim() == "" ? SizedBox() : Text(
                    "You'll recieve verification code on "+emailText,
                    style: TextStyle(
                      color:Colors.green,
                      fontSize: 13.0
                    ),
                    textAlign: TextAlign.center,
                  )
                  ) : Text(
                    "Email already exists",
                    style: TextStyle(
                      color:Colors.red,
                      fontSize: 13.0
                    ),
                  )
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
                    "Next",
                  ),
                  splashColor: Colors.white,
                  onPressed: emailText == null || emailText.trim() == "" || error ? null : () async {
                    print(emailText);
                    setState(() {
                      showLoad = true;
                    });
                    var resp = await postMe(data:{'data' : {'email': emailText}, 'check': 'email'});
                    setState(() {
                      showLoad = false;
                    });
                    // print(resp.data);
                    if(resp.data != null){
                      setState(() {
                        error = true;
                      });
                    }
                    else{
                      setState(() {
                        error = false;
                      });
                    }

                    if(!error){
                      save(key: 'page', data: '1');
                      save(key: 'data', data: jsonEncode({'email' : emailText}));

                      FocusScope.of(context).unfocus();
                      setState(() {
                        pageController.nextPage(
                          duration: Duration(milliseconds:500),
                          curve: Curves.easeIn
                        );
                      });
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

  bool validate(){
    
    if(name == null || name.trim() == ""){
      return false;
    }
    if(phone == null || phone.trim() == ""){
      return false;
    }
    if(pass == null || pass.trim() == "" ){
      return false;
    }
    if(confPass == null || confPass.trim() == ""){
      return false;
    }
    if(pass != confPass || pass.length < 8){
      return false;
    }

    return true;
  }

  Widget EnterInfo({var screen}){
    return Container(
      width: screen.width,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              padding: EdgeInsets.all(25.0),
              width:screen.width - 20,
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  children:[
                    Image.asset('assets/image/Template_3/deals_layout/financeMenu.png', width: screen.width/3,),
                    SizedBox(height:20.0),
                    Text(
                      "Enter your personal information",
                      style: TextStyle(fontSize: 22),
                    ),
                    SizedBox(height:10.0),
                    Text(
                      "Details are required to store information and personalised experience",
                      style: TextStyle(fontSize: 12, color:Colors.grey[700]),
                    ),
                    SizedBox(height:10.0),
                    Input(
                      hint:"Joe Doe",
                      label:"Name",
                      controller: _nameController,
                      onChanged:(val){
                        setState(() {
                          name = val;
                        });
                      },
                    ),
                    SizedBox(height:10.0),
                    Input(
                      controller: _phoneController,
                      input: TextInputType.phone,
                      hint:"XXXXX-XXXXX",
                      label:"Phone Number",
                      max:11,
                      onChanged:(val){
                        setState(() {
                          phone = val;
                        });
                      },
                      prefix: Padding(
                        padding: EdgeInsets.only(top:15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            InkWell(
                              onTap: (){
                                showCountryPicker(
                                  context: context,
                                  onSelect: (Country country){
                                    setState(() {
                                      code = country.phoneCode;
                                    });
                                  }
                                );
                              },
                              child: Text("+ "+code),
                            )
                          ]
                        )
                      )
                    ),
                    SizedBox(height:10.0),
                    Input(
                      hint: "Password must be 8 in length.",
                      label: "Password",
                      controller: _passwordController,
                      onChanged: (val){
                        setState(() {
                          pass = val;
                        });
                      },
                      input: TextInputType.visiblePassword,
                    ),
                    SizedBox(height:10.0),
                    Input(
                      hint: "Same as password",
                      label: "Confirm Password",
                      onChanged: (val){
                        setState(() {
                          confPass = val;
                        });
                      },
                      input: TextInputType.visiblePassword,
                    ),
                    SizedBox(height:20.0),
                    showLoad ? CircularProgressIndicator(
                      backgroundColor: Colors.greenAccent,
                    ):SizedBox()
                  ]
                )
              )
            ),
          ),
          Positioned(
            bottom:0,
            right:0,
            left:0,
            child: Column(
              children:[FlatButton(
              disabledTextColor: Colors.black,
                onPressed: !validate() ? null : () async {
                  setState(() {
                    showLoad = true;
                  });
                  FocusScope.of(context).unfocus();
                  var data = {'name' : _nameController.text, 'email' : emailText, 'password' : _passwordController.text};
                  var register = await doRegister(data: data);
                  print(register);
                  if(register['error'] != null){
                    toast("Error occured while registration", color: Colors.red);
                    Timer(Duration(seconds:1), (){
                      setState(() {
                        showLoad = false;
                      });
                    });
                    return;
                  }
                  Timer(Duration(seconds:1), (){
                    setState(() {
                      showLoad = false;
                    });
                  });

                  setState(() {
                    otpCode = register['otp'].toString();
                  });
                  toast("Code sent!", color: Colors.green);
                  save(key: 'page', data: '2');
                  save(key: 'data', data: jsonEncode({'email' : emailText, 'name': _nameController.text, 'phone' : _phoneController.text, 'password':_passwordController.text, 'otp' :  register['otp'].toString()}));
                  setState((){
                    pageController.nextPage(
                      duration: Duration(milliseconds:500),
                      curve: Curves.easeIn
                    );
                  });
                },
                textColor: Colors.white,
                child: Text(
                  'Submit',
                ),
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius:BorderRadius.circular(15.0)
                ),
                minWidth: screen.width - 40.0,
              )
              ]
            )
          )
        ],
      ),
    );
  }

  Widget EnterCode({var screen}){
    return Container(
      padding: EdgeInsets.all(20.0),
      width: screen.width,
      child: Stack(
        children:[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              padding: EdgeInsets.all(25.0),
              width:screen.width - 20,
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  children:[
                    Image.asset('assets/image/Template_3/deals_layout/buildingMenu.png', width: screen.width/3,),
                    SizedBox(height: 20.0,),
                    Text(
                      "Verify code",
                      style: TextStyle(
                        fontSize: 22.0
                      ),
                    ),
                    SizedBox(
                      height:10.0,
                    ),
                    emailText == null ? SizedBox() : Text(
                      "Verification code is sent to "+emailText,
                      style:TextStyle(
                        color:Colors.green,
                        fontSize: 12.0
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height:10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        FlatButton.icon(
                          icon:Icon(Icons.mail_outline),
                          label: Text("Check Mail"),
                          color: Colors.grey[200],
                          onPressed: () async {
                            var result = await OpenMailApp.openMailApp();
                            if (!result.didOpen && !result.canOpen) {
                              toast("No mail apps found", color: Colors.red);
                            } else if (!result.didOpen && result.canOpen) {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return MailAppPickerDialog(
                                    mailApps: result.options,
                                  );
                                },
                              );
                            }
                          },
                        ),
                        FlatButton.icon(
                          icon:Icon(Icons.refresh),
                          label: Text( isResend ? count.toString() : "Resend Code"),
                          color: Colors.grey[200],
                          onPressed: isResend ? null : () async {
                            print("Sending code");
                            setState(() {
                              showLoad = true;
                            });
                            var resp = await postMe(data: {'data' : {'email' : emailText, 'otp' : otpCode}, 'resendCode' : true});
                            resp = resp.data;
                            print(resp);
                            if(resp['error'] != null){
                              toast("Code sending failed! Try again in few seconds", color: Colors.red[700]);
                              setState(() {
                                showLoad = false;
                              });
                              return;
                            }
                            toast("Resend code to : "+emailText);
                            setState(() {
                              showLoad = false;
                              isResend = true;
                            });
                            Timer.periodic(Duration(milliseconds: 900), (timer) {
                              setState(() {
                                if(count == 0){
                                  isResend = false;
                                  count = 30;
                                }
                                count -= 1;
                              });
                            });
                          },
                        ),
                      ]
                    ),
                    SizedBox(
                      height:25.0,
                    ),
                    Input(
                      max:5,
                      input: TextInputType.number,
                      onChanged: (val){
                        print(otpCode);
                        if(val == otpCode){
                          setState(() {
                            verified = true;
                          });
                        }
                        else{
                          setState(() {
                            verified = false;
                          });
                        }
                      }
                    )
                  ]
                )
              ),
            )
          ),
          Positioned(
            bottom:0,
            right:0,
            left:0,
            child: Padding(
              padding: EdgeInsets.only(right:10.0, left:10.0, bottom:5.0),
              child: Column(
                children:[
                  FlatButton(
                    disabledTextColor: Colors.black,
                    onPressed: !verified ? null : () async {
                      toast("Verified Successfully");
                      setState(() {
                        showLoad = true;
                        verified = false;
                      });
                      FocusScope.of(context).unfocus();
                      var data = {'name' : _nameController.text, 'email' : emailText, 'password' : _passwordController.text};
                      data['phone'] = _phoneController.text.replaceAll('-', '');
                      var res = await registerMain(data: data);
                      toast("Registration Successfully");
                      await saveLog(data:res);
                      await clearKey('page');
                      await clearKey('data');
                      cancel(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => SetPin()
                        )
                      );
                    },
                    textColor: Colors.white,
                    child: Text(
                      'Submit',
                    ),
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius:BorderRadius.circular(15.0)
                    ),
                    minWidth: screen.width - 40.0,
                  )
                ]
              )
            )
          )
        ]
      )
    );
  }

}
