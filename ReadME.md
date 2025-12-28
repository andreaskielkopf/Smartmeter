# Was notwendig ist, um das Projekt auf einem ESP-8266 zu installieren:

### Weitergehende Infos
 * https://nodemcu.readthedocs.io/en/release/
 * https://nodemcu.readthedocs.io/en/release/getting-started

## Hardware
Mögliche Hardware: D1-mini, NodeMCU, ...(mit 8266)
### anpassen
Um die IR-Signale zu erfassen wird ein IR-receiver benötigt. Dazu reicht ein einfacher Fototransistor.
Der hat 2 pins !!! und wird an die Anschlüsse D6 und D7 angeschlossen 
(Im weiteren Verlauf wird dann noch ein 1kOhm Widerstand von Masse(G) zu D5 gebraucht.)

## Grundfirmware mit esptool flashen
NodeMcu oder D1-mini per USB- an den PC anschließen

### Verbindung testen:
```
esptool -v -c esp8266 -p /dev/ttyUSB0 read-mac 
```

### Firmware installieren:
Die Dateien 0x00000.bin und 0x10000.bin enthalten die von mir vorbereitete firmware

```
esptool -v -c esp8266 -p /dev/ttyUSB0 erase-flash
esptool -v -c esp8266 -p /dev/ttyUSB0 write-flash -fm dout 0x0 0x00000.bin 0x10000 0x10000.bin 
```

## Software
Die Software enthält:
* `smartmeter`
  Das eigentliche Programm zum Erfassen der IR-Impulse
* `telnet` auf port 2323
  Zum fernsteuern z.B. mit putty
* `ftp-server` (Zugang mit user=smart und passwort=meter)
  Zum direkten Zugang zu den Dateien (programme und messwerte) z.B. mit mc
* `http-server` 
  Um die Messdaten programmatisch abfragen zu können z.B. mit curl

Damit das alles nicht zu viel RAM braucht, muss der Großteil im LFS gespeichert sein. 
Nur die Startdatei `init.lua` muss unbedingt im normalen Dateisystem(`SPIFFS`) liegen

### Software aufspielen
 * https://nodemcu.readthedocs.io/en/release/upload/

#### eus_params.lua
Es gibt verschieden Wege den ESP-8266 an ihr WLAN anzupassen. Aber irgendwie muss er ja SSID und Passwort bekommen. 
Sonst ist er später nicht im WLAN erreichbar.

Eine Möglichkeit ist es die Datei `eus_params.lua` an ihr Wlan anzupassen.
* SSID eintragen
* Passwort eintragen

#### init.lua
Das ist die Startdatei die nach dem Einstecken der Betriebsspannung gestartet wird. Diese muss im `SPIFFS` installiert werden. 
Sie prüft, ob die Verbindung bei D5 besteht.
* mit D5 auf Masse, startet der Smartmeter (durch `start.lua`)
* mit D5 offen hält der Boot an (Um mit dem ESPlorer Dateien aufspielen zu können)

#### smartmeter.img
Alle LUA-Quelltexte für das Projekt sind bereits in die Datei `smartmeter.img` compiliert. Diese Datei muß unbedingt im `LFS` installiert werden.
Zwar können einzelne Dateien auch im `SPIFFS` auf dem ESP-8266 gespeichert werden, und diese haben dann Vorrang, 
aber das braucht eine Menge RAM(Heap) zur Laufzeit. Der FTP-server zum Beispiel funktioniert deswegen nur aus dem `LFS`.

#### start.lua
Das ist das eigentliche Programm. Es wird nur dann gestartet, wenn `init.lua` die Brücke bei D5 findet. 
(`start.lua` und `init.lua` sind auch im LFS enthalten, aber `init.lua` kann nicht von dort starten)

