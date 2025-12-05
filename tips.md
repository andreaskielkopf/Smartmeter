# Tips

### z= "Hallo" .. " " .. "Welt" print(z)
Lua kann strings zwar auf diese Art zusammenfügen. Das führt aber oft zu Abstürzen
#### Besser ist:
```
local z={"Hallo"," Welt"}
z=table.concat(z)
print(z)
z=nil
```
#### oder besser gleich
```
print( table.concat( {"Hallo","Welt"}, " ")
```

## init sofort ausführen
Anstatt die init() mit dem Modul zu exportieren und aus dem Hauptprogramm aufzurufen, kann man die jeweilige init() auch direkt beim laden des Moduls ausführen, und nicht exportieren.
```
do
	M={}
	local function init()
	..
	end
	
   -- Init sofort ausführen und nicht exportieren.
   --   M.init=init
   init()
   return M
end
```
Das hat den Vorteil, dass die init() nur einmalig ausgeführt wird (beim reqire()). Danach wird die Methode nicht weiter gespeichert. Alle damit verbundenen Recourcen werden freigegeben. Das betrifft auch lokale Funktionen und variablen die nur von init verwendet werden. In diesem Fall hat das **mehrere kiloByte** gebracht

## Module entladen
Wenn ein Modul nur einmalig verwendet wird um z.B. die Verbindung zum wifi aufzubauen, kann es nach erfolgreicher Nutzung komplett entladen werden. 
Das gibt ALLE Resourcen des Moduls frei. Insbesondere der **Heap** profitiert davon stark .

Beispiel:
```
 connect=require 'connect'   -- Wifi-Verbindung herstellen
   --   connect.init() ist bereits includiert
   if connect.gotIP() then -- Das ist zwar aufwändig, spart aber Heap !!!
      connect=nil -- connect trennen
      package.loaded.connect=nil -- connect unload spart 3k auf dem Heap
   end
```
In diesem Fall hat das **3 kByte** auf dem Heap freigegeben
 
## Modul mit *do - end* eingrenzen
Das umklammern des Moduls mit do - end sichert ab, dass alle lokalen variablen nicht versehentlich im scope bleiben (ins Hauptprogramm wandern) Das hilft den Heap sauber zu halten
```
do 
	M={}	
	...
	return M
end
```