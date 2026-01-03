-- Eine Interne Uhr auf dem laufenden halten
do
   print "load zeit"
   local M= {}
   jetzt= {} -- globale zeittabelle anlegen
   -- jetzt.heute  string 2025-12-01
   -- jetzt.stunde int
   -- jetzt.minute int
   -- jetzt.unix   unix time in sekunden

   -- unix-Zeit in Tabelle umwandeln
   local function dateTable(sec)
      sec= sec or rtctime.get()-- if not sec then sec, usec, rate=rtctime.get() end
      local d= rtctime.epoch2cal(sec)
      d.unix= sec -- tabelle ergänzen um unix-timestamp
      return d end

   -- Tabelle in Zeitwerte für "jetzt" umwandeln
   local function zeit(d)
      d= d or dateTable() -- if not d then d = dateTable() end
      local heute= string.format("%d-%02d-%02d", d.year, d.mon, d.day)
      local stunde= d.hour
      local minute= d.min
      if minute~=jetzt.minute and smart then -- wenn das smartmeter bereits geladen ist
         smart.next(heute, stunde, minute) -- Minute weiterschalten (neue Werte in next index erfassen)
      end
      return {unix= d.unix, heute= heute, stunde= stunde, minute= minute} end

   local was= 0 -- letzter unix-timestamp
   -- timeticker (IRQ)
   local function timeTicker(ti)
      local sec= rtctime.get() -- beachte nur die Änderung der Sekunden
      if sec~=was then -- jede neue Sekunde verarbeiten
         was= sec
         jetzt= zeit(dateTable(sec)) -- global eintragen
      end end

   -- 4 mal pro Sekunde genauer brauchts nicht sein ???
   local function init()
      sntp.sync(nil, nil, nil, 1) -- Zeit aus dem Netzwerk holen (SNTP)
      tmr.create():alarm(250, tmr.ALARM_AUTO, timeTicker) -- alle 250 ms den IRQ aufrufen
      -- Damit ist die Abrechnung der Minuten auf +/- 250ms genau (4 Promille)
   end

   -- Init sofort ausführen und nicht exportieren. Das schont den Heap
   init() -- SNTP aktivieren
   M.get= zeit
   --   M.dateTable=dateTable -- nur lokal genutzt
   print "end zeit"
   return M
end
