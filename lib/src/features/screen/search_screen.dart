import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/bottom_song_sheet.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/header_text.dart';
import 'package:untitled1/src/features/common_widgets/song_box.dart';
import 'package:untitled1/src/features/controller/song_controller.dart';
import '../constants.dart';
import '../models/song.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SearchScreenState();

}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController searchController = TextEditingController();
  List<Song> songList = [];
  late SongController controller;

  @override
  void initState() {
    super.initState();
    controller = SongController(context);
  }

  @override
  Widget build(BuildContext context) {

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
                        return BottomSongSheet(song: songList[index],);
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