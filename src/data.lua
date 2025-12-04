local M={}
--local heap=node.heap

fake={  heap=node.heap,
   ['2025-12-01']=test,
   ['2025-12-02']={
      {1,2,3,4,5,6,7,8,9,},
      {9,8,7,6,5,4,3,2,1},
   },
}

function getD(filename) -- aufruf mit dem gewünschten datum
   if not filename then filename='2025-12-01' end
   print (filename..'.lua')
   if not file.exists(filename..'.lua') then return {} end
   local stunden={}
   function date(d)
      if #d == 1 then stunden.datum=d[1] end
   end
   function hour(h)
      if #h == 2 then stunden[h[1]]=h[2] end
   end
   dofile(filename..'.lua')
   util.print3d(stunden)
   return stunden
end

function setD(data)
   if not data then return end
   if not data.datum then return end
   lines={}
   for k,v in pairs(data) do
      if k=='datum' then
         print("date{'"..v.."'}")
      elseif type(v) =="table" then-- stundenweise
         local  line="hour{"..k..",{"
         for n=1,10 do -- 60 minuten
            local w=v[n]
            line = line .. w .. ","
         end
         line=line.."}}"
         print (line)
      end
   end
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

do
   setD(getD('2025-12-01'))
end
