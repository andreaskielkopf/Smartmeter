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
      local i,fd=0,nil -- Zeilennummer
      print ('iterator über:',name)
      if name then fd=file.open(name,"r") end
      return function()
         if fd then
            i = i + 1
            local line = fd:readline() --keys[i]
            --            print ('line:',line)
            if line then return i, line end -- weiter so
            fd:close()
         end
         fd=nil -- close, end
         i=nil
         print 'end iterator'
         return nil end-- iterator beenden
   end

   -- holt eine komplette textzeile mit bis zu 100 Zeiten ab
   --   local function get()
   --      local tmp={'leer'}
   --      for k,v in ipop() do tmp[k]=v end
   --      return table.concat(tmp,',') end

   local function getObject(line)
      local text= table.concat({"return ",line})
      --      print ('obj:',text)
      local chunk, err = loadstring(text)
      if chunk then err=nil return chunk() end
      error(err)
   end

   local function getObj(oname,line)
      oname=oname or ''
      if line then
         local c,d=line:find('%-%-')
         if c then line=line:sub(1,c+1) end -- comments ;-)
         local a,b=line:find(oname)
         if a then
            return getObject(line:sub(b+1))
         end end end -- datei interpretieren

   M.fName=fName
   --   M.dof=dof
   M.nextLine=nextLine
   M.getObject=getObject
   M.getObj=getObj
--   M.print3d=print3d
   print 'end util'
   return M
end
