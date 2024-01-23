import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/models/user.dart';
import '../constants.dart';
import '../service/storage_service.dart';

class AnotherUserProfile extends StatefulWidget {
  final String username;
  final VoidCallback onUpdate;
  const AnotherUserProfile({Key? key, required this.username, required this.onUpdate}) : super(key: key);

  @override
  State<AnotherUserProfile> createState() => _AnotherUserProfileState();
}

class _AnotherUserProfileState extends State<AnotherUserProfile> {
  late Future<User?> userData;
  late UserController controller;
  late Future<User?> baseUserData;
  late String? baseUserName;

  @override
  void initState() {
    super.initState();
    controller = UserController(context: context);
    userData = fetchData(widget.username);
    baseUserData = fetchBaseData();

  }

  Future<User?> fetchData(String username) async {
    return controller.getUserProfile(username);
  }

  Future<User?> fetchBaseData() async {
    baseUserName =  await StorageService().readSecureData('username');
    return controller.getUserProfile('$baseUserName');
  }


  Future<User?> updateData(String username) async {
    return controller.updateUserProfile(username);
  }

  bool isFollowing(String username, List<String> baseUserFollowings) {
    return baseUserFollowings.contains(username);
  }

  void toggleFollow(String username, List<String> baseUserFollowings) async {
    bool isCurrentlyFollowing = isFollowing(username, baseUserFollowings);

    if (isCurrentlyFollowing) {
      controller.unfollowUser(username).then((dbResult) async {
        if (dbResult == true) {
          await controller.updateUserProfile('$baseUserName');
          await controller.updateUserProfile(widget.username);
          baseUserData = controller.getUserProfile('$baseUserName');
          userData =  controller.getUserProfile(widget.username);
          setState(() {

          });
          widget.onUpdate();
        } else {
          print('Unfollow database call failed');
        }
      });
    } else {
      controller.followUser(username).then((dbResult) async {
        if (dbResult == true) {
          await controller.updateUserProfile('$baseUserName');
          await controller.updateUserProfile(widget.username);
          baseUserData = controller.getUserProfile('$baseUserName');
          userData =  controller.getUserProfile(widget.username);
          setState(() {

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
      appBar: const CommonAppBar(appBarText: "Profile", canGoBack: true),
      backgroundColor: const Color(kOpeningBG),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            userData = updateData(widget.username);
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: FutureBuilder<User?>(
              future: userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  Container(); // Show loading indicator
                } else if (snapshot.hasData && snapshot.data != null) {
                  User user = snapshot.data!;
                  return Column(
                    children: [
                      SizedBox(height: 20),
                      const Icon(Icons.supervised_user_circle, color: Colors.white, size: 82),
                      SizedBox(height: 10),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green, // Text color green
                        ),
                      ),
                      Text(
                        '${user.name} ${user.surname}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green, // Text color green
                        ),
                      ),
                      SizedBox(height: 20),
                      followerFollowingSection(user),
                      SizedBox(height: 20),
                      FutureBuilder(
                          future: baseUserData,
                          builder: (context, baseUserSnapshot) {
                            if(baseUserSnapshot.connectionState == ConnectionState.waiting) {
                              return Container();
                            } else if (baseUserSnapshot.hasError) {
                              Text('Error While Fetching Data');
                            } else if (baseUserSnapshot.hasData && baseUserSnapshot.data != null) {
                              final List<String> baseUserFollowings = baseUserSnapshot.data!.followings;
                              final isFollowingUser = isFollowing(widget.username, baseUserFollowings);
                              return ElevatedButton(
                                onPressed: () async {
                                  toggleFollow(widget.username, baseUserFollowings);

                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(isFollowingUser ? Colors.red : Colors.green),
                                ),
                                child: Text( isFollowingUser ? 'Unfollow' : 'Follow'),
                              );
                            }
                              return Text('No User Data Available');

                          }
                      ),
                      profileOption('Lists', Icons.list, () {
                        controller.navigateToMyListsPage(context, user.username, false);
                      }),
                      profileOption('Liked Lists', Icons.list, () {
                        controller.navigateToLikedLists(user.likedPlaylists);
                      }),
                      profileOption('Likings', Icons.favorite_border, () {
                        controller.navigateOthersToLikedSongsPage(context, user);
                      }),
                      profileOption('Analysis', Icons.analytics, () {
                        controller.navigateToAnalysis(user.username);
                      }),
                    ],
                  );
                } else {
                  return Text(
                    'No user data available.',
                    style: TextStyle(color: Colors.green), // Text color green
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget followerFollowingSection(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => controller.navigateToAnotherUserFollowers(widget.username, widget.onUpdate),
          child: Text(
            'Followers: ${user.followers.length}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.green, // Text color green
            ),
          ),
        ),
        Text(
          ' | ',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white, // Separator color
          ),
        ),
        GestureDetector(
          onTap: () => controller.navigateToAnotherUserFollowings(widget.username, widget.onUpdate),
          child: Text(
            'Following: ${user.followings.length}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.green, // Text color green
            ),
          ),
        ),
      ],
    );
  }

  Widget profileOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green), // Icon color green
      title: Text(title, style: TextStyle(color: Colors.green)), // Text color green
      onTap: onTap,
    );
  }


}
