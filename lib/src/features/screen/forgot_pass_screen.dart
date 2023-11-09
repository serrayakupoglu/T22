import 'package:flutter/material.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPassState();


}

class _ForgotPassState extends State<ForgotPass> {
  String value = "k";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        storageService.readSecureData("email").then((result) {
          setState(() {
            value = result ?? ""; // You can set a default value if result is null
            debugPrint(value);
          });
        });
      },

      ),
      body: Container(
        child: Text(value),

      ),
    );
  }

}