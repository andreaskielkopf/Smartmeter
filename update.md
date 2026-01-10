# Update
Damit man das Smartmeter nicht jedes mal für ein Update abbauen, zum PC tragen, und später wieder neu aufbauen muss, kann es per `FTP` mit einem Update versehen werden.

Das Update-immage `smartmeter.img` muss nur per FTP im Dateisystem des Smartmeter ablegt werden. Zusätzlich ist eine Datei `update.flag` notwendig. 

Die Zugangsdaten per FTP: 
 * user = smart
 * passwort =meter

Immer beim Tageswechsel (0:00 Uhr) wird überprüft, ob ein `update.flag` und ein `smartmeter.img` im `SPIFFS` vorhanden sind. Wenn ja, wird das image als neues `LFS` installiert, und der smartmeter dazu neu gestartet. Durch den Neustart fehlen dann eventuell die Messwerte einiger Sekunden in der ersten Minute des Tages.
