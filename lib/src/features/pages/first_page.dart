import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/social_login_button.dart';


class FirstPage extends StatelessWidget {
  const FirstPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 50),
                child: const Icon(Icons.music_note, color: Colors.white, size: 64),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: (){},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                    )
                  ),
                  child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: const Text(
                  "already have an account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),

              RichText(
                textAlign: TextAlign.center,
                selectionColor: Colors.white30,
                text: TextSpan(
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 16
                  ),
                  text: "Sign In",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      debugPrint('The button is clicked!');
                    },
                ),
              ),
            ],
          ),
        ),
    );
  }

}