import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/bottom_song_sheet.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/header_text.dart';
import 'package:untitled1/src/features/common_widgets/song_box.dart';
import 'package:untitled1/src/features/controller/song_controller.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/service/storage_service.dart';
import '../constants.dart';
import '../models/search_user.dart';
import '../models/song.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SearchScreenState();

}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController searchController = TextEditingController();
  final TextEditingController userSearchController = TextEditingController();
  List<Song> songList = [];
  List<SearchUser> userList = [];
  late SongController controller;
  late UserController userController;
  late Future<String?> username;

  @override
  void initState() {
    super.initState();
    controller = SongController(context);
    userController = UserController(context: context);
    username = fetchUserName();
  }

  Future<String?> fetchUserName() async {
    return await storageService.readSecureData('username');
  }

  @override
  Widget build(BuildContext context) {

    return PageView(
      children: [
        _buildSearchSongsPage(),
        _buildSearchUsersPage(),
      ],
    );
  }

  Widget _buildSearchSongsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kSignInPageSideMargin),
          child: SearchBar(
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                  decorationThickness: 0,
                  fontSize: kSignInPageInputTextSize,
                  color: Colors.white
              ),
            ),
            controller: searchController,
            shape: MaterialStateProperty.all(const ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(kInputButtonBorder * 2))
            )),
            backgroundColor: MaterialStateProperty.all(const Color(kInputButtonColor)),
            hintText: "Search a song",
            leading: const Icon(Icons.search, color: Color(kIconColor), size: kSearchBoxIconSize, ),
            constraints: const BoxConstraints(
                minHeight: kSearchBoxHeight,
                minWidth: kSearchBoxWidth
            ),
            onSubmitted: (String value) {
              controller.search(searchController.text).then((result) {
                setState(() {
                  songList = [];
                  songList = result;
                });
              });
            },
          ),
        ),
        Expanded(child: ListView.builder(
          itemCount: songList.length,
          itemBuilder: (context, index) => Card(
              color: const Color(kSignUpPageBG),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(kOpeningButtonSidePadding, 0, kOpeningButtonSidePadding, kOpeningButtonSidePadding/4),
                child: songList.isEmpty
                    ? const HeaderText(msg: "Search a Song")
                    : SongBox(
                      artistName: songList[index].getConcatenatedArtistNames(),
                      songName: songList[index].songName,
                      onIconPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.green.shade400,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return BottomSongSheet(
                            song: songList[index],
                            likeSongFunction: () async {
                              final response = await userController.addSongToLikedList('$username', songList[index].songName);
                              Future.delayed(Duration.zero, () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(response ? 'Success' : 'Error'),
                                      content: Text(response ? 'Song is successfully added to the list.' : 'Song cannot be added to the List.'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              });
                          },
                        );
                      },
                    );
                  },
                ),
              )
          ),
        ))
      ],
    );
  }

  Widget _buildSearchUsersPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kSignInPageSideMargin),
          child: SearchBar(
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                  decorationThickness: 0,
                  fontSize: kSignInPageInputTextSize,
                  color: Colors.white
              ),
            ),
            controller: userSearchController,
            shape: MaterialStateProperty.all(const ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(kInputButtonBorder * 2))
            )),
            backgroundColor: MaterialStateProperty.all(const Color(kInputButtonColor)),
            hintText: "Search a user",
            leading: const Icon(Icons.search, color: Color(kIconColor), size: kSearchBoxIconSize, ),
            constraints: const BoxConstraints(
                minHeight: kSearchBoxHeight,
                minWidth: kSearchBoxWidth
            ),
            onSubmitted: (String value) {
              userController.searchUser(userSearchController.text).then((result) {
                setState(() {
                  userList = [];
                  userList = result;
                });
              });
            },
          ),
        ),
        Expanded(child: ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) => Card(
              color: const Color(kSignUpPageBG),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(kOpeningButtonSidePadding, 0, kOpeningButtonSidePadding, kOpeningButtonSidePadding/4),
                child: userList.isEmpty
                    ? const HeaderText(msg: "Search a User")
                    : SongBox(
                  artistName: "@${userList[index].username}",
                  songName: "${userList[index].name} ${userList[index].surname}",
                  onIconPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Wrap(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.person_add),
                              title: Text('Follow ${userList[index].username}'),
                              onTap: () {
                                userController.followUser(userList[index].username);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              )
          ),
        ))
      ],
    );
  }

}