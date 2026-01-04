-- Teste beim Boot ob PinBoot auf Masse liegt
do
   local pinBoot ,levelBoot= 1, gpio.LOW -- Testen auf Verbindung zu Masse pinBoot:1,2,5,6,7
   gpio.mode(pinBoot, gpio.INPUT, gpio.PULLUP) -- Als Input mit internem pullup (20kOhm)
   print(table.concat({'boot Test D', pinBoot, '==', levelBoot, ' ? '}))
   local boot= gpio.read(pinBoot)
   gpio.mode(pinBoot, gpio.INPUT, gpio.FLOAT) -- Pullup abschalten um Strom zu sparen
   if boot then
      boot= nil -- brauchen wir nicht mehr
      print 'boot OK'
      node.flashindex("_init")() -- LFS aktivieren
      require 'start' -- start.lua oder start.lc starten
   else
      print 'kein auto-boot, bitte manuell starten'
   end
end
