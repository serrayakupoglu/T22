import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/body_text.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/models/user.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Future<User?> userData;
  late UserController controller;

  @override
  void initState() {
    super.initState();
    controller = UserController(context: context);
    userData = fetchData();
  }

  Future<User?> fetchData() async {
    String? username = await storageService.readSecureData('username');
    if (username != null) {
      return controller.getUserProfile(username);
    } else {
      return null;
    }
  }
  Future<User?> updateData() async {
    String? username = await storageService.readSecureData('username');
    if (username != null) {
      return controller.updateUserProfile(username);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          setState(() {
            userData = updateData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20),

                FutureBuilder<User?>(
                  future: userData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return  Container();
                    } else if (snapshot.hasData && snapshot.data != null) {
                      User user = snapshot.data!;
                      return Column(
                        children: [
                          SizedBox(height: 40),
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
                          profileOption('My Lists', Icons.list, () {
                            controller.navigateToMyListsPage(context, user.username, true);
                          }),
                          profileOption('Likings', Icons.favorite_border, () {
                            controller.navigateToLikedSongsPage(context, user);
                          }),
                          profileOption('Analysis', Icons.analytics, () {
                            controller.navigateToAnalysis(user.username);
                          }),
                          SizedBox(height: 20),
                          logoutButton(context, user.username),
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
              ],
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
          onTap: () => controller.navigateToFollowers(user.followers, user.followings, user.username),
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
          onTap: () => controller.navigateToFollowings(user.followings, user.followings, user.username),
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

  Widget logoutButton(BuildContext context, String username) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.green, // Button color green
        onPrimary: Colors.white,
      ),
      onPressed: () {
        controller.logout(username);
      },
      child: Text('Logout'),
    );
  }
}