if node.getpartitiontable().lfs_size > 0 then
   if file.exists("lfs.img") then
      if file.exists("lfs_lock") then
         file.remove("lfs_lock")
         file.remove("lfs.img")
      else
         local f = file.open("lfs_lock", "w")
     	 f:flush()
	     f:close()
       	 file.remove("httpserver-compile.lua")
	     node.flashreload("lfs.img")
      end
   end

   pcall(node.flashindex("_init"))
end

wifi.setmode(wifi.STATION)
wifi.sta.config({ssid="GALAVEYSON",pwd="2gretjochotnerghatwa"})
--[[
wifi.sta.connect()
tmr.alarm(0, 1000, 1, function ()
  local ip = wifi.sta.getip()
  if ip then
    tmr.stop(0)
    print(ip)
  end
end)
--]]

-- setup

-- gestion relais
relayPin = 1
gpio.mode(relayPin, gpio.OUTPUT)
DURATION=10000

-- led on the board
ledPin = 4
gpio.mode(ledPin, gpio.OUTPUT)
gpio.write(ledPin, gpio.HIGH)

-- AM 2320
SDA, SCL = 2, 6
i2c.setup(0, SDA, SCL, i2c.SLOW)
model, version, serial = am2320.setup()
print('am2320 : model ' .. model .. ' - version ' .. version .. ' - serial ' .. serial)
if not tmr.create():alarm(2000, tmr.ALARM_SINGLE, function()
	local rh, t = am2320.read()
	print(string.format('Temp : %s℃ - Humidité : %s%%', t/10, rh/10))
end) then
	print('Whoopsie')
end


function myjob()
	gpio.write(relayPin, gpio.HIGH)
	print('Relay on')
	if not tmr.create():alarm(DURATION, tmr.ALARM_SINGLE, function()
		gpio.write(relayPin, gpio.LOW)
		print('Relay off')
	end) then
		print('Whoopsie')
	end
end

function sendStatus(conn)
	local template = [[{"am2320":{"t":%f,"rh":%f},"time":%u,"relay":%o,"led":%o}]]

	local rh, t = am2320.read()
	local tm, _, _ = rtctime.get()
	print('rtctime : ' .. tm)
	SendWebsocketMessage(conn, string.format(
		template,
		t/10,
		rh/10,
		tm,
		gpio.read(relayPin),
		gpio.read(ledPin)
	))
end

function websocketOnRxCallback(conn, message)
	print("Received", message)

	if message == 'status' then
		sendStatus(conn)
		return
	end

	local value = string.match(message, '^setTime=(%d+)$')
	if value then
		rtctime.set(value, 0)
		sendStatus(conn)
		return
	end

	value = string.match(message, '^relay=(' .. gpio.LOW .. '|' .. gpio.HIGH .. ')$')
	if value then
		gpio.write(relayPin, value)
		sendStatus(conn)
	end

	-- default echo
	SendWebsocketMessage(conn, message)
end

function websocketOnConnectCallback(conn)
	print("Connect")
end

function websocketOnCloseCallback(conn)
	print("Close")
end

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
	print('Starting server at http://'..T['IP'])

	loadfile("WebsocketServer.lua")({
		onConnect=websocketOnConnectCallback,
		onReceive=websocketOnRxCallback,
		onClose=websocketOnCloseCallback
	})
end)
