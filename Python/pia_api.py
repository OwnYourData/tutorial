#!/usr/bin/env python
# -*- coding: UTF-8 -*-
from __future__ import print_function
import sys
import requests
import json

__author__ = 'Steven Malin'
__copyright__ = 'Copyright (c) 2016 Steven Malin'
__license__ = 'MIT'
__version__ = '1'
__all__ = ['itemsUrl', 'setupApp', 'readItems',
           'writeItem', 'updateItem', 'deleteItem']


def _defaultHeaders(token):
    """Default headers for GET or POST requests.

    :param token: token string."""
    return {'Accept': '*/*',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token}


def _getToken(pia_url, app_key, app_secret):
    """Get app token from PIA.

    :param pia_url: url string.
    :param app_key: app id string.
    :param app_secret: app secret string."""
    return dict(requests.post(pia_url + '/oauth/token',
                              data={'grant_type': 'client_credentials'},
                              auth=requests.auth.HTTPBasicAuth
                              (app_key, app_secret)).json())['access_token']


def itemsUrl(pia_url, repo_name):
    """Generate URL for accessing PIA Repo.

    :param pia_url: url string.
    :param repo_name: repo name string."""
    return pia_url + '/api/repos/' + repo_name + '/items'


def setupApp(pia_url, app_key, app_secret):
    """Generate dict including all app information for PIA access.

    :param pia_url: url string.
    :param app_key: app id string.
    :param app_secret: app secret string."""
    return {'url': pia_url,
            'app_key': app_key,
            'app_secret': app_secret,
            'token': _getToken(pia_url, app_key, app_secret)}


def readItems(app, repo_url):
    """Read items (data) from PIA.

    :param app: app dict.
    :param repo_url: url string from itemsUrl."""
    return requests.get(repo_url + '/?size=2000',
                        headers=_defaultHeaders(app["token"]))


def writeItem(app, repo_url, item):
    """Write item (data) into PIA.

    :param app: app dict.
    :param repo_url: url string from itemsUrl.
    :param item: data dict."""
    return requests.post(repo_url, headers=_defaultHeaders(app["token"]),
                         data=json.dumps(item))


def updateItem(app, repo_url, item, itemId):
    """Update item (data) in PIA.

    :param app: app dict.
    :param repo_url: url string from itemsUrl.
    :param item: data dict.
    :param itemId: id dict."""
    data = itemId.copy()
    data.update(item)
    return requests.post(repo_url, headers=_defaultHeaders(app["token"]),
                         data=json.dumps(data))


def deleteItem(app, repo_url, itemId):
    """Delete item (data) from PIA.

    :param app: app dict.
    :param repo_url: url string from itemsUrl.
    :param itemId: id dict."""
    return requests.delete(repo_url + '/' + itemId['id'],
                           headers=_defaultHeaders(app["token"]))

if __name__ == "__main__":
    print('This is a module, do not run it on its own.', file=sys.stderr)
    sys.exit(1)
