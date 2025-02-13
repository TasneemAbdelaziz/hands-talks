import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static const String routeName = "HomePage";

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FeedsPage(),
      routes: {
        PostDetailsPage.routeName: (context) => const PostDetailsPage(),
      },
    );
  }
}

class FeedsPage extends StatefulWidget {
  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  int selected = 0;

  final List<String> dishTypes = ['Daily Posts', 'Community'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: dishTypes.length, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            'Feeds',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: GestureDetector(
                onTap: () {
                  print('Filter icon tapped!');
                },
                child: Image.asset(
                  'assets/icons/filter.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  print('Notification icon tapped!');
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      'assets/icons/notification.png',
                      width: 24,
                      height: 24,
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TabBar(
                  onTap: (index) {
                    setState(() {
                      selected = index;
                    });
                  },
                  isScrollable: true,
                  indicatorColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: null,
                  tabs: dishTypes.map((source) {
                    bool isSelected = selected == dishTypes.indexOf(source);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected ? Colors.grey : Colors.transparent,
                        border: isSelected ? null : Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Text(
                        source,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      String postDescription = (index % 2 == 0)
                          ? "This is a short post description."
                          : "This is a longer post description to demonstrate the 'Read More' functionality. It is longer than what should be shown in the preview.";
                      return CommunityPost(
                        userName: "Zepenllin",
                        location: "Satellites",
                        postDescription: postDescription,
                        imageUrl: "https://via.placeholder.com/400x200",
                        seenCount: 1900,
                        userAvatars: [
                          "https://via.placeholder.com/40",
                          "https://via.placeholder.com/40",
                          "https://via.placeholder.com/40",
                        ],
                        onReadMore: () {
                          Navigator.pushNamed(
                            context,
                            PostDetailsPage.routeName,
                            arguments: PostDetailsArguments(
                              userName: "Zepenllin",
                              location: "Satellites",
                              postDescription: postDescription,
                              imageUrl: "https://via.placeholder.com/400x200",
                            ),
                          );
                        },
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Card(

                        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Community Name.",
                                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                              ),
                            ),

                            const SizedBox(height: 10.0),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),

                              child: Image.network("https://via.placeholder.com/600x400"),

                            ),
                          ],
                        ),
                      );
                    },
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

class CommunityPost extends StatelessWidget {
  final String userName;
  final String location;
  final String postDescription;
  final String imageUrl;
  final int seenCount;
  final List<String> userAvatars;
  final VoidCallback? onReadMore;

  const CommunityPost({
    required this.userName,
    required this.location,
    required this.postDescription,
    required this.imageUrl,
    required this.seenCount,
    required this.userAvatars,
    this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLongDescription = postDescription.length > 100;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userAvatars[0]),
                ),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0)),
                    Text(location, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(imageUrl),
            ),
            const SizedBox(height: 8.0),
            Text(
              isLongDescription
                  ? "${postDescription.substring(0, 100)}..."
                  : postDescription,
            ),
            if (isLongDescription)
              TextButton(
                onPressed: onReadMore,
                child: const Text("Read More"),
              ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Row(
                  children: userAvatars.take(3).map((avatar) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: CircleAvatar(
                        radius: 12.0,
                        backgroundImage: NetworkImage(avatar),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 8.0),
                Text("Seen by $seenCount")
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PostDetailsPage extends StatelessWidget {
  static const String routeName = "/postDetails";

  const PostDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PostDetailsArguments args =
    ModalRoute.of(context)!.settings.arguments as PostDetailsArguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(args.imageUrl),
                ),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(args.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0)),
                    Text(args.location, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(args.imageUrl),
            ),
            const SizedBox(height: 16.0),
            Text(args.postDescription),
          ],
        ),
      ),
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
