import 'package:flutter/material.dart';
import 'app_lifecyle_utility_callbacks.dart';

class AppOverlayWidget extends StatelessWidget {
  const AppOverlayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        AppLifeCycleUtilityCallbacks.bringToForeground(
            "/screenTwo");
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
            color: Colors.red, shape: BoxShape.circle),
        child: const FlutterLogo(),
      ),
    );
  }
}
