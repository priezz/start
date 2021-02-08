# Changelog

## 0.8.0

Upgrade dependencies, temporarily move http_server code into src.

## 0.7.0

Try to parse POST payload as JSON even when content type is text.

## 0.6.0

Process POST handlers for GET requests. Fix a few minor bugs.

## 0.5.0

Remove dependency on mirrors and logging.

## 0.4.0

Fix Websockets.

## 0.3.0

Fix support for dart@2.

## 0.0.8

Breaking changes. Removed `hart` dependency, `start` now uses proper `Cookie` library,
serves `index.html` by default.

## 0.0.7

This update is dependent on a breaking change in the latest version of the Dart
stdlib. Please make sure you update to the latest version of Dart before
installing.

* Change HttpRequest.queryParameters to HttpRequest.uri.queryParameters.
