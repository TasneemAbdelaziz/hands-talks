import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Image"),
        leading: IconButton(onPressed:() => Navigator.pop(context), icon:Icon(Icons.arrow_back,color:Colors.white,)),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer( // allows zoom & pan
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
