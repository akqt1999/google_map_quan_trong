import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class GeoProvider with ChangeNotifier {
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );
  Geolocator geolocator;
  GeoProvider() {
    print("khoi tao");
    // vay la bi loi o day
    try{
      // Geolocator.getPositionStream().listen(( Position position) {
      //   print("conket");
      //   getCurrentLocationUpdate(position);
      // });
    }catch(e){print("loii $e");}

  }

  getCurrentLocationUpdate(Position position){
    print("conket2");
    print("vitri lat${position.latitude.toString()} lng${position.latitude.toString()}");
//    notifyListeners();

  }

}
