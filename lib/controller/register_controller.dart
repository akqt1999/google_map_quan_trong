import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:prefs/prefs.dart';
import 'package:testspappp/helper/constains.dart';

import '../maptest.dart';

class RegisterController extends GetxController {

  register(String userName) async {
    try {
      Map<String, dynamic> data = {'lat': 0, 'long': 0};

     await firebaseFirestore.collection(COLLECTION_USER_NAME).doc(userName).set(data);
      final prefs=await SharedPreferences.getInstance();
      await prefs.setString(KEY_USER_NAME, userName);
      Get.offAll(MapSample());
    } catch (e) {
      print("loiii_${e}");
      Fluttertoast.showToast(msg: "register fail", toastLength: Toast.LENGTH_SHORT);
    }
  }

  Future<bool> checkUserLogined()async{
    final prefs =await SharedPreferences.getInstance();
    if(prefs.getString(KEY_USER_NAME)!=null){
      print("testtt true");
      return true;
    }else{
      print("testtt false");
      return false;
    }
  }
}
