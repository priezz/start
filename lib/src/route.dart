part of start;

class Route {
  final String _method;
  final Map _path;
  final StreamController<Request> _requestController = StreamController();
  final StreamController<HttpRequest> _socketController = StreamController();
  Stream<Request> requestStream;
  Stream<Socket> socketStream;

  Route(String method, path, {List<String> keys})
      : _method = method.toUpperCase(),
        _path = _normalize(path, keys: keys) {
    requestStream = _requestController.stream;
  }

  Route.ws(dynamic path, {List<String> keys})
      : _method = 'WS',
        _path = _normalize(path, keys: keys) {
    socketStream = _socketController.stream
        .transform(WebSocketTransformer())
        .map((WebSocket ws) => Socket(ws));
  }

  bool match(HttpRequest req) =>
      // (_method == req.method || _method == 'WS') &&
      _path['regexp'].hasMatch(req.uri.path);

  void handle(HttpRequest req) {
    if (_method == 'WS') {
      _socketController.add(req);
    } else {
      var request = Request(req);
      request.params = _parseParams(req.uri.path, _path);
      request.response = Response(req.response);
      _requestController.add(request);
    }
  }

  static Map _normalize(dynamic path, {List<String> keys, bool strict: false}) {
    if (keys == null) {
      keys = [];
    }

    if (path is RegExp) {
      return {'regexp': path, 'keys': keys};
    }
    if (path is List) {
      path = '(${path.join('|')})';
    }

    if (!strict) {
      path += '/?';
    }

    path =
        path.replaceAllMapped(RegExp(r'(\.)?:(\w+)(\?)?'), (Match placeholder) {
      var replace = StringBuffer('(?:');

      if (placeholder[1] != null) {
        replace.write('\.');
      }

      replace.write('([\\w%+-._~!\$&\'()*,;=:@]+))');

      if (placeholder[3] != null) {
        replace.write('?');
      }

      keys.add(placeholder[2]);

      return replace.toString();
    }).replaceAll('//', '/');

    return {'regexp': RegExp('^$path\$'), 'keys': keys};
  }

  Map<String, String> _parseParams(String path, Map routePath) {
    Map<String, String> params = Map<String, String>();
    Match paramsMatch = routePath['regexp'].firstMatch(path);
    for (var i = 0; i < routePath['keys'].length; i++) {
      String param;
      try {
        param = Uri.decodeQueryComponent(paramsMatch[i + 1]);
      } catch (e) {
        param = paramsMatch[i + 1];
      }

      params[routePath['keys'][i]] = param;
    }
    return params;
  }
}
