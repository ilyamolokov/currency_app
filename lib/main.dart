import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'src/currency.dart';

final key = new GlobalKey<CurrencyAppHomeState>();

void main() => runApp(MaterialApp(home: MyApp(key: key)));

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return new CurrencyAppHomeState();
  }
}

class CurrencyAppHomeState extends State<MyApp> {
  final backgroundColor = Color(0xFF5cd65c);

  var values;

  final currencyCodes = [];

  final myController1 = new TextEditingController();
  final myController2 = new TextEditingController();

  bool _btnState;
  bool textFieldState;

  var _btnText1 = "Валюта";
  var _btnText2 = "Валюта";

  var ourCountries;
  var reversed;



  textListener1() {
    print(myController1.text);
    if ((_btnText1 != "Валюта") & (_btnText2 != "Валюта")) {
      var calcNum1;

      if (myController1.text == "") {
        myController2.text = "";
      } else {
        calcNum1 = (double.parse(myController1.text) / values[_btnText1]) *
            values[_btnText2];
        myController2.text = calcNum1.toStringAsFixed(2);
      }
    }
  }

  textListener2() {
    print(myController2.text);
    if ((_btnText1 != "Валюта") & (_btnText2 != "Валюта")) {
      var calcNum2;
      if (myController2.text == "") {
        myController1.text = "";
      } else {
        calcNum2 = (double.parse(myController2.text) / values[_btnText2]) *
            values[_btnText1];
        myController1.text = calcNum2.toStringAsFixed(2);
      }
    }
  }

  _initState(value) {
    if (value == true) {
      myController2.removeListener(textListener2);
      myController1.addListener(textListener1);
    } else if (value == false) {
      myController1.removeListener(textListener1);
      myController2.addListener(textListener2);
    }
  }


  List<Currency> _listOfObjects = new List<Currency>();

  _fetchData() async {
    final url =
        "http://data.fixer.io/api/latest?access_key=1cfaa89f4627fefaca736d42d7b10343";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final map = json.decode(response.body);

      this.values = map["rates"];
      this.values.forEach((k, v) => currencyCodes.add(k));
    }

    var root = await rootBundle.loadString('assets/country_values.json');
    var decodedRoot = json.decode(root);
    this.ourCountries = decodedRoot["values"];
    this.reversed = ourCountries.map((k, v) => MapEntry(k, v + " (" + k + ")"));

    var listOfObjects = List<Currency>();

