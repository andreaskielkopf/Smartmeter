# smartmeter

## Stromverbrauch von einem Smartmeter mit IR-Schnittstelle fortlaufend aufzeichnen
Viele Smartmeter haben eine IR-Schnittstelle, über die je Abrechnungseinheit ein IR-Impuls gesendet wird.
Wenn man die Pulse pro Minute mitzählt, erhält man ein direktes Maß für den Stromverbrauch in dieser Zeit.

Ein `D1-mini` mit einem `ESP8266` reicht für diesen Zweck völlig aus. Der Stromverbrauch dafür liegt bei ca. 50mA.
Man braucht noch einen `IR-Transistor` als Empfänger und ein kurzes Kabel von D6 und D7 das bis zum Smartmeter reicht.
Ein USB-Netztei und ein kurzes USB-Kabel bis zum D1-mini und zusätzlich eine Drahtbrücke oder einen 1kOhm Widerstand für D5

Der ESP8266 hat genug Speicher für die Daten von 2-3 Monaten (je nach Verbaruch). Damit müssen die Daten nicht täglich abgerufen werden.
Der Abruf kann bequem über WLAN im lokalen Netz durchgeführt werden. Dazu muss jedoch `SSID` und `Passwort` eingetragen werden.
Keine Cloud. Die Daten verlassen das lokale Netzwerk nicht. Es werden keinerlei personenbezogenen Daten gespeichert.
Kalkulation:
    * 2.50 € wemos D1-mini ESP-8266 (NICHT ESP-32 !!!) mit Buchsenleiste und micro-USB
    * 0.10 € Fototransistor (Receiver hat nur 2 Pins, weil die Basis IR-Licht empfängt)
    * 0.10 € 1kOhm Widerstand oder kurze Drahtbrücke
    * 2.05 € USB-Netzteil 5V mit Kabel für micro-USB (oder von altem Telefon)
    * 0.25 € 10cm 2-poliges Kabel abgespaltet von einem 40pin Flachkabel (male to female)
    * `5.00 €` 

## Was notwendig ist, um das Projekt auf einem ESP-8266 zu installieren:
Verwendet wird in diesem Fall Lua.

### Weitergehende Infos
 * https://nodemcu.readthedocs.io/en/release/
 * https://nodemcu.readthedocs.io/en/release/getting-started

## Hardware
Mögliche Hardware: D1-mini, NodeMCU, ...(mit ESP-8266)

### anpassen
Um die IR-Signale zu erfassen wird ein IR-Receiver benötigt. Dazu reicht ein einfacher Fototransistor.(Z.B. SFH3100F)
Der hat 2 pins !!! und wird an die Anschlüsse D6 und D7 angeschlossen 
(Im weiteren Verlauf wird dann noch ein 1kOhm Widerstand von Masse(G) zu D1 gebraucht.)

## Grundfirmware mit esptool flashen
NodeMcu oder D1-mini per USB- an den PC anschließen. Achtung das muss ein USB-Kabel sein, das auch Datenleitungen enthält. 
Manche reinen Ladekabel eignen sich nicht.

### Verbindung testen:
```
esptool -v -c esp8266 -p /dev/ttyUSB0 read-mac 
```
Wenn das geht, ist das Kabel OK.

### Firmware installieren:
Die Dateien 0x00000.bin und 0x10000.bin enthalten die von mir vorbereitete Firmware.

```
esptool -v -c esp8266 -p /dev/ttyUSB0 erase-flash
esptool -v -c esp8266 -p /dev/ttyUSB0 write-flash -fm dout 0x0 0x00000.bin 0x10000 0x10000.bin 
```

## Software
Die Software enthält:
* `smartmeter`
  Das eigentliche Programm zum Erfassen der IR-Impulse
* `telnet` auf port 2323
  Zum fernsteuern z.B. mit `putty` oder einem anderen telnet-Client
* `ftp-server` (Zugang mit user=smart und passwort=meter)
  Zum direkten Zugang zu den Dateien (Lua-Programme und Messwerte) z.B. mit `mc` oder einem anderen ftp-Client
* `http-server` 
  Um die Messdaten programmatisch abfragen zu können z.B. mit `curl`

Damit das alles nicht zu viel RAM(`Heap`) braucht, muss der Großteil davon im LFS gespeichert sein. 
Nur die Startdatei `init.lua` muss unbedingt im normalen Dateisystem(`SPIFFS`) liegen

### Software aufspielen
 * https://nodemcu.readthedocs.io/en/release/upload/

#### eus_params.lua
Es gibt verschieden Wege den ESP-8266 an ihr WLAN anzupassen. Aber irgendwie muss er ja SSID und Passwort bekommen. 
Sonst ist er später nicht im WLAN erreichbar.

