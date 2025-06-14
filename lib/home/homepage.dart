import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_storage/firebase_storage.dart';


Future<String> getDownloadUrl(String url) async {
  try {
    // If URL is already valid, return it directly.
    if (url.startsWith('http')) return url;

    // Fallback: Treat as filename (old logic).
    return await FirebaseStorage.instance
        .ref('posts_images/$url')
        .getDownloadURL();
  } catch (e) {
    return 'Failed to get image URL: $e';
  }
}

// Future<String> getDownloadUrl(String url) async {
//   try {
//     // Extract filename from URL (e.g., "posts_images/1745065624689_images.jpeg")
//     final uri = Uri.parse(url);
//     final pathSegments = uri.pathSegments; // ["v0", "b", "hands-talks-e581c.appspot.com", "o", "posts_images%2F1745065624689_images.jpeg"]
//     final encodedFilename = pathSegments.last; // "posts_images%2F1745065624689_images.jpeg"
//     var filename = Uri.decodeComponent(encodedFilename); // "posts_images/1745065624689_images.jpeg"
//     // Get download URL (redundant if `url` is already public)
//     return url; // If the URL is public, just return it directly.
//   } catch (e) {
//     return 'Failed to get image URL: $e';
//   }
// }

// void main() {
//   runApp(const HomePage());
// }

class HomePage extends StatelessWidget {
  static const String routeName = "HomePage";

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FeedsPage(),
      routes: {
        PostDetailsPage.routeName: (context) => const PostDetailsPage(),
      },
    );
  }
}

class FeedsPage extends StatefulWidget {
  const FeedsPage({super.key});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  int selected = 0;
  final List<String> tabs = ['Daily Posts', 'Community'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('Feeds',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            _iconButton('assets/icons/filter.png', 'Filter icon tapped!'),
            _iconButton('assets/icons/notification.png', 'Notification icon tapped!', showDot: true),
          ],
        ),
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDailyPosts(),
                  _buildCommunityCards(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        onTap: (index) => setState(() => selected = index),
        isScrollable: true,
        indicatorColor: Colors.transparent,
        tabs: tabs.map((title) {
          final bool isSelected = tabs.indexOf(title) == selected;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSelected ? Colors.grey : Colors.transparent,
              border: isSelected ? null : Border.all(color: Colors.grey),
            ),
            child: Text(
              title,
              style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _iconButton(String path, String message, {bool showDot = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () => print(message),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(path, width: 24, height: 24),
            if (showDot)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No posts found"));
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (_, index) {
            final doc = posts[index];
            final data = doc.data() as Map<String, dynamic>;

            final String title = data['title'] ?? 'No Title';
            final String content = data['content'] ?? '';
            final String filename = data['mediaUrl'] ?? '';
            final Timestamp? timestamp = data['timestamp'];

            String formattedTime = '';
            if (timestamp != null) {
              final DateTime dateTime = timestamp.toDate();
              formattedTime = timeago.format(dateTime);
            }

            return PostCard(
              timeAgo: formattedTime,
              title: title,
              content: content,
              filename: filename,
            );
          },
        );
      },
    );
  }

  Widget _buildCommunityCards() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (_, __) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Community Name.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network("https://via.placeholder.com/600x400"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PostCard extends StatefulWidget {
  final String timeAgo;
  final String title;
  final String content;
  final String filename;

  const PostCard({
    super.key,
    required this.timeAgo,
    required this.title,
    required this.content,
    required this.filename,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.content.length > 100;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.timeAgo, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            expanded || !isLong ? widget.content : '${widget.content.substring(0, 100)}...',
            style: const TextStyle(fontSize: 14),
          ),
          if (isLong && !expanded)
            TextButton(
              onPressed: () => setState(() => expanded = true),
              child: const Text('Read More'),
            ),
          const SizedBox(height: 8),
          if (widget.filename.isNotEmpty)

            FutureBuilder<String>(
              future: getDownloadUrl(widget.filename),
              builder: (context, snapshot) {
                print("WidgetFilename${widget.filename}");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  print("Snapshot.data${snapshot.data}");
                  return const Icon(Icons.broken_image, size: 100);
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text(
                          'Image failed to load',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ]),
      ),
    );
  }
}

class PostDetailsPage extends StatelessWidget {
  static const String routeName = "/postDetails";

  const PostDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Post Details Placeholder')),
    );
  }
}

class PostDetailsArguments {
  final String userName;
  final String location;
  final String postDescription;
  final String imageUrl;

  PostDetailsArguments({
    required this.userName,
    required this.location,
    required this.postDescription,
    required this.imageUrl,
  });
}
