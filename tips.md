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

## Die selbst compilierte firmware flashen:
esptool -v -c esp8266 -p /dev/ttyUSB0 write-flash -fm dout 0x0 0x00000.bin 0x10000 0x10000.bin 

Partitionstabelle ist:
* pos: 0x000000	size: 0x007A60 =>  31kByte firmware
* pos: 0x010000	size: 0x06A000 => 424kByte firmware
* pos: 0x07a000	size: 0x010000 =>  64kByte	für LFS (readonly)
* pos: 0x08a000	size: 0x073000 => 460kByte	für SPIFFS (beschreibbar)

Vorteil LFS:		Lua-Code kann aus dem FFS direkt ausgeführt werden, was eine Menge Heap spart
Vorteil SPIFFS		Daten können im SPIFFS gespeichert werden, und sind dann per FTP zugänglich

Die gewünschte größe des LFS kann in user_config.h angepasst werden
Die größe des SPIFFS wird automatisch größer, wenn weniger module einkompiliert werden. Das kann in user_modules.h konfiguriert werden ;-)

@todo unnötige module entfernen

-- folgende module werden benötigt:
-- node, net, wifi, end user setup
-- file, GPIO, UART
-- timer, RTC time, SNTP
-- LFS mit 64kByte

-- Optional: BME280, BME280.math
-- DS18B20.lua, 1-Wire
-- DHT
-- SPI UCG ST7735 ???

### Besonderheiten in `user_config.h`
| Nr| Text |Kommentar|
|----------|----------|---|
| 10|#define FLASH_AUTOSIZE| |
| 21|#define BIT_RATE_DEFAULT BIT_RATE_115200| Baudrate = 115 kBaud |
| 53|#define LUA_NUMBER_INTEGRAL| Integer-Build |
| 82|#define LUA_FLASH_STORE 0x10000| 64 kByte reservieren für LFS|
|154|#define NET_PING_ENABLE| Ping über Netzwerk wird beantwortet |
|186|#define WIFI_STA_HOSTNAME "Smartmeter"||
|187|#define WIFI_STA_HOSTNAME_APPEND_MAC||
|194|#define ENDUSER_SETUP_AP_SSID "Smartmeter"||
### Besonderheiten in `user_modules.h`
| Nr| Text |Kommentar|
|----------|----------|---|
|28|#define LUA_USE_MODULES_ENDUSER_SETUP|Enduser-setup per wlan AP (hab ich noch nicht zum Laufen bekommen) |
|29|#define LUA_USE_MODULES_FILE|SPIFFS brauchen wir|
|31|#define LUA_USE_MODULES_GPIO|Für den IR-Empfänger|
|40|#define LUA_USE_MODULES|MDNS ??? (aus)|
|42|#define LUA_USE_MODULES_NET|Netzwerk brauchen wir|
|43|#define LUA_USE_MODULES_NODE|wegen LFS und Updatefunktion auf jeden Fall|
|55|#define LUA_USE_MODULES_RCTTIME|Um die Zeit auf dem laufenden zu halten|
|59|#define LUA_USE_MODULES_SNTP|SNTP um die Zeit mit dem Netzwerk abzugleichen|
|68|#define LUA_USE_MODULES_TMR|Für den Timer IRQ|
|70|#define LUA_USE_MODULES_UART|Für die Kommunikation mit dem ESP-Tool ??? |
|75|#define LUA_USE_MODULES_WIFI|WLAN brauchen wir auch ;-)|


export USER_PROLOG="Smartmeter © 2025 Andreas Kielkopf";make


---


# Hier kurz und präzise Links und Hinweise — aktuelle Infos zu NodeMCU auf ESP32 und geeignete Boards:

Wichtige Quellen
- NodeMCU-ESP32 (Projekt, Firmware, Docs): https://nodemcu.readthedocs.io/ (Dokumentation)  
- NodeMCU-ESP32 GitHub (Quellcode, Releases, Issues): https://github.com/nodemcu/nodemcu-firmware (achte auf dev-esp32 branch / ESP32-spezifische Repos)  
- NodeMCU-ESP32 community builds / Forks: suche auf GitHub nach "nodemcu-esp32" für aktuelle ESP-IDF-kompatible Builds.  
- Espressif (ESP32-SDK, Datenblätter, Board-Referenz): https://www.espressif.com (ESP-IDF, SoC-Varianten, Modulspezifikationen)  
- PlatformIO / Board-Index (Kompatible Devkits und board IDs): https://docs.platformio.org

