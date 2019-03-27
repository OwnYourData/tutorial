# write data 

var pia_url = "https://vault.datentresor.org"; # replace with OYD data vault
var app_key = "eu.ownyourdata.app";            # replace with respective app identifier
var app_secret = "secret";                     # replace with respective app secret
var repo = app_key;                            # replace with repo name
var request = new XMLHttpRequest();
request.open('POST', pia_url + '/oauth/token?' + 
             'grant_type=client_credentials&' + 
             'client_id=' + app_key + '&' +
             'client_secret=' + app_secret, true);
request.send('');
request.onreadystatechange = function () {
    if (request.readyState == 4) {
        var token = JSON.parse(request.responseText).access_token;
        var req2 = new XMLHttpRequest();
        req2.open('POST', pia_url + '/api/repos/' + repo + '/items', true);
        req2.setRequestHeader('Accept', '*/*');
        req2.setRequestHeader('Content-Type', 'application/json');
        req2.setRequestHeader('Authorization', 'Bearer ' + token);
        var data = JSON.stringify({volume: val,
                                   time: Date.now(), 
                                   _oydRepoName: 'Gonimo'});
        req2.send(data);
    }
}
