part of start;

class Socket implements SocketBase {
  final WebSocket _ws;
  final _messageController = StreamController(),
      _openController = StreamController(),
      _closeController = StreamController();

  Stream _messages;

  Socket(this._ws) {
    _messages = _messageController.stream.asBroadcastStream();

    _openController.add(_ws);
    _ws.listen((data) {
      var msg = Message.fromPacket(data);
      _messageController.add(msg);
    }, onDone: () {
      _closeController.add(_ws);
    });
  }

  void send(String messageName, [data]) {
    var message = Message(messageName, data);
    _ws.add(message.toPacket());
  }

  Stream on(String messageName) {
    return _messages
        .where((msg) => msg.name == messageName)
        .map((msg) => msg.data);
  }

  Stream get onOpen => _openController.stream;

  Stream get onClose => _closeController.stream;

  void close([int status, String reason]) {
    _ws.close(status, reason);
  }
}
