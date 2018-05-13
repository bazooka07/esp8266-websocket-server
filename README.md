# esp8266-websocket-server
A somewhat limited use Lua websocket server for use on ESP8266 with a small memory footprint.

This webserver supports basic GET request and websockets. The intention is that webpages set up websockets for all communication.

Websocket messages received are parsed by looking for a lua script as the first word and a space delimeted list of parameters after.
If spaces are needed within a parameter, it should be replaced with 0x1F.
NOTE THAT THIS PROCESS DOES NOT CURRENTLY DIFFERENTIATE FILES THAT SHOULD BE CALLED FROM INITIALIZATION/CONFIGURATION SCRIPTS.
The websocket command can either return nothing or a table. If it returns a table, it will be json encoded and sent back to the client.

In order to reduce the memory footprint, this webserver has been made very simple. As a result, error codes returned are very limited.

NOTE: The webserver currently does not explicitly use file handles. You should be careful if you use file IO in the websocket command scripts.

## Example Usage
### Server Initialization
loadfile("WebsocketGetServer.lua")()

### Example Websocket Command Script
TestCommand.lua:
param1, param2 = ...
print("param1", param1)
print("param2", param2)
return {params = param1 + param2}

### Websocket Message Example:
websocket.send("TestCommand.lua Param\1With\1fSpaces ParamWithoutSpaces")

## Server Customization
This webserver supports four parameters which, if not defined or defined to nil, will take default values.
1) connTimeout: Number of seconds without any communication before the server drops the connection. Defaults to 5.
2) restrictedFiles: A list of files which cannot be retrieved by a GET request. Note that .lua and .lc may not be retrieved by a GET request. Defaults to no restrictions.
3) fileTXBufferSize: The max number of bytes sent at a time as a response to a GET request. Default 1024.
4) contentTypeLookup: A table indicating the content type for each type of file that can be loaded by a GET request. Default {css="text/css", ico = "image/x-icon", html = "text/html; charset=utf-8", js = "application/javascript"}

