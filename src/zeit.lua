local M={}

local function dateTable(sec) -- unix-Zeit in Tabelle umwandeln
   if not sec then sec, usec, rate=rtctime.get() end
   local tb=rtctime.epoch2cal(sec)
   tb.unix=sec
   --   print("Sec=" .. sec)
   return tb end

jetzt={} -- globale zeittabelle
--local function heuteIst()
--   return 'heute ist '..jetzt.heute..string.format("(%02d:%02d)",jetzt.stunde,jetzt.minute)
--end

local function zeit(d) --Tabelle in Zeitwerte für jetzt umwandeln
   if not d then d = dateTable() end
   local heute = string.format("%d-%02d-%02d", d.year,d.mon,d.day)
   local stunde = d.hour
   local minute = d.min
   if minute ~= jetzt.minute then      --      print (heuteIst())
      print ('heute ist '..heute.."("..stunde..":"..minute..')')
   end
   return { unix=d.unix, heute=heute, stunde=stunde, minute=minute }
end


local was=0
local function timeTicker(ti)
   local sec = rtctime.get() -- beachte nur die Änderung der Sekunden
   if sec == was then return end
   local t=dateTable(now)
   --   if t.minute == jetzt.minute then return end
   jetzt = zeit(t) -- global eintragen
   --   util.print3d(jetzt)
end
-- einmal pro Sekunde genauer brauchts nicht sein
local function init()
   sntp.sync(nil,nil,nil,1)
   tmr.create():alarm(1000,tmr.ALARM_AUTO,timeTicker)
end
--printT3d(d)

M.init=init
M.get=zeit
M.dateTable=dateTable
--M.jetzt=jetzt
return M
