import 'dart:async';

import 'package:background_locator/location_dto.dart';
import 'package:flutter/material.dart';

import 'background_service_repository.dart';

class BackgroundCallbackHandler {
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    BackgroundServiceRepository myLocationCallbackRepository =
    BackgroundServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  static Future<void> disposeCallback() async {
    BackgroundServiceRepository myLocationCallbackRepository =
    BackgroundServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  static Future<void> callback(LocationDto locationDto) async {
    BackgroundServiceRepository myLocationCallbackRepository =
    BackgroundServiceRepository();
    await myLocationCallbackRepository.callback(locationDto);
  }

  static Future<void> notificationCallback() async {
    debugPrint('***notificationCallback');
  }
}