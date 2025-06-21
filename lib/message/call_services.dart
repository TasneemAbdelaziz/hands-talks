// import 'package:hands_talks/message/call_constant.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
//
// class CallService{
//   /// on App's user login
//   static void onUserLogin({required id,required name})async {
//     /// 1.2.1. initialized ZegoUIKitPrebuiltCallInvitationService
//     /// when app's user is logged in or re-logged in
//     /// We recommend calling this method as soon as the user logs in to your app.
//     await ZegoUIKitPrebuiltCallInvitationService().init(
//       appID: CallConstant.appId /*input your AppID*/,
//       appSign: CallConstant.appSign /*input your AppSign*/,
//       userID: id,
//       userName: name,
//       plugins: [ZegoUIKitSignalingPlugin()],
//     );
//   }
//
//   /// on App's user logout
//   static void onUserLogout()async {
//     /// 1.2.2. de-initialization ZegoUIKitPrebuiltCallInvitationService
//     /// when app's user is logged out
//    await ZegoUIKitPrebuiltCallInvitationService().uninit();
//   }
//
// }