Welche ESP32-Varianten sind geeignet
- Gängige und gut unterstützte Module/Devkits:
  - ESP32-WROOM-32 / DevKitC (Standard, Dual-Core, gut für die meisten Projekte)  
  - ESP32-WROOM-32D/32U (ähnlich, U = für externe Antenne)  
  - ESP32-S3 (mehr AI/USB-Funktionen, PSRAM-Varianten sinnvoll bei Speicherbedarf)  
  - ESP32-C3 (RISC‑V, weniger GPIOs, andere Peripherie — prüfen, ob NodeMCU-Build C3 unterstützt)  
  - ESP32-CAM (Kamera‑Board; NodeMCU-Builds oft angepasst)  
  - NodeMCU-32S (fertiges Devboard-Layout; gängig im Shop‑Segment)

Worauf achten
- Flash-Größe: mind. 4 MB empfohlen (mehr für Module mit Filesystem/mehr Lua-Module).  
- PSRAM: wichtig bei speicherintensiven Lua-Operationen (z. B. viele Module/Bilder).  
- Chip-Variante: prüfe, ob dein gewählter NodeMCU-ESP32-Build S3/C3 unterstützt (nicht alle Builds unterstützen alle SoC-Varianten).  
- USB‑Serial-Chip und Boot-Buttons: erleichtern Flashen.

Kurzempfehlung
- Start: ESP32-WROOM-32 / DevKitC (4 MB Flash) oder NodeMCU-32S — maximale Kompatibilität mit vorhandenen NodeMCU-ESP32 Builds.  
- Bei hohem Speicherbedarf: ESP32-S3 mit 8 MB Flash + PSRAM.


---
## Stromsparendstes Board
- **ESP32-C3** (RISC‑V) ist in der Regel am stromsparendsten unter den aktuellen ESP32-Familien, besonders im Deep‑Sleep: typ. ~5–10 µA im Deep‑Sleep (abhängig vom Modul und Peripherie).  
- **ESP32-S3** und **ESP32-WROOM-32** (Classic) haben höhere Deep‑Sleep-Ströme; typische Werte liegen eher im Bereich von ~20–150 µA je nach Modul/Revision und Peripherie.  
Hinweis: tatsächlicher Verbrauch hängt stark von Peripherie (Spannungsregler, USB‑Serial, angeschlossene Sensoren, Pull‑Ups) und Board‑Layout ab — reine SoC‑Vergleiche gelten nur für Module mit ähnlichen externen Komponenten.

## Board/Modul mit meisten Flash‑Optionen
- **ESP32‑S3**-Module und viele ESP32-WROOM/ESP32-WROVER Varianten bieten die größten Flash‑Optionen:
  - gängige Optionen: **4 MB**, **8 MB**, **16 MB** (seltener), manche WROVER-Module mit PSRAM kombinieren **8 MB Flash + PSRAM**.
  - Beispiel: **ESP32-WROVER**-Module (häufig 8 MB Flash + 8 MB PSRAM).  
- Für maximalen Flash such nach Modulen/Devkits mit explizit 16 MB Flash (Verfügbarkeit variabel).

## Kurze Entscheidungshilfe
- Wenn Energieverbrauch kritisch: wähle ein ESP32‑C3 Modul/Devkit und achte auf externe Komponenten (low‑IQ LDO, kein USB‑to‑UART immer aktiv, Schaltbare Peripherie).  
- Wenn viel Flash notwendig: wähle ESP32‑WROVER/ESP32‑S3 Module mit 8–16 MB Flash (plus PSRAM falls benötigt).

Wenn du möchtest, nenne ich konkrete Modul- oder Devkit-Modelle mit typischen Deep‑Sleep‑Messwerten und Flash‑Konfigurationen.

# ESP32

```
git clone --branch dev-esp32-idf3-final --recurse-submodules https://github.com/nodemcu/nodemcu-firmware.git nodemcu-firmware-esp32 
```
cd ~/git/nodemcu-firmware-esp32
make config
make
install.sh
. ./export.sh
idf.py set-target esp32c3
make all
idf.py menuconfig
idf.py -p /def/ttyACM0 flash