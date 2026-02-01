# Kompression
Im Dateisystem der NodeMcu ist nur wenig Platz. 
## Ziele:
* so viel Daten wie möglich lokal zwischenspeichern
* möglichst mehr als 1 Monat
* Datenabruf per HTTP
* Überlauf des Dateisystems verhindern
* Datenabruf auch per FTP
* geregeltes Update über FTP

## HTTP
Der Datenabruf erfolgt per HTTP GET. Im folgenden werden die unterstützten URLs aufgelistet. Es muss natürlich jeweils die **IP-Adresse** des Smartmeter vorgestellt werden. also z.B. **`192.168.178.57`**
#### /smartmeter
Erkennung als Smartmeter, anzeige einiger GET-kommandos

#### /smartmeter/heap
Zeigt den aktuellen Platz auf dem Heap. 20-30 kByte sind ein guter Wert
```
{"Heap":20944}
```

#### /smartmeter/data
Daten der aktuellen Stunde die noch nicht im Dateisystem abgelegt sind
```
{"Data":
{"hour":17, "ticks":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,495]}
}
```

#### /smartmeter/2026
Liste der Monate für 2026, für die Daten vorliegen
```
{"Data":
{"filter":"2026", "found":[01]}
}
```

#### /smartmeter/2026/01
Liste der Tage im Januar 2026 für die Daten vorliegen
```
{"Data":
{"filter":"2026-01", "found":[01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27]}
}
```
#### /smartmeter/2026/01/26
Liste der Stunden am 26.01.2026 für die Daten vorliegen
```
{"Data":
{"date":"2026-01-27", "hours":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]}
}
```

#### /smartmeter/2026/01/26/16
Daten der Stunde 16 (Achtung die Angabe ist **immer in UTC** und ohne Sommer/Winterzeit) also real 17:00 bis 17:59
```
{"Data":
{"hour":16, "ticks":[73,77,76,74,70,75,71,67,67,66,57,54,50,51,53,51,51,54,51,50,52,54,53,50,52,52,52,51,50,59,56,53,56,53,51,55,57,59,64,67,65,65,64,66,68,63,67,65,66,63,63,67,68,65,65,75,89,94,87,86]}
}%                                                                                    
```

## Update
 Damit das Update per FTP stattfinden kann, wird im Dateisystem 100 kByte Platz freigehalten. Zum Update wird eine neue `smartmeter.img`-Datei ins Dateisystem kopiert die das LFS enthält. Zusätzlich ist eine `update.flag`-Datei erforderlich. 

Das Update wird nach einem **Reboot** geprüft und sofort eingespielt. Dabei gehen aber die Daten der aktuellen Stunde verloren. Der Reboot kann mit dem Knopf auf dem 8266-Modul ausgelöst werden.

Das Update wird auch automatisch um **Mitternacht** geprüft und dann eingespielt. Dabei gehen nur die Daten von wenigen Sekunden verloren. Das ist also **der bevorzugte Weg**. Nach dem Update wird das Flag und das Img gelöscht.

## FTP
Das Dateisystem des Smartmeter ist per FTP erreichbar.
* Username: **`smart`** 
* Passwort:  **`meter`** 

## cleanup
Damit das Dateisystem nicht überläuft, wird um Mitternacht geprüft, ob genug Platz frei ist. Wenn wenoger als 100 kByte frei sind, werden solange fortlaufend die jeweils ältesten Dateien gelöscht bis 100 kByte frei sind.

## Datenformat
### lua
Die erste Version verwendet ein lua-Datenformat

* Vorteil: Im Klartext lesbar, per FTP leicht zu überprüfen
* Nachteil: Für 30 Tage werden ca. 150 kByte Platz verwendet. Bei mir reicht das für ca. 60 Tage
  * 2 Byte -> 0 .. 9
  * 3 Byte -> -9 .. 99
  * 4 Byte -> -99 .. 999
  * 5 Byte -> -999 .. 9 999
  * 8 Byte -> -999 999 .. 9 999 999
  * 11 Byte -> -999 999 999 .. 9 999 999 999


### varint
Die neuere Version verwendet ein "teilweise" binäres Datenformat um kleinere Dateien zu erzeugen.
#### hour
Für jede gemessene Stunde wird eine Zeile in der Datei angelegt.
* `hour` als Kennung für den Typ der Daten
* `00` .. `23` als Wert für die Stunde die hier gespeichert ist
* ein codierter String der Die eigentlichen Daten für die 60 Minuten enthält
* 0x0A als Zeilenende

##### Codierung
Die Codierung kann in der datei varint.lua genau betrachtet werden. Sie ist ähnlich dem "Varint-Verfahren", verwendet jedoch nur 250 der 256 verfügbaren codes, um den Zeilenvorschub und andere Sonderzeichen auszusparen.
* 1 Byte -> -62 .. 62 
* 2 Byte -> -7 812 .. 7 812 
* 3 Byte -> -976 562 .. 976 562
* 4 Byte -> -122 070 312 -- 122 070 312
* 5 Byte -> -1 073 741 824 .. -1 073 741 824 (30Bit-Zahl)

Der Speicherbedarf ist umso kleiner, je kleiner der Wert ist. Im Mittel sollte das 3x so viele Tage im Dateisystem erlauben.

##### Compression
Der Platzverbrauch im Datesystem wird umso kleiner, je kleiner die jeweiligen Werte sind. Weil unsere Messwerte ziemlich kontinuierlich sind, kann eine Platzerspasrnis erreicht werden, indem statt der aktuellen Werte, die Differenzen zum jeweils vorigen Wert gespeichert werden. 

Wenn der Stromverbrauch gerade gleichmäßig ist, werden dann einige Minuten lang sehr kleine Werte gespeichert. Das bedeutet, dass meist nur ein Byte pro Minute im Dateisystem verbraucht wird. Wenn der Verbrauch sich stark ändert, werden halt mal in einer Minute 2 Byte verbaucht ;-) 


