import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/enum.dart';
import 'package:socket_io_client/socket_io_client.dart' as ws;
import 'package:billd_live_flutter/utils/index.dart';

class WsClass {
  late ws.Socket socket;

  WsClass() {
    socket = ws.io(
        websocketUrl, ws.OptionBuilder().setTransports(['websocket']).build());
  }
  init() {
    billdPrint('===init===$websocketUrl');
    socket.onConnect((data) {
      billdPrint('===onConnect===,$data,${socket.id}');
    });
    socket.on(wsMsgTypeEnum['message']!, (data) {
      billdPrint('===message===,$data');
      billdPrint(data);
    });
    socket.onDisconnect((data) {
      billdPrint('===onDisconnect===');
      billdPrint(data);
    });
    socket.on('fromServer', (data) {
      billdPrint('===fromServer===', data);
    });
  }

  close() {
    billdPrint('===close===');
    socket.close();
  }

  send(String msgType, String requestId, dynamic data) {
    billdPrint('===send===');
    // request_id: requestId,
    // socket_id: this.socketIo.id,
    // is_anchor: this.isAnchor,
    // user_info: userStore.userInfo,
    // user_token: userStore.token || undefined,
    // data: data || {},
    var sendData = {
      'request_id': requestId,
      'socket_id': socket.id,
      'is_anchor': false,
      'data': data
    };
    socket.emit(msgType, sendData);
  }
}
