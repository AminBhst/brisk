import 'dart:convert';
import 'dart:io';

import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

class SingleInstanceHandler {
  static const socketPath = '/tmp/brisk_ipc_socket';
  static final socketFile = File(socketPath);
  static ServerSocket? _serverSocket;

  static init() async {
    if (Platform.isWindows) {
      await WindowsSingleInstance.ensureSingleInstance(
        [],
        "brisk_single_instance",
      );
      return;
    }
    await _initUnix();
  }

  static _initUnix() async {
    _tryClearSocket();
    await _bindToSocket();
    _handleProcessTerminationSignals();
    _listenToActivateSignal();
  }

  /// Connect to unix socket. If it fails, it means that it's no instance has been created
  /// and is listening. Therefore, this is the first instance of the app that's running.
  /// If doesn't fail, it means that this is not the first instance and an activate signal is sent to
  /// the first instance.
  static tryConnectSocket() async {
    try {
      final socket = await Socket.connect(
        InternetAddress(socketPath, type: InternetAddressType.unix),
        0,
      );
      socket.write('activate\n');
      await socket.flush();
      await socket.close();
      exit(0);
    } catch (_) {}
  }

  static void _tryClearSocket() {
    if (socketFile.existsSync()) {
      socketFile.deleteSync();
    }
  }

  static void _handleProcessTerminationSignals() {
    ProcessSignal.sigint.watch().listen((_) async {
      await socketFile.delete();
      exit(0);
    });
    ProcessSignal.sigterm.watch().listen((_) async {
      await socketFile.delete();
      exit(0);
    });
  }

  static void _listenToActivateSignal() {
    _serverSocket?.listen((client) {
      client.listen((data) async {
        final message = utf8.decode(data);
        if (message.trim() == 'activate') {
          await windowManager.show();
          await windowManager.focus();
        }
      });
    });
  }

  static _bindToSocket() async {
    _serverSocket = await ServerSocket.bind(
      InternetAddress(socketPath, type: InternetAddressType.unix),
      0,
    );
  }
}
