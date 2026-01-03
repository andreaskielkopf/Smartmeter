-- Teste beim Boot ob PinBoot auf Masse liegt
do
   local pinBoot ,levelBoot= 1, gpio.LOW -- Testen auf Verbindung zu Masse pinBoot:1,2,5,6,7
   gpio.mode(pinBoot, gpio.INPUT, gpio.PULLUP) -- Als Input mit internem pullup (20kOhm)
   print(table.concat({'boot Test D', pinBoot, '==', levelBoot, ' ? '}))
   if gpio.read(pinBoot)==levelBoot then
      print 'boot OK'
      node.flashindex("_init")() -- LFS aktivieren
      require 'start' -- start.lua oder start.lc starten
   else
      print 'kein boot'
   end
end
