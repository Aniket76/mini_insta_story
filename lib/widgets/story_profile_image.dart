import 'package:flutter/material.dart';

class StoryProfileImage extends StatelessWidget {
  const StoryProfileImage({Key? key, required this.imagePath, required this.name, required this.isSeen, required this.onTapProfile }) : super(key: key);

  final bool isSeen;
  final String imagePath;
  final String name;
  final VoidCallback onTapProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTapProfile,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container (
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        gradient: isSeen ? const LinearGradient(
                            colors: [
                              Color(0xFF555555),
                              Color(0xFF555555),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp
                        ) : const LinearGradient(
                            colors: [
                              Color(0xFFF6B55A),
                              Color(0xFFD42366),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp
                        ),
                      ),
                    )
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container (
                      width: 70,
                      height: 70,
                      color: Colors.black,
                    )
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    imagePath,
                    width: 62,
                  ),
                )
              ],
            ),
            const SizedBox(height: 4,),
            Text(
              name,
              style: TextStyle(
                  fontSize: 12,
                  color: isSeen ? const Color(0xFFA8A8A8) : Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
