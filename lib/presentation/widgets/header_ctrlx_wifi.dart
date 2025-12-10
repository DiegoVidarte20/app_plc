// lib/presentation/widgets/header_ctrlx_wifi.dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'header_ctrlx.dart';

class CtrlXHeaderWifi extends StatefulWidget {
  final String title;
  final String subtitle;
  final String ctrlxIp; // 192.168.170.1

  const CtrlXHeaderWifi({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctrlxIp,
  });

  @override
  State<CtrlXHeaderWifi> createState() => _CtrlXHeaderWifiState();
}

class _CtrlXHeaderWifiState extends State<CtrlXHeaderWifi> {
  static const String _targetSsid = 'Spider5';

  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();

  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _pollTimer;

  String _status = 'DISCONNECTED';
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // 1) Permiso necesario en Android para leer SSID
    final perm = await Permission.locationWhenInUse.request();

    if (!perm.isGranted) {
      if (!mounted) return;
      setState(() {
        _status = 'DISCONNECTED';
        _connected = false;
      });
      return;
    }

    // 2) Cambios de red general (wifi/datos)
    _sub?.cancel();
    _sub = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _refreshFromConnectivity(results);
      },
    );

    // 3) Poll para detectar cambio wifi → wifi (Android no lo notifica)
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _refreshFull(),
    );

    // 4) Estado inicial
    await _refreshFull();
  }

  Future<void> _refreshFull() async {
    final results = await _connectivity.checkConnectivity();
    await _refreshFromConnectivity(results);
  }

  Future<void> _refreshFromConnectivity(
    List<ConnectivityResult> results,
  ) async {
    if (!mounted) return;

    // SIN WiFi
    if (!results.contains(ConnectivityResult.wifi)) {
      setState(() {
        _status = 'DISCONNECTED';
        _connected = false;
      });
      return;
    }

    // Estamos en WiFi → obtener SSID
    String? ssid = await _networkInfo.getWifiName();
    if (ssid != null) {
      ssid = ssid.replaceAll('"', '');
    }

    final bool ok = (ssid == _targetSsid);

    setState(() {
      _connected = ok;
      _status = ok ? 'CONNECTED' : 'DISCONNECTED';
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CtrlXHeader(
      title: widget.title,
      subtitle: widget.subtitle,
      status: _status,      // CONNECTED / DISCONNECTED
      ip: widget.ctrlxIp,   // 192.168.170.1
      connected: _connected,
    );
  }
}
