import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddressInput extends StatelessWidget {
  final IconData iconData;
  final TextEditingController controller;
  final String hintText;
  final Function onTap;
  final bool enabled;

  const AddressInput(
      {Key key,
        this.iconData,
        this.controller,
        this.hintText,
        this.onTap,
        this.enabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          this.iconData,
          size: 18,
          color: Colors.black,
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width / 1.4,
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.grey[300]),
            child: TextField(
              controller: controller,
              onTap: onTap,
              enabled: enabled,
              decoration: InputDecoration.collapsed(hintText: hintText),
            ),
          ),

        ),

      ],
    );
  }
}
