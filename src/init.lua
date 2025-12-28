-- teste beim boot ob D5 auf Masse liegt
do   
   local pinTest ,levelBoot = 5, 0  -- D5 testen auf Verbindung zu Masse
   gpio.mode(pinTest,gpio.INPUT,gpio.PULLUP) -- Als Input mit internem pullup (20kOhm)
   print (table.concat({'boot Test D',pinTest,'==',levelBoot}))
   if gpio.read(pinTest)==levelBoot then
      print 'boot OK'
      node.flashindex("_init")() -- LFS aktivieren
      require 'start' -- start.lua oder start.lc starten
   else
      print 'kein boot'
   end
end
