import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:network_info_plus/network_info_plus.dart';

import 'notification_service.dart';

class WifiScannerResult {
  final String? ssid;
  final String? localIp;
  final List<String> reachableIps;

  WifiScannerResult({this.ssid, this.localIp, required this.reachableIps});
}

class WifiScannerService {
  WifiScannerService._();
  static final instance = WifiScannerService._();

  final _info = NetworkInfo();

  Future<WifiScannerResult> scan() async {
    final ssid = await _info.getWifiName();
    final ip = await _info.getWifiIP();
    final subnet = _deriveSubnet(ip);
    final reachable = await _pingSweep(subnet);

    await NotificationService.instance.showNotification(
      id: 101,
      title: 'CyberAI Scan Complete',
      body: 'Reachable hosts: ${reachable.length}',
    );

    return WifiScannerResult(ssid: ssid, localIp: ip, reachableIps: reachable);
  }

  String _deriveSubnet(String? ip) {
    if (ip == null || !ip.contains('.')) return '192.168.1.';
    final parts = ip.split('.');
    return '${parts[0]}.${parts[1]}.${parts[2]}.';
  }

  Future<List<String>> _pingSweep(String subnet) async {
    final results = <String>[];
    final controller = StreamController<String>();
    final completer = Completer<List<String>>();

    controller.stream.listen((ip) {
      results.add(ip);
    }, onDone: () => completer.complete(results));

    final receivePort = ReceivePort();
    await Isolate.spawn<_SweepParams>(_sweepIsolate, _SweepParams(subnet, receivePort.sendPort));

    int done = 0;
    receivePort.listen((message) {
      if (message is String) {
        controller.add(message);
      } else if (message == 'done') {
        done++;
        if (done >= 1) {
          controller.close();
          receivePort.close();
        }
      }
    });

    return completer.future.timeout(const Duration(seconds: 25), onTimeout: () => results);
  }
}

class _SweepParams {
  final String subnet;
  final SendPort sendPort;
  _SweepParams(this.subnet, this.sendPort);
}

Future<void> _sweepIsolate(_SweepParams params) async {
  final send = params.sendPort;
  final futures = <Future<void>>[];

  for (int i = 1; i < 255; i++) {
    final ip = '${params.subnet}$i';
    futures.add(_ping(ip).then((ok) {
      if (ok) send.send(ip);
    }));
  }
  await Future.wait(futures);
  send.send('done');
}

Future<bool> _ping(String host) async {
  try {
    final result = await Process.run('ping', ['-c', '1', '-W', '1', host]);
    return result.exitCode == 0;
  } catch (_) {
    // Fallback: try connecting to port 80
    try {
      final socket = await Socket.connect(host, 80, timeout: const Duration(milliseconds: 700));
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}