-- server für smartmeter-daten
local M={}
local sm    ='/smartmeter'
local body1 ="{\"Testdaten\":1,2,3,4,5,6,7,8,9,10}"
local body2 ="<html><body><h1>NodeMCU</h1><p>Use "..sm.."</p></body></html>"
local srv

local function create(b)
   local r = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: "..#b.."\r\n\r\n"..b
   return r
end

local function receiver(sck, payload)
   -- Request‑Parsen (nur nach GET)
   print('receive')
   if string.find(payload, "GET "..sm) then
      print('get')
      local resp = create(body1)
      sck:send(resp)
   else
      local resp = create(body2)
      sck:send(resp)
   end
   print('send')
end

local function init()
   if not srv then srv=net.createServer(net.TCP,30) end
   srv:listen(80,function(socket)
      socket:on("receive", receiver )
      socket:on("sent", function(sck) print('sent') sck:close() end)
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
