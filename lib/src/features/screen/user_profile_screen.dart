import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/body_text.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/header_text.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/models/user.dart';
import 'package:untitled1/src/features/service/storage_service.dart';
import '../common_widgets/profile_buttons.dart';


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
        print("refresh");
        userData = updateData();
        setState(() {});
      },

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder(
                future: userData,
                builder: (context, snapshot) {
                  if(snapshot.hasData && snapshot.data != null) {
                    return Column(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(left: 15, top: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.supervised_user_circle, color: Colors.white, size: 82),
                                Column(
                                  children: [
                                    HeaderText(msg: "${snapshot.data!.name} ${snapshot.data!.surname}"),
                                    BodyText(msg: "@${snapshot.data!.username}")
                                  ],
                                ),
                              ],
                            )
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {controller.navigateToFollowers(snapshot.data!.followers, snapshot.data!.followings, snapshot.data!.username);},
                                child: HeaderText(msg: "Followers: ${snapshot.data!.followers.length}"),
                              ),
                              GestureDetector(
                                onTap: () {
                                  controller.navigateToFollowings(snapshot.data!.followings, snapshot.data!.followings, snapshot.data!.username);
                                },
                                child: HeaderText(msg: "Followings: ${snapshot.data!.followings.length}"),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  controller.navigateToMyListsPage(context, snapshot.data!.username, true);
                                },
                                child: const HeaderText(msg: "My Lists"), // Placeholder for My Lists
                              ),
                              GestureDetector(
                                onTap: () {
                                  controller.navigateToAnalysis(snapshot.data!.username);
                                },
                                child: const HeaderText(msg: "Analysis"), // Placeholder for Analysis
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  controller.navigateToLikedSongsPage(context, snapshot.data!);
                                },
                                child: const HeaderText(msg: "Likings"), // Placeholder for My Lists
                              ),
                            ],
                          ),
                        ),


                        Container(margin: EdgeInsets.only(top: 250),child: ProfileButton(buttonText: "Logout", onPressed: () {controller.logout(snapshot.data!.username);}),)
                      ],

                    );
                  }

                  else {
                    return Container();
                  }
                }
            )

          ],
        ),
      )
    );
  }
}