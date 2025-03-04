import 'package:flutter/material.dart';
import 'package:hands_talks/theming.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../Firebase_Utils/profile_setting.dart';



class FullScreenImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileSetting>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(onPressed:() => Navigator.pop(context), icon:Icon(Icons.arrow_back,color:Colors.white,)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Profile photo",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit,color: Colors.white,),
            onPressed: () => _showEditOptions(context),
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: "profilePic",
          child: profile.profileImageUrl != null
              ? Image.network(profile.profileImageUrl!)
              : Image.asset("assets/Default_pfp.jpg"),
        ),
      ),
    );
  }

  /// Shows the edit options bottom sheet.
  void _showEditOptions(BuildContext context) {
    final profile = Provider.of<ProfileSetting>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor:Theming.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: profile.profileImageUrl != null
                      ? Image.network(profile.profileImageUrl!)
                      :  Image.asset("assets/Default_pfp.jpg"),
                ),
                title: Text("Edit profile picture", style: TextStyle(color: Colors.white)),
              ),
              Divider(color: Colors.grey),
       
              _editOption(Icons.camera_alt, "Take photo", () {
                profile.pickAndUploadImage(ImageSource.camera);
                Navigator.pop(context);
              }),
              _editOption(Icons.photo, "Choose photo", () {
                profile.pickAndUploadImage(ImageSource.gallery);
                Navigator.pop(context);
              }),
              _editOption(Icons.delete, "Delete photo", () {
                profile.deleteImage();
                Navigator.pop(context);
              }, color: Colors.red),
            ],
          ),
        );
      },
    );
  }

  /// Helper method to create an edit option tile.
  ListTile _editOption(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(title, style: TextStyle(color: color ?? Colors.white)),
      onTap: onTap,
    );
  }
}
