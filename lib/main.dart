import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:testspappp/provider/app_state.dart';
import 'package:testspappp/screen/register_screen.dart';
import 'package:testspappp/service/GeoServices.dart';

import 'controller/register_controller.dart';
import 'maptest.dart';

void main() async{
  //runApp( MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<GeoProvider>.value(value: GeoProvider()),
      ChangeNotifierProvider<AppStateProvider>.value(value: AppStateProvider()),
    ],
    child:MyApp(),
  ));
}

// class MyApp extends StatelessWidget {
//
//   // This widget is the root of your application.
//
//   RegisterController _registerController=Get.put(RegisterController());
//   bool isLogined;
//
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//
//         primarySwatch: Colors.blue,
//       ),
//       home : _registerController.checkUserLogined==true? MapSample():RegisterScreen(),
//     );
//   }
//
//
//
// }

class MyApp extends StatefulWidget {


  @override
  _MyAppState createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {

  RegisterController _registerController=Get.put(RegisterController());
  bool isLogined;

  getIsLogin()async{
    await _registerController.checkUserLogined().then((value) {
    setState(() {
      isLogined=value;
    });
    });
  }

  @override
  void initState() {
    getIsLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home : isLogined==true? MapSample():RegisterScreen(),
    );
  }

}




