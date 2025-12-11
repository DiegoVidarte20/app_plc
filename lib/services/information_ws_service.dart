// lib/services/information_ws_service.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CtrlXInformation {
  final String hostname;
  final String operatingSystem;
  final String storeSerialId;
  final String typeCode;

  CtrlXInformation({
    required this.hostname,
    required this.operatingSystem,
    required this.storeSerialId,
    required this.typeCode,
  });

  factory CtrlXInformation.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>?;
    final typeplate = json['typeplate'] as Map<String, dynamic>?;

    return CtrlXInformation(
      hostname: info?['hostname']?.toString() ?? '-',
      operatingSystem: info?['operatingSystem']?.toString() ?? '-',
      storeSerialId: typeplate?['storeSerialId']?.toString() ?? '-',
      typeCode: typeplate?['typeCode']?.toString() ?? '-',
    );
  }
}

class InformationWSService {
  final String url;
  late final WebSocketChannel _channel;

  InformationWSService(this.url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  Stream<CtrlXInformation> get stream =>
      _channel.stream.map<CtrlXInformation?>((event) {
        debugPrint('[INFO WS RAW] type=${event.runtimeType} value=$event');

        dynamic data;
        try {
          data = event is String ? jsonDecode(event) : event;
        } catch (e) {
          debugPrint('[INFO WS] JSON decode error: $e');
          return null;
        }

        if (data is! Map<String, dynamic>) {
          debugPrint('[INFO WS] payload no es Map, lo ignoro');
          return null;
        }

        return CtrlXInformation.fromJson(data);
      }).where((e) => e != null).cast<CtrlXInformation>();

  void dispose() {
    _channel.sink.close();
  }
}
