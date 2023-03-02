abstract class RideDirectionNotificationService {
  Future<bool> get isServiceRunning;

  void init({String channelID, String channelName, String description});

  void runService();

  void stop();
}
