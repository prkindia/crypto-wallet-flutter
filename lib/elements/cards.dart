import 'package:bitsbull_app/service/service.dart';
import 'package:bitsbull_app/transaction/deposit.dart';
import 'package:bitsbull_app/transaction/withdraw.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:palette_generator/palette_generator.dart';
import 'elements.dart';

class MainRobinCard extends StatefulWidget{
  MainRobinCard({this.asset});
  var asset;

  @override
  _RobCard createState() => _RobCard();
}
class _RobCard extends State<MainRobinCard> {
  Color color;
  var asset;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async{
    setState(() {
      asset = widget.asset;
    });
    var colorFetched = await getColorFromPallete(NetworkImage("https://s2.coinmarketcap.com/static/img/coins/64x64/"+asset['id'].toString()+".png"));
    print(colorFetched.toString());
    setState(() {
      color = colorFetched;
    });
  }

  Future<Color> getColorFromPallete(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor.color;
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return RobinCard(
        child: Container(
            width: screen.width / 2 + 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: color!=null?color.withOpacity(.3):Colors.white.withOpacity(.3),
                borderRadius: BorderRadius.circular(20.0)
            ),
            child: Stack(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Image.network(
                              'https://s2.coinmarketcap.com/static/img/coins/64x64/'+asset['id'].toString()+'.png')
                      )
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Image.asset('assets/image/logo.png', width: 25.0,)
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: EdgeInsets.only(top: 40.0, left: 15.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RobText(asset['name'] != null ? asset['name'] : "Error",
                                    style: TextStyle(fontSize: 18.0)),
                                RobText(
                                    asset['symbol'] != null ? asset['symbol'] : '0x44D',
                                    style: TextStyle(fontSize: 15.0)
                                ),
                              ]
                          )
                      )
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: RobText(
                            "\$ " + (asset['quote']['USD']['price'] != null ? asset['quote']['USD']['price'].toStringAsFixed(2) : "0.0"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            )
                        )
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: RobText(
                            asset['quote']['USD']['percent_change_1h'] != null ?
                            (asset['quote']['USD']['percent_change_1h'].toStringAsFixed(2))+" %"
                            : "0xFFE44",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: (asset['quote']['USD']['percent_change_1h'] < 0 ? Colors.red[600] : Colors.green[600])
                            )
                        )
                    ),
                  )
                ]
            )
        )
    );
  }
}


class DepositRobinCard extends StatefulWidget{
  DepositRobinCard({this.asset, this.isCustom});
  var asset;
  bool isCustom;

  @override
  _RobDepoCard createState() => _RobDepoCard();
}
class _RobDepoCard extends State<DepositRobinCard> {
  Color color;
  var asset;
  bool isCustom = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async{
    setState(() {
      asset = widget.asset;
      isCustom = widget.isCustom != null ? widget.isCustom : false;
    });
    if(!isCustom) {
      var colorFetched = await getColorFromPallete(NetworkImage(
          "https://s2.coinmarketcap.com/static/img/coins/64x64/" +
              asset['id'].toString() + ".png"));
      print(colorFetched.toString());
      setState(() {
        color = colorFetched;
      });
    }
    else{
      var colorFetched = await getColorFromPallete(NetworkImage(
          baseUrl + "coins/" +
              asset['symbol'] + ".png"));
      print(colorFetched.toString());
      setState(() {
        color = colorFetched;
      });
    }

  }

