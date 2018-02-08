# NodeMCU/BME280 Weather station

## Features
* integrated with IoTCC using mqtt
* display on SPI TFT LCD
* NTP time sync
* debug un serial and LCD

## WIP
* integration with PWS
* forcast

## SPI setup to connect display in func.lua
Initialize the matching driver for your display. All available are here http://nodemcu.readthedocs.io/en/master/en/modules/ucg/#display-drivers
```sh
disp = ucg.ili9341_18x240x320_hw_spi(cs, dc, res)
```

Connect it to NodeMCU
* Hardware SPI CLK  = GPIO14
* Hardware SPI MOSI = GPIO13
* Hardware SPI MISO = GPIO12 (not used)
* Hardware SPI /CS  = GPIO15 (not used)
* CS, D/C, and RES can be assigned freely to available GPIOs
* local cs  = 8 -- GPIO15, pull-down 10k to GND
* local dc  = 4 -- GPIO2
* local res = 0 -- GPIO16

## NodeMCU modules required
* bit
* bme280
* bmp085
* cron
* enduser_setup
* file
* gpio
* i2c
* mqtt
* net
* node
* rtctime
* sjson
* sntp
* spi
* tmr
* uart
* ucg
* wifi
* tls
