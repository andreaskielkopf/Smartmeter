-- ringbuffer für Analyse von Dauer und Pegel des IR-Signals
-- IR ein sind positive Zahlen
-- IR aus sind negative Zahlen
do
   print 'ring r02'
   ver[#ver+1]= "r02"
   M= {}
   local buf= {} -- tabelle für den Ringtbuffer mit den Zeiten
   local inp,out,max,overflow,overrun -- zeiger und anderes
   
   -- trägt die Zahl im Ringpuffer ein
   local function push(wert) -- if inp >= out+max then overflow=true end
      buf[inp%max+1]= wert inp= inp+1 end -- ablegen, increment zeiger   
   
   -- init
   local function init()
      print 'init ring'
      inp,out,max, overflow,overrun= 0,0,500, false,false
      for i=1,max do buf[i]= i end end-- init array
   
   -- holt eine Zahl aus dem Puffer oder nil
   local function pop()
      if inp<=out then return -- es sind keine daten da
      elseif inp>out+max then out= inp-max return 'overflow' -- reset ring, Überlauf signalisieren
      else local erg= buf[out%max+1] out= out+1 return erg end end -- holen, increment zeiger
      
   -- eigener Iterator
   local function ipop()
      local i= 0
      return function()
         i= i+1 local v= pop() --keys[i]
         if v then return i, v end -- iterator beenden
      end end
      
   -- holt eine komplette textzeile mit bis zu 100 Zeiten ab
   local function get()
      local tmp= {'leer'}
      for k,v in ipop() do tmp[k]= v end
      return table.concat(tmp,',') end

   init()
   M.push=push
   M.pop=pop
   M.get=get
   print 'end ring'
   return M
end
