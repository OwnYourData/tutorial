Manifest für Beispiel App (encodieren zB mit https://www.base64encode.org/)
{
  "name":"OwnYourData Beispiel",
  "identifier":"eu.ownyourdata.sample",
  "type":"external",
  "description":"Beispiel für eine einfache OwnYourData App",
  "permissions":["eu.ownyourdata.sample:read",
                 "eu.ownyourdata.sample:write",
                 "eu.ownyourdata.sample:update",
                 "eu.ownyourdata.sample:delete"]
}
ew0KICAibmFtZSI6Ik93bllvdXJEYXRhIEJlaXNwaWVsIiwNCiAgImlkZW50aWZpZXIiOiJldS5vd255b3VyZGF0YS5zYW1wbGUiLA0KICAidHlwZSI6ImV4dGVybmFsIiwNCiAgImRlc2NyaXB0aW9uIjoiQmVpc3BpZWwgZsO8ciBlaW5lIGVpbmZhY2hlIE93bllvdXJEYXRhIEFwcCIsDQogICJwZXJtaXNzaW9ucyI6WyJldS5vd255b3VyZGF0YS5zYW1wbGU6cmVhZCIsDQogICAgICAgICAgICAgICAgICJldS5vd255b3VyZGF0YS5zYW1wbGU6d3JpdGUiLA0KICAgICAgICAgICAgICAgICAiZXUub3dueW91cmRhdGEuc2FtcGxlOnVwZGF0ZSIsDQogICAgICAgICAgICAgICAgICJldS5vd255b3VyZGF0YS5zYW1wbGU6ZGVsZXRlIl0NCn0=

Einrichten der Demo:
* PIA Setup: http://osdwiki.open-entry.com/doku.php/de:projekte:ownyourdata
    - JAVA installieren
    - PIA installieren
    - PIA starten
* Beispiel App registrieren
    - in PIA einloggen (http://127.0.0.1:8080, user: admin, passwort: admin)
    - Entities > Plugin > [Register a new Plugin]
    - base64 encodierten String (ew0KICA...) einfügen
    - Plugin-Registrierung bestätigen: [Grant]
    - Credentials für Zugriff notieren:
      . Client ID
      . Client Secret
* Beispiel Programm ausführen
    - sicher stellen, dass requests installiert ist
      $ pip install requests
    - Client Secret