Eine Möglichkeit ist es die Datei `eus_params.lua` an ihr WLAN anzupassen.
* SSID eintragen
* Passwort eintragen

#### init.lua
Das ist die Startdatei die nach dem Einstecken der Betriebsspannung gestartet wird. Diese muss im `SPIFFS` installiert werden. 
Sie prüft, ob die Verbindung bei D1 besteht.
* mit D1 auf Masse, startet der Smartmeter (durch `start.lua`)
* mit D1 offen hält der Boot an (Um mit dem ESPlorer Dateien aufspielen zu können)

#### smartmeter.img
Alle LUA-Quelltexte für das Projekt sind bereits in die Datei `smartmeter.img` compiliert. Diese Datei muß unbedingt im `LFS` installiert werden.
Zwar können einzelne Dateien auch im `SPIFFS` auf dem ESP-8266 gespeichert werden, und diese haben dann Vorrang, 
aber das braucht eine Menge RAM(Heap) zur Laufzeit. Der FTP-server zum Beispiel funktioniert deswegen nur aus dem `LFS`.

#### start.lua
Das ist das eigentliche Programm. Es wird nur dann gestartet, wenn `init.lua` die Brücke bei D1 findet. 
(`start.lua` und `init.lua` sind auch im LFS enthalten, aber `init.lua` kann nicht von dort starten)

#### mit ESPlorer uploaden
Alle diese Dateien (`smartmeter.img`, `eus_params.lua`, `start.lua` und zuletzt `init.lua` müssen per [Upload] ins 
Dateisystem(`SPIFFS`) auf den ESP8266 übertragen werden.
(Bitte dazu erst mal die Brücke an D1 entfernen)

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
ESPlorer -> [rechte Bildschirmhälfte] -> [Großer Knopf "Open"]
```
* Reset des 8266 (per RTS)
```
ESPlorer -> [rechte Bildschirmhälfte] -> [Knopf RTS]
```
  Einschalten, kurz warten, ausschalten.
  Spätestens jetzt sollten die ESP-Startmeldungen im Fenster erscheinen.

* Upload erste Datei ins `SPIFFS`
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
Den Inhalt des Eingabefelds durch `node.LFS.reload('smartmeter.img')` ersetzen, und `[return]` drücken.
Danach sollte der ESP-8266 einige Zeilen ausgeben, und dann automatisch neu starten.

https://nodemcu.readthedocs.io/en/release/modules/node/#nodelfsreload

### Autostart
Nachdem die Hardware eingerichtet und die Software aufgespielt ist, kann das Projekt in Betrieb genommen werden.
Damit die Software automatisch startet ist eine Drahtbrücke oder besser ein `1kOhm Widerstand` zwischen Masse(`G`) und `D1` notwendig
Wenn ein Fehler bei der Entwicklung passiert, kann durch entfernen der Brücke zu `D1` der Autostart (Bootschleife) unterbrochen werden

## Tests
Jetzt am D1-Mini die Resettaste kurz drücken um das Programm zu starten

### HTTP server
Beim starten des ESP-8266 an ESPlorer, zeigt er die IP an, die er bekommen hat. Es ist gut sich diese zu notieren ;-)
Bei mir war das `192.168.178.45`

#### Abfrage des Heap
`curl http://192.168.178.45/smartmeter/heap`
ergibt z.B.
```
{"Heap":30280}
```
Der freie Heap sollte so ca. 30kByte groß sein

#### Abfrage der Musterdaten aus `2025-12-01.lua` im `LFS`
`curl http://192.168.178.45/smartmeter/data/2025/12/01`
ergibt
```
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

### IR-Empfang
Jeder Impuls des Smartmeters, der vom IR-Transistor empfangen wird, wird durch Aufblinken der blkauen LED an D4 quittiert.
Das kann man leicht mit einer beliebigen IR-Fernbedienung prüfen. Wenn das nicht oder schlecht klappt:
* Wackelkontakt der Leitung zum IR-Empfänger -> nachprüfen
* IR-Empfänger an D6,D7 verpolt -> IR-Empfänger umstecken
* Umgebungslicht -> etwas abdunkeln

### Abfrage der aktuell gemessenen Daten
`curl http://192.168.178.45/smartmeter/data`
ergibt z.B.
```
{"Data":
{"hour":8, "ticks":[106,107,116,118,118,16]}
}
```

# ToDo´s

* Die Abfrage eines Tages liefer keine Daten, wenn die erste Stunde fehlt
* Liste der vorhandene Dateien mit Messwerten
* Löschen alter Dateien bei Platzmangel (max 80% im `SPIFFS` belegt ?)
