# esp8266-websocket-server
A somewhat limited use Lua websocket server for use on ESP8266 with a small memory footprint.

This webserver supports parameterless GET request and websockets. The intention is that webpages set up websockets for all communication.
In order to reduce the memory footprint, this webserver has been made very simple. As a result, error codes returned are very limited.
NOTE: The webserver currently does not explicitly use file handles. You should be careful if you use file IO in the websocket command scripts.


## Example Usage
### Server Initialization
```lua
function websocketOnRxCallback(conn, message)
	print("Received", message)
end

function websocketOnConnectCallback(conn)
	print("Connect")
end

function websocketOnCloseCallback(conn)
	print("Close")
end

local websocketCallbacks = {onConnect=websocketOnConnectCallback, onReceive=websocketOnRxCallback, onClose=websocketOnCloseCallback}
loadfile("WebsocketServer.lua")(websocketCallbacks)
```

## Server Customization
This webserver supports four parameters which, if not defined or defined to nil, will take default values.
1) websocketCallbacks: Callbacks table. onConnect, onReceive, and onClose are the relavent keys. See the example above for usage. Each can be nil.
2) connTimeout: Number of seconds without any communication before the server drops the connection. Defaults to 5.
3) restrictedFiles: A list of files which cannot be retrieved by a GET request. Note that .lua and .lc may not be retrieved by a GET request. Defaults to no restrictions.
4) fileTXBufferSize: The max number of bytes sent at a time as a response to a GET request. Default 1024.
5) contentTypeLookup: A table indicating the content type for each type of file that can be loaded by a GET request. Default {css="text/css", ico = "image/x-icon", html = "text/html; charset=utf-8", js = "application/javascript"}

