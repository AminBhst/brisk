import 'dart:convert';
import 'dart:io';

import 'package:window_manager/window_manager.dart';

class SingleInstanceIpcHandler {
  static const socketPath = '/tmp/brisk_ipc_socket';
  static final socketFile = File(socketPath);
  static ServerSocket? _serverSocket;

  static init() async {
    await tryClearSocket();
    await bindToSocket();
    handleProcessTerminationSignals();
    listenToActivateSignal();
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

  static tryClearSocket() async {
    if (await socketFile.exists()) {
      await socketFile.delete();
    }
  }

  static void handleProcessTerminationSignals() {
    ProcessSignal.sigint.watch().listen((_) async {
      await socketFile.delete();
      exit(0);
    });
    ProcessSignal.sigterm.watch().listen((_) async {
      await socketFile.delete();
      exit(0);
    });
  }

  static void listenToActivateSignal() {
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

  static bindToSocket() async {
    _serverSocket = await ServerSocket.bind(
      InternetAddress(socketPath, type: InternetAddressType.unix),
      0,
    );
  }
}
