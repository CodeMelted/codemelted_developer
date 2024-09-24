/*
===============================================================================
MIT License

© 2024 Mark Shaffer. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
===============================================================================
*/

// TODO: WebSocket, WebRTC

/// Provides the collection of all network related items from the Browser APIs
/// minus webrtc. Any communication you need to make with a backend server
/// are handled via this library.
library codemelted_network;

import "dart:io";
import 'dart:js_interop';

import "package:codemelted_flutter/src/prototype/codemelted_json.dart";
import "package:codemelted_flutter/src/prototype/codemelted_logger.dart";
import "package:web/web.dart" as web;

/// Message handler that receives a JSON object with two fields. "type" which
/// equals either "error" or "data". Then "data" which contains the actual data
/// received.
typedef COnMessageListener = Future<void> Function(CObject);

/// Wrapper object for the Broadcast Channel API. Constructed via the
/// [CodeMeltedNetwork] API and provides the flutter bindings for working with
/// the channel.
///
/// see https://developer.mozilla.org/en-US/docs/Web/API/Broadcast_Channel_API
class CBroadcastChannel {
  /// Holds the constructed broadcast channel for this object.
  late web.BroadcastChannel _channel;

  /// Closes the channel.
  Future<void> close() async {
    _channel.close();
  }

  /// Posts a message for other channels to receive and process.
  Future<void> postMessage([dynamic data]) async {
    _channel.postMessage(data);
  }

  /// Constructor for the object.
  CBroadcastChannel._(String name, COnMessageListener onMessage) {
    _channel = web.BroadcastChannel(name);
    _channel.onmessage = (e) {
      onMessage({
        "type": "data",
        "data": (e as web.MessageEvent).data,
      });
    }.toJS;
    _channel.onmessageerror = (e) {
      onMessage({
        "type": "error",
        "data": (e as web.MessageEvent).data,
      });
    }.toJS;
  }
}

/// The EventSource interface is web content's interface to server-sent events.
/// An EventSource instance opens a persistent connection to an HTTP server,
/// which sends events in text/event-stream format. The connection remains
/// open until closed.
///
/// See https://developer.mozilla.org/en-US/docs/Web/API/EventSource
class CEventSource {
  /// Holds the server sent event object constructed.
  late web.EventSource _eventSource;

  /// Closes the server sent event object.
  Future<void> close() async {
    _eventSource.close();
  }

  /// Constructor for the object.
  CEventSource._(
      String url, bool withCredentials, COnMessageListener onMessage) {
    _eventSource = web.EventSource(
        url, web.EventSourceInit(withCredentials: withCredentials));
    _eventSource.onmessage = (e) {
      onMessage({
        "type": "message",
        "data": (e as web.MessageEvent).data,
      });
    }.toJS;

    _eventSource.onerror = (e) {
      onMessage({
        "type": "error",
        "data": e.toString(),
      });
    }.toJS;
  }
}

/// The actions supported by the module fetch call.
enum CFetchAction {
  /// The HTTP DELETE request method deletes the specified resource.
  delete,

  /// The HTTP GET method requests a representation of the specified resource.
  get,

  /// The HTTP POST method sends data to the server.
  post,

  /// The HTTP PUT request method creates a new resource or replaces a
  /// representation of the target resource with the request payload.
  put;
}

/// The response object that results from the module [CodeMeltedNetwork.fetch]
/// call.
///
/// See https://developer.mozilla.org/en-US/docs/Web/API/Response of the
/// data types that can be translated from the call.
class CFetchResponse {
  /// The data received.
  final dynamic data;

  /// The status code of the call
  final int status;

  /// Any text associated with the status.
  final String statusText;

  /// https://developer.mozilla.org/en-US/docs/Web/API/Blob
  web.Blob? get asBlob => data as web.Blob?;

  /// https://developer.mozilla.org/en-US/docs/Web/API/FormData
  web.FormData? get asFormData => data as web.FormData?;

  /// The data object is represented as a JSON object.
  CObject? get asObject => data as CObject?;

  /// The data object is simply a string object.
  String? get asString => (data as JSString?)?.toDart;

  /// Constructs the [CFetchResponse] object.
  CFetchResponse(this.data, this.status, this.statusText);
}

/// Event listener for messages received from different loaded pages.
typedef COnWindowMessengerListener = Future<void> Function(String, dynamic);

/// Wrapper object for receiving and posting messages between pages.
///
/// See https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage
class CWindowMessenger {
  /// Tracks to ensure only 1 [CWindowMessenger] exists to ensure proper
  /// cleanup of the callbacks.
  static int _count = 0;

  /// Removes the callback from the window object.
  Future<void> close() async {
    _count = 0;
    web.window.onmessage = null;
  }

  /// Posts a message to another page.
  Future<void> postMessage({
    String? targetOrigin,
    required dynamic data,
  }) async {
    if (targetOrigin != null) {
      web.window.postMessage(data.jsify(), targetOrigin.toJS);
    } else {
      web.window.postMessage(data.jsify());
    }
  }

