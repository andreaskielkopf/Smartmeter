do
   local M={}
   local _file='2025-12-01'
   --local heap=node.heap

   --fake={  heap=node.heap,
   --   ['2025-12-01']=test,
   --   ['2025-12-02']={
   --      {1,2,3,4,5,6,7,8,9,},
   --      {9,8,7,6,5,4,3,2,1},
   --   },
   --}

   local function getD(filename) -- aufruf mit dem gewünschten datum
      if not filename then filename=_file end
      local lc=filename..'.lc'
      if file.exists(lc) then
         filename=lc lc=nil
      else
         filename=filename..'.lua'
      end
      print (filename)
      if not file.exists(filename) then return {} end
      local stunden={}
      function date(d)
         if #d == 1 then stunden.datum=d[1] end
         d=nil
      end
      function hour(h)
         if #h == 2 then
            local z={}
            for k,v in pairs(h[2]) do
               if v>0 then z[k]=v end
               --            v=nil
            end
            h[2]=nil
            stunden[h[1]]=z
            z=nil
            print(h[1])
            h[1]=nil
         end
         h=nil
      end
      dofile(filename)
      filename=nil
      print "done"
      return stunden
   end

   local function setD(data) -- consumer = verbraucht die daten
      if not data then return end
      if not data.datum then return end
      local lines={}
      local line
      for k,v in pairs(data) do
         collectgarbage()
         print("heap("..k..")="..node.heap())
         if k=='datum' then
            line="date{'"..v.."'}"
         elseif type(v) =="table" then-- stundenweise
            --            local rest="}}"
            local buf={}
            local q="}}"
--            print("insert("..q..")")
            table.insert(buf,1,q)
            for n=60,1,-1 do -- 60 minuten
               local w=v[n]
               if w and w>0 then
                  --                  rest=w..','..rest
--                  print("insert("..w..")")
                  table.insert(buf,1,w)
               elseif #buf>1 then
                  --                  rest='0,'..rest
                  local n="0"
--                  print("insert("..n..")")
                  table.insert(buf,1,n)
               end
            end
--            u= require("util")
--            u.print3d(buf)
            local rest= table.concat(buf,',')
            line="hour{"..k..",{"..rest
         end
         data[k]=nil
         if line then
            --         table.insert(lines,line)
            print (line)
            line=nil
         end
      end
      data=nil
      --   table.sort(lines)
      return lines
         --   if not filename then filename='2025-12-01' end
         --   print (filename..'.lua')
         --   if not file.exists(filename..'.lua') then return {} end
         --   local stunden={}
         --   function date(d)
         --      if #d == 1 then stunden.datum=d[1] end
         --   end
         --   function hour(h)
         --      if #h == 2 then stunden[h[1]]=h[2] end
         --   end
         --   dofile(filename..'.lua')
         --   util.print3d(stunden)
         --   return stunden
   end

   local erg= getD(_file)
   print(node.heap())
   print "got it"
   erg= setD(erg)
   print(node.heap())
   erg=nil
   --   util.print3d(erg)

   --   return M
end
