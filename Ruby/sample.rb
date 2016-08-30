# last update: 2016-07-27
=begin
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
    - sicher stellen, dass HTTParty installiert ist
      $ gem install httparty
    - Client Secret 
=end

require 'httparty'
PIA_URL = "http://127.0.0.1:8080"   # !!! ggf. aktualisieren
APP_ID = "eu.ownyourdata.sample"    # !!! ggf. aktualisieren
APP_SECRET = "hGS0Sh80yOdFdHLuSAiJ" # !!! unbeding aktualisieren !!!

# Basis-Funktionen zum Zugriff auf PIA ====================
# verwendete Header bei GET oder POST Requests
def defaultHeaders(token)
  { 'Accept' => '*/*',
    'Content-Type' => 'application/json',
    'Authorization' => 'Bearer ' + token }
end

# URL beim Zugriff auf eine Repo
def itemsUrl(url, repo_name)
  url + '/api/repos/' + repo_name + '/items'
end

# Anforderung eines Tokens für ein Plugin (App)
def getToken(pia_url, app_key, app_secret)
  auth_url = pia_url + '/oauth/token'
  auth_credentials = { username: app_key, 
                       password: app_secret }
  response = HTTParty.post(auth_url,
                           basic_auth: auth_credentials,
                           body: { grant_type: 'client_credentials' })
  token = response.parsed_response["access_token"]
  if token.nil?
      nil
  else
      token
  end
end

# Hash mit allen App-Informationen zum Zugriff auf PIA
def setupApp(pia_url, app_key, app_secret)
  token = getToken(pia_url, app_key, app_secret)
  { "url"        => pia_url,
    "app_key"    => app_key,
    "app_secret" => app_secret,
    "token"      => token }
end

# Lese und CRUD Operationen für ein Plugin (App) ==========
# Daten aus PIA lesen
def readItems(app, repo_url)
  if app.nil? | app == ""
      nil
  else
      headers = defaultHeaders(app["token"])
      url_data = repo_url + '?size=2000'
      response = HTTParty.get(url_data,
                              headers: headers).parsed_response
      if response.nil? or 
         response == "" or
         response.include?("error")
          nil
      else
          response
      end
  end
end

# Daten in PIA schreiben
def writeItem(app, repo_url, item)
  headers = defaultHeaders(app["token"])
  data = item.to_json
  response = HTTParty.post(repo_url,
                           headers: headers,
                           body: data)
  response
end

# Daten in PIA aktualisieren
def updateItem(app, repo_url, item, id)
  headers = defaultHeaders(app["token"])
  data = id.merge(item).to_json
  response = HTTParty.post(repo_url,
                           headers: headers,
                           body: data)
  response    
end

# Daten in PIA löschen
def deleteItem(app, repo_url, id)
  headers = defaultHeaders(app["token"])
  url = repo_url + '/' + id.to_s
  response = HTTParty.delete(url,
                             headers: headers)
  response
end

# Beispiel Code ===========================================
# Setup
myApp = setupApp(PIA_URL, APP_ID, APP_SECRET)
puts "Token: " + myApp["token"].to_s
myUrl = itemsUrl(myApp["url"], "eu.ownyourdata.sample")
myData = { "text"      => "hello world",
           "timestamp" => Time.now}
           
# Daten schreiben & lesen         
writeItem(myApp, myUrl, myData)
retVal = readItems(myApp, myUrl)
puts retVal

# Daten aktualisieren
myData = { "text"      => "hello world again",
           "timestamp" => Time.now}
updateItem(myApp, myUrl, myData, { "id" => retVal.last["id"] })
retVal = readItems(myApp, myUrl)
puts retVal

# Daten löschen
deleteItem(myApp, myUrl, retVal.last["id"])
retVal = readItems(myApp, myUrl)
puts retVal

