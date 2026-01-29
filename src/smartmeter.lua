do
   print "load smartmeter"
   local M= {}
   local hour_= require 'hour'
   local day_= require 'day'
   local util_= require 'util'
   --   local ring= require 'ring'
   local stunde,nr,nr_c
   --   local function test() print '' hour_.test() day_.test() end

   -- Datensatz für heute vorbereiten und stunde laden, dann IRQ aktivieren
   local function init(tag_, stunde_)
      print ("smartmeter init", tag_, stunde_)
      local tag = day_.create(tag_)
      --      print (table.concat(day_.toLua(tag),'\n'))
      stunde = hour_.get(tag_,stunde_)
      --      print (hour_.toLua(stunde))
      --      test()
      require 'blinker' -- lade den IRQ für den sensor und starte damit den IRQ
      --      if ring and ring.init then ring.init() end
   end

   -- Nach jeder Minute den Zeiger für den IRQ weitersetzen
   local function nextMin(tag_neu, stunde_neu, minute_neu)
      if jetzt and jetzt.heute then
         if not stunde then init(tag_neu, stunde_neu) end
         local tag_alt, stunde_alt, minute_alt= jetzt.heute, jetzt.stunde, jetzt.minute
         --         print(table.concat({'jetzt ist ',tag_neu,"(",stunde_neu,":",minute_neu,')'}))
         --         print ('min:', node.heap())
         --         print('>',stunde,stunde_alt,stunde_neu,tag_alt)
         if stunde_alt~=stunde_neu then
            hour_.append(tag_alt, stunde) -- stunde speichern
            jetzt.stunde= stunde_neu
            if tag_alt~=tag_neu then -- tag anpassen
               day_.create(tag_neu) -- day_.compile(tag_alt)
               jetzt.heute= tag_neu
            end
            stunde= hour_.get(tag_neu, stunde_neu) -- neue stunde vorbereiten
         end
         if nr~=minute_neu+1 then nr= minute_neu+1 nr_c= true end -- pointer für den IRQ anpassen
         if tag_alt~=tag_neu then util_.clean() end -- cleanup am ende des tages
      end end

   -- Die Daten vom IRQ entgegennehmen und in die aktuelle stunde eintragen
   local function irPuls(cnt,when,last) -- print ('irPuls',stunde,nr,q)
      if stunde and type(stunde[2])=='table' then
         cnt= cnt*6 -- umrechnung in WattMinuten
         local t,i,j= stunde[2],nr,nr_c -- nr ist der globale Zeiger auf die aktuelle minute
         if j then nr_c=false end -- sofort rücksetzen
         if i then
         -- IRGENDOW hier ist ein gravierender Rechenfehler ;-)
            --            if i>1 and j and last then -- mit Abgleich
            --               local ms_d= (when-last+500)/1000 -- Millisekunden Abstand (Überlauf möglich)
            --               ms_d= ms_d>0 and ms_d or 1 -- Division durch 0 verhindern
            --               local uts,us= rtctime.get()
            --               local cal= rtctime.epoch2cal(uts)
            --               local s= cal.sec
            --               local ms_2= 1000*s+ (us/1000) -- Millisekunden in der neuen Minute
            --               local c2= (cnt*ms_2)/ms_d -- Anteile in der neuen Minute
            --               c2= c2>cnt and cnt or c2
            --               c2= c2<0 and 0 or c2 -- bei Überlauf von ms_d
            --               local c1= cnt-c2
            --               t[i-1]= t[i-1] and t[i-1]+c1 or c1
            --               t[i]=   t[i]   and t[i]+c2   or c2
            --               print('irPuls:',c1,c2,ms_d-ms_2,ms_2)
            --            else -- ohne Abgleich
            t[i]=   t[i]   and t[i]+cnt or cnt
            --            end
            --            print('sum=',i,stunde[2],#stunde[2],t,t[i])
         end
   end end

   -- Angefragte Daten an den Webserver liefern
   local function data(anfrage) -- anfrage ist der angefragte text
      if type(anfrage)=='string' then -- 2025/12/01/xx
         local tmp= {}
         for c in anfrage:gmatch("[0-9]+") do tmp[#tmp+1]= c end
         local x
         if #tmp>0 then
            x= table.concat(tmp, '-', 1, #tmp>3 and 3 or #tmp)
         end -- print (datum)
         if #tmp==1 or #tmp==2 then -- anfrage 2025 Liste Monate oder Tage
            -- "2025"={01,02,03,05,06,07,12} Monate im Jahr 2025
            -- "2025-04"={12,17,22,23,24,30,31} Tage im Monat April 2025
            return table.concat({'{"filter":"', x, '", "found":[', table.concat(util_.welche(tmp), ','), ']}'})
         elseif #tmp==3 then -- anfrage 2025/12/01 Der ganzze tag
            -- "2025-12-01"={1,2,7,8,14,22} Stunden am 1.12.2025
            return table.concat({'{"date":"', x, '", "hours":[', table.concat(day_.stunden(x), ','), ']}'})
         elseif #tmp==4 then -- anfrage 2025/12/01/xx nach einer bestimmten Stunde
            -- 2025-12-01-xx Messwerte pro Minute in dieser Stunde (bis zu 60 Messwerte)
            local uhr= tmp[4]+0 -- in number umwandeln
            if type(uhr)=='number' then
               local h= hour_.get(x, uhr)
               if h then return hour_.toJson(h)
               else      return 'nicht gefunden'
               end end
         elseif #tmp==0 then do
            if stunde then -- sonst immer die aktuelle Stunde              --               print ("datum",datum)
               return hour_.toJson(stunde)
            else
               return 'Es sind noch keine Daten vorhanden'
            end end end end
   return table.concat({anfrage, '   ???   '}, '\n') end

   M.data= data
   M.init= init
   M.next= nextMin
   M.stunde= stunde
   M.irPuls= irPuls
   print "end smartmeter"
   return M
end
