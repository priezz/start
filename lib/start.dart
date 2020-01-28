library start;

import 'dart:io' hide Socket;
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart';
import 'package:mime/mime.dart';

import 'src/socket_base.dart';

part 'src/request.dart';
part 'src/response.dart';
part 'src/route.dart';
part 'src/server.dart';
part 'src/socket.dart';

Future<Server> start(
    {String host: '127.0.0.1',
    int port: 8080,
    String certificateChain,
    String privateKey,
    String password}) {
  return Server().listen(host, port,
      certificateChain: certificateChain,
      privateKey: privateKey,
      password: password);
}
