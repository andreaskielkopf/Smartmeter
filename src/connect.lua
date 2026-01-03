-- wifi initialisiren, so dass ein server gestartet werden kann
do
   print 'load connect'
   local M= {}
   local util_= require 'util'

   -- ist eine Verbindung da, und eine IP auch
   local function gotIP()
      return wifi.sta.status()==wifi.STA_GOTIP end

   -- Zeige die Daten der Verbindung an (wenn möglich)
   local function printStatus()
      if not gotIP() then return false end
      local cfg= wifi.sta.getconfig(true)
      if cfg then
         print("\tStation config")
         print("\tssid    :", cfg.ssid)
         print("\tpassword:", cfg.pwd)
         print("\tbssid   :", cfg.bssid)
      end
      print("\tVerbunden mit ", wifi.sta.getip())
      return true end

   local eus= nil
   -- lade die Verbindungsdaten aus dem Dateisystem
   local function eusRead()
      local eus_file= util_.fName('eus_params')
      if eus_file then
         if not eus then
            print('read file ', eus_file)
            eus= dofile(eus_file) -- Callbacks definieren
            eus.connected_cb      = function() print "Wifi connected"    end
            eus.disconnected_cb   = function() print "Connection lost"   end
            eus.got_ip_cb         = function() print "IP erhalten "      end
            eus.authmode_change_cb= function() print "Auth mode changed" end
            eus.dhcp_timeout      = function() print "DHCP timeout"      end
         end return eus
      end return nil end

   -- stelle die Verbindung her, wenn nicht schon da
   local function init()
      if not printStatus() then eus= eusRead() -- Verbindungsdaten laden
         if eus then
            print 'config wifi'
            wifi.sta.config(eus) -- verbinden
            wifi.setmode(wifi.STATION)
            return printStatus() -- tailcall
      end end
      return false end

   -- starte main, sobald die Verbindung steht
   local function runLater(main, retries) 
      if gotIP() then return main() end -- tailcall
      local retries= retries or 30 -- default sind 30 Sekunden
      tmr.create():alarm(1000, tmr.ALARM_AUTO, function (t)
         if not gotIP() and retries>0 then
            print ("Warte ", retries, " auf Wlan")
            retries= retries-1
            return -- ein weiteres mal versuchen
         end
         t:stop() t:unregister() -- t=nil ???
         retries= nil
         if printStatus() then
            return main() -- Weiter im Hauptprogramm
         else
            print ("Timeout: Verbindung fehlgeschlagen")
            -- Fehlerbehandlung  in 5 Minuten erneut ?
            -- print ("Programm wird beendet")
            return false
         end end ) end

   init()
   -- um den Heap zu schonen wird init sofort ausgeführt, und nicht exportiert
   -- Das hat ca. 2k Heap gespart !!!   
   M.gotIP= gotIP
   M.runLater= runLater
   -- usage:
   -- runLater(function() print "Hallo Albershausen" end, 15)
   -- runLater(main)
   -- if gotIP() then main() else runLater(main, 20) end
   print 'end connect'
   return M
end