  Future<Color> getColorFromPallete(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor.color;
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Card(
      color: Colors.white.withOpacity(.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13.0)
      ),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.0),
          gradient: RadialGradient(
            colors: [Colors.white70, color!=null?color.withOpacity(.7):Colors.blue[100]],
            radius: 2.0
          )
        ),
        padding: EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Image.network(
                    !isCustom ? "https://s2.coinmarketcap.com/static/img/coins/64x64/"+asset['id'].toString()+".png"
                    : baseUrl + "coins/"+widget.asset['symbol']+".png",
                    width: 30.0,
                  ),
                  SizedBox(width: 10.0,),
                  RobText(
                    !isCustom ? (asset['symbol'] != null ? asset['symbol'] : "ERR")
                    : asset['name'],
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: RobText(
                  asset['quote']['USD']['price'] != null ?
                      "\$ "+double.parse(asset['quote']['USD']['price'].toString()).toStringAsFixed(2) :
                      "Error",
                style: TextStyle(fontSize: 13.0)
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FlatButton.icon(
                icon: Icon(Icons.upload_rounded),
                label: RobText("Deposit"),
                onPressed: (){
                  showCupertinoModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    builder: (context) => RobinDeposit(asset:asset, isCustom: isCustom,)
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}




class PortFolioCard extends StatefulWidget{
  PortFolioCard({this.asset, this.isCustom});
  bool isCustom;
  var asset;

  @override
  _PortState createState() => _PortState();
}
class _PortState extends State<PortFolioCard> {
  Color color;
  var asset;
  bool isCustom = false;
  double price = 0.00;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async{
    setState(() {
      asset = widget.asset;
      isCustom = widget.isCustom != null ? widget.isCustom : false;
    });
    if(!isCustom) {
      var colorFetched = await getColorFromPallete(NetworkImage(
          "https://s2.coinmarketcap.com/static/img/coins/64x64/" +
              asset['id'].toString() + ".png"));
      print(colorFetched.toString());
      setState(() {
        color = colorFetched;
        price = double.parse(asset['quote']['USD']['price'].toString());
      });
    }
    else{
      var colorFetched = await getColorFromPallete(NetworkImage(
          baseUrl + "coins/" +
              asset['icon']));
      print(colorFetched.toString());
      setState(() {
        color = colorFetched;
        price = double.parse(asset['rate'].toString());
      });
    }
  }

  Future<Color> getColorFromPallete(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor.color;
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return Card(
      color: Colors.white.withOpacity(.7),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13.0)
      ),
      child: GestureDetector(
        onTap: (){
          if(!isCustom) {
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => WithdrawRobin(coin: asset['symbol'], avail: asset['hold_value'], value: price,)
            );
          }
          else{
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => WithdrawRobin(coin: asset['name'], value: price, avail: asset['value'],)
            );
          }
        },
        child:Container(
          height: 80,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13.0),
              gradient: RadialGradient(
                  colors: [Colors.white70, color!=null?color.withOpacity(.7):Colors.blue[100]],
                  radius: 2.0
              )
          ),
          padding: EdgeInsets.all(10.0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image.network(
                      !isCustom ? "https://s2.coinmarketcap.com/static/img/coins/64x64/"+asset['id'].toString()+".png"
                          : baseUrl + "coins/"+widget.asset['icon'],
                      width: 30.0,
                    ),
                    SizedBox(width: 10.0,),
                    RobText(
                      !isCustom ? (asset['symbol'] != null ? asset['symbol'] : "ERR")
                          : asset['coin_name'],
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: RobText(
                    !isCustom ? asset['quote']['USD']['price'] != null ?
                    "\$ "+double.parse(asset['quote']['USD']['price'].toString()).toStringAsFixed(2) :
                    "Error"
                    : "\$ " + asset['rate'],
                    style: TextStyle(fontSize: 13.0)
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child:RobText(
                        !isCustom ? "\$ "+double.parse(asset['hold_value'].toString()).toStringAsFixed(2)
                          : "\$ " + double.parse(asset['value'].toString()).toStringAsFixed(2),
                        textAlign: TextAlign.right
                      ),
                    ),
                    SizedBox(height: 5.0,),
                    Align(
                      alignment: Alignment.centerRight,
                      child:RobText(
                      !isCustom ? (asset['quote']['USD']['price']*double.parse(asset['hold_value'].toString())).toStringAsFixed(2)
                      : (double.parse(asset['rate'].toString())*double.parse(asset['value'].toString())).toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 12.0
                      )
                      )
                    )
                  ],
                )
              )
            ],
          ),
        )
      ),
    );
  }
}



