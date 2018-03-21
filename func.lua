-- func.lua --

-- setup SPI and connect display
function init_spi_display()
   -- Hardware SPI CLK  = D5 / GPIO14
   -- Hardware SPI MOSI = D7 / GPIO13
   -- Hardware SPI MISO = D6 / GPIO12 (not used)
   -- Hardware SPI /CS  = D8 / GPIO15 (not used)
   -- CS, D/C, and RES can be assigned freely to available GPIOs
   local cs  = 8 -- D8 / GPIO15, pull-down 10k to GND
   local dc  = 4 -- D4 / GPIO2
   local res = 0 -- D0 / GPIO16

   spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)
   -- we won't be using the HSPI /CS line, so disable it again
   gpio.mode(8, gpio.INPUT, gpio.PULLUP)

   -- initialize the matching driver for your display
   disp = ucg.ili9341_18x240x320_hw_spi(cs, dc, res)
end

function getDateTime ()
    tm = rtctime.epoch2cal(rtctime.get())
    return string.format("%02d/%02d/%04d %02d:%02d",  tm["day"], tm["mon"], tm["year"], tm["hour"], tm["min"])
end

function lcdPrint(txt, txt1)
    txt1 = txt1 or ''
    if serialDebug then print(txt, txt1) end
    disp:setColor(255, 0, 0)
    disp:drawBox(0, 210, 320, 20)
    disp:setPrintPos(2, 225)
    disp:setColor(255, 255, 255);
    disp:setFont(ucg.font_7x13B_tr)
    disp:print(txt)

    tmr.stop(2)
    tmr.alarm(2, 10000, 1, function()
        disp:setColor(0, 0, 0);
        disp:drawBox(0, 205, 320, 25);
        tmr.stop(2)
    end)
end

function printText(text, font, x, y, r, g, b)
    if font == 18 then
        disp:setFont(ucg.font_helvB18_hr)
    else
        disp:setFont(ucg.font_helvB10_hr)
    end
    disp:setFontPosBottom()
    local w = disp:getStrWidth(text)
    local h = disp:getFontAscent() - disp:getFontDescent()
    if x == nil then
        x = ((disp:getWidth() - disp:getStrWidth(text)) / 2)
    end
    disp:setColor(0, 0, 0)
    disp:drawBox(x, y-h, w, h)
    disp:setColor(255, 255, 255)
    disp:setPrintPos(x, y)
    disp:print(text)
end

function update()
    datetime = getDateTime()
    lcdPrint("Update run at " .. datetime)

    printText(datetime, 18, nil, 60)

    H, T = bme280.humi()
    if T and H then
        local Tsgn = (T < 0 and -1 or 1); T = Tsgn*T
        sData.temperature = string.format("%s%d.%02d", Tsgn<0 and "-" or "", T/100, T%100)
        if serialDebug then print("Temperature=" .. sData.temperature) end
        printText(sData.temperature .. " C", 18, 170, 90)

        -- thermometer GradientBox
        --disp:setColor(0, 0, 0)
        --disp:drawBox(21, 94, 40, 100)
        --disp:setColor(0, 255, 10, 0)
        --disp:setColor(1, 255, 10, 0)
        --disp:setColor(2, 5, 0, 255)
        --disp:setColor(3, 5, 0, 255)
        --local h = (20 + tonumber(sData.temperature)) * 1.42
        --disp:drawGradientBox(21, 94 + 100 - h , 40, h)
        --printText("-20", 10, 50, 192)
        --printText("50", 10, 20, 70)

        -- classic thermometer
        local h = (20 + tonumber(sData.temperature)) * 1.71
        disp:setColor(255, 255, 255);
        disp:drawDisc(300, 170, 16, 15);
        disp:drawRBox(290, 50, 20, 120, 8);
        disp:setColor(255, 0, 0);
        disp:drawDisc(300, 170, 10, 15);
        disp:drawRBox(295, 55 + 120 - h, 10, h, 4);

        sData.humidity = string.format("%d.%03d", H/1000, H%1000)
        if serialDebug then print("Humidity=" .. sData.humidity) end
        printText(sData.humidity .. " %", 18, 170, 120)

        D = bme280.dewpoint(H, T)
        local Dsgn = (D < 0 and -1 or 1); D = Dsgn*D
        sData.dew_point = string.format("%s%d.%02d", Dsgn<0 and "-" or "", D/100, D%100)
        if serialDebug then print("Dew point=" .. sData.dew_point) end
    end
    P, T = bme280.baro()
    if P and T then
        sData.baro_qfe = string.format("%d.%03d", P/1000, P%1000)
        if serialDebug then print("QFE=" .. sData.baro_qfe) end
        printText(sData.baro_qfe, 18, 170, 150)

        -- convert measure air pressure to sea level pressure
        QNH = bme280.qfe2qnh(P, altitude)
        sData.baro_qnh = string.format("%d.%03d", QNH/1000, QNH%1000)
        if serialDebug then print("QNH=" .. sData.baro_qnh) end
    end
        -- altimeter function - calculate altitude based on current sea level pressure (QNH) and measure pressure
    P = bme280.baro()
    if P then
        curAlt = bme280.altitude(P, QNH)
        local curAltsgn = (curAlt < 0 and -1 or 1); curAlt = curAltsgn*curAlt
        sData.altitude = string.format("%s%d.%02d", curAltsgn<0 and "-" or "", curAlt/100, curAlt%100)
        if serialDebug then print("Altitude=" .. sData.altitude) end
    end

    if mqttConfig.connected == true then
        sData.value = sData.temperature
        sData.valueappend = " C"
        mqtt:publish(sData.topic .. "/config", sjson.encode(sData), 1, 0, function(conn)
        end)
    end
end

-- configure wifi reset button
function pin3cb()
    lcdPrint("Resetting wireless configuration and restarting")
    node.restore()
    node.restart()
end
