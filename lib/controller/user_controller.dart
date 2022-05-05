import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:prefs/prefs.dart';
import 'package:testspappp/helper/constains.dart';

class UserController extends GetxController{

  updateLocationCurrentUser(currentLocation)async{
      final prefs=await SharedPreferences.getInstance();
      firebaseFirestore.collection(COLLECTION_USER_NAME).doc(prefs.getString(KEY_USER_NAME)).update(currentLocation);
  }
  Stream<QuerySnapshot>driverStream(){
    CollectionReference reference=FirebaseFirestore.instance.collection(COLLECTION_USER_NAME);
    return reference.snapshots();
  }
  driverStream2(){
    FirebaseFirestore.instance.collection(COLLECTION_USER_NAME).snapshots().listen((event) {
      event.docChanges.forEach((element) {
        print("vitri1 ${element.doc.data()}");
      });
    });
  }
  

}