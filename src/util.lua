-- Einige eigene funktionen
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

M.print3d=print3d
return M
