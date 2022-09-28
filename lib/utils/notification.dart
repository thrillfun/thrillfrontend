import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class CustomNotification {
  static initialize() {
    AwesomeNotifications().initialize(
        'resource://drawable/icon',
        [
          NotificationChannel(
              channelGroupKey: 'normal_channel_group',
              channelKey: 'normal_channel',
              channelName: 'Normal Notifications',
              channelDescription:
                  'Notification channel for normal notifications',
              defaultColor: const Color(0xFF9D50DD),
              ledColor: Colors.white),
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupkey: 'normal_channel_group',
              channelGroupName: 'Normal group'),
        ],
        debug: true);
  }

  static showNormal({
    required String title,
    required String body,
  }) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: Random().nextInt(111),
          channelKey: 'normal_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          autoDismissible: true,
          showWhen: true),
    );
  }
}
