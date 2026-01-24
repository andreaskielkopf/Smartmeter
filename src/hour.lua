do
   print "load hour"
   local M= {}
   local util_= require 'util'
   local zeit_= require 'zeit' -- aber es dauert einige Zeit bis today aktuell ist !!!
   local vint_= require 'varint'

   -- liefert den Datensatz für die angegebene Stunde aus den vorhandenen Dateien
   -- oder einen leeren Datensatz für diese Stunde als Liste (einfach durchnummeriert)
   -- Tabelle {Stunde, {0 bis zu 60 x(Takte je Minute)}}
   -- Beispiel: {23,{}} oder {7,{0,99}} oder {0,{99,25,72,5,0,0,12,0,0}}
   local function getHour(tag, stunde) -- aufruf mit dem gewünschten datum
      tag= tag or jetzt.heute or '2025-12-01'
      stunde= stunde or jetzt.stunde or 15 -- default 14:00 Uhr bis 14:59
      local filename,ext= util_.fName(tag)
      local gefunden
      for _, line in util_.nextLine(filename) do
         if ext=='var' then -- binär interpretieren
            local k,n,a= vint_.l2d(line)
            if k=='hour' and type(a)=='table' and n==stunde then
               gefunden= {n, a} end-- liefere die letzte gefundene Zeile
         else -- konventionell interpretieren
            local hour= util_.getObj('hour', line)
            if type(hour)=='table' and hour[1] and hour[1]==stunde then
               gefunden= hour end-- liefere die letzte gefundene Zeile
         end
      end return gefunden or {stunde, {}} end

   -- Tabelle {Stunde, {0 bis zu 60 x(Takte je Minute)}}
   -- wird nur lokal genutzt
   local function hourToTable(h) -- Aufruf mit einer StundenTabelle
      local stunde= h[1] or 0
      local takte= h[2] or {}
      --      print ('HourToLine:',h,type(stunde),type(takte))
      local buf= {}
      for i= 60, 1, -1 do -- 60 Minuten rückwärts zuweisen in den buffer
         if takte[i] and takte[i]>0 then
            table.insert(buf, 1, takte[i]) -- alles andere nach rechts schieben
      elseif #buf>0 then
         table.insert(buf, 1, 0)
      end end
      return stunde, buf end -- liefert die stunde und die ticks(als tabelle)

   -- Tabelle {Stunde, {0 bis zu 60 x(Takte je Minute)}}
   local function hourToLua(h) -- Aufruf mit einer StundenTabelle
      local stunde, ticks= hourToTable(h)
      return table.concat({'hour{', stunde, ',{', table.concat(ticks, ','), '}}'})
   end

   -- Tabelle {Stunde, {0 bis zu 60 x(Takte je Minute)}}
   local function hourToJson(h) -- Aufruf mit einer StundenTabelle
      local stunde, ticks= hourToTable(h)
      return table.concat({'{"hour":', stunde, ', "ticks":[', table.concat(ticks, ','), ']}'})
   end

   -- Tabelle in Base64 codieren
   --   local function hourToBase64(h) -- Aufruf mit einer StundenTabelle
   --      local stunde, ticks= hourToTable(h)
   --      ticks=util_.tBase64(ticks)
   --      return table.concat({'{"hour":', stunde, ', "ticks":[', table.concat(ticks), ']}'})
   --   end

   -- speichert diesen Stunden-Datensatz in das angegebene Datum
   local function hourAppend(datum, stunde)
      local dat,ext= util_.fName(datum)
      if dat and stunde then
         local fd= file.open(dat, "a")
         if ext=='lua' then
            fd:writeline(hourToLua(stunde)) -- konventionell schreiben
         elseif ext=='var' then
            local st, ti= hourToTable(stunde)
            fd:writeline(vint_.d2l('hour',st,ti)) -- binär schreiben
         end
         fd:close() fd= nil
      end end

   --   local function test()
   --      local erg=getHour('2025-12-01',4)
   --      --      print (erg,type(erg[1]),type(erg[2]))
   --      print ('test hour Lua:', hourToLua(erg))
   --      print ''
   --      print ('test hour Json:', hourToJson(erg))
   --      print ''
   --   end

   --   M.test=test

   --   M.toBase64=hourToBase64
   M.get= getHour        -- Datensatz für eine Stunde
   M.append= hourAppend
   M.toLua= hourToLua      -- diese Stunde Serialisieren
   M.toJson= hourToJson
   print "end hour"
   return M
end
