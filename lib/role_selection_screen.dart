import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class RoleSelectionScreen extends StatefulWidget {
  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isImageLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload image after dependencies are initialized
    precacheImage(AssetImage('assets/bg_img.jpg'), context).then((_) {
      setState(() {
        _isImageLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isImageLoaded
          ? Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/bg_img.jpg',
                    fit: BoxFit.cover, // Ensures the image covers the screen
                  ),
                ),
                // Overlay UI
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 120.0, left: 20.0),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Direct, Create, Interact',
                            speed: const Duration(milliseconds: 100), // Adjust typing speed
                            textStyle: TextStyle(
                              fontSize: 50, // Increase font size to make it bigger
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        totalRepeatCount: 1,
                        pause: const Duration(seconds: 1),
                        displayFullTextOnTap: true,
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 60, // Adjusted size for bigger buttons
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to the Artist screen
                                Navigator.pushNamed(context, '/artist');
                              },
                              child: const Text(
                                "I am an Artist",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            height: 60, // Adjusted size for bigger buttons
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to the Director screen
                                Navigator.pushNamed(context, '/director');
                              },
                              child: const Text(
                                "I am a Director",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()), // Show loader until image is loaded
    );
  }
}
