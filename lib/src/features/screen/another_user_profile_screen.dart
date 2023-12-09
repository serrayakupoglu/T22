import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/body_text.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/header_text.dart';
import 'package:untitled1/src/features/common_widgets/profile_buttons.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/models/user.dart';
import 'package:untitled1/src/features/screen/opening_screen.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

import '../constants.dart';

class AnotherUserProfile extends StatefulWidget {
  final String username;
  final List<String> baseFollowings;
  const AnotherUserProfile({Key? key, required this.username, required this.baseFollowings}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnotherUserProfileState();
}

class _AnotherUserProfileState extends State<AnotherUserProfile> {
  late Future<User?> userData;
  late UserController controller;
  bool isFollowing = true;

  @override
  void initState() {
    super.initState();
    controller = UserController(context: context);
    userData = fetchData(widget.username);
  }

  Future<User?> fetchData(String username) async {
    return controller.getUserProfile(username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(appBarText: "Profile"),
      backgroundColor: const Color(kOpeningBG),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FutureBuilder(
            future: userData,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 15, top: 10),
                      child: Row(
                        children: [
                          Icon(Icons.supervised_user_circle, color: Colors.white, size: 82),
                          Column(
                            children: [
                              HeaderText(msg: "${snapshot.data!.name} ${snapshot.data!.surname}"),
                              BodyText(msg: "@${snapshot.data!.username}")
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.navigateToFollowers(snapshot.data!.followers, widget.baseFollowings, snapshot.data!.username);
                            },
                            child: HeaderText(msg: "Followers: ${snapshot.data!.followers.length}"),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.navigateToFollowings(snapshot.data!.followings, widget.baseFollowings, snapshot.data!.username);
                            },
                            child: HeaderText(msg: "Followings: ${snapshot.data!.followings.length}"),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.navigateOthersToLikedSongsPage(context, snapshot.data!);
                            },
                            child: HeaderText(msg: "Lists"), // Placeholder for My Lists
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: HeaderText(msg: "Analysis"), // Placeholder for Analysis
                          )
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
