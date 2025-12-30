-- Behandle den IRQ und lass zur Kontrolle die LED blinken
do
   print 'load blinker'
   --   local ring=require 'ring'
   local function init()
      local pinIR,pinNext,pinLED,flanke = 7,6,4,"down"
      --      local last=0 -- last holds last us
      if file.exists('flanke_up.flag') then flanke='up' end
      if file.exists('flanke_both.flag') then flanke='both' end
      -- use pinLED D4 with blue LED to show pulses
      gpio.mode(pinLED, gpio.OUTPUT) gpio.write(pinLED, gpio.LOW)
      gpio.write(pinLED, 0) -- show LED
      -- use pinIR D7 as the input for pulses
      gpio.mode(pinIR,gpio.INT,gpio.PULLUP) -- internen pullup 20-50 kOhm
      --      gpio.mode(pinIR,gpio.INT,gpio.FLOAT) -- extern pullup 20kOhm
      gpio.mode(pinNext,gpio.OPENDRAIN) -- extern geschaltte Masse
      gpio.write(pinNext, 0) -- auf Masse schalten

      local function fnIRpuls(level, when, cnt)
         gpio.write(pinLED, 0) -- show LED
         if smart and smart.irPuls then
            --         print( tmr.time(),pulsCounter, level, cnt, pulse - lastPulse  )
            smart.irPuls(cnt)
         end
         --         if ring and ring.push then do
         --            local zeit
         --               if cnt~=1 then ring.push('overrun') ring.push( cnt) end
         --               local zeit=when-last
         --               last=when
         --               ring.push(level==0 and zeit or -zeit)
         --            end end
         gpio.write(pinLED, 1) -- hide LED
      end
      gpio.trig(pinIR, flanke, fnIRpuls) -- starte den IRQ
      gpio.write(pinLED, 1) -- hide LED
      print 'init blinker'
   end
   init()
   print 'end blinker'
end
