abstract class LocationService {
  Future checkIfGpsEnabled();
  Stream checkPermission();

  Future getCurrentLocation();

  Future openSettings();

  Future<bool> checkIfPermissionGranted();
}