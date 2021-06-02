import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:envirosense_fyp/ValueNotifiers.dart';

class MapPage extends StatefulWidget {
  final double latValue;
  final double longValue;
  final double zoom;
  MapPage({@required this.latValue, @required this.longValue, @required this.zoom, Key key}) : super(key: key);
  @override
  _MapPageState createState() => _MapPageState(this.latValue, this.longValue, this.zoom);
}

class _MapPageState extends State<MapPage> {
  _MapPageState(double _latitudeVal, double _longitudeVal, double _zoomVal){
    this._latitude = _latitudeVal;
    this._longitude = _longitudeVal;
    this._zoom = _zoomVal;
  }
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _zoom = 0.0;
  final Map<String, Marker> _markers = {};
  Location _location = Location();
  void _onMapCreated(controller) {
    setState(() {
      _location.getLocation();
      _markers.clear();
      print(location.value.length);
      for(int i = 0; i < location.value.length; i++){
        final marker = Marker(
          markerId: MarkerId(location.value[i]),
          position: LatLng(double.parse(latitude.value[i]), double.parse(longitude.value[i])),
          infoWindow: InfoWindow(
              title: "AQWMS Node ${i+1}",
              snippet: "${location.value[i]}"
          ),
        );
        _markers[location.value[i]] = marker;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GoogleMap(
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        compassEnabled: true,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(_latitude,_longitude),
          zoom: _zoom,
        ),
        markers: _markers.values.toSet(),
        mapToolbarEnabled: true,
      ),
    );
  }
}
