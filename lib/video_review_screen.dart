import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoReviewScreen extends StatefulWidget {
  final String role; // Role: 'Director' or 'Artist'

  const VideoReviewScreen({super.key, required this.role});

  @override
  _VideoReviewScreenState createState() => _VideoReviewScreenState();
}

class _VideoReviewScreenState extends State<VideoReviewScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  double _currentPosition = 0.0;
  double _volume = 1.0;

  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // List to store comments
  List<Map<String, dynamic>> comments = [];

  // List to filter the comments based on search query
  List<Map<String, dynamic>> filteredComments = [];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/UNCOUNTED.mp4');
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.addListener(_updatePosition);

    // Initially, all comments are shown
    filteredComments = [...comments];
  }

  @override
  void dispose() {
    _controller.removeListener(_updatePosition);
    _controller.dispose();
    _commentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updatePosition() {
    setState(() {
      _currentPosition = _controller.value.position.inSeconds.toDouble();
    });
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add({
          'text': _commentController.text,
          'timestamp': _currentPosition,
          'user': widget.role,
        });
        _commentController.clear();
        _filterComments(_searchController.text);
      });
    }
  }

  void _filterComments(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredComments = [...comments];
      } else {
        filteredComments = comments
            .where((comment) =>
                comment['text'].toLowerCase().contains(query.toLowerCase()) ||
                (comment['reply']?.toLowerCase() ?? '')
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _replyToComment(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final replyController = TextEditingController();
        return AlertDialog(
          title: const Text("Reply to Comment"),
          content: TextField(
            controller: replyController,
            decoration: const InputDecoration(hintText: "Type your reply here"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (replyController.text.isNotEmpty) {
                  setState(() {
                    comments[index]['reply'] = replyController.text;
                    _filterComments(_searchController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Reply"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Review - ${widget.role}"),
      ),
      body: Container(
        child: Column(
          children: [
            // Video player section
            SizedBox(
              height: 250,
              child: FutureBuilder<void>(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),

            // Custom seek bar
            Slider(
              min: 0,
              max: _controller.value.duration.inSeconds.toDouble(),
              value: _currentPosition,
              onChanged: (value) =>
                  _controller.seekTo(Duration(seconds: value.toInt())),
            ),

            // Play/Pause button and volume control
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
                Slider(
                  min: 0,
                  max: 1,
                  value: _volume,
                  onChanged: (value) {
                    setState(() {
                      _volume = value;
                      _controller.setVolume(value);
                    });
                  },
                ),
              ],
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Search comments",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _filterComments,
              ),
            ),

            // Comment section
            Expanded(
              child: filteredComments.isEmpty
                  ? const Center(child: Text("No comments yet"))
                  : ListView.builder(
                      itemCount: filteredComments.length,
                      itemBuilder: (context, index) {
                        final comment = filteredComments[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white, // White background
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              comment['text'],
                              style: const TextStyle(color: Colors.black),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Timestamp: ${comment['timestamp']}s',
                                  style:
                                      const TextStyle(color: Colors.black54),
                                ),
                                if (comment.containsKey('reply'))
                                  Text(
                                    'Reply: ${comment['reply']}',
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                              ],
                            ),
                            trailing: widget.role == 'Artist'
                                ? IconButton(
                                    icon: const Icon(Icons.reply,
                                        color: Colors.black),
                                    onPressed: () => _replyToComment(index),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),

            // Add comment input for Director
            if (widget.role == 'Director')
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: "Add a comment",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _addComment,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
