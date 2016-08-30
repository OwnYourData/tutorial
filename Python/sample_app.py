#!/usr/bin/env python
# -*- coding: UTF-8 -*-
from __future__ import print_function
import pia_api
import sys
import datetime

__author__ = 'Steven Malin'
__copyright__ = 'Copyright (c) 2016 Steven Malin'
__license__ = 'MIT'
__version__ = '1'

# variables
PIA_URL = 'http://localhost:8080'  # update if needed
APP_ID = 'eu.ownyourdata.sample'  # update if needed
APP_SECRET = 'ZAhNsD6fKo2RYpX5OMY4'  # update in any case

# setup
try:
    print('Running with Python ' + sys.version[0] + '\n')
    myApp = pia_api.setupApp(PIA_URL, APP_ID, APP_SECRET)
    print('Token: ' + myApp['token'])
    myUrl = pia_api.itemsUrl(myApp['url'], 'eu.ownyourdata.sample')
    myData = {'text': 'hello world',
              'timestamp': str(datetime.datetime.now())}
except:
    print('App setup failed - stopped.', file=sys.stderr)
    sys.exit(1)

# write and read data
try:
    pia_api.writeItem(myApp, myUrl, myData)
    retVal = pia_api.readItems(myApp, myUrl)
    print('Written data: ' + retVal.text)
except:
    print('Writing to PIA failed - moving on.', file=sys.stderr)

# update and read data
try:
    myData = {'text': 'hello world',
              'timestamp': str(datetime.datetime.now())}
    pia_api.updateItem(myApp, myUrl, myData,
                       {'id': str(retVal.json()[0]['id'])})
    retVal = pia_api.readItems(myApp, myUrl)
    print('Updated data: ' + retVal.text)
except:
    print('Updating PIA item failed - moving on.', file=sys.stderr)

# delete and read data
try:
    pia_api.deleteItem(myApp, myUrl, {'id': str(retVal.json()[0]['id'])})
    retVal = pia_api.readItems(myApp, myUrl)
    print('Deleted data: ' + retVal.text)
except:
    print('Deleting PIA item failed - finished.', file=sys.stderr)
    sys.exit(1)
