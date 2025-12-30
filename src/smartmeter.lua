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
   print "load smartmeter"
   local M={}
   local hour_=require 'hour'
   local day_=require 'day'
   --   local ring=require 'ring'
   local stunde
   local nr

   --   local function test()
   --      print ''
   --      hour_.test()
   --      day_.test()
   --   end

   local function init(tag_,stunde_)
      print ("smartmeter init", tag_,stunde_)
      local tag = day_.create(tag_)
      --      print (table.concat(day_.toLua(tag),'\n'))
      stunde = hour_.get(tag_,stunde_)
      --      print (hour_.toLua(stunde))
      --      test()
      require 'blinker' -- lade den IRQ für den sensor
      --      if ring and ring.init then ring.init() end
   end

   local function nextMin(tag_neu,stunde_neu,minute_neu)
      if jetzt and jetzt.heute then
         if not stunde then init(tag_neu,stunde_neu) end
         local tag_alt,stunde_alt,minute_alt = jetzt.heute,jetzt.stunde,jetzt.minute
         print(table.concat({'jetzt ist ',tag_neu,"(",stunde_neu,":",minute_neu,')'}))
         print ('min:', node.heap())
         --         print('>',stunde,stunde_alt,stunde_neu,tag_alt)
         if stunde_alt~=stunde_neu then -- stunde speichern
            hour_.append(tag_alt,stunde)
            jetzt.stunde=stunde_neu
            if tag_alt~=tag_neu then -- tag anpassen
               day_.create(tag_neu)
--               day_.compile(tag_alt)
               jetzt.heute=tag_neu
            end
            stunde= hour_.get(tag_neu,stunde_neu) -- neue stunde vorbereiten
         end
         nr=minute_neu+1
      end end

   local function irPuls(count)
      --      print ('irPuls',stunde,nr)
      if stunde and type(stunde[2])=='table' then
         local t=stunde[2]
         local i=nr
         if i then
            if t[i] then t[i]=t[i]+count
            else         t[i]=count  end
            --            print('sum=',i,stunde[2],#stunde[2],t,t[i])
         end end end

   local function data(datum)
      if type(datum)=='string' then -- 2025-12-01
         local tmp={}
         for c in datum:gmatch("[0-9]+") do tmp[#tmp+1]=c end
         if #tmp==3 then
            datum=table.concat(tmp,'-') -- print (datum)
            return table.concat(day_.toJson(day_.get(datum)),'\n')
         else
            if stunde then
               --               print ("datum",datum)
               if datum=='/store' then
                  --                  print 'datum==/store'
                  if jetzt then
                     --                     print 'jetzt ok'
                     if jetzt.heute then
                        --                        print 'jetzt.heute OK'
                        local j=jetzt.heute
                        local t=stunde[2]
                        --                        print('append',j,stunde[1],t,#t)
                        --                        print('toLua',hour_.toLua(stunde))
                        --                        print('toJson',hour_.toJson(stunde))
--                        hour_.append(j,stunde)
                     end
                  end
               end
               -- print ("data stunde",stunde,#stunde,hour_.toLua(stunde))
               return hour_.toJson(stunde)
            end
         end
      end
      return table.concat({datum,'   ???   '},'\n') end

   M.data=data
   M.init=init
   M.next=nextMin
   M.stunde=stunde
   M.irPuls=irPuls
   print "end smartmeter" -- jetzt
   return M
end
