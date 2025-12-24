-- Einige eigene funktionen
do
   local M={}
   local function print3d(v0)
      --   if not v0 then print 'nil' return end -- nullpointer
      if type(v0) ~= "table" then print(v0) return end
      if #v0 == 0 then print 'empty{}' return end
      for k1,v1 in pairs(v0) do
         if type(v1) == "table" then
            print(" "..k1.." \t={" )
            for k2,v2 in pairs(v1) do
               if type(v2) == "table" then
                  print("\t "..k2.." \t={" )
                  for k3,v3 in pairs(v2) do
                     print("\t\t "..k3.." \t= "..v3 ) end
                  print("\t ".." \t} " )
               else
                  print("\t "..k2.." \t= "..v2 ) end end
            print("\t ".." \t} " )
         else
            print(" "..k1.." \t= "..v1 ) end end end

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

   M.fName=fName
   M.print3d=print3d
   return M
end
