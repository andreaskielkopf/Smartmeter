do
   print "load hour"
   local M={}
   local util_=require 'util'
   local zeit_=require 'zeit' -- aber es dauert einige Zeit bis today aktuell ist !!!

   -- liefert den Datensatz für die angegebene Stunde aus den vorhandenen Dateien
   -- oder einen leeren Datensatz für diese Stunde als Liste (einfach durchnummeriert)
   -- Tabelle {Stunde, {0 bis zu 60 x(Takte je Minute)}}
   -- Beispiel: {23,{}} oder {7,{0,99}} oder {0,{99,25,72,5,0,0,12,0,0}}
   local function getHour(tag,stunde) -- aufruf mit dem gewünschten datum
      tag=tag or jetzt.heute or '2025-12-01'
      stunde=stunde or jetzt.stunde or 15 -- default 14:00 Uhr bis 14:59
      local filename= util_.fName(tag)
      local erg
      --      print ("getHour:",filename or tag,stunde)
      if filename then
         function date(d) end -- noop
         function hour(h)
            --            print (type(h), #h, type(h[1]),type(h[2]))
            if not erg --shortcut
               and type(h)=='table' and #h==2 -- table mit 2 einträgen
               and type(h[1])~='table' and h[1]==stunde -- stunde stimmt überein
               and type(h[2])=='table' then -- tabelle mit den minuten
               --               print (h[1],#h[2])
               erg=h
            end end
         dofile(filename) end -- datei interpretieren
      --      print (erg,type(erg[1]),type(erg[2]))
      return erg or {stunde,{}} end

   -- Tabelle {Stunde, {0 bis zu 60 x(Takte je Minute)}}
   local function hourToTable(h) -- Aufruf mit einer StundenTabelle
      local stunde=h[1] or 0
      local takte=h[2] or {}
      --      print ('HourToLine:',h,type(stunde),type(takte))
      local buf={}
      for i=60,1,-1 do -- 60 Minuten rückwärts zuweisen in den buffer
         if takte[i] and takte[i]>0 then
            table.insert(buf,1,takte[i]) -- alles andere nach rechts schieben
      elseif #buf>0 then
         table.insert(buf,1,'0')
      end end
      return stunde, table.concat(buf,',') end -- liefert die stunde und die ticks

   -- Tabelle {Stunde, {0 bis zu 60 x(Takte je Minute)}}
   local function hourToLua(h) -- Aufruf mit einer StundenTabelle
      local stunde, ticks= hourToTable(h)
      return table.concat({'hour{', stunde, ',{', ticks, '}}'})
   end

   -- Tabelle {Stunde, {0 bis zu 60 x(Takte je Minute)}}
   local function hourToJson(h) -- Aufruf mit einer StundenTabelle
      local stunde, ticks= hourToTable(h)
      return table.concat({'{"hour":', stunde, ', "ticks":[', ticks, ']}'})
   end

   local function hourAppend(datum,stunde)
      local lua=table.concat({datum,'.lua'})
      if stunde and file.exists(lua) then
         --         print (datum,hourToLua(stunde))
         local f=file.open(lua,"a")
         f:write(hourToLua(stunde))
         f:write('\n')
         f:close()
         f=nil end end

   --   local function test()
   --      local erg=getHour('2025-12-01',4)
   --      --      print (erg,type(erg[1]),type(erg[2]))
   --      print ('test hour Lua:', hourToLua(erg))
   --      print ''
   --      print ('test hour Json:', hourToJson(erg))
   --      print ''
   --   end

   --   M.test=test
   M.get=getHour        -- Datensatz für eine Stunde
   M.append=hourAppend
   M.toLua=hourToLua      -- diese Stunde Serialisieren
   M.toJson=hourToJson
   print "end hour"
   return M
end


