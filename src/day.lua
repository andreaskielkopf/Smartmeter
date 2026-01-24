do
   print "load day"
   local M= {}
   local util_= require 'util'
   local zeit_= require 'zeit' -- aber es dauert einige Zeit bis today aktuell ist !!!
   local hour_= require 'hour'
   local vint_= require 'varint'

   -- liefert den Datensatz eines Tages aus den vorhanden Dateien,
   -- oder einen leeren Datensatz für diesen Tag als verschachtelte Tabelle
   -- Tabelle {Tag, {Stunde1, Stunde2, Stunde3 ...}
   -- Beispiel{'2025-12-01',{}}
   -- Aufruf mit dem gewünschten Datum
   local function getDay(datum)
      datum= datum or jetzt.heute or '2025-12-01'
      local stunden, filename= {}, util_.fName(datum)
      local erg= {datum, stunden} -- Tabelle mit den Stunden ist erstmal leer
      for _, line in util_.nextLine(filename) do
         local h= util_.getObj('hour', line) line= nil
         if h then
            if type(h)=='table' and #h==2 and type(h[2])=='table' then
               local uhr, takte= h[1], {} -- uhrzeit,array
               for k, v in ipairs(h[2]) do -- Reihenfolge beibehalten
                  if v>0 then takte[k]= v end -- Nullen entfernen
               end
               if #takte>0 then
                  stunden[uhr]= {uhr, takte} -- print (stunden[uhr][1],#stunden[uhr][2])
               end end h=nil
         else
            local d= util_.getObj('date', line) line=nil
            if d and type(d)=='table' and d[1] then
               erg[1]= d[1] end d=nil
         end end return erg end

   -- Tabelle {Tag, {Stunde1, Stunde2, Stunde3 ...}
   -- wird zu:
   -- Tabelle {line1, line2 ...}
   -- consumer = verbraucht die Daten und liefert ein Array mit Textzeilen
   local function dayToLua(day)
      local lines= {}
      if day and day[1] then
         print('day:', day[1])
         lines[1]= table.concat({"date{'", day[1], "'}"})
         local stunden= day[2]
         print('stunden', type(stunden), #stunden, #day)
         if type(stunden)=='table' and #stunden>0 then
            for i= 0, 24 do
               if stunden[i] then
                  lines[#lines+1]= hour_.toLua(stunden[i])
               end end end end
      return lines end

   -- consumer = verbraucht die daten und liefert ein array mit textzeilen
   --      local function dayToJson(day)
   --         if day and day[1] then
   --            collectgarbage("collect")
   --            print('day:', day[1] )
   --            local lines= {table.concat({'{"date":"', day[1], '",'}), '"hours":['}
   --            local stunden= day[2]
   --            print('stunden', type(stunden), #stunden, #day)
   --            if type(stunden)=='table' and #stunden>0 then
   --               for i= 0, 24 do
   --                  local s= stunden[i] stunden[i]= nil
   --                  if s then
   --                     print('s:', i, s, s[1], node.heap())
   --                     local line= hour_.toJson(s)
   --                     --                  print (line)
   --                     if #lines==2 then lines[#lines+1]= line
   --                     else lines[#lines+1]= table.concat({',', line})
   --                     end line= nil
   --                  end end end
   --            lines[#lines+1]= ']}'
   --            print 'end toJson'
   --            return lines end
   --      return {} end

   -- erzeugt die leere Datei für den aktuellen Tag
   local function dayCreate(datum)
      if not util_.fName(datum) and datum and #datum==10 then --wenn es datum gibt, und keine Datei existiert
         -- print ('create day Lua:',datum,'\n', table.concat(dayToLua(getDay(datum)),'\n'))
         --         local fd= file.open(table.concat({datum, '.lua'}), "a")
         local fd= file.open(table.concat({datum, '.var'}), "a")
         --         for _, line in ipairs(dayToLua(getDay(datum))) do fd:writeline(line) end
         fd:close() fd= nil end
      return getDay(datum) end  --vorhandene Datei übergeben

   -- Liefert eine Liste der Stunden die vorhanden sind
   local function dayStunden(tag)
      local l= {}
      for k, _ in pairs(getDay(tag)[2]) do -- eventuell verschobene Reihenfolge
         l[#l+1]= k
      end table.sort(l)
      return l end

   --   local function test()
   --      local erg=getDay('2025-12-01') -- Tabelle {Tag, {Stunde1, Stunde2, Stunde3 ...}
   --      --      print ('test dayx:',erg,erg[1] )
   --      print ('test day Lua:',table.concat( dayToLua(erg),'\n'))
   --      print ''
   --      print ('test day Json:',table.concat( dayToJson(erg),'\n'))
   --      print ''
   --   end

   --   M.test=test
   --   M.compile=dayCompile
   --   M.toJson=dayToJson
   --   M.toBase64=dayToBase64
   M.get= getDay       -- Datensatz für einen Tag
   M.create= dayCreate -- und Datei sicherstellen
   M.toLua= dayToLua  -- diesen Tag Serialisieren
   M.stunden= dayStunden
   print 'end day'
   return M
end
