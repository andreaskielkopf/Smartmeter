-- Http Server für Smartmeter Daten
do
   print "load server"
   local M= {}
   local sm= require 'smartmeter'
   -- local ring= require 'ring'
   local sm_    = '/smartmeter'
   local sm_heap= table.concat({sm_, "/heap"})
   local sm_data= table.concat({sm_, "/data"})
   --   local sm_ring= table.concat({sm_, "/ring"})
   local usage= table.concat({"<html><body><h1>NodeMCU</h1><p>Use ", sm_, "</p></body></html>"})

   -- erzeuge ein response mit dem richtigen Rahmen
   local function create(b)
      return table.concat({
         "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: ",
         #b, "\r\n\r\n", b}) end -- tailcall

   -- hole die passende Antwort für diesen pfad
   local function fetch(pfad)
      if pfad then
         if pfad:find(sm_heap) then
            return table.concat({'{"Heap":', node.heap(), '}'})  -- tailcall
         elseif sm and sm.data and pfad:find(sm_data) then
            return table.concat({'{"Data":', sm.data(pfad:match("/data(.*)")), '}'}, '\n')  -- tailcall
               --         elseif ring and ring.get and pfad:find(sm_ring) then
               --            return table.concat({'{"Ring":', ring.get(pfad:match("/ring(.*)")), '}'}, '\n')  -- tailcall ???
         elseif pfad:find(sm_) then
            return table.concat({'{"', sm_, '/{heap, data, data/store, data/2025/12/01, ring}'})  -- tailcall
         end end
      return usage end

   -- empfänger callback
   local function receiver(sck, payload)
      local pfad= payload:match("GET (/[%w/]*)")   -- pfad
      payload= nil
      local answer= fetch(pfad)
      sck:send(create(answer))
      --      if answer==usage then answer="" end
      --      print('receive ',pfad," > ",answer)
   end

   -- starte den HTTP Server
   local function init(timeout)
      print 'server init'
      timeout= timeout or 30
      -- erzeugt eine globale variable mit dem Server
      srv= srv or net.createServer(net.TCP, timeout)
      srv:listen(80, function(socket)
         socket:on("receive", receiver )
         socket:on("sent", function(sck) sck:close() sck= nil end )
      end )
      print "HTTP server running on port 80" end

   init()
   print "end server"
   return M
end
