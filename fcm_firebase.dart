import 'package:bebunge/src/utils/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Fcm{
  late FirebaseMessaging _messaging;
  String? _deviceToken;
  Future<void> initializeFCM() async {
    _messaging = FirebaseMessaging.instance;

    // Meminta izin notifikasi
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Izin notifikasi diberikan');
    } else {
      print('Izin notifikasi ditolak');
    }

    // Mendapatkan token perangkat
    _deviceToken = await _messaging.getToken();
    print('Device Token: $_deviceToken');

    // Listener untuk pesan foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Pesan diterima di foreground: ${message.notification?.title}');
      LocalNotificationService.showNotificationWithImage(id: 1, channelId: message.notification!.android!.channelId!, channelName: message.notification!.title!, channelDescription: "Review Nik", title: message.notification!.title!, body: message.notification!.body!, imageUrl: message.notification!.android!.imageUrl!);
    });

    // Listener untuk pesan yang membuka aplikasi
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Pesan dibuka: ${message.notification?.title}');
    });
  }
}