import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mini_insta_story/models/story.dart';

class ViewStory extends StatefulWidget {
  const ViewStory({Key? key, required this.stories}) : super(key: key);

  final List<Story> stories;

  @override
  _ViewStoryState createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Offset _offset = Offset.zero;

  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
    _offset = Offset(widget.stories[0].xOffset,widget.stories[0].yOffset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.stories.length,
          itemBuilder: (context, index) {
            return storyViewSection(widget.stories[index]);
          },
        ),
      ),
    );
  }

  Widget storyViewSection(Story story) {
    return Center(
      child: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                    image: FileImage(File(story.imagePath)),
                    fit: BoxFit.cover
                )
            ),
          ),

          if (story.text.isNotEmpty)
            draggableText(story),

          footerSection(story),

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
    );
  }

  Widget draggableText(Story story) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
          child: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                      story.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: story.textSize,
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

  Widget footerSection(Story story) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
              story.tag,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red
              )
          ),
          const SizedBox(height: 12,),
        ],
      ),
    );
  }

}
