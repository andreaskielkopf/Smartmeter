-- folgende module werden benötigt:
-- node, net, wifi, end user setup
-- file, GPIO, UART
-- timer, RTC time, SNTP

-- LFS mit 64kByte
-- BME280, BME280.math
-- DS18B20.lua, 1-Wire
-- DHT
-- SPI UCG ST7735 ??
do
   local M={}
   print "lade smartmeter"
   local data=require 'data'
   local hour=require 'hour'
   local heute
   local gestern
   local stunde={}
   -- local datum

   -- local jetzt={}
   local function init()
      print ("smartmeter gestartet")
      gestern={}
      heute={}
   end

   local function info(a)
      hour.test()
      local antwort={}
      antwort[#antwort+1]=a
      antwort[#antwort+1]="Hallo Welt"
      for _,v in pairs(data.toLines(data.getDay("2025-12-01"))) do -- print (k,v)
         antwort[#antwort+1]=v
      end
      antwort[#antwort+1]="-"
      antwort[#antwort+1]=data.toLine2(data.getHour())
      print "info"
      return table.concat(antwort,'\n')
   end


   M.info=info
   M.init=init
   print "end smartmeter"
   return M

end
