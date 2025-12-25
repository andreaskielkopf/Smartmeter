-- Eine Interne Uhr auf dem laufenden halten

jetzt={} -- globale zeittabelle anlegen
-- jetzt.heute  string 2025-12-01
-- jetzt.stunde int
-- jetzt.minute int
-- jetzt.unix   unix time in sekunden
do
   print "load zeit"
   local M={}

   local function dateTable(sec) -- unix-Zeit in Tabelle umwandeln
      sec=sec or rtctime.get()-- if not sec then sec, usec, rate=rtctime.get() end
      local d=rtctime.epoch2cal(sec)
      d.unix=sec -- tabelle ergänzen um unix-timestamp
      return d end

   local function zeit(d) -- Tabelle in Zeitwerte für jetzt umwandeln
      d=d or dateTable() -- if not d then d = dateTable() end
      local heute = string.format("%d-%02d-%02d", d.year,d.mon,d.day)
      local stunde = d.hour
      local minute = d.min
      if minute ~= jetzt.minute and smart then
            smart.next(heute,stunde,minute) -- Minute weiterschalten (neue Werte)
         end
      return { unix=d.unix, heute=heute, stunde=stunde, minute=minute } end

   local was=0 -- letzter unix-timestamp
   local function timeTicker(ti)
      local sec = rtctime.get() -- beachte nur die Änderung der Sekunden
      if sec ~= was then
         was=sec         
         jetzt = zeit(dateTable(sec)) -- global eintragen
      end end

   local function init() -- 4 mal pro Sekunde genauer brauchts nicht sein ???
      sntp.sync(nil,nil,nil,1)
      tmr.create():alarm(250,tmr.ALARM_AUTO,timeTicker)
   end
   -- Init sofort ausführen und nicht exportieren. Das schont den Heap   
   init()
   M.get=zeit
   M.dateTable=dateTable
--   M.jetzt=jetzt
   print "end zeit"
   return M
end
