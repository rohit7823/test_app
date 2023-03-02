import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../app_lifecyle_utility_callbacks.dart';
import '../app_location_service.dart';
import '../constants.dart';
import '../directions.dart';
import '../main.dart';
import '../timestamp_with_direction.dart';


class DestinationTaskHandler extends TaskHandler {
  final Directions _directionsApi;
  SendPort? _sendPort;
  final AppLocationService _locationService;

  DestinationTaskHandler(
      this._directionsApi, this._locationService);

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = null;
    await FlutterForegroundTask.clearAllData();
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    var currentLocation = await _locationService.getCurrentLocation();
    var directionResponse = await _directionsApi
        .origin(LatLng(currentLocation.latitude, currentLocation.longitude))
        .destination(
            LatLng(currentLocation.latitude, currentLocation.longitude))
        .request();

    if (directionResponse != null) {
      await FlutterForegroundTask.updateService(
        notificationTitle:
            "You've Reached - ${directionResponse.routes.first.summary}",
        notificationText: directionResponse.routes.first.legs.first.endAddress,
        callback: startCallback
      );
      /*_sendPort?.send(TimeStampWithDirection(
          timpStamp: timestamp, directionResponse: directionResponse)
      );*/
    }
  }

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    var currentLocation = await _locationService.getCurrentLocation();
    var directionResponse = await _directionsApi
        .origin(LatLng(currentLocation.latitude, currentLocation.longitude))
        .destination(
            LatLng(currentLocation.latitude, currentLocation.longitude))
        .request();

    if (directionResponse != null) {
      FlutterForegroundTask.updateService(
        notificationTitle: "You're Currently on",
        notificationText: directionResponse.routes.first.legs.first.endAddress,
        callback: startCallback
      );
    }
  }

  @override
  void onButtonPressed(String id) {
    if (id == Constants.backToApp) {
      AppLifeCycleUtilityCallbacks.bringToForeground(
          "/screenTwo"
      );
    }
  }

  @override
  void onNotificationPressed() {
    AppLifeCycleUtilityCallbacks.bringToForeground(
        "/screenTwo");
    _sendPort?.send("/screenTwo");
  }
}
