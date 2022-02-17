# README

Herzlich Willkommen beim HomematicIP CCU Netatmo Addon Projekt.

Das Projekt basiert auf den Postings im Thread [NetAtmo Wetterdaten HOWTO](https://homematic-forum.de/forum/viewtopic.php?t=28188) aus dem [HomeMatic-Forum / FHZ-Forum](https://homematic-forum.de). Um die Handhabung des dort vorgestellten Skripts zu vereinfachen wurde es für dieses Projekt überarbeitet und stellenweise angepasst. Die optionalen Blöcke für die Wind-, Regen- und Zusatzmodule müssen nicht mehr auskommentiert werden, diese werden nur noch ausgeführt wenn die entsprechenden Modulids gesetzt wurden. Anstatt die Credentials und Modulids statisch im Skript anzugeben können diese nun als Kommandozeilenparameter beim Aufruf übergeben werden.

Nachfolgend finden Sie eine Beschreibung der Kommandozeilenparameter und eine detaillierte Schritt-für-Schritt Anleitung zur Erstinstallation. Es ist aber auch möglich anhand der Anleitung bei bedarf bisher nicht genutzte Module nachträglich einzubinden, dazu müssen lediglich die entsprechenden Abschnitte befolgt werden.

**Parameter:**
* -clientid: API Client ID (erforderlich) => Siehe [1.3 Beziehen der Clientid und des Clientsecrets](#13-beziehen-der-clientid-und-des-clientsecrets)
* -clientsecret: API Client Secret (erforderlich) => Siehe [1.3 Beziehen der Clientid und des Clientsecrets](#13-beziehen-der-clientid-und-des-clientsecrets)
* -username: Netatmo Account Benutzername (erforderlich)
* -password: Netatmo Account Passwort (erforderlich)
* -deviceid: ID des Netatmo Basismoduls (erforderlich) => Siehe [1.4.1 Basisstation](#141-basisstation)
* -moduleid: ID des Netatmo Außenmoduls (optional) => Siehe [1.4.2 Übrige Module](#142-übrige-module)
* -windid: ID des Netatmo Windsensors (optional) => Siehe [1.4.2 Übrige Module](#142-übrige-module)
* -rainid: ID des Netatmo Regensensors (optional) => Siehe [1.4.2 Übrige Module](#142-übrige-module)
* -z1moduleid: ID des ersten Netatmo Zusatz Innenmoduls (optional) => Siehe [1.4.2 Übrige Module](#142-übrige-module)
* -z2moduleid: ID des ersten Netatmo Zusatz Innenmoduls (optional) => Siehe [1.4.2 Übrige Module](#142-übrige-module)
* -z3moduleid: ID des ersten Netatmo Zusatz Innenmoduls (optional) => Siehe [1.4.2 Übrige Module](#142-übrige-module)

**Inhaltsverzeichnis**
1. [Vorbereitungen](#1-vorbereitungen)
2. [Installation](#2-installation)
3. [Anlegen der Geräte im CUx Daemon](#3-anlegen-der-geräte-im-cux-daemon)
4. [CCU Geräte anlernen](#4-ccu-geräte-anlernen)
5. [Systemvariablen anlegen](#5-systemvariablen-anlegen)
6. [Programm für automatischen Datenabruf anlegen](#6-programm-für-automatischen-datenabruf-anlegen)

## 1. Vorbereitungen
Für die Nutzung des HmIP-CCU-Netatmo-Addons werden neben den normalen Benutzerdaten für Ihren Netatmo Account noch eine Clientid sowie ein Clientsecret notwendig. Dafür wird ein Netatmo Developer Account benötigt, im Folgenden wird beschrieben wie Sie den Account anlegen und wo die benötigten Daten zu finden sind.

### 1.1 Erstellung eines Netatmo Developer Accounts
Falls Sie bereits einen Netatmo Developer Account haben fahren Sie bitte mit Abschnitt 1.2 fort
1. Öffnen Sie einen beliebigen Browser und navigieren Sie zur Adresse [https://dev.netatmo.com/](https://dev.netatmo.com/)
2. Klicken Sie auf Log In
3. Klicken Sie auf Singn Up
4. Vergeben Sie einen Benutzernamen und Passwort
5. Setzen Sie das Häkchen zum Bestätigen der AGBs und Nutzungsbedingungen
6. Bestätigen Sie Ihre Eingaben mit einem Klick auf den Button Sign Up

### 1.2 Registrieren einer neuen App
1. Öffnen Sie einen beliebigen Browser und navigieren Sie zur Adresse [https://dev.netatmo.com/](https://dev.netatmo.com/)
2. Klicken Sie auf Log In
3. Geben Sie Ihren Benutzernamen und Passwort ein
4. Melden Sie sich mit einem Klick auf den Button LOG IN an
5. Klicken Sie auf Ihren Benutzernamen => my apps
6. Klicken Sie auf den Button Create
7. Füllen Sie das Formular aus
8. Setzen Sie das Häkchen zum Akzeptieren der Nutzungsbedingungen
9. Speichern Sie die Eingaben mit einem Klick auf den Button Save

### 1.3 Beziehen der Clientid und des Clientsecrets
1. Öffnen Sie einen beliebigen Browser und navigieren Sie zur Adresse [https://dev.netatmo.com/](https://dev.netatmo.com/)
2. Klicken Sie auf Log In
3. Geben Sie Ihren Benutzernamen und Passwort ein
4. Melden Sie sich mit einem Klick auf den Button LOG IN an
5. Klicken Sie auf Ihren Benutzernamen => my apps
6. Klicken Sie auf die Kachel Ihrer App
7. Notieren Sie die Angaben aus den Feldern client ID und client secret im Abschnitt App Technical Parameters

### 1.4 Ermitteln der Modul IDs
#### 1.4.1 Basisstation
Die Modul ID der Basisstation finden Sie in der Netatmo Android-/iOS bzw iPad OS App, gehen Sie dazu wie folgt vor:
1. Öffnen Sie die App auf Ihrem Tablet oder Smartphone
2. Tippen Sie auf die drei Striche oben links
3. Tippen Sie auf den Menüpunkt Haus steuern
4. Tippen Sie auf eine Gruppe
5. Tippen Sie auf eínen Geräteeintrag
6. Notieren Sie sich die Daten des Eintrags MAC-Adresse

#### 1.4.2 Übrige Module
Die Modul IDs der Netatmo Außen-, Wind-, Regen-, sowie Zusatz Innenmodule setzen sich je nach Modultyp aus einem Präfix und den letzten sechs Stellen der Seriennummer des Moduls im Schema 00:00:00:00:00:00 zusammen. Die Seriennummer der Module finden Sie auf der Rückseite der original Netatmo Modulverpackung auf dem Etikett über dem oberen Barcode.

Die Modultypspezifischen Präfixe lauten wie folgt:
* Außenmodul: 02:00:00
* Regensensor: 05:00:00
* Windsensor: 06:00:00
* Zusatz Innenmodul: 03:00:00

## 2. Installation
### 2.1 CUx Daemon Installieren
1. Laden Sie [hier](https://homematic-forum.de/forum/viewtopic.php?f=37&t=15298) den CUx Daemon herunter 
2. Öffnen Sie einen beliebigen Browser und navigieren Sie zur Adresse ihrer CCU
3. Loggen Sie sich mit ihrem User und Passwort ein
4. Klicken Sie auf Einstellungen -> Systemsteuerung
5. Klicken Sie auf den Button Zusatzsoftware
6. Wählen Sie die in Schritt 1. heruntergeladene Datei zum Upload aus
7. Klicken Sie auf den Button Installieren
8. Bestätigen Sie die folgenden Hinweise mit einem Klick auf OK

### 2.2 Addon Verzeichnis für Netatmo anlegen
1. Mit Kommandozeile: ssh <ihr_ccu_user>@<ihre_ccu_addresse> mkdir /usr/local/addons/netatmo
2. Mit einem Client wie WinSCP: Mit ihrem CCU User und Passwort einloggen und das Verzeichnis netatmo manuell anlegen unter /usr/local/addons

### 2.3 Hochladen des Addon Script in das Addon Verzeichnis
1. Mit Kommandozeile: scp <pfad_zum_skript>/[netatmo_new.tcl](netatmo_new.tcl) <ihr_ccu_user>@<ihre_ccu_addresse>:/usr/local/addons/netatmo
2. Mit einem Client wie WinSCP: Mit ihrem CCU User und Passwort einloggen und das tcl Skript manuell im Verzeichnis netatmo ablegen unter /usr/local/addons/netatmo

## 3. Anlegen der Geräte im CUx Daemon
### 3.1 Login auf der CCU Web UI
1. Öffnen Sie einen beliebigen Browser und navigieren Sie zur Adresse ihrer CCU
2. Loggen Sie sich mit ihrem User und Passwort ein
3. Klicken Sie auf Einstellungen -> Systemsteuerung
4. Klicken Sie auf den Button CUx-Daemon
5. Klicken Sie auf Geräte

### 3.2 Main Modul
1. Wählen Sie als CUxD Gerätetyp (90) Universal Wrapper Device aus
2. Wählen Sie als Funktion Thermostat aus
3. Setzen Sie als Seriennummer 1, bzw. die erste freie Nummer
4. Vergeben Sie als Name einen eindeutigen Namen
5. Wählen Sie als Geräte-Icon Temperatursensor innen
6. Klicken Sie auf den Button Gerät auf CCU erzeugen!
7. Öffnen Sie das Dropdown Aktueller Status und Notieren Sie die CUx Geräte ID beginnend mit CUX900200

### 3.3 Optional: Außenmodul
1. Wählen Sie als CUxD Gerätetyp (90) Universal Wrapper Device aus
2. Wählen Sie als Funktion Thermostat aus
3. Setzen Sie als Seriennummer 2, bzw. die erste freie Nummer
4. Vergeben Sie als Name einen eindeutigen Namen
5. Wählen Sie als Geräte-Icon Temperatursensor außen
6. Klicken Sie auf den Button Gerät auf CCU erzeugen!
7. Öffnen Sie das Dropdown Aktueller Status und Notieren Sie die CUx Geräte ID beginnend mit CUX900200

### 3.4 Optional: Windmesser
Achtung: Der Netatmo Windmesser kann nur in Verbindung mit dem Außenmodul eingebunden werden

Für den Netatmo Windmesser muss kein eigenes CUxD Gerät angelegt werden, es muss lediglich eine Systemvariable angelegt werden. Zum Anlegen der Systemvariable folgen Sie bitte der Anleitung unter [5.4 Optional: Windmesser](#54-optional-windmesser)

Nach der Anlage der Systemvariable werden die Daten des Windmessers zusammen mit den Daten des Innenmoduls angezeigt.

### 3.5 Optional: Regenmesser
Achtung: Der Netatmo Regenmesser kann nur in Verbindung mit dem Außenmodul eingebunden werden

Für den Netatmo Windmesser muss kein eigenes CUxD Gerät angelegt werden, es muss lediglich eine Systemvariable angelegt werden. Zum Anlegen der Systemvariable folgen Sie bitte der Anleitung unter [5.5 Optional: Regenmesser](#55-optional-regenmesser).

Nach der Anlage der Systemvariable werden die Daten des Regenmessers zusammen mit den Daten des Innenmoduls angezeigt.

### 3.6 Optional: Erstes Zusatz Innenmodul
1. Wählen Sie als CUxD Gerätetyp (90) Universal Wrapper Device aus
2. Wählen Sie als Funktion Thermostat aus
3. Setzen Sie als Seriennummer 3, bzw. die erste freie Nummer
4. Vergeben Sie als Name einen eindeutigen Namen
5. Wählen Sie als Geräte-Icon Temperatursensor innen
6. Klicken Sie auf den Button Gerät auf CCU erzeugen!
7. Öffnen Sie das Dropdown Aktueller Status und Notieren Sie die CUx Geräte ID beginnend mit CUX900200

### 3.7 Optional: Zweites Zusatz Innenmodul
1. Wählen Sie als CUxD Gerätetyp (90) Universal Wrapper Device aus
2. Wählen Sie als Funktion Thermostat aus
3. Setzen Sie als Seriennummer 4, bzw. die erste freie Nummer
4. Vergeben Sie als Name einen eindeutigen Namen
5. Wählen Sie als Geräte-Icon Temperatursensor innen
6. Klicken Sie auf den Button Gerät auf CCU erzeugen!
7. Öffnen Sie das Dropdown Aktueller Status und Notieren Sie die CUx Geräte ID beginnend mit CUX900200

### 3.8 Optional: Drittes Zusatz Innenmodul
1. Wählen Sie als CUxD Gerätetyp (90) Universal Wrapper Device aus
2. Wählen Sie als Funktion Thermostat aus
3. Setzen Sie als Seriennummer 5, bzw. die erste freie Nummer
4. Vergeben Sie als Name einen eindeutigen Namen
5. Wählen Sie als Geräte-Icon Temperatursensor innen
6. Klicken Sie auf den Button Gerät auf CCU erzeugen!
7. Öffnen Sie das Dropdown Aktueller Status und Notieren Sie die CUx Geräte ID beginnend mit CUX900200

### 3.9 CUxD Zentrale
1. Wählen Sie als CUxD Gerätetyp (28) System
2. Wählen Sie als Funktion Exec aus
3. Setzen Sie als Seriennummer 1, bzw. die erste freie Nummer
4. Vergeben Sie als Namen Zentrale CUxD
5. Wählen Sie als Geräte-Icon Fernbedienung 19 Tasten
6. Wählen Sie als Control Taster
7. Klicken Sie auf den Button Gerät auf CCU erzeugen!
8. Öffnen Sie das Dropdown Aktueller Status und Notieren Sie die CUx Geräte ID beginnend mit CUX900200

## 4. CCU Geräte anlernen
### 4.1 Navigieren Sie zurück zur CCU Web UI und öffnen Sie den Geräte Posteingang
1. Loggen Sie sich ggf. mit ihrem User und Passwort ein
2. Klicken Sie auf den Button Geräte anlernen
3. klicken Sie auf den Button Posteingang

### 4.2 Main Modul
1. Suchen Sie das Gerät anhand der in [3.2 Main Modul](#32-main-modul) notierten Seriennummer aus der Liste heraus
2. Klicken Sie beim entsprechenden Eintrag auf den Button Einstellen
3. Wählen Sie im MODE Dropdown TEMP+HUM aus
4. Deaktivieren Sie das Häkchen bei WEATHER|USE_HMDATAPT falls es gesetzt ist
5. Setzen Sie das Häkchen bei Zyklische Statusmeldung
6. Setzen Sie das Häkchen bei WEATHER|STATISTIC
7. Speichern Sie die Änderungen mit einem Klick auf den Button OK
8. Schließen Sie das Status Popup mit einem Klick auf OK
9. Schließen Sie das Anlernen des Geräts mit einem Klick auf Fertig beim entsprechenden Eintrag ab

### 4.3 Optional: Außenmodul
1. Suchen Sie das Gerät anhand der in [3.3 Optional: Außenmodul](#33-optional-außenmodul) notierten Seriennummer aus der Liste heraus
2. Klicken Sie beim entsprechenden Eintrag auf den Button Einstellen
3. Wählen Sie im MODE Dropdown TEMP+HUM aus
4. Deaktivieren Sie das Häkchen bei WEATHER|USE_HMDATAPT falls es gesetzt ist
5. Setzen Sie das Häkchen bei Zyklische Statusmeldung
6. Setzen Sie das Häkchen bei WEATHER|STATISTIC
7. Speichern Sie die Änderungen mit einem Klick auf den Button OK
8. Schließen Sie das Status Popup mit einem Klick auf OK
9. Schließen Sie das Anlernen des Geräts mit einem Klick auf Fertig beim entsprechenden Eintrag ab

### 4.4 Optional: Windmesser
**Achtung:** Der Netatmo Windmesser kann nur in Verbindung mit dem Außenmodul eingebunden werden

Für den Netatmo Windmesser muss kein eigenes CUxD Gerät angelegt werden, es muss lediglich eine Systemvariable angelegt werden. Zum Anlegen der Systemvariable folgen Sie bitte der Anleitung unter [5.4 Optional: Windmesser](#54-optional-windmesser).


Nach der Anlage der Systemvariable werden die Daten des Windmessers zusammen mit den Daten des Innenmoduls angezeigt.

### 4.5 Optional: Regenmesser
**Achtung:** Der Netatmo Regenmesser kann nur in Verbindung mit dem Außenmodul eingebunden werden

Für den Netatmo Regenmesser muss kein eigenes CUxD Gerät angelegt werden, es muss lediglich eine Systemvariable angelegt werden. Zum Anlegen der Systemvariable folgen Sie bitte der Anleitung unter [5.5 Optional: Regenmesser](#55-optional-regenmesser).

Nach der Anlage der Systemvariable werden die Daten des Regenmessers zusammen mit den Daten des Innenmoduls angezeigt.

### 4.6 Optional: Erstes Zusatz Innenmodul
1. Suchen Sie das Gerät anhand der in [3.6 Optional: Erstes Zusatz Innenmodul](#36-optional-erstes-zusatz-innenmodul) notierten Seriennummer aus der Liste heraus
2. Klicken Sie beim entsprechenden Eintrag auf den Button Einstellen
3. Wählen Sie im MODE Dropdown TEMP+HUM aus
4. Deaktivieren Sie das Häkchen bei WEATHER|USE_HMDATAPT falls es gesetzt ist
5. Setzen Sie das Häkchen bei Zyklische Statusmeldung
6. Setzen Sie das Häkchen bei WEATHER|STATISTIC
7. Speichern Sie die Änderungen mit einem Klick auf den Button OK
8. Schließen Sie das Status Popup mit einem Klick auf OK
9. Schließen Sie das Anlernen des Geräts mit einem Klick auf Fertig beim entsprechenden Eintrag ab

### 4.7 Optional: Zweites Zusatz Innenmodul
1. Suchen Sie das Gerät anhand der in [3.7 Optional: Zweites Zusatz Innenmodul](#37-optional-zweites-zusatz-innenmodul) notierten Seriennummer aus der Liste heraus
2. Klicken Sie beim entsprechenden Eintrag auf den Button Einstellen
3. Wählen Sie im MODE Dropdown TEMP+HUM aus
4. Deaktivieren Sie das Häkchen bei WEATHER|USE_HMDATAPT falls es gesetzt ist
5. Setzen Sie das Häkchen bei Zyklische Statusmeldung
6. Setzen Sie das Häkchen bei WEATHER|STATISTIC
7. Speichern Sie die Änderungen mit einem Klick auf den Button OK
8. Schließen Sie das Status Popup mit einem Klick auf OK

### 4.8 Optional: Drittes Zusatz Innenmodul
1. Suchen Sie das Gerät anhand der in [3.8 Optional: Drittes Zusatz Innenmodul](#38-optional-drittes-zusatz-innenmodul) notierten Seriennummer aus der Liste heraus
2. Klicken Sie beim entsprechenden Eintrag auf den Button Einstellen
3. Wählen Sie im MODE Dropdown TEMP+HUM aus
4. Deaktivieren Sie das Häkchen bei WEATHER|USE_HMDATAPT falls es gesetzt ist
5. Setzen Sie das Häkchen bei Zyklische Statusmeldung
6. Setzen Sie das Häkchen bei WEATHER|STATISTIC
7. Speichern Sie die Änderungen mit einem Klick auf den Button OK
8. Schließen Sie das Status Popup mit einem Klick auf OK
9. Schließen Sie das Anlernen des Geräts mit einem Klick auf Fertig beim entsprechenden Eintrag ab

### 4.9 CUxD Zentrale
1. Suchen Sie das Gerät anhand der in [3.9 CUxD Zetrale](#39-cuxd-zentrale) notierten Seriennummer aus der Liste heraus
2. Klicken Sie beim entsprechenden Eintrag auf den Button Einstellen
3. Geben Sie bei KEY|CMD_SHORT tclsh /usr/local/addons/netatmo/[netatmo_new.tcl](netatmo_new.tcl) -clientid <ihre_netatmo_clientid> -clientsecret <ihr_netatmo_clientsecret> -username <ihr_netatmo_account_user> -password <ihr netatmo_account_passwort> -deviceid <ihre_netatmo_innenmodul_id> -moduleid <ihre_netatmo_aussenmodul_id> -windid <ihre_netatmo_windmodul_id> -rainid <ihre_netatmo_regenmodul_id> -z1moduleid <ihre_netatmo_zusatzmodul1_id> -z2moduleid <ihre_netatmo_zusatzmodul2_id> -z3moduleid <ihre_netatmo_zusatzmodul3_id> ein
4. Passen Sie die Platzhalter mit Ihren Daten an, die moduleid, rainid, windid sowie die Zusatzmoduleid sind optional
5. Geben Sie bei KEY|CMD_LONG tclsh /usr/local/addons/netatmo/[netatmo_new.tcl](netatmo_new.tcl) -clientid <ihre_netatmo_clientid> -clientsecret <ihr_netatmo_clientsecret> -username <ihr_netatmo_account_user> -password <ihr netatmo_account_passwort> -deviceid <ihre_netatmo_innenmodul_id> -moduleid <ihre_netatmo_aussenmodul_id> -windid <ihre_netatmo_windmodul_id> -rainid <ihre_netatmo_regenmodul_id> -z1moduleid <ihre_netatmo_zusatzmodul1_id> -z2moduleid <ihre_netatmo_zusatzmodul2_id> -z3moduleid <ihre_netatmo_zusatzmodul3_id> ein
6. Passen Sie die Platzhalter mit Ihren Daten an, die moduleid, rainid, windid sowie die Zusatzmoduleid sind optional
7. Speichern Sie die Änderungen mit einem Klick auf den Button OK
8. Schließen Sie das Status Popup mit einem Klick auf OK
9. Schließen Sie das Anlernen des Geräts mit einem Klick auf Fertig beim entsprechenden Eintrag ab

## 5. Systemvariablen anlegen
### 5.1 Wechseln Sie zu den Systemvariablen
1. Klicken Sie auf Einstellungen -> Systemvariable

### 5.2 Main Modul
#### 5.2.1 CO2
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name CO2 ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 10000 ein
7. Geben Sie als Maßeinheit ppm ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät Netatmo Innen mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

#### 5.2.2 Luftdruck
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Luftdruck ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 2000 ein
7. Geben Sie als Maßeinheit mb ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät Netatmo Innen mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

#### 5.2.3 Sonometer
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Sonometer ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 200 ein
7. Geben Sie als Maßeinheit dB ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät Netatmo Innen mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

### 5.3 Optional: Außenmodul

### 5.4 Optional: Windmesser
**Achtung:** Der Netatmo Windmesser kann nur in Verbindung mit dem Außenmodul eingebunden werden

#### 5.4.1 Windrichtung
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Windrichtung ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 1000 ein
7. Geben Sie als Maßeinheit ° ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät Netatmo Außen mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

#### 5.4.2 Windstaerke
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Windstaerke ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 1000 ein
7. Geben Sie als Maßeinheit km/h ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät Netatmo Außen mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

#### 5.4.3 Gustangle
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Gustangle ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 1000 ein
7. Geben Sie als Maßeinheit ° ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät Netatmo Außen mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

#### 5.4.4 Guststaerke
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Guststaerke ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 1000 ein
7. Geben Sie als Maßeinheit km/h ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät Netatmo Außen mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

### 5.5 Optional: Regenmesser
**Achtung:** Der Netatmo Regenmesser kann nur in Verbindung mit dem Außenmodul eingebunden werden

#### 5.5.1 Regenmenge_1d
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Regenmenge_1d ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 1000 ein
7. Geben Sie als Maßeinheit mm ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät Netatmo Außen mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

#### 5.5.2 Regenmenge_30min
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Regenmenge_30min ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 1000 ein
7. Geben Sie als Maßeinheit mm ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät Netatmo Außen mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

#### 5.5.3 Regen aktuell
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Regenmenge_1d ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 1000 ein
7. Geben Sie als Maßeinheit mm ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät Netatmo Außen mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

### 5.6 Optional: Erstes Zusatz Innenmodul
#### 5.6.1 Z1_CO2
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Z1_CO2 ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 10000 ein
7. Geben Sie als Maßeinheit ppm ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät anhand der in [3.6 Optional: Erstes Zusatz Innenmodul](#36-optional-erstes-zusatz-innenmodul) notierten Seriennummer mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

### 5.7 Optional: Zweites Zusatz Innenmodul
#### 5.7.1 Z2_CO2
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Z2_CO2 ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 10000 ein
7. Geben Sie als Maßeinheit ppm ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät anhand der in [3.7 Optional: Zweites Zusatz Innenmodul](#37-optional-zweites-zusatz-innenmodul) notierten Seriennummer mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

### 5.8 Optional: Drittes Zusatz Innenmodul
#### 5.8.1 Z3_CO2
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name Z3_CO2 ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zahl aus
5. Geben Sie beim Wertebereich als Minimalwert 0 ein
6. Geben Sie beim Wertebereich als Maximalwert 10000 ein
7. Geben Sie als Maßeinheit ppm ein
8. Wählen Sie bei Kanalzuordnung mit aus
9. Wählen Sie in der Liste das Gerät anhand der in [3.8 Optional: Drittes Zusatz Innenmodul](#38-optional-drittes-zusatz-innenmodul) notierten Seriennummer mit einem Klick auf den Eintrag aus
10. Speichern Sie die Änderungen mit einem Klick auf den Button OK

### 5.9 Netatmo Sync
#### 5.9.1 SyncTime
1. Klicken Sie auf den Button Neu
2. Geben Sie als Name SyncTime ein
3. Optional: Geben Sie eine Beschreibung ein
4. Wählen Sie im Varablentyp Dropdown Zeichenkette aus
5. Lassen Sie die Maßeinheit leer
6. Wählen Sie bei Kanalzuordnung mit aus
7. Wählen Sie in der Liste das Gerät Netatmo Innen mit einem Klick auf den Eintrag aus
8. Speichern Sie die Änderungen mit einem Klick auf den Button OK

## 6. Programm für automatischen Datenabruf anlegen
### 6.1 Wechseln Sie zu den Programmen
1. Klicken Sie auf Programme und Verknüpfungen -> Programme & Zentralenverknüpfung

### 6.2 Netatmo Sync
1. Klicken Sie auf Neu
2. Geben Sie als Name Netatmo Sync ein
3. Fügen Sie als Bedingung Zeitsteuerung hinzu
4. Öffnen Sie die Zeitsteuerungsparameter mit einem Klick auf Zeitmodul
5. Konfigurieren Sie die Zeitsteuerungsparameter
   1. Wählen Sie bei Zeit Zeitspanne und Ganztägig
   2. Wählen Sie bei Serienmuster Zeitintervall und tragen Sie als Intervall 10 Minuten ein
   3. Wählen Sie bei Gültigkeitsdauer Kein Enddatum aus
6. Schließen Sie die mit einem Klick auf OK
7. Fügen Sie eíne Aktivität hinzu
   1. Wählen Sie im Dropdown Skript aus
   2. Klicken Sie auf die drei Punkte
   3. Fügen Sie im Eingabefeld den Inhalt der Datei [NetatmoSync_Script.txt](NetatmoSync_Script.txt) ein
   4. Passen Sie die Platzhalter mit Ihren Daten an, die moduleid, rainid, windid sowie die Zusatzmoduleid sind optional
   5. Schließen Sie das Popup mit einem Klick auf OK
8. Speichern Sie die Änderungen mit einem Klick auf OK
