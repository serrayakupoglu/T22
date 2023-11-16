import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/profile_buttons.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Future<String?>? userData;

  @override
  void initState() {
    super.initState();
    userData = fetchData();
  }

  Future<String?> fetchData() async {
    return await storageService.readSecureData('userName');
  }

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
          FutureBuilder<String?>(
            future: userData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(), // Show a circular progress indicator while fetching data
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                return Center(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: Text(
                      snapshot.data!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: Text(
                      'User data unavailable',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          ProfileButton(buttonText: "Liked-Songs", onPressed: (){}),
          ProfileButton(buttonText: "Statistics", onPressed: (){}),
          ProfileButton(buttonText: "Friends", onPressed: (){}),
        ],
      ),
    );
  }
}
