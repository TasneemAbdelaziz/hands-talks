import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/message/chatpage.dart';
import 'package:hands_talks/theming.dart';

class MessagesPage extends StatelessWidget {
  static const String routeName = "MessagePage";
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages",style: Theming.lightTheme.textTheme.titleLarge,),
        elevation: 0,
        actions: [
          Padding(
            padding:const EdgeInsets.only(right: 10.0) ,
              child: Image.asset("assets/icons/Button - Compose.png")),
        ],
      ),
      body:
         Column(
          children: [
            Padding(
              padding:const EdgeInsets.all(10) ,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theming.searchbar,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                      color: Theming.form,
                      size: 25,
                    ),
                    const SizedBox(width: 10,),
                    Text("Search",style: TextStyle(color:Theming.form,fontSize: 20 ),)
                  ],
                ),
              ),
            ),
            Expanded(
              child:Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                child: ListView(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.of(context).pushNamed(ChatPage.routeName);
                      },
                      child: Card(
                        color: Colors.transparent,
                        margin: const EdgeInsets.all(5),
                        elevation: 0,
                        // color: Colors.transparent,
                        child: ListTile(
                          leading: const Padding(
                            padding: EdgeInsets.only(right: 0),
                            child: CircleAvatar(backgroundColor: Colors.transparent,child: Icon(Icons.account_circle_rounded,size: 50,),
                              ),
                          ),

                          title: Text("Ali Ahmed",style: Theming.lightTheme.textTheme.titleLarge!.copyWith(fontSize: 17),),
                          subtitle: Text("Hello!!",style: Theming.lightTheme.textTheme.bodySmall,),
                          trailing: Text("9:40 AM",style: Theming.lightTheme.textTheme.bodySmall),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal:15 ),
                        ),
                      ),
                    ),
                    const Divider(
                      indent: 10,
                      endIndent: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

    );
  }
}