  /// Constructor for the object.
  CWindowMessenger._(COnWindowMessengerListener onMessage) {
    assert(_count < 2, "Only one CWindowMessenger can exist");
    _count += 1;
    web.window.onmessage = (e) {
      var msg = e as web.MessageEvent;
      onMessage(msg.origin, msg.data);
    }.toJS;
  }
}

class CodeMeltedNetwork {
  /// Sends an HTTP POST request containing a small amount of data to a web
  /// server. It's intended to be used for sending analytics data to a web
  /// server, and avoids some of the problems with legacy techniques for
  /// sending analytics, such as the use of XMLHttpRequest.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/API/Beacon_API
  bool beacon({required String url, CObject? data}) {
    return web.window.navigator.sendBeacon(url, data?.jsify());
  }

  /// Constructs a [CBroadcastChannel] object for posting messages between
  /// pages within the same domain.
  CBroadcastChannel broadcastChannel({
    required String name,
    required COnMessageListener onMessage,
  }) {
    return CBroadcastChannel._(name, onMessage);
  }

  /// Implements the ability to fetch a server's REST API endpoint to retrieve
  /// and manage data. The actions for the REST API are controlled via the
  /// [CFetchAction] enumerated values with optional items to pass to the
  /// endpoint. The result is a [CFetchResponse] wrapping the REST API endpoint
  /// response to the request.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/API/RequestInit for
  /// details of all the options.
  Future<CFetchResponse> fetch({
    required CFetchAction action,
    required String url,
    bool? adAuctionHeaders,
    CObject? body,
    String? cache,
    String? credentials,
    CObject? headers,
    String? integrity,
    bool? keepalive,
    String? mode,
    String? priority,
    String? redirect,
    String? referrer,
    String? referrerPolicy,
    web.AbortSignal? signal,
  }) async {
    try {
      // Form the request for the fetch call.
      var request = web.RequestInit();
      request.method = action.name.toUpperCase();
      if (adAuctionHeaders != null) {
        request.adAuctionHeaders = adAuctionHeaders;
      }
      if (body != null) {
        request.body = body.jsify();
      }
      if (cache != null) {
        request.cache = cache;
      }
      if (credentials != null) {
        request.credentials = credentials;
      }
      if (headers != null) {
        request.headers = headers.jsify() as JSObject;
      }
      if (integrity != null) {
        request.integrity = integrity;
      }
      if (keepalive != null) {
        request.keepalive = keepalive;
      }
      if (mode != null) {
        request.mode = mode;
      }
      if (priority != null) {
        request.priority = priority;
      }
      if (redirect != null) {
        request.redirect = redirect;
      }
      if (referrer != null) {
        request.referrer = referrer;
      }
      if (referrerPolicy != null) {
        request.referrerPolicy = referrerPolicy;
      }
      if (signal != null) {
        request.signal = signal;
      }

      // Go perform the fetch
      var resp = await web.window.fetch(url.toJS, request).toDart;
      var contentType = resp.headers.get(HttpHeaders.contentTypeHeader) ?? '';
      var status = resp.status;
      var statusText = resp.statusText;
      var data = contentType.containsIgnoreCase("application/json")
          ? await resp.json().toDart
          : contentType.containsIgnoreCase("form-data")
              ? await resp.formData().toDart
              : contentType.containsIgnoreCase("application/octet-stream")
                  ? await resp.blob().toDart
                  : contentType.containsIgnoreCase("text/")
                      ? await resp.text().toDart
                      : "";
      return CFetchResponse(data, status, statusText);
    } catch (ex, st) {
      codemelted_logger.error(data: ex.toString(), stackTrace: st);
      return CFetchResponse(null, 500, ex.toString());
    }
  }

  /// Identifies if a clear connection exists to the Internet from the browser.
  bool get online => web.window.navigator.onLine;

  /// Constructs a [CEventSource] object to open a dedicated connection to a
  /// HTTP server to receive messages only.
  CEventSource severSentEvents({
    required String url,
    required COnMessageListener onMessage,
    bool withCredentials = false,
  }) {
    return CEventSource._(url, withCredentials, onMessage);
  }

  /// Constructs a [CWindowMessenger] object to allow for communication between
  /// pages.
  CWindowMessenger windowMessenger({
    required COnWindowMessengerListener onMessage,
  }) {
    return CWindowMessenger._(onMessage);
  }

  /// Gets the single instance of the API.
  static CodeMeltedNetwork? _instance;

  /// Sets up the internal instance for this object.
  factory CodeMeltedNetwork() => _instance ?? CodeMeltedNetwork._();

  /// Sets up the namespace for the [CodeMeltedNetwork] object.
  CodeMeltedNetwork._() {
    _instance = this;
  }
}

/// Sets up the namespace for the [CodeMeltedNetwork] object.
final codemelted_data_broker = CodeMeltedNetwork();
