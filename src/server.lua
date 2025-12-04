-- server für smartmeter-daten
local M={}
local sm    ='/smartmeter'
local icon  ='/favicon'
local body1 ='{\"'..sm..'":"heap","2025-12-01",3,4,5,6,7,8,9,10}'
local body2 ="<html><body><h1>NodeMCU</h1><p>Use "..sm.."</p></body></html>"
local srv

local function create(b)
   local r = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: "..#b.."\r\n\r\n"..b
   return r
end

local function fetch(pfad)
   if pfad then
      if pfad:find(sm.."/heap") then return '{"Heap":'..node.heap()..'}' end
      if pfad:find(sm) then return body1 end
      if pfad:find(icon) then return nil end -- nicht unterstützt
   end
   return nil
end

local function receiver(sck, payload)
   --   print (payload)
   local pfad=payload:match("GET (/[%w/]*)")   -- pfad
   --   if pfad then print(pfad) else print 'nil' end
   local answer=fetch(pfad)
   if answer then
      print('receive '..pfad.." > "..answer)  -- Request‑Parsen (nur nach GET)
      sck:send(create(answer))
   else
      print('receive '..pfad)  -- Request‑Parsen (nur nach GET)
      sck:send(create(body2))
   end
   --      sck:send(resp)
   --
   --   if payload:find("GET "..sm) then
   --      local resp = create(fetch(pfad))
   --      sck:send(resp)
   --   else
   --      local resp = create(body2)
   --      sck:send(resp)
   --   end
   --   print('send')
end

local function init()
   if not srv then srv=net.createServer(net.TCP,30) end
   srv:listen(80,function(socket)
      socket:on("receive", receiver )
      socket:on("sent", function(sck) --[[print('sent')--]] sck:close() end)
   end )
   print("HTTP server running on port 80")
end

local function setData(data)
end

local function setBody(body)
end

M.init=init
M.create=create
M.body=body1
M.srv=srv
M.setBody=setBody
M.setData=setData
-- usage: M.init()
return M
