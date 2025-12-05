-- Eine Interne Uhr auf dem laufenden halten
jetzt={} -- globale zeittabelle anlegen
do
   local M={}

   local function dateTable(sec) -- unix-Zeit in Tabelle umwandeln
      sec=sec or rtctime.get()-- if not sec then sec, usec, rate=rtctime.get() end
      local tb=rtctime.epoch2cal(sec)
      tb.unix=sec -- tabelle ergänzen um unix-timestamp
      return tb end  

   local function zeit(d) -- Tabelle in Zeitwerte für jetzt umwandeln
      d=d or dateTable() -- if not d then d = dateTable() end
      local heute = string.format("%d-%02d-%02d", d.year,d.mon,d.day)
      local stunde = d.hour
      local minute = d.min
      if minute ~= jetzt.minute then
         --         local t={'heute ist ',heute,"(",stunde,":",minute,')'}
         --         print(table.concat(t))
         print(table.concat({'heute ist ',heute,"(",stunde,":",minute,')'}))
      end
      return { unix=d.unix, heute=heute, stunde=stunde, minute=minute }
   end

   local was=0
   local function timeTicker(ti)
      local sec = rtctime.get() -- beachte nur die Änderung der Sekunden
      if sec == was then return end
      local t=dateTable(sec)
      jetzt = zeit(t) -- global eintragen
   end
  
   local function init() -- einmal pro Sekunde genauer brauchts nicht sein
      sntp.sync(nil,nil,nil,1)
      tmr.create():alarm(1000,tmr.ALARM_AUTO,timeTicker)
   end

   -- Init sofort ausführen und nicht exportieren. Das schont den Heap
   -- M.init=init
   init()
   M.get=zeit
   M.dateTable=dateTable
   M.jetzt=jetzt
   --M.jetzt=jetzt
   return M
end
