import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:test_app/app_location_service.dart';
import 'package:test_app/app_overlay_settings.dart';
import 'package:test_app/directions.dart';
import 'package:test_app/tasks/destination_task_handler.dart';
import 'package:test_app/tasks/ride_direction_foreground_service.dart';

import 'app_overlay_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/home",
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/home":
            return MaterialPageRoute(
                builder: (context) =>
                    const MyHomePage(title: 'Flutter Demo Home Page'));
          case "/screenTwo":
            return MaterialPageRoute(
              builder: (context) => const ScreenTwo(),
            );
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/screenTwo");
            },
            child: const Text("Navigate")),
      ),
    );
  }
}

class ScreenTwo extends StatefulWidget {
  const ScreenTwo({Key? key}) : super(key: key);

  @override
  State<ScreenTwo> createState() => _ScreenTwoState();
}

class _ScreenTwoState extends State<ScreenTwo> with WidgetsBindingObserver {
  late final RideDirectionForegroundService _service;
  bool isRunning = false;

  @override
  void initState() {
    _service = RideDirectionForegroundService();
    WidgetsBinding.instance.addObserver(this);
    if(!isRunning) {
      _service.init(
        channelID: "jadu_ride_direction_navigation_service_id",
        channelName: "JaduRide Direction Navigation Service",
      );
    }
    super.initState();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      _service.stopOverlay();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    var value = await _service.runService();
                    setState(() {
                      isRunning = value;
                    });
                  },
                  child: const Text("Start Service")),
              Text("Service Running:: $isRunning ::")
            ],
          ),
        ),
      ),
    );
  }
}

@pragma("vm:entry-point")
void startCallback() {
  FlutterForegroundTask.setTaskHandler(DestinationTaskHandler(
      Directions("AIzaSyDCx7UqFSWYeSjVzcXbgBKB5nnarnHZWoM"),
      AppLocationService())
  );
}


@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppOverlayWidget())
  );
}
