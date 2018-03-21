# NodeMCU/BME280/320x240 TFT Weather station

## Features
* integrated with IoTCC using mqtt
* display on SPI TFT LCD (ILI9341)
* NTP time sync
* debug on serial and LCD

## WIP
* integration with PWS
* forcast via external webservice (based on pressure) due to low memory

## SPI setup to connect display in func.lua
Initialize the matching driver for your display. All available are here http://nodemcu.readthedocs.io/en/master/en/modules/ucg/#display-drivers
```sh
disp = ucg.ili9341_18x240x320_hw_spi(cs, dc, res)
```

Connect TFT to NodeMCU
* Hardware SPI CLK  -> D5 / GPIO14
* Hardware SPI MOSI -> D7 / GPIO13
* Hardware SPI MISO -> D6 / GPIO12 (not used)
* Hardware SPI /CS  -> D8 / GPIO15 (not used)
* CS, D/C, and RES can be assigned freely to available GPIOs
* cs                -> D8 / GPIO15, pull-down 10k to GND
* dc                -> D4 / GPIO2
* res               -> D0 / GPIO16
* LED               -> 3.3v
* VCC               -> 3.3v
* GND               -> GND

Connect BME280 to NodeMCU
* SDA  -> D2 / GPIO4
* SCL  -> D1 / GPIO5
* 3.3v -> 3.3v
* GND  -> GND

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

### Comana weather station
![Alt text](/info/screenshot.jpg?raw=true "Comana weather station")