    for (var object in currencyCodes) {
      listOfObjects.add(new Currency(object, values[object], reversed[object]));
    }
    return listOfObjects;

  }

  @override
  void initState() {
    _fetchData().then((value) {
      setState(() {
        _listOfObjects.addAll(value);
      });
    });
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    myController1.dispose();
    myController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
      appBar: new AppBar(
          backgroundColor: backgroundColor, title: new Text("Currency App")),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Column(
            children: <Widget>[
              new ButtonTheme(
                  minWidth: 270.0,
                  child: new RaisedButton.icon(
                      // Первая кнопка
                      onPressed: () {
                        _btnState = true;
                        myController2.removeListener(textListener2);
                        myController1.removeListener(textListener1);
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new CurrencyList(
                                    _listOfObjects,
                                    backgroundColor
                                    )));
                      },
                      color: backgroundColor,
                      label: new Text(_btnText1,
                          style: new TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.white)),
                      icon: new Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 30.0))),
              new Container(
                  padding: EdgeInsets.only(left: 70.0, right: 70.0),
                  child: new TextField(
                    controller: myController1, // ПОЛЕ ТЕКСТА 1
                    onTap: () {
                      setState(() {
                        textFieldState = true;
                        _initState(textFieldState);
                        print(textFieldState);
                      });
                    },
                    style: new TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.start,
                    textDirection: TextDirection.ltr,
                    decoration: new InputDecoration(hintText: "Введите сумму"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp("[0-9.]"))
                    ],
                  ))
            ],
          ),
          new Container(
              padding: EdgeInsets.all(6.50),
              child: new Icon(
                Icons.repeat,
                size: 40.0,
              )),
          new Column(
            children: <Widget>[
              new ButtonTheme(
                  minWidth: 270.0,
                  child: new RaisedButton.icon(
                      // Вторая кнопка
                      onPressed: () {
                        _btnState = false;
                        myController2.removeListener(textListener2);
                        myController1.removeListener(textListener1);
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new CurrencyList(
                                    _listOfObjects,
                                    backgroundColor)));
                      },
                      color: backgroundColor,
                      label: new Text(_btnText2,
                          style: new TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.white)),
                      icon: new Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 30.0))),
              new Container(
                  padding: EdgeInsets.only(left: 70.0, right: 70.0),
                  child: new TextField(
                    controller: myController2, // ПОЛЕ ТЕКСТА 2
                    onTap: () {
                      setState(() {
                        textFieldState = false;
                        _initState(textFieldState);
                        print(textFieldState);
                      });
                    },
                    style: new TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.start,
                    textDirection: TextDirection.ltr,
                    decoration: new InputDecoration(hintText: "Введите сумму"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp("[0-9.]"))
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}

class CurrencyList extends StatefulWidget {
  final listOfObjects;  
  final backgroundColor;


  CurrencyList(this.listOfObjects, this.backgroundColor);

  @override
  State<StatefulWidget> createState() {
    return new CurrencyListState();
  }
}

class CurrencyListState extends State<CurrencyList> {
  List listOfObjects;
  var backgroundColor;
  List _objectsForDisplay;


  @override
  void initState() {
    key.currentState.textFieldState = null;
    backgroundColor = widget.backgroundColor;
    this.listOfObjects = widget.listOfObjects;
    setState(() {
      this._objectsForDisplay = this.listOfObjects;
    });


    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Выберите валюту"),
        backgroundColor: backgroundColor,
      ),
      body: new ListView.builder(
        itemCount: this._objectsForDisplay != null
            ? this._objectsForDisplay.length + 1
            : 0, // if condition(this.videos != null) is true EVALUATE expression 1(this.videos.length), otherwise EVALUATE expresson 2
        itemBuilder: (context, index) {
          return index == 0 ? _searchBar() : _listItem(index - 1);
        },
      ),
    );
  }

  // child: new TextField(style: new TextStyle(fontSize: 25.0, color: Colors.white),decoration: new InputDecoration.collapsed(hintText: "Введите валюту")))

  _searchBar() {
    return new Padding(
        padding: EdgeInsets.only(bottom:10.0, left: 15.0, right: 15.0),
        child: new TextField(
            style: new TextStyle(fontSize: 18.0, color: Colors.grey[700]),
            decoration:
                new InputDecoration(hintText: "Введите название валюты"),
            onChanged: (text) {
              text = text.toLowerCase();
              setState(() {
                _objectsForDisplay = listOfObjects.where((object) {
                  var currencyName = object.currencyName.toLowerCase();
                  return currencyName.contains(text);
                }).toList();
              });
            }));
  }

  _listItem(index) {
    return SingleChildScrollView(
        child: new Column(children: <Widget>[
      new FlatButton(
          child: new Column(children: <Widget>[
            new Container(
                width: 412.0,
                height: 68.0,
                child: new Text(_objectsForDisplay[index].currencyName,
                    textAlign: TextAlign.center,
                    style:
                        new TextStyle(fontSize: 20.0, color: Colors.grey[700])))
          ]),
          onPressed: () {
            if (key.currentState._btnState == true) {
              key.currentState._btnText1 = _objectsForDisplay[index].currencyCode;
              Navigator.pop(context);
            } else {
              key.currentState._btnText2 = _objectsForDisplay[index].currencyCode;
              Navigator.pop(context);
            }
          }),
      new Divider(height: 0.0, color: backgroundColor)
    ]));
  }
}
