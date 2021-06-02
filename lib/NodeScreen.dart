import 'package:flutter/material.dart';
import 'package:envirosense_fyp/ValueNotifiers.dart';
import 'package:envirosense_fyp/Maps.dart';
import 'package:envirosense_fyp/DataScreen.dart';

final ValueNotifier<String> locationName = ValueNotifier<String>("Loading");

class Node extends StatefulWidget {
  final String deviceId;
  final int index;
  final int lastAqi;
  final int lastTem;
  final int lastHum;
  final int lastPres;
  final double lastPm;
  final double lastNo2;
  final double lastCo;
  Node({@required this.index, @required this.deviceId, this.lastAqi, this.lastCo, this.lastHum, this.lastNo2, this.lastPm, this.lastPres, this.lastTem, Key key}) : super(key: key);
  @override
  _NodeState createState() => _NodeState(this.deviceId, this.index, this.lastAqi, this.lastCo, this.lastHum, this.lastNo2, this.lastPm, this.lastPres, this.lastTem);
}

class _NodeState extends State<Node> {
  _NodeState(String devId, int _index, int aqi, double co, int hum, double no2, double pm25, int pres, int temp){
    this._deviceId = devId;
    this._index = _index;
    this._aqi = aqi;
    this._co = co;
    this._hum = hum;
    this._no2 = no2;
    this._pm25 = pm25;
    this._pres = pres;
    this._temp = temp;
  }
  String _deviceId = "";
  int _index = 0;
  int _aqi = 0;
  double _co = 0.0;
  int _hum = 0;
  double _no2 = 0.0;
  double _pm25 = 0.0;
  int _pres = 0;
  int _temp = 0;
  @override
  void initState() {
    super.initState();
    locationName.value = location.value[_index];
  }
  @override
  void dispose() {
    super.dispose();
  }
  int selectedIndex = 0;
  List<Widget> screens = <Widget>[
    DataPage(devId: "h", devIndex: 0, lastAqi: 0, lastCo: 0.0, lastHum: 0, lastNo2: 0.0, lastPm: 0.0, lastPres: 0, lastTem: 0),
    MapPage(latValue: double.parse(latitude.value[1]), longValue: double.parse(longitude.value[0]), zoom: 16.0),
    // StatisticsPage(devId: "h")
  ];
  @override
  Widget build(BuildContext context) {
    screens[0] = DataPage(devId: _deviceId, devIndex: _index, lastPres: _pres, lastTem: _temp, lastPm: _pm25, lastNo2: _no2, lastHum: _hum, lastCo: _co, lastAqi: _aqi);
    screens[1] = MapPage(latValue: double.parse(latitude.value[_index]), longValue: double.parse(longitude.value[_index]), zoom: 16.0);
    // screens[2] = StatisticsPage(devId: _deviceId);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.square(60.0 * MediaQuery.of(context).size.width / screenWidth),
        child: AppBar(
          elevation: 10 * MediaQuery.of(context).size.width / screenWidth,
          title: Text(locationName.value),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_location_alt_sharp,
            ),
            label: 'MyAir',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
            ),
            label: 'Map',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.bar_chart_sharp),
          //   label: 'Statistics',
          // ),
        ],
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedFontSize: 15 * MediaQuery.of(context).size.width / screenWidth,
        unselectedFontSize: 15 * MediaQuery.of(context).size.width / screenWidth,
        iconSize: 27 * MediaQuery.of(context).size.width / screenWidth,
      ),
      body: screens.elementAt(selectedIndex),
    );
  }
}
