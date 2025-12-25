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
   print "load smartmeter"
   local hour_=require 'hour'
   local day_=require 'day'
   local heute
   local gestern
   local stunde={}

   local function test()
      print ''
      hour_.test()
      day_.test()
   end

   local function init()
      print ("smartmeter gestartet")
      gestern={}
      heute={}
--      test()
   end

   local function data(datum)
      --      test()
      if type(datum)=='string' then -- 2025-12-01
         local tmp={}
         for c in datum:gmatch("[0-9]+") do
            tmp[#tmp+1]=c
         end
         if #tmp==3 then
            datum=table.concat(tmp,'-')
            --            print (datum)
            local tag=day_.get(datum)
            local lines=day_.toJson(tag)
            return table.concat(lines,'\n')
         end
      end
      return table.concat({datum,'   ???   '},'\n')
   end



   M.data=data
   M.init=init
   print "end smartmeter"
   return M
end
