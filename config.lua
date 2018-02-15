-- config.lua --

serialDebug = true

-- network
wifiEnabled = true
network = {}
--network.ip = "192.168.0.51"
--network.netmask = "255.255.255.0"
--network.gateway = "192.168.0.1"

-- MQTT
prefix = "/iotcc"
device = "/" .. wifi.sta.getmac() -- set the device as the wifi card mac address. Is unique, also easy to trace

mqttConfig = {}
mqttConfig.enabled = true
mqttConfig.host = ''
mqttConfig.port = ''
mqttConfig.user = ''
mqttConfig.pass = ''
mqttConfig.secure = 0
mqttConfig.connected = false

sData = {}
sData.baro_qfe = 0
sData.baro_qnh = 0
sData.temperature = 0
sData.humidity = 0
sData.dew_point = 0
sData.altitude = 0
sData.pageName = "Comana weather station"
sData.pageId = 50
sData.widget = "data"
sData.title = "Summer kitchen temperature"
sData.topic = prefix .. device ..'/ws1'
sData.template = "template-1"
sData.icon = "fa fa-thermometer-quarter"
sData.class = "bg-green"
sData.class2 = "text-center"
sData.order = 10

-- BME280
sda, scl = 1, 2
altitude = 81 -- altitude of the measurement place

-- other
deviceTitle = "Comana weather station"
ntpserver = "194.177.34.116"
timezoneHours = 2
