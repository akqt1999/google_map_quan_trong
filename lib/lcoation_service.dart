import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'as convert;
class LocationService{
  final String key='AIzaSyCxgg-GPHfwhzEF35CdICkW0vWzRV7QNnE';

  Future<String>getPlaceId(String input)async{
    final String url='https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
    //
    var response=await http.get(Uri.parse(url));
    var json=convert.jsonDecode(response.body);
    var placeId=json['candidates'][0]['place_id'] as String;
    print('place id:${placeId}');
    return placeId;
  }


  Future<Map<String ,dynamic>>getPlace(String input ) async{
    final placeId=await getPlaceId(input);
      final String url='https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
      var response=await http.get(Uri.parse(url));
      var json=convert.jsonDecode(response.body);
      var results=json['result']as Map<String,dynamic>;
       print("place : ${results}");
       return results;
  }

  Future<Map<String,dynamic>>getDirections(String origin,String destination)async{
      final String url=
          'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';
      var response=await http.get(Uri.parse(url));
      var json =convert.jsonDecode(response.body);
      var results={
        'bounds_ne':json['routes'][0]['bounds']['northeast'],
        'bounds_sw':json['routes'][0]['bounds']['southwest'],
        'start_location':json['routes'][0]['legs'][0]['start_location'],
        'end_location':json['routes'][0]['legs'][0]['end_location'],
        'polyline':json['routes'][0]['overview_polyline']['points'],
        'polyline_decoded':PolylinePoints().
        decodePolyline( json['routes'][0]['overview_polyline']['points']),

      };
      print(results);
      return results;

  }

  Future<Map<String,dynamic>>getDirectionsByLatLng(
      {LatLng origin, LatLng destination})async{
    double oriLat=origin.latitude,oriLng=origin.longitude,
        desLat=destination.latitude,desLng=destination.longitude;

    final String url=
        'https://maps.googleapis.com/maps/api/directions/json?origin=$oriLat,$oriLng&destination=$desLat,$desLng&key=$key';
    String url2='https://rsapi.goong.io/Direction?origin=21.046623224000029,105.790168203000060&destination=21.046666732000062,105.790169569000060&vehicle=bike&api_key=j0UIH8CE8gcnKzql7Zfd2F9LT6Lur7GaaXGt34My';

    var response=await http.get(Uri.parse(url2));
    var json =convert.jsonDecode(response.body);
    var results={
      'bounds_ne':json['routes'][0]['bounds']['northeast'],
      'bounds_sw':json['routes'][0]['bounds']['southwest'],
      'start_location':json['routes'][0]['legs'][0]['start_location'],
      'end_location':json['routes'][0]['legs'][0]['end_location'],
      'polyline':json['routes'][0]['overview_polyline']['points'],
      'distance':json['routes'][0]['legs'][0]['distance'],
      'polyline_decoded':PolylinePoints().
      decodePolyline( json['routes'][0]['overview_polyline']['points']),

    };
    print("fdsafds__$results");

    print('fdsafds__: ${json['routes'][0]['legs'][0]['distance']['value']}');
    print('fdsafds__: ${json['routes'][0]['legs'][0]['distance']['text']}');

    print('fdsafds__: ${json['routes'][0]['legs'][0]['duration']['value']}');
    print('fdsafds__: ${json['routes'][0]['legs'][0]['duration']['text']}');

    return results;

  }
//https://maps.googleapis.com/maps/api/geocode/json
  Future<String>getNameAddressByLatLng({double lat,double lng})async{

    final String url='https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$key';
    try{
      var response=await http.get(Uri.parse(url));
      var json=convert.jsonDecode(response.body);
      var results=json['results'][0]['formatted_address']as String;
      return results;
    }catch(e){
      print("loi : $e");
    }

    return "";
  }

  void getCurrentLovcation()async{
    print('lastPositionasd');
    var position=await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lastPosition=await Geolocator.getLastKnownPosition();
    print('lastPosition:$lastPosition');
    print('position123:$position');

  }

}
