do
   local M={}
   local util=require 'util'

   -- liefert den Datensatz für die angegebene Stunde aus den vorhandenen Dateien
   -- oder einen leeren Datensatz für diese Stunde als Liste (einfach durchnummeriert)
   -- Tabelle {Stunde, {0 bis zu 60 x(Takte je Minute)}}
   -- Beispiel: {23,{}} oder {7,{0,99}} oder {0,{99,25,72,5,0,0,12,0,0}}
   local function getHour(tag,stunde) -- aufruf mit dem gewünschten datum
      local filename= util.fName(tag or today or '2025-12-01')
      stunde=stunde or 15 -- default 15:00 Uhr bis 15:59:59
      local erg
      print ("read",filename or tag,stunde)
      if filename then
         function date(d) end -- alternative ohne print
         -- function date(d) if type(d)=='table' and #d==1 then
         --    print("date",d[1]) end end
         function hour(h)
            if not erg and type(h)=='table' and #h==2 and
               type(h[1])~='table' and h[1]==stunde then
               --               print('a=',h[1])
               if type(h[2])=='table' then
                  --                  print('b=',h[2])
                  erg=h
               end end end
         dofile(filename) end
      return erg or {stunde,{}}
   end

   -- liefert den kompletten Datensatz eines Tages aus den vorhanden Dateien,
   -- oder einen leeren Datensatz für diesen Tag als verschachtelte Tabelle
   -- Tabelle {Tag, {Stunde1, Stunde2, Stunde3 ...}
   -- Beispiel{'2025-12-01',{}}
   --
   local function getDay(tag) -- aufruf mit dem gewünschten datum
      local filename=util.fName(tag or today or '2025-12-01')
      local stunden={}
      print (filename or tag)
      if filename then
         function date(d)
            if #d == 1 then stunden.datum=d[1] end
            d=nil
         end
         function hour(h)
            if #h == 2 then -- print(h[1])
               local z={}
               for k,v in pairs(h[2]) do
                  if v>0 then z[k]=v end
               end
               stunden[h[1]]=z
            end end
         dofile(filename) -- print ("done",filename)
      end
      return stunden end

   local function toLines(day) -- consumer = verbraucht die daten und liefert textzeilen
      if not day or not day.datum then return end
      local lines={}
      local line
      for k,v in pairs(day) do
         -- print("heap(",k,node.heap())
         if k=='datum' then
            line=table.concat({"date{'",v,"'}"})
         elseif type(v) =="table" then-- stundenweise
            local buf={"}}"}
            for n=60,1,-1 do -- 60 minuten
               local w=v[n]
               if w and w>0 then
                  table.insert(buf,1,w)
               elseif #buf>1 then
                  table.insert(buf,1,'0') -- nix=0
               end end -- util.print3d(buf)
            --            local rest= table.concat(buf,',')
            line=table.concat({"hour{",k,",{",
               table.concat(buf,',')})
         end
         day[k]=nil
         if line then
            table.insert(lines,line) -- print (line)
            line=nil
         end end
      day=nil -- table.sort(lines)
      return lines end

   local function testA()
      collectgarbage()
      print('getDay()',node.heap())
      local day= getDay()
      collectgarbage()
      print('toLines',node.heap())
      local lines= toLines(day)
      day=nil -- optioal ???
      collectgarbage()
      print('umgewandelt',node.heap())
      lines=nil
      collectgarbage()
      print('sauber',node.heap())
   end

   local function testB()
      for stunde= 0,23 do
         print(getHour('2025-12-01',stunde))
      end
   end

   testB()
   --   util.print3d(erg)
   M.getHour=getHour    -- get Hour from Storage
   M.getDay=getDay      -- get Day from Storage
   M.dayToLines=toLines -- convert Day to lines{} for html
   --   M.writeDay=writeDay
   --   M.writeHour=writeHour

   --   return M
end
