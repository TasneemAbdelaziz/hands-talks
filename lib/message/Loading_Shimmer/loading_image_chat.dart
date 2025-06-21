import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingImageChat extends StatelessWidget {
  const LoadingImageChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 25,
      ),
    );
  }
}
