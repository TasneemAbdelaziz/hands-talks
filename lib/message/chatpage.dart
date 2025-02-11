import 'dart:io';
// import 'dart:math';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hands_talks/message/iconcreation.dart';
import 'package:hands_talks/theming.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  static const String routeName = "chatPage";

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  File? img;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if(pickedImage != null){
        img = File(pickedImage.path);
      }
      else{
        print("NO image");
      }
    });
  }


  final record = AudioRecorder();
  String path='';
  String url='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd9d9d9),
      appBar: AppBar(
        title: Text("Messages",style:Theming.lightTheme.textTheme.titleMedium,),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theming.white,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            color: Theming.white,
            elevation: 0,
            child: ListTile(
                    leading:const CircleAvatar(backgroundColor: Colors.transparent,child: Icon(Icons.account_circle_rounded,size: 50,),
                    ),
                  // ),
                  title: Text("Ali Ahmed",style: Theming.lightTheme.textTheme.titleLarge!.copyWith(fontSize: 17),),
                  subtitle: Text("+01114481034",style: Theming.lightTheme.textTheme.bodySmall,),
                  trailing:Image.asset("assets/icons/Videocamera.png",),
                  ),
            ),
          const Spacer(),
          Container(
            color: Theming.white,
            height: 100,
            child: Row(
              children: [
                Spacer(),
                InkWell(
                  onTap: (){
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context, builder: (build)=>
                        bottomsheet(),
                    );
                  },
                  child: Icon(Icons.add,size: 40,color: Theming.primary,),
                ),
                Spacer(),
                SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        fillColor: Theming.secondary,
                        filled: true,
                        hintText: "Type a message",
                        hintStyle: TextStyle(color: Theming.form),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                Spacer(),
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 25,
                  child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: Theming.icons,
                      ),
                      child: IconButton(onPressed: (){}, icon: Icon(Icons.send,color: Theming.white,size: 25,))),
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );


  }

  Widget bottomsheet(){
    return Container(
      decoration: BoxDecoration(
          color: Theming.white,
        borderRadius: BorderRadius.circular(20)
      ),
      height: 208,

      margin: const EdgeInsets.all(18),

      child: Column(
        children: [
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: open_image_camera,
                child: IconCreation(icon: Icons.camera_alt_rounded, text: "Camera")),
              const Spacer(),
              IconCreation(icon: Icons.mic_rounded, text: "Record",ontab: (){},),
              const Spacer(),
              IconCreation(icon: Icons.person_2_rounded, text: "Contact",ontab: (){},),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              InkWell(
                  onTap:getImage,
                  child: IconCreation(icon: Icons.insert_photo_rounded, text: "Gallery")),
              const Spacer(),
              IconCreation(icon: Icons.location_on_rounded, text: "My Location",ontab: (){},),
              const Spacer(),
              IconCreation(icon: Icons.insert_drive_file_rounded, text: "Document",ontab: (){},),
              const Spacer(),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  start_record()async{
    // to get us location for record to recording in it
    final location = await getApplicationDocumentsDirectory();
    String name = const Uuid().v1();
    if(await record.hasPermission()){
      await record.start(const RecordConfig(), path: '${location.path}$name.m4a');
    }
    print("Start Record");
  }
  stop_record()async{
    String? finalPath = await record.stop();
    setState(() {
      path=finalPath!;
    });
    print("Stop record");
  }
  open_image_gallery()async{
    var get = await ImagePicker().pickImage(source: ImageSource.gallery);
    print("=========================");

    img=File(get!.path);
    setState(() {

    });
    showAndSend();
  }
  open_image_camera()async{
    var get = await ImagePicker().pickImage(source: ImageSource.camera);
    if (get == null) return;

    img=File(get.path);
    setState(() {
      print("=========================");

    });
    showAndSend();
  }

  showAndSend(){

    showModalBottomSheet(
      context: context, builder: (build)=> Container(

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Image(image: FileImage(img!,scale: 50)),
          ElevatedButton(onPressed: (){}, child: const Text("Send"))
        ],
      ),
    ),


    );

  }


}



