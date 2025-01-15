# projek


import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize the notification plugin
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Small icon

    const InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap event
        print("Notification tapped: ${response.payload}");
      },
    );
  }

  // Download image from URL and save to local storage
  static Future<String?> _downloadAndSaveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/notification_image.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e) {
      print("Error downloading image: $e");
    }
    return null;
  }

  // Show notification with image from URL
  static Future<void> showNotificationWithImage({
    required int id,
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String title,
    required String body,
    required String imageUrl,
    String? payload,
  }) async {
    final bigPicturePath = await _downloadAndSaveImage(imageUrl);

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher', // Small icon
      styleInformation: bigPicturePath != null
          ? BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath), // Local path for image
        contentTitle: title,
        summaryText: body,
      )
          : DefaultStyleInformation(true, true), // Default style
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}

