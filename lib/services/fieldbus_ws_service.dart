// lib/services/fieldbus_ws_service.dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class FieldbusMasterStatus {
  final String masterState;        // "op"
  final String requestedState;     // "op"
  final String componentState;     // "OPERATING"
  final String topologyState;      // "valid"
  final int topologyChanges;       // 0
  final String port;               // "XF50"
  final String linkStatus;         // "disconnected"
  final String linkLayer;          // "EcmIpCoreAfXdp"
  final double cycleTimeMs;        // 2.0 ms (2000 µs)
  final int physicalErrorCount;    // 0
  final int telegramErrorCount;    // 0

  const FieldbusMasterStatus({
    required this.masterState,
    required this.requestedState,
    required this.componentState,
    required this.topologyState,
    required this.topologyChanges,
    required this.port,
    required this.linkStatus,
    required this.linkLayer,
    required this.cycleTimeMs,
    required this.physicalErrorCount,
    required this.telegramErrorCount,
  });

  factory FieldbusMasterStatus.fromJson(Map<String, dynamic> json) {
    final master = json['masterInfo'] ?? {};
    final state = master['masterState'] ?? {};
    final topology = master['topologyStatus'] ?? {};
    final component = master['componentState'] ?? {};

    final taskInfos = (master['taskInfos'] as List?) ?? [];
    int cycleUs = 0;
    if (taskInfos.isNotEmpty) {
      final task = taskInfos[0]['task'] ?? {};
      cycleUs = (task['cycletime'] ?? 0) as int;
    }

    final online = json['onlineInfo'] ?? {};

    return FieldbusMasterStatus(
      masterState: (state['currentState'] ?? '').toString(),
      requestedState: (state['requestedState'] ?? '').toString(),
      componentState: (component['state'] ?? '').toString(),
      topologyState: (topology['state'] ?? '').toString(),
      topologyChanges: (topology['numChanges'] ?? 0) as int,
      port: (online['port'] ?? '').toString(),
      linkStatus: (online['linkStatus'] ?? '').toString(),
      linkLayer: (online['linkLayer'] ?? '').toString(),
      cycleTimeMs: cycleUs / 1000.0,
      physicalErrorCount: (online['physicalErrorCnt'] ?? 0) as int,
      telegramErrorCount: (online['telegramErrorCnt'] ?? 0) as int,
    );
  }
}

class FieldbusWSService {
  final String url;
  late final WebSocketChannel _channel;

  FieldbusWSService(this.url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  Stream<FieldbusMasterStatus> get stream =>
      _channel.stream.map<FieldbusMasterStatus>((event) {
        final data = jsonDecode(event as String);
        return FieldbusMasterStatus.fromJson(data as Map<String, dynamic>);
      });

  void dispose() {
    _channel.sink.close();
  }
}
