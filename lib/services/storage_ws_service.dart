// lib/services/storage_ws_service.dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class StorageVolume {
  final String uuid;
  final String label;
  final bool mounted;
  final String format;
  final double sizeBytes;
  final double usedBytes;
  final String device;
  final bool internal;
  final String? parent;

  StorageVolume({
    required this.uuid,
    required this.label,
    required this.mounted,
    required this.format,
    required this.sizeBytes,
    required this.usedBytes,
    required this.device,
    required this.internal,
    required this.parent,
  });

  double get usedRatio =>
      sizeBytes <= 0 ? 0.0 : (usedBytes / sizeBytes).clamp(0.0, 1.0);

  factory StorageVolume.fromJson(Map<String, dynamic> json) {
    return StorageVolume(
      uuid: (json['uuid'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      mounted: json['mounted'] == true,
      format: (json['format'] ?? '').toString(),
      sizeBytes: (json['size'] as num?)?.toDouble() ?? 0.0,
      usedBytes: (json['used'] as num?)?.toDouble() ?? 0.0,
      device: (json['device'] ?? '').toString(),
      internal: json['internal'] == true,
      parent: json['parent']?.toString(),
    );
  }
}

class StorageWSService {
  final String url;
  late final WebSocketChannel _channel;

  StorageWSService(this.url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  Stream<List<StorageVolume>> get stream =>
      _channel.stream.map<List<StorageVolume>>((event) {
        final data = event is String ? jsonDecode(event) : event;

        // Caso típico: lista directa de volúmenes
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(StorageVolume.fromJson)
              .toList();
        }

        // Por si algún día viene envuelto en {"volumes":[...]}
        if (data is Map<String, dynamic>) {
          final vols = data['volumes'];
          if (vols is List) {
            return vols
                .whereType<Map<String, dynamic>>()
                .map(StorageVolume.fromJson)
                .toList();
          }
        }

        return const <StorageVolume>[];
      });

  void dispose() {
    _channel.sink.close();
  }
}
