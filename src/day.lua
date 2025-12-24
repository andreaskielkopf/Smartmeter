do
   local M={}
   print "load day"
   local util=require 'util'
   local zeit=require 'zeit' -- aber es dauert einige Zeit bis today aktuell ist !!!

   -- liefert den Datensatz eines Tages aus den vorhanden Dateien,
   -- oder einen leeren Datensatz für diesen Tag als verschachtelte Tabelle
   -- Tabelle {Tag, {Stunde1, Stunde2, Stunde3 ...}
   -- Beispiel{'2025-12-01',{}}
   local function getDay(datum) -- aufruf mit dem gewünschten datum
      datum=datum or jetzt.heute or '2025-12-01'
      local filename=util.fName(datum)
      local stunden={} -- Tabelle mit den Stunden ist erstmal leer
      local erg={datum,stunden}
      print (filename or datum)
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
         end end end
      dofile(filename) -- print ("done",filename)     
   end
   return erg end

-- Tabelle {Tag, {Stunde1, Stunde2, Stunde3 ...}
-- wird zu:
-- Tabelle {line1, line2 ...}
local function dayToLines(day) -- consumer = verbraucht die daten und liefert ein array mit textzeilen
   local lines={}
   if day and day[1] then
      print(day[1])
      lines[#lines+1]=table.concat({"date{'",day[1],"'}"})
      local stunden=day[2]
      if type(stunden)=='table' and #stunden>0 then
         for k,v in pairs(stunden) do
            local line
            -- print("heap(",k,node.heap())
            if k=='datum' then
               line=table.concat({"date{'",v,"'}"})
            elseif type(v) =="table" then-- stundenweise
               for i=1,24 do if v[i] then
                  local h=v[i]
                  local buf={"}}"}
                  for n=60,1,-1 do -- 60 minuten
                     local w=h[n]
                     if w and w>0 then
                        table.insert(buf,1,w)
                     elseif #buf>1 then
                        table.insert(buf,1,'0') -- nix=0
                     end end -- util.print3d(buf)
                  --            local rest= table.concat(buf,',')
                  line=table.concat({"hour{",i,",{",
                     table.concat(buf,',')})
               end end end
            day[k]=nil
            if line then
               table.insert(lines,line) -- print (line)
               line=nil
            end end
         day=nil -- table.sort(lines)
      end
      return lines end


   M.get=getDay        -- Datensatz für einen Tag
   M.toLine=dayToLine  -- diesen Tag Serialisieren
   print "end day"
   return M
end
