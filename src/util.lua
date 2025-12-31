-- Einige eigene funktionen
do
   print 'load util'
   local M={}
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

   local function fName(name) -- usage: filename=fName(a or b or c)
      local lc=table.concat({name,'.lc'})
      if file.exists(lc) then return lc end
      local lua=table.concat({name,'.lua'})
      if file.exists(lua) then return lua end
      return nil end

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

   -- eigener iterator über Zeilen einer datei
   local function nextLine(name)
      local i,fd= 0,nil -- Zeilennummer
      print ('iterator über:',name)
      if name then fd=file.open(name,"r") end
      return function()
         if fd then i= i+1
            local line = fd:readline() -- print ('line:',i,line)
            if line then return i, line end -- weiter so
            fd:close() end
         fd=nil i=nil -- close, end
         print 'end iterator'
         return nil end -- iterator beenden
   end

   local function getObject(line)
      local text= table.concat({"return ",line}) -- print ('obj:',text)
      local chunk, err = loadstring(text)
      if chunk then err=nil return chunk() end
      error(err) end

   local function getObj(oname,line)
      oname=oname or ''
      if line then
         local c,d=line:find('%-%-')
         if c then line=line:sub(1,c+1) end -- comments ;-)
         local a,b=line:find(oname)
         if a then
            return getObject(line:sub(b+1))
         end end end -- datei interpretieren

   -- wandle eine kleine zahl in bas64 um
   local b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
   --   local b88 = b64 .. '!#$%&()*-,.:;=@[]^_`{|}~' -- local b91 = b88 .. '<>\\'
   local function base64(n) -- wert umwandeln
      if type(n)=='number' then
         do
            if n<0 then return '~~' -- Fehler
            elseif n==0 then return '  ' -- Leer ;-)
            elseif n>4095 then return '##' -- Überlauf
            else local a,b=math.floor(n/64) +1,n % 64 +1
               return table.concat({b64:sub(a,a),b64:sub(b,b)}) end
         end
   elseif n==nil then return ' _' end  -- nil
   print(type(n),n) return '??' end -- Fehler

   local function tBase64(t) -- tabelle mit werten umwandeln
      local erg={}
      for k,v in ipairs(t) do erg[k]=base64(v) end
      return erg end

   -- Lösche solange Dateien im SPIFFS bis genug Platz frei ist
   local function cleanUp(soll)
      soll= soll and soll>75000 and soll or 100000 -- print('soll=',soll)
      local names,map= {},file.list('[0-9-]+.lua') -- map(filename:size) von 2025-12-01.lua ...
      for key,_ in pairs(map) do names[#names+1]=key end
      table.sort(names) -- älteste zuerst löschen
      for _,name in ipairs(names) do
         local remaining,used,total= file.fsinfo()
         if remaining<soll then
            print(table.concat({"remove ",name,"(",map[name],') rest=',remaining}))
            file.remove(name)
         else break end end
         if update then update() end
      end

   -- welche monate oder tage gibt es als dateien
   local function welche(name)
      local monate,keys,z= {},{},#name==1 and 6 or 9 -- zeiger auf monat oder tag
      name[#name+1]='[0-9-]+.lua'
      local map=file.list(table.concat(name,'.')) -- map(filename:size) von 2025-12-01.lua ...
      for key,_ in pairs(map) do -- print (key)
         local m= key:sub(z,z+1)
         keys[m]=m
      end map=nil
      for monat,_ in pairs(keys) do
         monate[#monate+1]=monat -- print (#monate,monat)
      end keys=nil
      table.sort(monate) return monate end

   cleanUp()

   M.fName=fName
   M.base64=base64
   M.tBase64=tBase64
   M.nextLine=nextLine
   M.getObject=getObject
   M.getObj=getObj
   M.clean=cleanUp
   M.welche=welche
   print 'end util'
   return M
end
