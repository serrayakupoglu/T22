import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: const Icon(Icons.music_note, color: Colors.white, size: 64),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text("Speak Friend and Enter", style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30, 30, 30, 30),
              child: TextField(
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: 'Email',
                  hintStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none
                      )
                  ),
                  filled: true,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30, 0, 30, 30),
              child: TextField(
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: 'Password',
                  hintStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none
                      )
                  ),
                  filled: true,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Text("or", style: TextStyle(color: Colors.white, fontSize: 18),),
            ),
            RichText(
                text: TextSpan(
                  text: "forgot password",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      debugPrint('The button is clicked!');
                    },
                ),
            ),
          ],
        )
      )
    );
  }

}