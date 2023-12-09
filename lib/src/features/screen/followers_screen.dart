import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import '../constants.dart';
class FollowersPage extends StatefulWidget {
  final String currentUserName;
  final List<String> followers;
  final List<String> followings; // New property for followings

  const FollowersPage({Key? key, required this.followers, required this.followings, required this.currentUserName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  late List<String> _currentFollowers;
  late List<String> _currentFollowings;
  late UserController _userController;

  @override
  void initState() {
    super.initState();
    _currentFollowers = widget.followers;
    _currentFollowings = widget.followings;
    _userController = UserController(context: context);
  }


  bool isFollowing(String username) {
    return _currentFollowings.contains(username);
  }


  void toggleFollow(String username) {
    bool isCurrentlyFollowing = isFollowing(username);

    if (isCurrentlyFollowing) {
      _userController.unfollowUser(widget.currentUserName, username).then((dbResult) {
        if (dbResult == true) {
          setState(() {
            _currentFollowings.remove(username);
          });
        } else {
          print('Unfollow database call failed');
        }
      });
    } else {
      _userController.followUser(widget.currentUserName, username).then((dbResult) {
        if (dbResult == true) {
          setState(() {
            _currentFollowings.add(username);
          });
        } else {
          print('Follow database call failed');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(appBarText: kFollowersAppBarText),
      backgroundColor: const Color(kOpeningBG),
      body: ListView.builder(
        itemCount: _currentFollowers.length,
        itemBuilder: (context, index) {
          final follower = _currentFollowers[index];
          final isFollowingUser = isFollowing(follower);
          return ListTile(
            title: GestureDetector(
              onTap: (){
                _userController.navigateToAnotherUserProfile(follower, _currentFollowings);
              },
              child: Text(
                "@$follower",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            trailing: ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(isFollowingUser ? Colors.green : Colors.white)),
              onPressed: () {
                toggleFollow(follower);
              },
              child: Text(
                  isFollowingUser ? 'Unfollow' : 'Follow',
                  style: TextStyle(
                    color: isFollowingUser ? Colors.white : Colors.green
                  ),
              ),
            ),
            // Add more UI elements or interactions as needed
          );
        },
      ),
    );
  }
}
