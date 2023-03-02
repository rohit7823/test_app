import 'dart:developer';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as overlay;
import '../main.dart';
import 'constants.dart';
import 'overlay_permission_status.dart';

mixin AppOverlaySettings {
  Future<OverlayPermissionStatus> checkPermission() async {
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        return OverlayPermissionStatus.notGranted;
      } else {
        return OverlayPermissionStatus.granted;
      }
    }
    return OverlayPermissionStatus.granted;
  }

  Future<bool> runServiceIfNot() async {
    await overlay.FlutterOverlayWindow.showOverlay(
      width: 200,
      height: 200,
      alignment: overlay.OverlayAlignment.centerLeft,
      enableDrag: true,
      overlayTitle: "",
      visibility: overlay.NotificationVisibility.visibilitySecret
    );
    if (await FlutterForegroundTask.isRunningService) {
      return await FlutterForegroundTask.restartService();
    } else {
      return await FlutterForegroundTask.startService(
          notificationTitle: "Ride Started",
          notificationText: "",
          callback: startCallback);
    }
  }

  stopOverlay() async {
    if (await overlay.FlutterOverlayWindow.isActive()) {
      return await overlay.FlutterOverlayWindow.closeOverlay();
    } else {
      log("overlay is not active");
    }
  }
}
