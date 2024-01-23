import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/service/storage_service.dart';
import '../constants.dart';
import '../models/user.dart';
class AnotherUserFollowersPage extends StatefulWidget {
  final String currentUserName;
  final VoidCallback onUpdate;
  const AnotherUserFollowersPage({Key? key, required this.currentUserName, required this.onUpdate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnotherUserFollowersPageState();
}

class _AnotherUserFollowersPageState extends State<AnotherUserFollowersPage> {
  late UserController _userController;
  late Future<User?> userData;
  late Future<User?> baseUserData;
  late String? baseUserName;
  @override
  void initState() {
    super.initState();
    _userController = UserController(context: context);
    userData = _userController.getUserProfile(widget.currentUserName);
    baseUserData = fetchData();
  }

  Future<User?> fetchData() async {
    baseUserName =  await StorageService().readSecureData('username');
    return _userController.getUserProfile('$baseUserName');

  }


  void toggleFollow(String username, List<String> baseUserFollowings) async {
    bool isCurrentlyFollowing = isFollowing(username, baseUserFollowings);

    if (isCurrentlyFollowing) {
      _userController.unfollowUser(username).then((dbResult) async {
        if (dbResult == true) {
          await _userController.updateUserProfile('$baseUserName');
          baseUserData = _userController.getUserProfile('$baseUserName');
          setState(() {

          });
          widget.onUpdate();
        } else {
          print('Unfollow database call failed');
        }
      });
    } else {
      _userController.followUser(username).then((dbResult) async {
        if (dbResult == true) {
          await _userController.updateUserProfile('$baseUserName');
          baseUserData = _userController.getUserProfile('$baseUserName');
          setState(() {

          });
          widget.onUpdate();
        } else {
          print('Follow database call failed');
        }
      });
    }
  }
  bool isFollowing(String username, List<String> baseUserFollowings) {
    return baseUserFollowings.contains(username);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(appBarText: kFollowingsAppBarText, canGoBack: true,),
      backgroundColor: const Color(kOpeningBG),
      body: FutureBuilder<User?>(
        future: userData,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            // If the Future is still running, show a loading indicator
            return CircularProgressIndicator();
          } else if (userSnapshot.hasError) {
            // If an error occurs during the Future execution, display an error message
            return Text('Error: ${userSnapshot.error}');
          } else if (userSnapshot.hasData && userSnapshot.data != null) {
            // If the Future is completed successfully, build the list
            final List<String> data = userSnapshot.data!.followers;

            return FutureBuilder<User?>(
              future: baseUserData,
              builder: (context, baseUserSnapshot) {
                if (baseUserSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (baseUserSnapshot.hasError) {
                  return Text('Error: ${baseUserSnapshot.error}');
                } else if (baseUserSnapshot.hasData && baseUserSnapshot.data != null) {
                  final List<String> baseUserFollowings = baseUserSnapshot.data!.followings;

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final follower = data[index];
                      final isFollowingUser = isFollowing(follower, baseUserFollowings);
                      return ListTile(
                        title: GestureDetector(
                          onTap: () {
                            _userController.navigateToAnotherUserProfile(follower, widget.onUpdate);
                          },
                          child: Text(
                            "@$follower",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        trailing: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              isFollowingUser ? Colors.green : Colors.white,
                            ),
                          ),
                          onPressed: () {
                            toggleFollow(follower, baseUserFollowings);
                          },
                          child: Text(
                            isFollowingUser ? 'Unfollow' : 'Follow',
                            style: TextStyle(
                              color: isFollowingUser ? Colors.white : Colors.green,
                            ),
                          ),
                        ),
                        // Add more UI elements or interactions as needed
                      );
                    },
                  );
                } else {
                  return Text('No Base User Data Available');
                }
              },
            );
          } else {
            return Text('No User Data Available');
          }
        },
      ),
    );
  }
}
