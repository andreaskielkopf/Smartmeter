-- Auswahl der verschiedenen Funktionen die bereits programmiert wurden
do
   node.flashindex("_init")() -- LFS
   update= require 'updateLFS' -- globale funktion update aufrufen
   connect= require 'connect' -- Wifi-Verbindung herstellen
   if connect.gotIP() then -- Das ist zwar aufwändig, spart aber Heap !!!
      print 'unload connect' 
      connect= nil -- connect entfernen fals die Verbindung schon steht
      package.loaded.connect= nil -- connect unload spart 3k auf dem Heap
   end
   require 'util' 
   -- Eine extra funktion für main zu verwenden ist aufwändige,
   -- erlaubt es aber nach dem Verbindungsaufbau die Methoden für connect wieder zu entladen
   -- Das entlastet den Heap erheblich
   local function main()
      zeit= require 'zeit' -- init() included Verbindung mit dem Zeitserver (für Timestamps notwendig)
      server= require 'server' -- HTTP Server aufsetzen init() included
      --      print 'load telnet'
      --      telnet=require 'telnet' -- global telnet anlegen
      --      print 'end telnet'
      --      if telnet then
      --         telnet:open(nil,nil,2323)
      --         print 'started telnet'
      --      end
      print 'load ftpserver' 
      FTP= require 'ftpserver' 
      print 'end ftpserver'-- global FTP anlegen
      if FTP then
         FTP:createServer('smart','meter') -- FTP-Server starten mit User "smart" und Passwort "meter"
         print 'started FTP'
      end
      smart= require 'smartmeter' -- globaler Zugriff auf smart sobald es geladen ist !!!
      print "Hallo Albershausen"
   end
   print('starte main', connect) -- wenn connect noch geladen ist, warte 30 Sekunden bis die Verbindung steht
   if connect then connect.runLater(main, 30) else main() end -- sonst sofort starten
   -- Jetzt ist Alles gestartet und läuft im Hintergrund. damit sind wir fertig.
end
