-- wifi initialisiren, so dass ein server gestartet werden kann
do
   local M={}

   local function gotIP() -- ist eine Verbindung da, und eine IP auch
      return wifi.sta.status() == wifi.STA_GOTIP end

   local function printStatus() -- Zeigde die Daten der Verbindung an (wenn möglich)
      if not gotIP() then return false end
      local cfg=wifi.sta.getconfig(true)
      if cfg then
         print ("\tStation config")
         print ("\tssid    :", cfg.ssid)
         print ("\tpassword:", cfg.pwd)
         print ("\tbssid   :", cfg.bssid)
         cfg=nil
      end
      print ("\tVerbunden mit ", wifi.sta.getip())
      return true end

   local eus=nil
   local function eusRead() -- lade die Verbindungsdaten aus dem Dateisystem
      local eus_file='eus_params.lua'
      if file.exists(eus_file) then
         if not eus then
            print ('read file ' , eus_file)
            eus=dofile(eus_file) -- Callbacks definieren
            eus.connected_cb       = function() print "Wifi connected"    end
            eus.disconnected_cb    = function() print "Connection lost"   end
            eus.got_ip_cb          = function() print "IP erhalten "      end
            eus.authmode_change_cb = function() print "Auth mode changed" end
            eus.dhcp_timeout       = function() print "DHCP timeout"      end
         end
         return eus end
      return nil end

   local function init() -- stelle die Verbindung her, wenn nicht schon da
      if not printStatus() then
         eus=eusRead() -- Verbindungsdaten laden
         if eus then
            wifi.sta.config(eus)-- verbinden
            return printStatus()-- tailcall
         end end
   return false end

   local function runLater(main,retries) -- starte main, sobald die Verbindung steht
      if gotIP() then return main() end -- tailcall
      local retries=retries or 30 -- default sind 30 Sekunden
      tmr.create():alarm(1000,tmr.ALARM_AUTO, function (t)
         if not gotIP() and retries > 0 then
            print ("Warte ", retries, " auf Wlan")
            retries=retries-1
            return -- ein weiteres mal versuchen
         end
         t:stop() t:unregister() -- t=nil ???
         retries=nil
         if printStatus() then
            return main() -- Weiter im Hauptprogramm
         else
            print ("Timeout: Verbindung fehlgeschlagen")
            -- Fehlerbehandlung  in 5 Minuten erneut ?
            -- print ("Programm wird beendet")
            return false
         end end ) end

   init()
   -- if not gotIP() then init() end
   -- um den Heap zu schonen wird init sofort ausgeführt, und nicht exportiert
   -- Das hat ca. 2k Heap gespart !!!
   -- M.init=init
   M.gotIP=gotIP
   M.runLater=runLater
   -- usage:
   -- runLater(function() print "Hallo Albershausen" end, 15)
   -- runLater(main)
   -- if gotIP() then main() else runLater(main, 20) end
   return M
end

