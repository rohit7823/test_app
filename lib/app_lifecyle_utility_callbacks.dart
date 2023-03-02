import 'package:flutter_foreground_task/flutter_foreground_task.dart';

mixin AppLifeCycleUtilityCallbacks {
  static Future<bool> isAppForeground() async {
    return FlutterForegroundTask.isAppOnForeground;
  }

  static bringToForeground(String argument) async {
    FlutterForegroundTask.launchApp(argument);
  }

  static lockScreenVisibility({bool visibility = true}) {
    FlutterForegroundTask.setOnLockScreenVisibility(visibility);
  }

  static minimizeApp() {
    FlutterForegroundTask.minimizeApp();
  }

  static wakeUpScreen() {
    FlutterForegroundTask.wakeUpScreen();
  }

  static Future<bool> canDrawOverlays() =>
      FlutterForegroundTask.canDrawOverlays;

  static Future<bool> ignoreBatteryOptimizations() =>
      FlutterForegroundTask.requestIgnoreBatteryOptimization();
}
