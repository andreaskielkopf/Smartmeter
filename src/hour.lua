do
   local M={}
   print "load hour"
   local util=require 'util'
   local zeit=require 'zeit' -- aber es dauert einige Zeit bis today aktuell ist !!!

   -- liefert den Datensatz für die angegebene Stunde aus den vorhandenen Dateien
   -- oder einen leeren Datensatz für diese Stunde als Liste (einfach durchnummeriert)
   -- Tabelle {Stunde, {0 bis zu 60 x(Takte je Minute)}}
   -- Beispiel: {23,{}} oder {7,{0,99}} oder {0,{99,25,72,5,0,0,12,0,0}}
   local function getHour(tag,stunde) -- aufruf mit dem gewünschten datum
      tag=tag or jetzt.heute or '2025-12-01'
      stunde=stunde or jetzt.stunde or 15 -- default 14:00 Uhr bis 14:59
      local filename= util.fName(tag)
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
      return erg or {stunde,{}}
   end

   -- Tabelle {Stunde, {0 bis zu 60 x(Takte je Minute)}}
   local function hourToLine(h) -- Aufruf mit einer StundenTabelle
      local stunde=h[1] or 0
      local takte=h[2] or {}
--      print ('HourToLine:',h,type(stunde),type(takte))
      local buf={}
      for i=60,1,-1 do -- 60 Minuten rückwärts zuweisen in den buffer
         if takte[i] and takte[i]>0 then
            table.insert(buf,1,takte[i]) -- alles andere nach rechts schieben
      elseif #buf>0 then
         table.insert(buf,1,"0")
      end end
      local line=table.concat({"hour{", stunde, ",{", table.concat(buf,','), "}}"})
      return line
   end

   --   local function getHours(tag)
   --      tag=tag or jetzt.heute or '2025-12-01'
   --      local filename= util.fName(tag)
   --      local stunden={}
   --      --      print ("getHours",filename or tag)
   --      if filename then
   --         function date(d) end -- noop
   --         function hour(h)
   --            if not erg and type(h)=='table' and #h==2 and
   --               type(h[1])~='table' then
   --               --               print('a=',h[1])
   --               if type(h[2])=='table' then
   --                  --                  print('b=',h[2])
   --                  stunden[h[1]+1]=h[1]
   --               end end end
   --         dofile(filename) end
   --      date=nil
   --      hour=nil
   --      local erg={}
   --      erg[1]=tag
   --      erg[2]=stunden
   --      return erg
   --   end

   local function test()
      local erg=getHour('2025-12-01',4)
--      print (erg,type(erg[1]),type(erg[2]))
      local b=hourToLine(erg)
      print ('test hour:', b)
   end
   
   M.test=test
   M.get=getHour        -- Datensatz für eine Stunde
   --   M.getAll=getHours    -- alle Stundensätze dieses Tages
   M.toLine=hourToLine  -- diese Stunde Serialisieren
   print "end hour"
   return M
end


