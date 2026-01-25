-- Einige eigene Funktionen die mehrfach verwendet werden
do
   print 'load util'
   local M= {}

   --   local function print3d(v0)
   --      --   if not v0 then print 'nil' return end -- nullpointer
   --      if type(v0) ~= "table" then print(v0) return end
   --      if #v0 == 0 then print 'empty{}' return end
   --      for k1,v1 in pairs(v0) do
   --         if type(v1) == "table" then
   --            print(" "..k1.." \t={" )
   --            for k2,v2 in pairs(v1) do
   --               if type(v2) == "table" then
   --                  print("\t "..k2.." \t={" )
   --                  for k3,v3 in pairs(v2) do
   --                     print("\t\t "..k3.." \t= "..v3 ) end
   --                  print("\t ".." \t} " )
   --               else
   --                  print("\t "..k2.." \t= "..v2 ) end end
   --            print("\t ".." \t} " )
   --         else
   --            print(" "..k1.." \t= "..v1 ) end end end

   -- Ermittle ob die datei als .lua, .lc oder als .var -Datei vorliegt, oder gar nicht
   -- usage: filename=fName(a or b or c)
   local function fName(name)
      local d=name
      for _,v in ipairs({'lc','lua','var'}) do
         d= table.concat({name,'.', v}) -- zusammenfügen
         if file.exists(d) then return d,v end -- dateiname, und Endung
      end end -- return nil end -- nicht da

   --   local function printPT()
   --      local p=node.getpartitiontable()
   --      local q={}
   --      for _,k in ipairs{'lfs_addr','lfs_size','spiffs_addr','spiffs_size'} do
   --         table.insert(q,#q+1,k)         table.insert(q,#q+1,p[k])
   --      end
   --      print(table.concat(q,"\t"))
   --      --      print3d(q)
   --   end
   --   M.printPT=printPT
   --   printPT()
   --   local function dof(name)
   --      local fd=file.open(name,"r")
   --      if fd then
   --         local line
   --         repeat
   --            line = fd:readline()
   --            if line then
   --               local f, err = loadstring(line)
   --               if f then
   --                  local ok, res = pcall(f)
   --                  if not ok then print("Fehler:", res) end
   --               else
   --                  print("Syntaxfehler:", err)
   --               end end
   --         until line==nil or #line==0
   --         fd:close()
   --      end end

   -- Iterator über Zeilen einer Datei. Liefert immer genau eine Zeile, bis die Datei zuende ist
   local function nextLine(name)
      local i, fd= 0, nil -- Zeilennummer
      print ('iterator über:', name)
      if name then fd= file.open(name, "r") end
      return function()
         if fd then i= i+1
            local line= fd:readline()
            if line then return i, line end -- iterator läuft weiter
            fd:close() end fd= nil -- close, end
         print 'end iterator' end end -- iterator beenden


   local function line2Object(line)
      local text= table.concat({"return ", line}) -- zeile um "return " erweitern
      local chunk, err= loadstring(text) -- zeile interpretieren (compile)
      if chunk then err= nil return chunk() end -- wenn sie interpretierbar war, ausführen
      error(err) end -- fehler

   -- Durchsucht die Zeile nach dem gewünschten Objekt
   -- hour{'hallo',{1,2,3,4,5}}
   -- oder nach einem namenlosen Objekt ( mit oder ohne führendes Komma )
   -- ,{5,'temp',{105,12,24},'c°C'}'
   -- Datensatz von 5 Uhr, Temperatur in centiGrad C
   local function getObj(oname, line)
      oname= oname or ''
      if line then
         local a, b= line:find('%-%-') -- Kommerntare entfernen bid zum Ende der Zeile
         if a then line= line:sub(1, a+1) end
         line= line:gsub("^,+","")-- führende Kommas entfernen
         a, b= line:find(oname) -- den rest interpretieren wenn der Name enthalten ist (ab dem Ende des namens)
         if a then return line2Object(line:sub(b+1)) end
      end end -- datei interpretieren und als objekt zurückliefern

   -- wandle eine kleine zahl in bas64 um
   --   local b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
   --   local b88 = b64 .. '!#$%&()*-,.:;=@[]^_`{|}~' -- local b91 = b88 .. '<>\\'
   --   local function base64(n) -- wert umwandeln
   --      if type(n)=='number' then
   --         do
   --            if n<0 then return '~~' -- Fehler
   --            elseif n==0 then return '  ' -- Leer ;-)
   --            elseif n>4095 then return '##' -- Überlauf
   --            else local a,b=math.floor(n/64) +1,n % 64 +1
   --               return table.concat({b64:sub(a,a),b64:sub(b,b)}) end
   --         end
   --   elseif n==nil then return ' _' end  -- nil
   --   print(type(n),n) return '??' end -- Fehler

   --   local function tBase64(t) -- tabelle mit werten umwandeln
   --      local erg={}
   --      for k,v in ipairs(t) do erg[k]=base64(v) end
   --      return erg end

   -- Lösche solange Dateien im SPIFFS bis genug Platz frei ist
   local function cleanUp(soll)
      soll= soll and soll>75000 and soll or 100000 -- halte 100kByte frei im Falle eines Updates
      local names, map= {}, file.list('20[0-9-]+.[lv][ua][ar]') -- map(filename:size) von 2025-12-01.lua .var
      for key, _ in pairs(map) do names[#names+1]= key end -- filenamen zusammentragen die zu Tagen gehören
      table.sort(names) -- sortieren, damit älteste zuerst gelöscht werden
      for _, name in ipairs(names) do
         local remaining, used, total= file.fsinfo() -- aktuellen Speicherplatz im Dateisystem prüfen
         if remaining<soll then -- mit dem sollwert vergleichen
            print(table.concat({"remove ", name, "(", map[name], ') rest=', remaining}))
            file.remove(name) -- eine Datei löschen
         else break end -- abbrechen sobald der Platz reicht
      end if update then update() end -- jetzt noch schnell prüfen, ob ein update ansteht
   end

   -- welche Monate oder Tage gibt es als Dateien (als Info für den PC)
   -- "2025" listet die Monate im Jahr die vorhanden sind
   -- "2025-01" listet die Tage im Monat Januar 2025 die Vorhanden sind
   -- "2025-01-05" listet die Stunden die in der Dazei vom 5.1.2025 enthalten sind ???
   local function welcheDateien(name)
      local monate, keys, z= {}, {}, #name==1 and 6 or 9 -- zeiger auf monat(6) oder tag(9)
      -- Die Variable "monat" wird auch für "tag" genutzt wenn z=9 ist
      name[#name+1]= '[0-9-]+.[lv][ua][ar]' -- regex hinzufügen für .lua und .var
      local map= file.list(table.concat(name, '.')) -- regex erzeugen
      for key, _ in pairs(map) do -- print (key)
         local m= key:sub(z, z+1)
         keys[m]= m
      end map= nil
      for monat, _ in pairs(keys) do
         monate[#monate+1]= monat -- print (#monate,monat)
      end keys= nil
      table.sort(monate) return monate end

   --   M.base64=base64
   --   M.tBase64=tBase64
   cleanUp() -- jetzt sofort
   M.fName= fName
   M.nextLine= nextLine
   --   M.getObject=getObject nur lokal
   M.getObj= getObj
   M.clean= cleanUp
   M.welche= welcheDateien
   print 'end util'
   return M
end
