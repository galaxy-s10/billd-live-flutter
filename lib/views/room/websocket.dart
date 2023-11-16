import 'package:billd_live_flutter/enum.dart';
import 'package:socket_io_client/socket_io_client.dart' as ws;

class WsClass {
  late ws.Socket socket;

  WsClass() {
    socket = ws.io('wss://srs-pull.hsslive.cn',
        ws.OptionBuilder().setTransports(['websocket']).build());
  }
  init() {
    print('====init===');
    socket.onConnect((data) {
      print('===onConnect===,$data,${socket.id}');
      socket.emit('message', {
        'socket_id': 'dfdffd',
        'is_anchor': true,
        'user_info': null,
        'data': {},
      });
    });
    socket.on(WsMsgTypeEnum['message']!, (data) {
      print('===message===,$data');
      print(data);
    });
    socket.onDisconnect((_) {
      print('===onDisconnect===');
      print(_);
    });
    socket.on('fromServer', (_) {
      print('===fromServer===');
      print(_);
    });
  }
}
