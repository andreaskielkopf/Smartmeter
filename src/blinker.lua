-- Behandle den IRQ und lass zur Kontrolle die LED blinken
do
   print 'blinker b0f'
   ver[#ver+1]="b0f"
   local ring=require 'ring'
   local function init()
      local pinGND,pinIR,pinLED,flanke= 2,3,4,"down" -- pinIR:1,2,3,5,6,7 pinGND:0,1,2,3,5,6,7 pinLED:4
      local last,c,dif -- holds last us for ring
      local vier=0x40000000
      local min= 3000 -- 3 ms entspricht 120kW als obere Messgrenze
      -- use pinLED with blue LED to show pulses
      gpio.mode(pinLED, gpio.OUTPUT)
      gpio.write(pinLED, gpio.LOW) -- show LED
      if pinGND then -- Optionaler Pin neben pinIR, der GND bereitstellt
         gpio.mode(pinGND, gpio.OPENDRAIN) -- geschaltte Masse für IR-Transistor
         gpio.write(pinGND, gpio.LOW) -- auf Masse schalten
      end
      if file.exists('flanke_up.flag')   then flanke= 'up' end
      if file.exists('flanke_both.flag') then flanke= 'both' end
      -- use pinIR as the input for pulses
      gpio.mode(pinIR, gpio.INT, gpio.PULLUP) -- internen pullup 20-50 kOhm
      -- gpio.mode(pinIR, gpio.INT, gpio.FLOAT) -- extern pullup 20kOhm

      local function fnIRpuls(level, when, cnt)
         gpio.write(pinLED, gpio.LOW) -- show LED
         if last then dif= when-last while dif<0 do dif= dif+vier end end -- us>0
         if smart and smart.irPuls then
            --         print( tmr.time(),pulsCounter, level, cnt, pulse - lastPulse  )
            if last and dif>=min then smart.irPuls(6,dif/1000) end -- WattMinuten,ms
         end
         if ring and ring.push and last then do
            --            if cnt~=1 then ring.push(':') ring.push(cnt) end
            --               ring.push(level==0 and zeit or -zeit)
            --               ring.push(string.format("%x", when/0x10000))
            if when<last then
               ring.push("---------------------->")
               ring.push(dif/1000)
            end
--            if dif>=min then
--               ring.push(dif/1000) --ms
--            else ring.push(' ') -- 0 ms
--            end
         end end
         last= when
         gpio.write(pinLED, gpio.HIGH) -- hide LED
      end

      gpio.trig(pinIR, flanke, fnIRpuls) -- starte den IRQ
      gpio.write(pinLED, gpio.HIGH) -- hide LED
      print 'init blinker'
   end
   init()
   print 'end blinker'
end
