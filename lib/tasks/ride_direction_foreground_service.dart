import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../app_lifecyle_utility_callbacks.dart';
import '../app_overlay_settings.dart';
import '../constants.dart';
import '../event_notifier.dart';
import '../overlay_permission_status.dart';
import '../ride_direction_notification_service.dart';

class RideDirectionForegroundService
    with AppOverlaySettings
    implements RideDirectionNotificationService, EventNotifier {
  ReceivePort? _eventPipeline;

  @override
  void init({String? channelID, String? channelName, String? description}) {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
          channelId: channelID ?? "jadu_ride_default_ride_notification_id",
          channelName: channelName ?? "Jadu Ride Direction Notification",
          channelDescription: description,
          channelImportance: NotificationChannelImportance.MAX,
          priority: NotificationPriority.MAX,
          buttons: [
            const NotificationButton(
                id: Constants.backToApp, text: 'Back to app'),
          ],
          visibility: NotificationVisibility.VISIBILITY_PUBLIC,
          enableVibration: true,
          iconData: const NotificationIconData(
            resType: ResourceType.mipmap,
            resPrefix: ResourcePrefix.ic,
            name: 'launcher',
          ),
          playSound: true),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: true,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: true,
        autoRunOnBoot: false,
        allowWakeLock: false,
      ),
    );
    AppLifeCycleUtilityCallbacks.lockScreenVisibility();
  }

  @override
  initPort(bool isGranted) async {
    closePort();

    if (isGranted) {
      _eventPipeline = await FlutterForegroundTask.receivePort;
      debugPrint("eventPipeLine $_eventPipeline");
    } else {
      _eventPipeline = null;
    }
  }

  @override
  ReceivePort? get eventPort => _eventPipeline;

  @override
  closePort() {
    _eventPipeline?.close();
    _eventPipeline = null;
  }

  @override
  void stop() async {
    await FlutterForegroundTask.stopService();
  }

  @override
  Future<bool> get isServiceRunning => FlutterForegroundTask.isRunningService;

  @override
  Future<bool> runService() async {
    var isGranted = await checkPermission();
    if (isGranted == OverlayPermissionStatus.granted) {
      var isRunning = await runServiceIfNot();
      log("service running $isRunning");
      initPort(isRunning);
      return isRunning;
    }

    return false;
  }
}
