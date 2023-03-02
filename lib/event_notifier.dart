import 'dart:isolate';

abstract class EventNotifier {
  ReceivePort? get eventPort;
  initPort(bool isGranted);
  closePort();
}
