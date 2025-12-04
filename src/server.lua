-- server für smartmeter-daten
local M={}
local sm    ='/smartmeter'
--local icon  ='/favicon'
local body1 ='{\"'..sm..'":"heap","2025-12-01",3,4,5,6,7,8,9,10}'
local body2 ="<html><body><h1>NodeMCU</h1><p>Use "..sm.."</p></body></html>"
local srv

local function create(b)
   return "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: "..#b.."\r\n\r\n"..b
end

local function fetch(pfad)
   if pfad then
      if pfad:find(sm.."/heap") then return '{"Heap":'..node.heap()..'}' end
      if pfad:find(sm) then return body1 end
      --      if pfad:find(icon) then return nil end -- nicht unterstützt
   end
   return body2
end

local function receiver(sck, payload)
   local pfad=payload:match("GET (/[%w/]*)")   -- pfad
   payload=nil
   local answer=fetch(pfad)
   sck:send(create(answer))
   if answer==body2 then answer="" end
   print('receive '..pfad.." > "..answer)
   pfad=nil
end

local function init()
   if not srv then srv=net.createServer(net.TCP,30) end
   srv:listen(80,function(socket)
      socket:on("receive", receiver )
      socket:on("sent", function(sck) sck:close() sck=nil end)
   end )
   print("HTTP server running on port 80")
end

--local function setData(data)
--end
--
--local function setBody(body)
--end

M.init=init
--M.create=create
--M.body=body1
M.srv=srv
--M.setBody=setBody
--M.setData=setData
-- usage: M.init()
return M
