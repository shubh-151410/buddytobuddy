

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePushNotification{
  final String serverToken = 'fE9gyF-jVDQ:APA91bGI7HlFmzAFtqumiimO8_yiJbj5RrrOmsfoyYjsfNE-GwuHXrAz79PXRC5oUVT3C3TrtCVlbeIw8v8PirVDEm8OjlAT5uYnGhB72J9WCefvANJP945xNBrsXx7I3ojwb0UydU8i';
final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
  await firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
  );

  var s = await http.post(
    'https://fcm.googleapis.com/fcm/send',
     headers: <String, String>{
       'Content-Type': 'application/json',
       'Authorization': 'key=$serverToken',
     },
     body: jsonEncode(
     <String, dynamic>{
       'notification': <String, dynamic>{
         'body': 'this is a body',
         'title': 'this is a title'
       },
       'priority': 'high',
       'data': <String, dynamic>{
         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
         'id': '1',
         'status': 'done'
       },
       'to': await firebaseMessaging.getToken(),
     },
    ),
  );

  print(s.body);
  print(s.statusCode);

  final Completer<Map<String, dynamic>> completer =
     Completer<Map<String, dynamic>>();

  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      completer.complete(message);
    },
  );

  return completer.future;
}
}

