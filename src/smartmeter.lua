-- folgende module werden benötigt:
-- node, net, wifi, end user setup
-- file, GPIO, UART
-- timer, RTC time, SNTP

-- LFS mit 64kByte
-- BME280, BME280.math
-- DS18B20.lua, 1-Wire
-- DHT
-- SPI UCG ST7735 ??
local M={}
local heute
local gestern
local stunde={}
local datum

local jetzt={}
local function init()
   print ("Smartmeter gestartet")
   gestern={}
   
   heute={}
end




M.init=init
return M