#### mit ESPlorer uploaden
Alle diese Dateien (`smartmeter.img`, `eus_params.lua`, `init.lua`, `start.lua` müssen zuerst 
per [Upload] ins Dateisystem`SPIFFS` auf den ESP8266 übertragen werden.
(Bitte dazu erst die Brücke an D5 entfernen)

* Ports refreshen
```
ESPlorer -> [rechte Bildschirmhälfte] -> [Knopf mit blauem Kreis]
```
* Port für die Verbindung wählen (meist /dev/ttyUSB0 oder ähnlich)
```
ESPlorer -> [rechte Bildschirmhälfte] -> [Dropdown]
```
* Verbinden
```
ESPlorer -> [rechte Bildschirmhälfte] -> [Großer Knopf Open]
```
* Reset des 8266 (per RTS)
```
ESPlorer -> [rechte Bildschirmhälfte] -> [Knopf RTS]
```
  Einschalten, kurz warten, ausschalten

* upload erste Datei ins `SPIFFS`
```
ESPlorer -> [linke Bildschirmhälfte] -> [NodeMCU & MicroPython] -> [Scripts] -> [Upload] "smartmeter.img"
```

* Nun das selbe mit den anderen Dateien ... 

* Dann überprüfen, ob es geklappt hat mit:
```
ESPlorer -> [rechte Bildschirmhälfte] -> [FS Info] -> [Reload] 
```
Danach sollten alle erfolgreich ins `SPIFFS` upgeloadeten Dateien aufgelistet werden

#### LFS installieren
Um `smartmeter.img` als `LFS` zu installieren muss im ESPlorer Terminal noch der Befehl `node.flashreload('smartmeter.img')` ausgeführt werden
```
ESPlorer -> [rechte Bildschirmhälfte] -> [untere Hälfte] -> [helles Eingabefeldt]
```
Den Inhalt des Eingabefelds durch `node.flashreload('smartmeter.img')` ersetzen, und `[return]` drücken.
Danach sollte der ESP-8266 einige Zeilen ausgeben, und dann automatisch neu starten.

### Autostart
Nachdem die Hardware eingerichtet und die Software aufgespielt ist, kann das Projekt in Betrieb genommen werden.
Damit die Software automatisch startet ist eine Drahtbrücke oder besser ein 1kOhm Widerstand zwischen Masse(G) und D5 notwendig

Wenn ein Fehler bei der Entwicklung passiert, kann durch entfernen der Brücke zu D5 der Autostart (Bootschleife) verhindert werden

## Tests

### HTTP server
Beim starten des ESP-8266 an ESPlorer, zeigt er die IP an, die er bekommen hat. Es ist gut sich diese zu notieren ;-)
#### Abfrage des Heap
```
curl http://192.168.178.45/smartmeter/heap
{"Heap":30280}
```
#### Abfrage der Musterdaten aus `2025-12-01.lua` im `LFS`
```
curl http://192.168.178.45/smartmeter/data/2025/12/01                                                                    ✔ 
{"Data":
{"date":"2025-12-01",
"hours":[
{"hour":0, "ticks":[1,1,2,0,4,5,6,7,8,9,10,11,12,13,14,15,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]}
,{"hour":1, "ticks":[1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]}
,{"hour":2, "ticks":[1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]}
,{"hour":3, "ticks":[1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]}
,{"hour":4, "ticks":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]}
,{"hour":5, "ticks":[]}
,{"hour":6, "ticks":[]}
,{"hour":7, "ticks":[1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]}
,{"hour":15, "ticks":[1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]}
,{"hour":23, "ticks":[1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]}
,{"hour":24, "ticks":[1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]}
]}
}
```
#### Abfrage der aktuell gemessenen Daten
```
curl http://192.168.178.45/smartmeter/data                                                                               ✔ 
{"Data":
{"hour":8, "ticks":[106,107,116,118,118,16]}
}
```

### IR-Empfang
Jeder Impuls des Smartmeters, der vom IR-Transistor empfangen wird, wird durch Aufblinken der blkauen LED an D4 quittiert.
Das kann man leicht mit einer beliebigen IR-Fernbedienung prüfen.

### 

# ToDo

echo "first upload 'smartmeter.img', '_init.lc', 'start.lc'"
echo "then execute:"
echo "node.LFS.reload('smartmeter.img')"
echo "node.flashindex('_init')()"
echo "print(LFS)"
# node.restart() 

* Die Abfrage eines Tages liefer keine Daten, wenn die erste stunde fehlt
* Liste der vorhandene Dateien
* Löschen alter Dateien bei Platzmangel (max 80% im SPIFFS belegt ?)
