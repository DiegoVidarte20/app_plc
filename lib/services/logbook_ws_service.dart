// lib/services/logbook_ws_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LogEntry {
  final DateTime timestamp;
  final String level;   // "info", "warning", "error"
  final String title;   // mainTitle
  final String message; // dynamicDescription limpio
  final String code;    // mainDiagnosisCode

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.title,
    required this.message,
    required this.code,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    final tsRaw = json['timestamp']?.toString() ?? '';
    DateTime ts;

    if (tsRaw.isNotEmpty) {
      try {
        // viene con "Z" (UTC) -> lo pasamos a hora local
        ts = DateTime.parse(tsRaw).toLocal();
      } catch (_) {
        ts = DateTime.now();
      }
    } else {
      ts = DateTime.now();
    }

    return LogEntry(
      timestamp: ts,
      level: (json['logLevel'] ?? 'info').toString().toLowerCase(),
      title: (json['mainTitle'] ?? '').toString(),
      message: (json['dynamicDescription'] ?? '')
          .toString()
          .replaceAll('"', '')
          .trim(),
      code: (json['mainDiagnosisCode'] ?? '').toString(),
    );
  }
}


class LogbookWSService {
  final String url;
  late final WebSocketChannel _channel;

  LogbookWSService(this.url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  Stream<List<LogEntry>> get stream =>
      _channel.stream.map<List<LogEntry>>((event) {
        debugPrint('[LOGBOOK RAW] type=${event.runtimeType} value=$event');

        dynamic data;
        if (event is String) {
          data = jsonDecode(event);
        } else {
          data = event;
        }

        // ===== Caso A: frame tipo wrapper { "type": "logbook", "entries": [...] }
        if (data is Map<String, dynamic>) {
          final type = data['type'];

          if (type == 'logbook') {
            final entries = data['entries'];
            if (entries is List) {
              return entries
                  .whereType<Map<String, dynamic>>()
                  .map(LogEntry.fromJson)
                  .toList();
            }
            // no hay entries -> nada que mostrar
            return const <LogEntry>[];
          }

          // Si viene un único evento "sueltito" (sin wrapper) con mainTitle / mainDiagnosisCode
          if (data.containsKey('mainTitle') ||
              data.containsKey('mainDiagnosisCode')) {
            return [LogEntry.fromJson(data)];
          }

          // Frames de otro tipo (p.ej. { "type": "system", "metrics": {...} })
          debugPrint('[LOGBOOK] frame ignorado, type=$type');
          return const <LogEntry>[];
        }

        // ===== Caso B: lista directa [ {...}, {...} ]
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(LogEntry.fromJson)
              .toList();
        }

        debugPrint('[LOGBOOK] payload no reconocido, lo ignoro');
        return const <LogEntry>[];
      });

  void dispose() {
    _channel.sink.close();
  }
}
