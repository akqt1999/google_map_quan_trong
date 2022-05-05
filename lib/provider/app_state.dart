import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testspappp/controller/user_controller.dart';
import 'package:uuid/uuid.dart';

import '../helper/constains.dart';

class AppStateProvider with ChangeNotifier {
  Set<Marker> _markers = {};
  LocationSettings _locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 1);
  UserController _userController = Get.put(UserController());
  BitmapDescriptor carPin;
  Set<Marker> get markers => _markers;

  AppStateProvider() {
    getPositionStream();
    driverStream();
    _setCustomImage();
  }

  getPositionStream() {
    Geolocator.getPositionStream(locationSettings: _locationSettings).listen((position) {

      _userController.updateLocationCurrentUser(position.toJson());
    });
  }

  driverStream() {
    FirebaseFirestore.instance.collection(COLLECTION_USER_NAME).snapshots().listen((event) {
      event.docChanges.forEach((element) {
        Map<String,dynamic>data=element.doc.data() as  Map<String,dynamic>;
        print("vitri123 $data");
        clearMarker();
        LatLng position=LatLng(data['latitude'], data['longitude']);
        addMarker(position: position,rotation: data['heading']);
        notifyListeners();
      });
    });
  }

  clearMarker() {
    _markers.clear();
    notifyListeners();
  }

  addMarker({LatLng position, double rotation}) {
    var uuid = new Uuid();
    String markerId = uuid.v1();
    _markers.add(Marker(
      markerId: MarkerId(markerId),
      position: position,
      rotation: rotation,
      draggable: true,
      zIndex: 2,
      flat: true,
      anchor: Offset(1, 1),
      icon: carPin,
    ));
  }

  _setCustomImage()async{
    carPin=await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'images/taxi.png');
  }


}
