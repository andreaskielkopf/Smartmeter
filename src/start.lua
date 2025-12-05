-- Auswahl der verschiedenen Funktionen die bereits programmiert wurden
do
   connect=require 'connect' -- Wifi-Verbindung herstellen
   --   connect.init() ist bereits includiert
   --   if not connect then return end -- abbruch
   if connect.gotIP() then -- Das ist zwar aufwändig, spart aber Heap !!!
      print 'unload connect'
      connect=nil -- connect trennen
      package.loaded.connect=nil -- connect unload spart 3k auf dem Heap
   end

   -- Eine extra funktion für main zu verwenden ist aufwändige,
   -- erlaubt es aber nach dem Verbindungsaufbau die Methoden für connect wieder zu entladen
   -- Das entlastet den Heap erheblich
   local function main()
      print 'lade zeit'
      zeit=require 'zeit' -- init() included
      print 'lade server'
      server=require 'server' -- server aufsetzen init() included
      --      if util then util.print3d(jetzt) end
      print "Hallo Albershausen"
   end
   print ('starte main',connect)
   -- wenn connect noch geladen ist, warte 30 Sekunden bis die Verbindung steht
   if connect then connect.runLater(main,30) else main() end -- sonst sofort starten
end
