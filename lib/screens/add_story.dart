import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mini_insta_story/models/story.dart';
import 'package:mini_insta_story/screens/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddStory extends StatefulWidget {
  const AddStory({Key? key, required this.image, required this.stories}) : super(key: key);

  final File image;
  final List<Story> stories;

  @override
  _AddStoryState createState() => _AddStoryState();
}

class _AddStoryState extends State<AddStory> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Offset _offset = const Offset(0,40);

  final TextEditingController _textInputController = TextEditingController();
  final TextEditingController _tagSearchInputController = TextEditingController();

  String _screenText = '';
  String _tagText = '';
  double _fontSizeValue = 18;

  final List<String> _tagsList = ['Location', 'Life', 'Love', 'Music', 'Art', 'Song', 'Food', 'Ride', 'Bike', 'Car'];

  late List<String> _filterTagList;

  String _dataArray = '';

  @override
  void dispose() {
    super.dispose();
    _textInputController.dispose();
    _tagSearchInputController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _filterTagList = List.from(_tagsList);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                        image: FileImage(widget.image),
                        fit: BoxFit.cover
                    )
                ),
              ),

              if (_screenText.isNotEmpty)
                draggableText(),

              footerSection(),

              Positioned(
                top: 12,
                right: 12,
                child: CloseButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget draggableText () {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _offset = Offset(_offset.dx + details.delta.dx, _offset.dy + details.delta.dy);
            });
          },
          onTap: _editText,
          child: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                      _screenText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _fontSizeValue,
                          color: Colors.white
                      )
                  ),
                ),
              ),
            ),
          )
      ),
    );
  }

  Widget footerSection() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
              _tagText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red
              )
          ),
          const SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 12,),
              footerButton(
                buttonText: _screenText.isNotEmpty ? 'Edit Text' : 'Add Text',
                onButtonPressed: () {
                  _editText();
                }
              ),
              const SizedBox(width: 12,),
              footerButton(
                  buttonText: 'Add Tags',
                  onButtonPressed: () {
                    _addTags();
                  }
              ),
              const SizedBox(width: 12,),
              footerButton(
                  buttonText: 'Save',
                  onButtonPressed: () {
                    _saveStory();
                  }
              ),
              const SizedBox(width: 12,),
            ],
          ),
          const SizedBox(height: 16,),
        ],
      ),
    );
  }

  Widget footerButton({required String buttonText, required Function() onButtonPressed}) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: InkWell(
        onTap: onButtonPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(30)
          ),
          child: Text(
              buttonText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white
              )
          ),
        ),
      ),
    );
  }

  Future _saveStory() async {

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    final File newImage = await widget.image.copy('$appDocPath/${widget.image.path.split("/").last}');


    widget.stories.add(Story(
      imagePath: newImage.path,
      text: _screenText,
      textSize: _fontSizeValue,
      tag: _tagText,
      xOffset: _offset.dx,
      yOffset: _offset.dy,
    ));

    widget.stories.forEach((element) {
      if (_dataArray.isNotEmpty) {
        _dataArray = '$_dataArray + ${element.imagePath}, ${element.text}, ${element.textSize}, ${element.tag}, ${element.xOffset}, ${element.yOffset}';
      } else {
        _dataArray = '${element.imagePath}, ${element.text}, ${element.textSize}, ${element.tag}, ${element.xOffset}, ${element.yOffset}';
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isViewedStory', false);
    await prefs.setString('stories', _dataArray).then(
            (value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()))
    );

  }

  Future _editText() async {
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
        backgroundColor: Colors.black,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(horizontal:18 ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 12.0,),
              Text(
                  _screenText.isNotEmpty ? 'Edit Text' : 'Add Text',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white
                  )
              ),
              const SizedBox(height: 12.0,),
              TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Add Text'
                ),
                autofocus: true,
                controller: _textInputController,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  setState(() {
                    _screenText = value;
                  });
                },
                onSubmitted: (value) {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: StatefulBuilder(
                  builder: (context, setState){
                    return Slider(
                      value: _fontSizeValue,
                      max: 48,
                      min: 12,
                      divisions: 9,
                      label: _fontSizeValue.round().toString(),
                      onChanged: (double value) {
                        this.setState(() {
                          _fontSizeValue = value;
                        });
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        )
    );
  }

  Future _addTags() async {
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
        backgroundColor: Colors.black,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(horizontal:18),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 12.0,),
                  const Text(
                      'Add Tags',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white
                      )
                  ),
                  const SizedBox(height: 12.0,),
                  TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Search Tag'
                    ),
                    controller: _tagSearchInputController,
                    onChanged: (value) {
                      setState(() {
                        _filterTagList = _tagsList.where((x) => x.toLowerCase().contains(value.toLowerCase())).toList();
                      });
                      this.setState(() {});
                      print(value);
                    },
                    onSubmitted: (value) {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 12),
                  Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          for(var item in _filterTagList ) tagLayout(title: item, onTagPressed: () {
                            this.setState(() {
                              _tagText = item;
                            });
                            setState(() {});
                          })
                        ],
                      )
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        )
    );
  }

  Widget tagLayout({required String title, required Function() onTagPressed}) {
    return InkWell(
      onTap: onTagPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: _tagText == title ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(30)
        ),
        child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white
            )
        ),
      ),
    );
  }

}
