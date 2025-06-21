import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingChats extends StatelessWidget {
  const LoadingChats({super.key});

  @override
  Widget build(BuildContext context) {
    return // Center(
      Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade200,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 25,
              ),
            ),

            const SizedBox(height: 10,),

            Column(
              children: [

                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade200,
                      child: Container(
                        height: 20,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.white,
                        ),
                      ),
                    ),


                const SizedBox(height: 10,),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade200,
                  child: Container(
                    height: 20,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                  ),
                ),

              ],
            )

          ],
          // ),
        ),
      );
  }
}



