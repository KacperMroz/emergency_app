import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:emergency_app/services/background_service/background_service_repository.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  ReceivePort port = ReceivePort();
  bool isRunning = false;
  late LocationDto lastLocation;
  BackgroundServiceRepository locationServiceRepository = BackgroundServiceRepository();

  @override
  void initState() {
    super.initState();
    printPeriodic();
    _determinePosition();

    if (IsolateNameServer.lookupPortByName(
        BackgroundServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          BackgroundServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, BackgroundServiceRepository.isolateName);

    initPlatformState();
    locationServiceRepository.onStart();
    _runServiceWhenFailed();
  }

  void printPeriodic(){
    Timer.periodic(const Duration(seconds: 60), (timer) async {
      print('Periodic timer ${timer.tick}');
    });
  }

  Future<void> initPlatformState() async {
    debugPrint('Initializing...');
    await BackgroundLocator.initialize();
    debugPrint('Initialization done');
    final _isRunning = await BackgroundLocator.isServiceRunning();
    setState(() {
      isRunning = _isRunning;
    });
    debugPrint('Running ${isRunning.toString()}');
  }


  void _runServiceWhenFailed() async {
    final _isRunning = await BackgroundLocator.isServiceRunning();
    setState(() {
      isRunning = _isRunning;
    });
    if(isRunning == false){
      locationServiceRepository.runServiceWhenFailed();
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    /// Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Splash Page'),
      )
    );
  }
}
