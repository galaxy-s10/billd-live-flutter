import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/enum.dart';
import 'package:socket_io_client/socket_io_client.dart' as ws;
import 'package:billd_live_flutter/utils/index.dart';

class WsClass {
  late ws.Socket socket;

  WsClass() {
    socket = ws.io(
        websocketUrl,
        ws.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
  }
  init() {
    billdPrint('===init===', websocketUrl);
    socket.onConnect((data) {
      billdPrint('===onConnect===,${socket.id}', data);
    });
    socket.on(wsMsgTypeEnum['message']!, (data) {
      billdPrint('===message===', data);
    });
    socket.on(wsMsgTypeEnum['joined']!, (data) {
      billdPrint('===joined===', data);
    });
    socket.on(wsMsgTypeEnum['batchSendOffer']!, (data) {
      billdPrint('===batchSendOffer===', data);
    });
    socket.onDisconnect((data) {
      billdPrint('===onDisconnect===', data);
    });
  }

  close() {
    billdPrint('===close===');
    socket.disconnect();
  }

  send(String msgType, String requestId, dynamic data) {
    billdPrint(
      '===send===,$msgType',
      data,
    );
    var sendData = {
      'request_id': requestId,
      'socket_id': socket.id,
      'is_anchor': false,
      'user_info': null,
      'user_token': null,
      'data': data
    };
    socket.emit(msgType, sendData);
  }
}
