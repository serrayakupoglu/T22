// import 'package:flutter/material.dart';
// import 'package:untitled1/src/features/common_widgets/body_text.dart';
// import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
// import 'package:untitled1/src/features/common_widgets/header_text.dart';
// import 'package:untitled1/src/features/common_widgets/profile_buttons.dart';
// import 'package:untitled1/src/features/controller/user_controller.dart';
// import 'package:untitled1/src/features/models/user.dart';
// import 'package:untitled1/src/features/screen/opening_screen.dart';
// import 'package:untitled1/src/features/service/storage_service.dart';
//
// import '../constants.dart';
//
// class AnotherUserProfile extends StatefulWidget {
//   final String username;
//   final List<String> baseFollowings;
//   const AnotherUserProfile({Key? key, required this.username, required this.baseFollowings}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => _AnotherUserProfileState();
// }
//
// class _AnotherUserProfileState extends State<AnotherUserProfile> {
//   late Future<User?> userData;
//   late UserController controller;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = UserController(context: context);
//     userData = fetchData(widget.username);
//   }
//
//   Future<User?> fetchData(String username) async {
//     return controller.getUserProfile(username);
//   }
//
//   Future<User?> updateData(String username) async {
//     return controller.updateUserProfile(username);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CommonAppBar(appBarText: "Profile", canGoBack: true),
//       backgroundColor: const Color(kOpeningBG),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           setState(() {
//             userData = updateData(widget.username);
//           });
//         },
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: SafeArea(
//             child: FutureBuilder<User?>(
//               future: userData,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Container(); // Show loading indicator
//                 } else if (snapshot.hasData && snapshot.data != null) {
//                   User user = snapshot.data!;
//                   return Column(
//                     children: [
//                       SizedBox(height: 20),
//                       const Icon(Icons.supervised_user_circle, color: Colors.white, size: 82),
//                       SizedBox(height: 10),
//                       Text(
//                         '@${user.username}',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green, // Text color green
//                         ),
//                       ),
//                       Text(
//                         '${user.name} ${user.surname}',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.green, // Text color green
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       followerFollowingSection(user),
//                       SizedBox(height: 20),
//                       profileOption('Lists', Icons.list, () {
//                         controller.navigateToMyListsPage(context, user.username, false);
//                       }),
//                       profileOption('Likings', Icons.favorite_border, () {
//                         controller.navigateOthersToLikedSongsPage(context, user);
//                       }),
//                       profileOption('Analysis', Icons.analytics, () {
//                         controller.navigateToAnalysis(user.username);
//                       }),
//                     ],
//                   );
//                 } else {
//                   return Text(
//                     'No user data available.',
//                     style: TextStyle(color: Colors.green), // Text color green
//                   );
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget followerFollowingSection(User user) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         GestureDetector(
//           onTap: () => controller.navigateToFollowers(user.followers, widget.baseFollowings, user.username),
//           child: Text(
//             'Followers: ${user.followers.length}',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.green, // Text color green
//             ),
//           ),
//         ),
//         Text(
//           ' | ',
//           style: TextStyle(
//             fontSize: 18,
//             color: Colors.white, // Separator color
//           ),
//         ),
//         GestureDetector(
//           onTap: () => controller.navigateToFollowings(user.followings, widget.baseFollowings, user.username),
//           child: Text(
//             'Following: ${user.followings.length}',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.green, // Text color green
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget profileOption(String title, IconData icon, VoidCallback onTap) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.green), // Icon color green
//       title: Text(title, style: TextStyle(color: Colors.green)), // Text color green
//       onTap: onTap,
//     );
//   }
// }