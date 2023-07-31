import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'background_callback_handler.dart';

@singleton
class BackgroundServiceRepository {
  static BackgroundServiceRepository _instance = BackgroundServiceRepository._();

  BackgroundServiceRepository._();

  factory BackgroundServiceRepository() {
    return _instance;
  }

  static const String isolateName = 'LocatorIsolate';

  int _count = -1;
  bool isRunning = false;

  Future<void> init(Map<dynamic, dynamic> params) async {
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    debugPrint("$_count");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    debugPrint("***********Dispose callback handler");
    debugPrint("$_count");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    debugPrint(
        'Location: latitude: ${locationDto.latitude}, longitude: ${locationDto.longitude}');
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto);
    _count++;
  }

  void onStop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  void onStart() async {
    await _startLocator();
  }

  void runServiceWhenFailed(){
    Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (isRunning == false){
        _startLocator();
        _checkIfServiceIsRunning();
      } else{
        timer.cancel();
        _checkIfServiceIsRunning();
      }
    });
  }

  void _checkIfServiceIsRunning() async {
    isRunning = await BackgroundLocator.isServiceRunning();
  }

  Future<void> _startLocator() async {
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        BackgroundCallbackHandler.callback,
        initCallback: BackgroundCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: BackgroundCallbackHandler.disposeCallback,
        autoStop: false,
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 590,
            distanceFilter: 0,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Pobieranie lokalizacji',
                notificationMsg: ' ',
                notificationBigMsg:
                ' ',
                notificationIconColor: Colors.purpleAccent,
                notificationTapCallback:
                BackgroundCallbackHandler.notificationCallback)));
  }
}
