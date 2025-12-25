meter={}
--data={}
do
   local M={}
   print "load data"
   local util=require 'util'
   local zeit=require 'zeit' -- aber es dauert einige Zeit bis today aktuell ist !!!
--   local hour=require 'hour'
--   local day =require 'day'

   

   -- Übergeben werden nested tables
   local function toLine2(data)
      local erg
      if data and type(data)=='table' and #data==2 then
         local a,b=data[1],data[2]
         data=nil
         if type(b)=='table' then
            local name= (type(a)~='string' or #a<=2) and 'hour' or 'date'
            --            print(name,a,#b)
            local buf={} -- 60 Minuten / 24 Stunden
            if name=='hour' then
               for i=60,1,-1 do
                  if b[i] and b[i]>0 then table.insert(buf,1,b[i])
                  elseif #buf>0      then table.insert(buf,1,"0")
                  end                  --                  print (#b,i,b[i],#buf)
               end
            else
               a=table.concat({"'",a,"'"})
               for i=1,24 do buf[#buf+1]=b[i] end
            end
            erg=table.concat({name,"{",a,",{",
               table.concat(buf,','),"}}"})
         end end
      return erg or "" end


  
--   local function testA()
--      collectgarbage()
--      print('getDay()',node.heap())
--      local day= getDay()
--      collectgarbage()
--      print('toLines',node.heap())
--      local lines= toLines(day)
--      day=nil -- optioal ???
--      collectgarbage()
--      print('umgewandelt',node.heap())
--      lines=nil
--      collectgarbage()
--      print('sauber',node.heap())
--   end

   local function init() -- initialisiert den datenbestand aus dem Dateisystem
      --      print ('init',#jetzt,jetzt.heute)
      if jetzt.heute then  -- erst aufrufen wenn die Zeit ok ist)
         if not meter.stunde then
            meter.stunde=hour.get()
            --            print(toLine2(meter.stunde))
      end end end

   local function testB() -- Datei lesen und korrigiert weitergeben
      local stunden=getHours('2025-12-01')
      print(toLine2(stunden))
      for i= 0,23 do
         local stunde=getHour('2025-12-01',i)
         if stunde[2] and #stunde[2]>0 then print(toLine2(stunde)) end
      end
      print 'Moment bitte'
      -- es dauert einige Zeit bis today aktuell ist !!!
      tmr.create():alarm(3000,tmr.ALARM_SINGLE,function()
         print(toLine2(getHours()))
         init()
         print(#meter)
         --                  if meterstunde then
         print(toLine2(meter.stunde)) --end
      end )
   end

   local function testC() -- aktuelle Stunde ausgeben
      print "testC"
      local stunde={}
      stunde=getHour('2025-12-01',5)
      print (stunde,#stunde,stunde[1])
      if stunde[2] then print(toLine2(stunde)) end
      stunde=getHour()
      print (stunde,#stunde,stunde[1])
      if stunde[2] then print(toLine2(stunde)) end
      stunde=getHour('2025-12-01')
      if stunde[2] and #stunde[2]>0 then print(toLine2(stunde)) end
   end
   --   testC()
   --   testB()
   --   util.print3d(erg)
   M.init=init
--   M.getHour=getHour    -- get Hour from Storage
--   M.getHours=getHours
--   M.getDay=getDay      -- get Day from Storage
--   M.toLines=toLines -- convert Day to lines{} for html
   M.toLine2=toLine2 -- convert Stunde to Line
   --   M.testC=testC

   --   M.writeDay=writeDay
   --   M.writeHour=writeHour

   print "end data"
   return M
end
