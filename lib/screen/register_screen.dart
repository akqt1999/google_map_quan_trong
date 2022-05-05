import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../controller/register_controller.dart';
import '../maptest.dart';

class RegisterScreen extends StatelessWidget {
  TextEditingController userNametextEditingController = TextEditingController();
  RegisterController _registerController=Get.put(RegisterController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: userNametextEditingController,
            decoration: InputDecoration(hintText: "user name"),
          ),
          ElevatedButton(child: Text("register"), onPressed: () async{
           await _registerController.register(userNametextEditingController.text);
          })
        ],
      ),
    );
  }
}
