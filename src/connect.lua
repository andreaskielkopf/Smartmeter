-- wifi initialisiwen, so dass ein server gestartet werden kann

local M = {}

local function printStatus()
   local status=wifi.sta.status()
   if status == wifi.STA_GOTIP then
      local cfg=wifi.sta.getconfig(true)
      if cfg then
         print ("\tStation config")
         print ("\tssid    :" .. cfg.ssid)
         print ("\tpassword:" .. cfg.pwd)
         print ("\tbssid   :" .. cfg.bssid)
         cfg=nil
      end
      print ("\tVerbunden mit " .. wifi.sta.getip())
      return true -- status
   else
      return false -- or nil ???
   end
end

local eus=nil
local eus_file='eus_params.lua'
local function eusRead()
   if file.exists(eus_file) then
      if not eus then
         print ('read file ' .. eus_file)
         eus = dofile(eus_file) -- Callbacks definieren
         eus.connected_cb       = function() print "Wifi connected"    end
         eus.disconnected_cb    = function() print "Connection lost"   end
         eus.got_ip_cb          = function() print "IP erhalten "      end
         eus.authmode_change_cb = function() print "Auth mode changed" end
         eus.dhcp_timeout       = function() print "DHCP timeout"      end
      end
      return eus end
   return nil
end

local function init()
   if not printStatus() then
      eus= eusRead()
      if eus then         --         print 'init Connection'
         wifi.sta.config(eus)
         return printStatus() end
   end
end

-- local function eu_store_wifi() end
--[[ local function eu_Setup()
      print "eu_Setup"
      erg= enduser_setup.start(
         'Smartmeter',
         function()
            print("Connected to WiFi as:" .. wifi.sta.getip())
            -- store_wifi()
         end,
         function(err, str)
            print("enduser_setup: Err #" .. err .. ": " .. str)
         end,
         function(str)
            print ('ERR:' .. str)
         end
      -- print("nix") -- Lua print function can serve as the debug callback),
      )
      print ("erg:")
      print (erg)
   end --]]
-- if not file.exists('eus_params.lua') then
--erg = eu_Setup()
-- end
-- Config laden und automatisch verbinden
-- funktion um das Hauptprogramm nur zu starten, wenn wifi verbunden werden kann

local function runOnCon(main)
   local retries=30
   tmr.create():alarm(500,tmr.ALARM_AUTO, function (t)
      local status= printStatus() -- dokumentieren
      if not status then
         if retries > 0 then
            print ("Warte "..retries.." auf Wlan")
            retries=retries-1
            return
         end end
      t:stop()
      t:unregister()
      retries=nil
      if status then
         status=nil
         main() -- Weiter im Hauptprogramm
      else
         print ("Timeout: Verbindung fehlgeschlagen ")
         -- Fehlerbehandlung  in 5 Minuten erneut ?--
         --         print ("Programm wird beendet")
      end end ) end

--local function runOnConnection(main)
--   local retries=20
--   tmr.create():alarm(500,tmr.ALARM_AUTO,
--      function(ti)
--         status=wifi.sta.status()
--         if status == wifi.STA_GOTIP then
--            ti:stop()
--            ti:unregister()
--            local cfg=wifi.sta.getconfig(true)
--            if cfg then
--               print ("\tCurrent station config")
--               print ("\tssid    :" .. cfg.ssid)
--               print ("\tpassword:" .. cfg.pwd)
--               print ("\tbssid   :" .. cfg.bssid)
--            end
--            print ("\tVerbunden mit " .. wifi.sta.getip())
--            main() -- Weiter im Hauptprogramm
--         else
--            if retries <= 0 then
--               print ("Timeout: Verbindung fehlgeschlagen ")
--               ti:stop()
--               ti:unregister()
--               -- Fehlerbehandlung  in 5 Minuten erneut ?--
--               print ("Programm wird beendet")
--            else
--               print ("Warte auf Wlan " .. status .. " noch " .. retries)
--               retries=retries-1
--            end
--         end
--      end
--   )
--end

--M.eus=eus
--M.printStatus=printStatus
--M.eusRead=eusRead
M.init=init
M.run=runOnCon
-- usage: M.init() M.run( function() print "Hallo Albershausen" end )
return M
