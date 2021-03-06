part of start;

typedef void HttpHandler(Request req, Response r);
typedef void WsHandler(Socket s);

class Server {
  final List<Route> _routes = [];
  HttpServer _server;
  VirtualDirectory _staticServer;

  Server();

  void stop() {
    _server.close();
  }

  Future<Server> listen(String host, num port,
      {String certificateChain, String privateKey, String password}) {
    handle(HttpServer server) {
      _server = server;
      server.listen((HttpRequest req) {
        var route = _routes.firstWhere((Route route) => route.match(req),
            orElse: () => null);
        if (route != null) {
          route.handle(req);
        } else if (_staticServer != null) {
          _staticServer.serveRequest(req);
        } else {
          _send404(req);
        }
      });

      return this;
    }

    if (privateKey != null) {
      var context = SecurityContext();
      if (certificateChain != null) {
        var chain = File(certificateChain);
        context.useCertificateChain(chain.path);
      }
      var key = File(privateKey);
      context.usePrivateKey(key.path, password: password);
      return HttpServer.bindSecure(host, port, context).then(handle);
    }
    return HttpServer.bind(host, port).then(handle);
  }

  void static(path, {listing: true, links: true, jail: true}) {
    _staticServer = VirtualDirectory(path)
      ..allowDirectoryListing = listing
      ..followLinks = links
      ..jailRoot = jail
      ..errorPageHandler = _send404;

    _staticServer.directoryHandler = (Directory dir, HttpRequest req) {
      var filePath = '${dir.path}${Platform.pathSeparator}index.html';
      var file = File(filePath);
      _staticServer.serveFile(file, req);
    };
  }

  Stream<Socket> ws(path, {List<String> keys}) {
    var route = Route.ws(path, keys: keys);
    _routes.add(route);

    return route.socketStream;
  }

  Stream<Request> get(path, {List<String> keys}) {
    Route route = Route('get', path, keys: keys);
    _routes.add(route);

    return route.requestStream;
  }

  Stream<Request> options(path, {List<String> keys}) {
    var route = Route('options', path, keys: keys);
    _routes.add(route);

    return route.requestStream;
  }

  Stream<Request> post(path, {List<String> keys}) {
    var route = Route('post', path, keys: keys);
    _routes.add(route);

    return route.requestStream;
  }

  Stream<Request> put(path, {List<String> keys}) {
    var route = Route('put', path, keys: keys);
    _routes.add(route);

    return route.requestStream;
  }

  Stream delete(path, {List<String> keys}) {
    var route = Route('delete', path, keys: keys);
    _routes.add(route);

    return route.requestStream;
  }

  void _send404(HttpRequest req) {
    req.response
      ..statusCode = HttpStatus.notFound
      ..close();
  }
}
