import 'package:flutter/material.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart';
import 'package:envirosense_fyp/main.dart';
import 'package:envirosense_fyp/ValueNotifiers.dart';

class Setting extends StatefulWidget {
  final bool val;
  Setting({this.val, Key key}) : super(key: key);
  @override
  _SettingState createState() => _SettingState(this.val);
}

class _SettingState extends State<Setting> {
  _SettingState(bool val){
    this._val =  val;
  }
  bool _val;
  _showPopup() async{
    String title = "This requires restarting the app. ";
    await _showDialog(title, context);
  }
  _showDialog(String title, BuildContext context) async{
    showDialog(
        context: context,
        builder: (BuildContext context){
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(title),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: (){
                    RestartWidget.restartApp(context);
                  },
                  child: Text("Restart Application"),
                )
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: SlidingSwitch(
            onChanged: (bool value) async{
              final prefs = await SharedPreferences.getInstance();
              if(value == true){
                await prefs.setBool('demoServer', true);
              }
              else{
                await prefs.setBool('demoServer', false);
              }
              _showPopup();
            },
            value: _val,
            textOn : "Cloud Server",
            textOff : "StandAlone Server",
            width: 300 * MediaQuery.of(context).size.width / screenWidth,
            height: 65 * MediaQuery.of(context).size.width / screenWidth,
          ),
        ),
      ),
    );
  }
}
