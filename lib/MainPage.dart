import 'package:flutter/material.dart';
import 'package:envirosense_fyp/ValueNotifiers.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:envirosense_fyp/functions.dart' as functions;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:envirosense_fyp/Locations.dart';

int i = 0;
int loginTries = 0;
bool demoVal = true;

class LoadingScreen extends StatefulWidget {
  final String title;
  LoadingScreen({ @required this.title, Key key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState(this.title);
}

class _LoadingScreenState extends State<LoadingScreen> {
  _LoadingScreenState(String title){
    this._title = title;
  }
  String _title;
  @override
  void initState() {
    _checkConnection();
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  String username = "fypaqwms@gmail.com";
  String password = "fypcloud2020";
  String bearerToken;
  var response;
  var data;
  _login(String user, String pass) async{
    final prefs = await SharedPreferences.getInstance();
    subtitle.value = "Connecting to server";
    var url = Uri.parse('https://${tbLinks[i]}/api/auth/login');
    var body = json.encode({
      "username" : user,
      "password" : pass
    });
    response = await http.post(
      url,
      headers: {
        'Content-Type' : 'application/json',
        'Accept' : 'application/json'
      },
      body: body,
    );
    await prefs.setInt('logInResponse', response.statusCode);
    if(response.statusCode != 200){
      i++;
      loginTries++;
      if(loginTries > 7){
        subtitle.value = "Error Connecting to Server";
        _showPopup();
      }
    }
    else if(response.statusCode == 200){
      loginTries = 0;
      await prefs.setInt('tbLinkIndex', i);
      String token = json.decode(response.body)['token'].toString();
      bearerToken = 'Bearer\$' + token;
      await functions.save('bearerToken.txt', bearerToken);
      if(response.body != null){
        subtitle.value = "Connected to server";
      }
    }
  }
  Future<Map<String,dynamic>> _getDeviceIds() async{
    final prefs = await SharedPreferences.getInstance();
    i = prefs.getInt('tbLinkIndex') ?? 0;
    var url = Uri.parse(
      'https://${tbLinks[i]}/api/tenant/devices?pageSize=10000&page=0'
    );
    var response = await http.get(
        url,
        headers: {
          'Content-Type':'application/json',
          'Accept':'application/json',
          'X-Authorization':'$bearerToken',
        }
    );
    // if(response.statusCode != 200){
    //
    // }
    data = await json.decode(response.body)['data'];
    for(int i = 0; i < data.length; i++){
      String devId = data[i]['id']['id'].toString();
      await functions.save('devId${i+1}.txt', devId);
    }
    return json.decode(response.body);
  }
  _checkConnection() async{
    final prefs = await SharedPreferences.getInstance();
    i = prefs.getInt('tbLinkIndex') ?? 0;
    demoVal = prefs.getBool('demoServer') ?? true;
    if(demoVal == true){
      username = "fypaqwms@gmail.com";
      i = 0;
    } else{
      username = "tenant@thingsboard.org";
      i = 1;
    }
    // await prefs.setInt('tbLinkIndex', 0);
    bool status = await DataConnectionChecker().hasConnection;
    if (!status){
      subtitle.value = "NO INTERNET CONNECTION";
      await Future.delayed(Duration(seconds: 1));
      await _showPopup();
    }
    else{
      // await Future.delayed(Duration(seconds: 1));
      // subtitle.value = "CONNECTED";
      await Future.delayed(Duration(seconds: 1));
      title.value = _title;
      await _login(username, password);
      int statusCode = prefs.getInt('logInResponse');
      while(statusCode != 200){
        statusCode = prefs.getInt('logInResponse');
        if(i > 5){
          i = 0;
          username = "fypaqwms@gmail.com";
          await prefs.setBool('demoServer', true);
        }
        await _login(username, password);
      }
      await _getDeviceIds();
      await _route();
    }
  }
  _route() async{
    await Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => LocationPage(devCount: data.length)),
    );
  }
  _showPopup() async{
    String title = "You are disconnected from the internet. ";
    String subtitle = "Please check your internet connection";
    await _showDialog(title, subtitle, context);
  }
  _showDialog(String title, String subtitle, BuildContext context) async{
    showDialog(
        context: context,
        builder: (BuildContext context){
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 18 * MediaQuery.of(context).size.width / screenWidth,
                ),
              ),
              content: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 18 * MediaQuery.of(context).size.width / screenWidth,
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: (){
                    SystemNavigator.pop(animated: true);
                  },
                  child: Text(
                    "Close Application",
                    style: TextStyle(
                      fontSize: 18 * MediaQuery.of(context).size.width / screenWidth,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async{
                    Navigator.pop(context);
                    await _checkConnection();
                  },
                  child: Text(
                    "Retry",
                    style: TextStyle(
                      fontSize: 18 * MediaQuery.of(context).size.width / screenWidth,
                    ),
                  ),
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
      backgroundColor: Color(0xff00356a),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 10),
              // Image(
              //   image: AssetImage('assets/logos/EnvLogo.png'),
              // ),
              Text(
                "ENVIROSENSE",
                style: TextStyle(
                  fontFamily: 'AstroSpace',
                  fontSize: 40 * MediaQuery.of(context).size.width / screenWidth,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.5 * MediaQuery.of(context).size.width / screenWidth,
                ),
              ),
              Spacer(flex: 3),
              Container(
                  child: SpinKitThreeBounce(
                    color: Colors.green,
                    size: 35.0 * MediaQuery.of(context).size.width / screenWidth,
                  )
              ),
              Spacer(),
              ValueListenableBuilder(
                valueListenable: subtitle,
                builder: (context, String subtitle, _){
                  return Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22 * MediaQuery.of(context).size.width / screenWidth,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              Spacer(flex: 10),
            ],
          ),
        ),
      ),
    );
  }
}
