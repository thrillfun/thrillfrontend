import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomNotification {
  AwesomeNotifications? awesomeNotifications;

  initialize() {
    awesomeNotifications = AwesomeNotifications();
    awesomeNotifications?.initialize(
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
              channelGroupName: 'Normal group',
              channelGroupKey: 'normal_channel_group'),
        ],
        debug: true);
  }

  showNormal({
    required String title,
    required String body,
  }) {
    awesomeNotifications?.createNotification(
      content: NotificationContent(
          id: Random().nextInt(111),
          channelKey: 'normal_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.ProgressBar,
          autoDismissible: false,
          showWhen: true),
    );
  }

  hideNotification() {
    awesomeNotifications?.dismiss(Random().nextInt(111));
  }
}
