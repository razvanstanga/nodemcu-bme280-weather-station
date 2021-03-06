-- mqtt.lua --

-- initiate NTP sync
sntp.sync(ntpserver,
    function(sec, usec, server, info)
        rtctime.set(sec + timezoneHours * 60 * 60, 0)
        lcdPrint('NTP sync success! ' .. getDateTime())
        --update()
    end,
    function()
        lcdPrint('NTP sync failed!')
    end,
    1
)

-- initiate the mqtt client and set keepalive timer to 120sec
if mqttConfig.enabled == true then

    function onConnect()
        lcdPrint("\tConnected to " .. mqttConfig.host .. ":" .. mqttConfig.port .. " MQTT broker\n")
        mqttConfig.connected = true
        -- subscribe topic with qos = 1
        mqtt:subscribe({[prefix .. "/+/+/data"]=1, [prefix .. "/device"]=1}, function(conn)
        end)
    end

    mqtt = mqtt.Client(device, 120, mqttConfig.user, mqttConfig.pass, true)

    -- on connect
    mqtt:on("connect", function(conn)
        onConnect()
    end)
    -- on disconnect
    mqtt:on("offline", function(conn)
        lcdPrint("\tDisconected from MQTT broker, reconnecting\n")
        mqttConfig.connected = false
        connect()
    end)
    -- on receive message
    mqtt:on("message", function(conn, topic, message)
        lcdPrint("\tReceived topic : " .. topic .. " / message : " .. message)

        -- catch json errors
        local ok, json = pcall(sjson.decode, message)
        if ok then
        else
            lcdPrint("\tError parsing JSON : " .. message)
            return
        end

        if topic == prefix .. "/device" then
            lcdPrint('\tNew request from IoT Control Center: clientId="' .. json.clientId .. '"')
            if json.time then
                rtctime.set(json.time + timezoneHours * 60 * 60, 0)
                --update()
            end
            mqtt:publish(prefix .. device .. "/device", '{"pages" : [{"id" : 50, "name" : "Weather stations", "icon": "fa fa-thermometer-quarter", "order": "1000"}]}', 1, 0, function(conn)
            end)
            update()
        end
    end)

    function connect()
        lcdPrint("\tConnecting to " .. mqttConfig.host .. ":" .. mqttConfig.port .. " MQTT broker\n")
        mqtt:connect(mqttConfig.host, mqttConfig.port, mqttConfig.secure, function(conn)
                onConnect()
            end,
            function(conn, reason)
                print("\tCould not connect to MQTT server, reconnecting")
                print("\tReason ", reason)
                tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, connect())
        end)
    end
    connect()
end
