import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';

import 'gps_status.dart';
import 'location_permission_status.dart';
import 'location_service.dart';

class AppLocationService implements LocationService {
  /*final BehaviorSubject<bool> notifyLocationRequest = BehaviorSubject<bool>();
  late final StreamSubscription? subscription;*/

  @override
  Future<bool> checkIfGpsEnabled() async {
    var isEnabled = await Geolocator.isLocationServiceEnabled();
    return isEnabled;
  }

  Stream<ServiceStatus> gpsStatusStream() =>
      Geolocator.getServiceStatusStream();

  @override
  Stream checkPermission() async* {
    LocationPermission permission;

    var isEnabled = await checkIfGpsEnabled();
    if (!isEnabled) {
      yield GpsStatus.disabled;
    } else {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          yield LocationPermissionStatus.showRationale;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        yield LocationPermissionStatus.openSetting;
      } else if (permission == LocationPermission.whileInUse) {
        yield LocationPermissionStatus.accepted;
      } else if (permission == LocationPermission.always) {
        yield LocationPermissionStatus.accepted;
      }
    }
  }

  /*dispose() async {
    await subscription?.cancel();
  }*/

  @override
  Future<Position> getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition();
    return position;
  }

  @override
  Future openSettings() async {
    if (Platform.isAndroid) {
      var isOpened = await Geolocator.openLocationSettings();
      return isOpened;
    } else if (Platform.isIOS) {
      var isOpened = await Geolocator.openAppSettings();
      return isOpened;
    }
  }

  @override
  Future<bool> checkIfPermissionGranted() async {
    var status = await Geolocator.checkPermission();

    if (status == LocationPermission.always ||
        status == LocationPermission.whileInUse) {
      return true;
    }

    return false;
  }
}
