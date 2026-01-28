
-- Messung der Temperatur oder anderer Werte und Ablegen in entsprechender Datei
-- Die dateinamen starten mit dem Datum 2026-01-01", dann ".lua"
-- Der Datensatz für eine Stunde wird im Speicher gehalten. Am Ende der Stunde wird im Dateisystem gespeichert
-- Der Datensatz für eine Stunde enthält die stunde, den Typ der Daten und ein array mit den 60 Werten.(ca.300 Byte ???)
-- Es gibt eine globale Tabelle (daten), in der alle Stundentabellen zwischengespeichert sind (ca. 2kByte ???)

-- liest die Temperatur und fügt sie in den lokalen Zwischenspeicher für diese Stunde ein
local function readTemp()
end

-- liest die Feuchtigkeit und fügt sie in den lokalen Zwischenspeicher für diese Stunde ein
local function readHum()
end

-- fügt eine Wert in eine beliebige Datensammlung ein
local function storeWert(wert, typ)
   for s,j in  data
     if s.typ and s.typ==typ then
    end
    end
end


-- lade den Datensatz für diese Stunde um dort weiterzumachen
local function loadStunde(tag,stunde, typ)
end

-- speichere den datensatz für diese Stunde jetzt im Dateisystem
local function loadStunde(daten, sammlung)
end

-- 