-- server für smartmeter-daten
do
   print "lade server"
   local M={}
   local data=require 'data'
   local sm=require 'smartmeter'
   local sm_    ='/smartmeter'
   local sm_heap=table.concat({sm_,"/heap"})
   local sm_info=table.concat({sm_,"/info"})
   --local icon  ='/favicon'
   --   local body1 =table.concat({'{\"', sm, '":"heap","2025-12-01",3,4,5,6,7,8,9,10}'})
   local usage =table.concat({"<html><body><h1>NodeMCU</h1><p>Use ", sm_, "</p></body></html>"})

   local function create(b)
      return table.concat({
         "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: ",
         #b, "\r\n\r\n", b}) end -- tailcall

   local function fetch(pfad)
      if pfad then
         if pfad:find(sm_heap) then return
            table.concat({'{"Heap":', node.heap(), '}'}) end -- tailcall
         if pfad:find(sm_info) then return
            table.concat({'{"Info":', sm.info(pfad:match("/info(.*)")) ,'}'}) end -- tailcall ???
            if pfad:find(sm_) then return
               table.concat({'{\"', sm_, '":"heap","2025-12-01",3,4,5,6,7,8,9,10}'}) end -- tailcall
            --      if pfad:find(icon) then return nil end -- nicht unterstützt
      end
      return usage end

   local function receiver(sck, payload)
      local pfad=payload:match("GET (/[%w/]*)")   -- pfad
      payload=nil
      local answer=fetch(pfad)
      sck:send(create(answer))
      if answer==usage then answer="" end
      print('receive ',pfad," > ",answer)
   end

   local srv
   local function init(timeout)
      timeout=timeout or 30
      print('server init')
      srv =srv or net.createServer(net.TCP,timeout)
      --      if not srv then srv=net.createServer(net.TCP,30) end
      srv:listen(80,function(socket)
         socket:on("receive", receiver )
         socket:on("sent", function(sck) sck:close() sck=nil end)
      end )
      print("HTTP server running on port 80")
      --      smartmeter.init()
   end

   --local function setData(data)
   --end
   --
   --local function setBody(body)
   --end
   init()
   --   M.init=init
   --M.create=create
   --M.body=body1
   M.srv=srv
   --M.setBody=setBody
   --M.setData=setData
   -- usage: M.init()
   print "end server"
   return M
end
