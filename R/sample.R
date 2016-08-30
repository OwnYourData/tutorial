# OYD R-Tutorial - last update:2016-07-26
# Manifest for sample app ===================================
'
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
encode with https://www.base64encode.org/
ew0KICAibmFtZSI6Ik93bllvdXJEYXRhIEJlaXNwaWVsIiwNCiAgImlkZW50aWZpZXIiOiJldS5vd255b3VyZGF0YS5zYW1wbGUiLA0KICAidHlwZSI6ImV4dGVybmFsIiwNCiAgImRlc2NyaXB0aW9uIjoiQmVpc3BpZWwgZsO8ciBlaW5lIGVpbmZhY2hlIE93bllvdXJEYXRhIEFwcCIsDQogICJwZXJtaXNzaW9ucyI6WyJldS5vd255b3VyZGF0YS5zYW1wbGU6cmVhZCIsDQogICAgICAgICAgICAgICAgICJldS5vd255b3VyZGF0YS5zYW1wbGU6d3JpdGUiLA0KICAgICAgICAgICAgICAgICAiZXUub3dueW91cmRhdGEuc2FtcGxlOnVwZGF0ZSIsDQogICAgICAgICAgICAgICAgICJldS5vd255b3VyZGF0YS5zYW1wbGU6ZGVsZXRlIl0NCn0=

Configure the demo:
* PIA Setup: http://osdwiki.open-entry.com/doku.php/de:projekte:ownyourdata
  - install JAVA
  - install PIA
  - start PIA

* register Sample plugin (app)
  - login to PIA einloggen
    URL: http://127.0.0.1:8080
    user: admin
    password: admin
  - Entities > Plugin > [Register a new Plugin]
  - insert base64 encoded String (ew0KICA...9DQo=)
  - confirm plugin registration, click: [Grant]
  - note credentials for access:
    . Client ID
    . Client Secret

* update config section in sample.R
  - PIA_URL - URL (usually you can leave "http://127.0.0.1:8080")
    relevant output shown after starting PIA:
    ----------------------------------------------------------
	Local: 		http://127.0.0.1:8080
        External: 	http://X.Y.Z.T:8080
    ----------------------------------------------------------
  - APP_ID - as specified in PIA, menu 
    Entities > Plugin > Sample Plugin > click "Edit"
    in the shown dialog it is the field "Identifier"
    (usually you can leave "eu.ownyourdata.sample")
  - APP_SECRET - as specified in PIA, menu 
    Entities > Plugin > Sample Plugin > click "Edit"
    in the shown dialog it is the field "Secret"
    (you need to update the configuration in sample.R!)

* run sample.R
'

# Config Section ==========================================
PIA_URL    <- "http://127.0.0.1:8080"
APP_ID     <- "eu.ownyourdata.sample"
APP_SECRET <- "hGS0Sh80yOdFdHLuSAiJ" # !!! update !!!

# Required Packages =======================================
library(rjson)
library(httr)
library(RCurl)

# Low-level functions to access PIA =======================
# used header for GET and POST requests
defaultHeaders <- function(token) {
        c('Accept'        = '*/*',
          'Content-Type'  = 'application/json',
          'Authorization' = paste('Bearer', token))
}

# URL to access a repo
itemsUrl <- function(url, repo_name) {
        paste0(url, '/api/repos/', repo_name, '/items')
}

# request token for a plugin (app)
getToken <- function(pia_url, app_key, app_secret) {
        auth_url <- paste0(pia_url, '/oauth/token')
        response <- tryCatch(
                postForm(auth_url,
                         client_id     = app_key,
                         client_secret = app_secret,
                         grant_type    = 'client_credentials'),
                error = function(e) { return(NA) })
        if (is.na(response)) {
                return(NA)
        } else {
                return(fromJSON(response[1])$access_token)
        }
}

# vector with all plugin (app) infos to access PIA
setupApp <- function(pia_url, app_key, app_secret) {
        app_token <- getToken(pia_url, 
                          app_key, 
                          app_secret)
        c('url'        = pia_url,
          'app_key'    = app_key,
          'app_secret' = app_secret,
          'token'      = app_token)
}

# Read and CRUD Operations for a Plugin (App) =============
# read data from PIA
readItems <- function(app, repo_url) {
        if (length(app) == 0) {
                data.frame()
        } else {
                headers <- defaultHeaders(app[['token']])
                url_data <- paste0(repo_url, '?size=2000')
                response <- tryCatch(
                        getURL(url_data,
                               .opts=list(httpheader = headers)),
                        error = function(e) { return(NA) })
                if (is.na(response)) {
                        data.frame()
                } else {
                        if (nchar(response) > 0) {
                                retVal <- fromJSON(response)
                                if(length(retVal) == 0) {
                                        data.frame()
                                } else {
                                        if ('error' %in% names(retVal)) {
                                                data.frame()
                                        } else {
                                                if (!is.null(retVal$message)) {
                                                        if (retVal$message == 'error.accessDenied') {
                                                                data.frame()
                                                        } else {
                                                                retVal
                                                        }
                                                } else {
                                                        retVal
                                                }
                                        }
                                }
                        } else {
                                data.frame()
                        }
                }
        }
}

# write data into PIA
writeItem <- function(app, repo_url, item) {
        headers <- defaultHeaders(app[['token']])
        data <- rjson::toJSON(item)
        response <- tryCatch(
                postForm(repo_url,
                         .opts=list(httpheader = headers,
                                    postfields = data)),
                error = function(e) { return(NA) })
        response
}

# update data in PIA
updateItem <- function(app, repo_url, item, id) {
        headers <- defaultHeaders(app[['token']])
        item <- c(item, c(id=as.numeric(id)))
        data <- rjson::toJSON(item)
        response <- tryCatch(
                postForm(repo_url,
                         .opts=list(httpheader = headers,
                                    postfields = data)),
                error = function(e) { return(NA) })
        response
}

# delete data in PIA
deleteItem <- function(app, repo_url, id){
        headers <- defaultHeaders(app[['token']])
        item_url <- paste0(repo_url, '/', id)
        response <- tryCatch(
                DELETE(item_url, 
                       add_headers(headers)),
                error = function(e) { return(NA) })
        response
}

# Sample Code =============================================
# Setup
print("OwnYourData Tutorial")
myApp <- setupApp(PIA_URL, APP_ID, APP_SECRET)
myUrl <- itemsUrl(myApp[['url']], "eu.ownyourdata.sample")
myData <- c('text'      = 'hello world',
            'timestamp' = as.character(Sys.time()))
cat(paste(
        "Token:",
        myApp[['token']],
        "\n"))

# write and read data 
print("Write data")
writeItem(myApp, myUrl, myData)
retVal <- readItems(myApp, myUrl)
print(do.call(rbind, lapply(retVal, data.frame, stringsAsFactors=FALSE)))

# update data
print("Update data")
myData <- c('text'      = 'hello world again',
            'timestamp' = as.character(Sys.time()))
updateItem(myApp, myUrl, myData, unlist(retVal[length(retVal)])[['id']])
retVal <- readItems(myApp, myUrl)
print(do.call(rbind, lapply(retVal, data.frame, stringsAsFactors=FALSE)))

# delete data
print("Delete data")
deleteItem(myApp, myUrl, unlist(retVal[length(retVal)])[['id']])
retVal <- readItems(myApp, myUrl)
print(do.call(rbind, lapply(retVal, data.frame, stringsAsFactors=FALSE)))
