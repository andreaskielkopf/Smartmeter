-- Auswahl der verschiedenen Funktionen die bereits programmiert wurden
do
   --   print ('doing start.lua')
   --   local function call(f)
   --      print ('dofile(' .. f ..')')
   --      if file.exists(f..'.lc')  or file.exists(f..'.lua') then
   --         return require (fname)
   --      else
   --         print(f2.. " not found")
   --         f2=nil
   --         return nil
   --      end
   --   end
   connect=require 'connect' -- Wifi-Verbindung herstellen
   if not connect then return end -- abbruch
   --   util=call 'util'
   zeit=require 'zeit'
   server=require 'server' -- server aufsetzen
   connect.init() connect.run( function()
      if not server then return end -- abbruch
      zeit.init()
      server.init()
      --      if util then util.print3d(jetzt) end
      print "Hallo Albershausen"
   end )
   --for k,v in pairs(_G) do print(k.." = "..v) end

   --   call('wifi.lua')
   -- if file.exists('smart_count.lua') then dofile('smart_count.lua') end
   -- if file.exists('blinker.lua') then dofile('blinker.lua') end
   -- if file.exists('blinker.lua') then dofile('blinker.lua') end
   -- if file.exists('blinker.lua') then dofile('blinker.lua') end
   -- if file.exists('blinker.lua') then dofile('blinker.lua') end
end
