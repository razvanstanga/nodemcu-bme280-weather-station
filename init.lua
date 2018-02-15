-- init.lua --

-- 10 seconds boot delay
print("10 seconds boot delay. use tmr.stop(0) to stop booting")
tmr.alarm(0, 10000, 1, function()
    dofile("config.lua")
    dofile("func.lua")
    init()
    tmr.stop(0)
end)

function init()
    -- configure wifi reset button
    gpio.trig(3, "down", pin3cb)

    -- initialize display
    init_spi_display()

    disp:begin(ucg.FONT_MODE_TRANSPARENT)
    disp:clearScreen()
    disp:setRotate90()

    disp:setFont(ucg.font_helvB18_hr)
    disp:setColor(255, 255, 255)
    disp:setPrintPos((disp:getWidth() - disp:getStrWidth(deviceTitle)) / 2, 25)
    disp:print(deviceTitle)

    printText("Temperature", 18, 5, 90)
    printText("Humidity", 18, 5, 120)
    printText("Pressure", 18, 5, 150)
    printText("50", 10, 292, 47)
    printText("-20", 10, 290, 206)

    --disp:drawFrame(20, 93, 42, 102)

    -- initialize BME280
    i2c.setup(0, sda, scl, i2c.SLOW) -- call i2c.setup() only once
    bme280.setup()

    if wifiEnabled then
        local def_sta_config=wifi.sta.getdefaultconfig(true)
        if def_sta_config.ssid ~= "" then
            lcdPrint(string.format("Found wifi config data in flash\n\tssid:\"%s\"\tpassword:\"%s\"%s", def_sta_config.ssid, def_sta_config.pwd, (type(def_sta_config.bssid)=="string" and "\tbssid:\""..def_sta_config.bssid.."\"" or "")))
            wifi.sta.config(def_sta_config)
            if network.ip ~= "" then
                --wifi.sta.setip(network)
            end
        else
            lcdPrint("No wifi config found on flash. Turning on IoT Setup")
        end

        -- configure wifi via enduser setup
        --wifi.setmode(wifi.STATIONAP)
        --wifi.ap.config({ssid="IoTSetup_" .. wifi.sta.getmac(), auth=wifi.OPEN})
        --enduser_setup.manual(true)
        enduser_setup.start(
            function()
                do
                    if network.ip ~= "" then
                        --wifi.sta.setip(network)
                    end
                    tmr.stop(0)
                    tmr.alarm(1, 3000, 1, function()
                        if wifi.sta.getip()==nil then
                            lcdPrint("\tConnected to access point, obtaining IP address ...")
                        else
                            def_sta_config=wifi.sta.getdefaultconfig(true)
                            lcdPrint(string.format("\tConnected to access point ssid:\"%s\"\tpassword:\"%s\"%s", def_sta_config.ssid, def_sta_config.pwd, (type(def_sta_config.bssid)=="string" and "\tbssid:\""..def_sta_config.bssid.."\"" or "")))
                            lcdPrint('\tip: ', wifi.sta.getip())
                            --enduser_setup.stop()
                            -- run the main file
                            if file.exists("mqtt.lc") then
                                dofile("mqtt.lc")
                            else
                                dofile("mqtt.lua")
                            end
                            tmr.stop(1)
                        end
                    end)
                end
            end,
            function(err, str)
                lcdPrint("enduser_setup: Err #" .. err .. ": " .. str)
            end
        )

        tmr.alarm(0, 3000, 1, function()
            if wifi.sta.getip()==nil then
                def_sta_config=wifi.sta.getdefaultconfig(true)
                lcdPrint("Connecting to access point " .. def_sta_config.ssid)
            else
                tmr.stop(0)
            end
        end)
    end

    -- run update at start
    update()

    cron.reset()
    cron.schedule("* * * * *", function(e)
        print("----------------Every minute----------------")
        update()
    end)

    -- restart every hour
    cron.schedule("1 * * * *", function(e)
        --node.restart()
    end)
end
