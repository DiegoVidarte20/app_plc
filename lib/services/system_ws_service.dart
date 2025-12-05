// lib/services/system_ws_service.dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SystemMetrics {
  final List<double> cores;   // 4 cores
  final double totalRam;      // bytes
  final double usedRam;       // bytes

  SystemMetrics({
    required this.cores,
    required this.totalRam,
    required this.usedRam,
  });

  factory SystemMetrics.fromJson(Map<String, dynamic> json) {
    final cpu = json['cpu']['cpu'];
    final mem = json['memory'];

    return SystemMetrics(
      cores: [
        (cpu['core0']['utilization'] as num).toDouble(),
        (cpu['core1']['utilization'] as num).toDouble(),
        (cpu['core2']['utilization'] as num).toDouble(),
        (cpu['core3']['utilization'] as num).toDouble(),
      ],
      totalRam: (mem['total'] as num).toDouble(),
      usedRam: (mem['used'] as num).toDouble(),
    );
  }
}

class SystemWSService {
  final String url;
  late final WebSocketChannel _channel;

  SystemWSService(this.url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  Stream<SystemMetrics> get stream =>
      _channel.stream.map<SystemMetrics>((event) {
        final data = jsonDecode(event as String);
        return SystemMetrics.fromJson(data as Map<String, dynamic>);
      });

  void dispose() {
    _channel.sink.close();
  }
}
