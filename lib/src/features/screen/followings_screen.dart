import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/service/storage_service.dart';
import '../constants.dart';
class FollowingsPage extends StatefulWidget {
  final String currentUserName;
  final List<String> followings;
  final List<String> baseFollowings; // New property for followings
  final VoidCallback onUpdate;

  const FollowingsPage({Key? key, required this.followings, required this.baseFollowings, required this.currentUserName, required this.onUpdate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FollowingsPageState();
}

class _FollowingsPageState extends State<FollowingsPage> {
  late List<String> _currentFollowings;
  late List<String> _currentBaseFollowings;
  late UserController _userController;

  @override
  void initState() {
    super.initState();
    _currentFollowings = widget.followings;
    _currentBaseFollowings = widget.baseFollowings;
    _userController = UserController(context: context);
  }


  bool isFollowing(String username) {
    return _currentBaseFollowings.contains(username);
  }


  void toggleFollow(String username) {
    bool isCurrentlyFollowing = isFollowing(username);

    if (isCurrentlyFollowing) {
      _userController.unfollowUser(username).then((dbResult) async {
        if (dbResult == true) {
          String? uname = await StorageService().readSecureData('username');
          await _userController.updateUserProfile('$uname');
          setState(() {
            _currentFollowings.remove(username);
          });
          widget.onUpdate();
        } else {
          print('Unfollow database call failed');
        }
      });
    } else {
      _userController.followUser(username).then((dbResult) async {
        if (dbResult == true) {
          String? uname = await StorageService().readSecureData('username');
          await _userController.updateUserProfile('$uname');
          setState(() {
            _currentFollowings.add(username);
          });
          widget.onUpdate();
        } else {
          print('Follow database call failed');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(appBarText: kFollowingsAppBarText, canGoBack: true),
      backgroundColor: const Color(kOpeningBG),
      body: ListView.builder(
        itemCount: _currentFollowings.length,
        itemBuilder: (context, index) {
          final following = _currentFollowings[index];
          final isFollowingUser = isFollowing(following);
          return ListTile(
            title: GestureDetector(
              onTap: (){
                _userController.navigateToAnotherUserProfile(following, widget.onUpdate);
              },
              child: Text(
                "@$following",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            trailing: ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(isFollowingUser ? Colors.green : Colors.white)),
              onPressed: () {
                toggleFollow(following);
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
