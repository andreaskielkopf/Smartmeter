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

   local stunde

   local function test()
      print ''
      hour_.test()
      day_.test()
   end

   local function init(tag_,stunde_)
      print ("smartmeter init", tag_,stunde_)
      local tag = day_.create(tag_)
      print (table.concat(day_.toLua(tag),'\n'))
      stunde = hour_.get(tag_,stunde_)
      print (hour_.toLua(stunde))
      --      test()
   end

   local function nextMin(tag_neu,stunde_neu,minute_neu)
      if jetzt and jetzt.heute then
         if not stunde then init(tag_neu,stunde_neu) end
         local tag_alt,stunde_alt,minute_alt=jetzt.heute,jetzt.stunde,jetzt.minute
         print(table.concat({'jetzt ist ',tag_neu,"(",stunde_neu,":",minute_neu,')'}))
         if stunde_alt~=stunde_neu then -- stunde speichern
            hour_.append(tag_alt,stunde)
            if tag_alt~=tag_neu then -- tag anpassen
               day_.create(tag_neu)
               day_.compile(tag_alt)
            end
            stunde= hour_.get(tag_neu,stunde_neu) -- neue stunde vorbereiten
         end
      else
         print('Minute = ',minute_neu)
      end
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
   M.next=nextMin
   M.stunde=stunde
   print "end smartmeter"
   return M
end
