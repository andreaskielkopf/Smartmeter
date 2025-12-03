-- Auswahl der verschiedenen Funktionen die bereits programmiert wurden
do
   print ('doing start.lua')
   local function call(fname)
      print ('dofile(' .. fname .. '.lua)')
      if file.exists(fname..'.lua') then         --         dofile(fname)
         return require (fname)
      else
         print(fname .. ".lua not found")
         return nil
      end
   end
   --   print 'bme280, bme280_math, dht, enduser_setup, file, gpio, mdns, net, node, ow, rtctime, sjson, sntp, tmr, uart, ucg, wifi'
   connect=call 'connect' -- Wifi-Verbindung herstellen
   if not connect then return end -- abbruch
   util=call 'util'
   zeit=call 'zeit'
   server=call 'server' -- server aufsetzen
   connect.init() connect.run( function()
      if not server then return end -- abbruch
      zeit.init()
      server.init()
      util.print3d(jetzt)
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
