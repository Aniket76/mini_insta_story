import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_insta_story/models/story.dart';
import 'package:mini_insta_story/screens/add_story.dart';
import 'package:mini_insta_story/screens/view_story.dart';
import 'package:mini_insta_story/widgets/story_profile_image.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();

  final List<Story> _stories = [];

  bool _isStoryViewed = true;

  @override
  void initState() {
    super.initState();
    _initPref();
  }

  Future _initPref() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedStories = prefs.getString('stories');
    final bool? isViewedStatus = prefs.getBool('isViewedStory');

    if (storedStories != null) {
      print(storedStories);

      List<String> tempArray = storedStories.split(" + ");

      tempArray.forEach((element) {
        List<String> temp = element.split(', ');
        Story story = Story(imagePath: temp[0], text: temp[1], textSize: double.parse(temp[2]), tag: temp[3], xOffset: double.parse(temp[4]), yOffset: double.parse(temp[5]));
        print(story.imagePath);
        _stories.add(story);
      });
    }

    if (isViewedStatus != null) {
      setState(() {
        _isStoryViewed = isViewedStatus;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Image.asset(
            'assets/name_logo.png',
          width: 120,
        ),
        actions: [
          InkWell(
            onTap: () {
              _selectPhoto();
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/add_icon.png',
                width: 24,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Chatting feature will be added soon'),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/chat_icon.png',
                width: 24,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Row(
            children: [
              StoryProfileImage(
                  isSeen : _isStoryViewed,
                  imagePath: 'assets/profile_one.jpeg',
                  name: 'Your Story',
                  onTapProfile: () async {
                    print('Story Icon Pressed');
                    if (_stories.isNotEmpty) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isViewedStory', true);
                      setState(() {
                        _isStoryViewed = true;
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ViewStory(stories: _stories)));
                    } else {
                      _selectPhoto();
                    }
                  },
              ),
            ],
          ),
          const Divider(
            thickness: 0.4,
            color: Color(0xFF252525),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () {
                _selectPhoto();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/add_icon.png',
                      width: 60,
                    ),
                  ),
                  const Text(
                    'Add Story',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future _selectPhoto() async {
    await showModalBottomSheet(
        context: _scaffoldKey.currentContext!,
        builder: (context) => BottomSheet(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  }),
              ListTile(
                  leading: const Icon(Icons.filter),
                  title: const Text('Pick a file'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  }),
            ],
          ),
          onClosing: () {},
        ));
  }

  Future _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile == null) {
      return;
    }

    print(pickedFile.path);
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddStory(image: File(pickedFile.path), stories: _stories,)));

  }

}