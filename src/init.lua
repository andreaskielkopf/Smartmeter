-- teste beim boot ob D5 auf Masse liegt
do   
   local pinBoot ,levelBoot = 1, 0  -- D5 testen auf Verbindung zu Masse pinTest:1,2,5,6,7
   gpio.mode(pinBoot,gpio.INPUT,gpio.PULLUP) -- Als Input mit internem pullup (20kOhm)
   print (table.concat({'boot Test D',pinBoot,'==',levelBoot,' ? '}))
   if gpio.read(pinBoot)==levelBoot then
      print 'boot OK'      
      node.flashindex("_init")() -- LFS aktivieren
      require 'start' -- start.lua oder start.lc starten
   else
      print 'kein boot'
   end
end
