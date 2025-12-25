do
   local M={}
   print "load day"
   local util_=require 'util'
   local zeit_=require 'zeit' -- aber es dauert einige Zeit bis today aktuell ist !!!
   local hour_=require 'hour'

   -- liefert den Datensatz eines Tages aus den vorhanden Dateien,
   -- oder einen leeren Datensatz für diesen Tag als verschachtelte Tabelle
   -- Tabelle {Tag, {Stunde1, Stunde2, Stunde3 ...}
   -- Beispiel{'2025-12-01',{}}
   local function getDay(datum) -- aufruf mit dem gewünschten datum
      datum=datum or jetzt.heute or '2025-12-01'
      local filename=util_.fName(datum)
      local stunden={} -- Tabelle mit den Stunden ist erstmal leer
      local erg={datum,stunden}
--      print (filename or datum)
      if filename then -- die datei gibt es
         function date(d) -- date interpretieren
            if #d >= 1 then erg[1]=d[1] end end
         function hour(h) -- hour interpretieren
            if #h == 2 and type(h[2])=='table' then
               local uhr=h[1] -- uhrzeit
               local takte={} -- array
               local stunde={uhr,takte}
               for k,v in pairs(h[2]) do
                  if v>0 then takte[k]=v end
               end
               stunden[uhr]=stunde -- ganze stunde zuweisen
               --               print('uhr',type(stunde),#stunden)
         end end
         dofile(filename) -- print ("done",filename)
      end return erg end

   -- Tabelle {Tag, {Stunde1, Stunde2, Stunde3 ...}
   -- wird zu:
   -- Tabelle {line1, line2 ...}
   local function dayToLua(day) -- consumer = verbraucht die daten und liefert ein array mit textzeilen
      local lines={}
      if day and day[1] then
         --         print('day:', day[1])
         lines[#lines+1]=table.concat({"date{'",day[1],"'}"})
         local stunden=day[2]
         --         print('stunden',type(stunden),#stunden,#day)
         if type(stunden)=='table' and #stunden>0 then
            for i=0,24 do
               if stunden[i] then
                  local line=hour_.toLua(stunden[i])
                  lines[#lines+1]=line
               end end end end
      return lines end

   local function dayToJson(day) -- consumer = verbraucht die daten und liefert ein array mit textzeilen
      local lines={}
      if day and day[1] then
         --         print('day:', day[1])
         lines[#lines+1]=table.concat({'{"date":"',day[1],'",'})
         lines[#lines+1]='"hours":['
         local stunden=day[2]
         --         print('stunden',type(stunden),#stunden,#day)
         if type(stunden)=='table' and #stunden>0 then
            for i=0,24 do
               if stunden[i] then
                  local line= hour_.toJson(stunden[i])
                  if #lines==2 then lines[#lines+1]=line
                  else lines[#lines+1]=table.concat({',',line}) end
               end end
         end
         lines[#lines+1]=']}'
      end
      return lines end

   local function test()
      local erg=getDay('2025-12-01') -- Tabelle {Tag, {Stunde1, Stunde2, Stunde3 ...}
      --      print ('test dayx:',erg,erg[1] )
      print ('test day Lua:',table.concat( dayToLua(erg),'\n'))
      print ''
      print ('test day Json:',table.concat( dayToJson(erg),'\n'))
      print ''      
   end

   M.test=test
   M.get=getDay      -- Datensatz für einen Tag
   M.toLua=dayToLua  -- diesen Tag Serialisieren
   M.toJson=dayToJson
   print 'end day'
   return M
end
