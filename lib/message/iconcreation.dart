import 'package:flutter/material.dart';
import 'package:hands_talks/theming.dart';

class IconCreation extends StatelessWidget {
  IconData icon;
  String text;
  final VoidCallback?  ontab;
   IconCreation({super.key, required this.icon,required this.text,this.ontab});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: ontab,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 30,
            child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: Theming.icons,
                ),
                child: IconButton(onPressed: (){}, icon: Icon(icon,color: Theming.white,size: 30,))),
          ),
        ),
        Text(text),
      ],
    );
  }
}
