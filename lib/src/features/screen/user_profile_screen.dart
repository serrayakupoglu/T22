import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/profile_buttons.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<StatefulWidget> createState() => _UserProfileState();

}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Replace this with user image
          Icon(Icons.supervised_user_circle, color: Colors.white, size: 128,),
          
          // Container of name and surname
          Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: const Text(
                "Kemal Ayhan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ProfileButton(buttonText: "Liked-Songs", onPressed: (){}),
          ProfileButton(buttonText: "Statistics", onPressed: (){}),
          ProfileButton(buttonText: "Friends", onPressed: (){}),
          
        ],
      )
    );
  }

}