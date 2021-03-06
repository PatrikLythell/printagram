// Generated by CoffeeScript 1.3.3
(function() {
  var apiBase, authorization_code, client_id, client_secret, hej, redirect_uri, request, thing, url;

  request = require('request');

  redirect_uri = '';

  client_id = '';

  client_secret = '';

  authorization_code = true;

  url = 'https://accounts.google.com/o/oauth2/token';

  hej = "https://www.google.com/cloudprint/submit?title=test&content=http://distilleryimage1.s3.amazonaws.com%2ff5d487fc6eef11e28a3222000a9f17b2_7.jpg&tag=test&printerid=e359c37c-fca4-00b2-3080-35f63bd65b1b&contentType=url";

  apiBase = 'https://www.google.com/cloudprint/';

  thing = "https://www.google.com/cloudprint/submit?title=test&content=http://distilleryimage2.s3.amazonaws.com/522d70fc81fd11e2a5bc22000a9e2899_7.jpg&tag=test&contentType=url&printerid=39426f74-808d-6637-8566-84951bf1c629";

  module.exports = {
    config: function(config) {
      redirect_uri = config.redirect_uri;
      client_id = config.client_id;
      client_secret = config.client_secret;
    },
    auth: function(callback) {
      var auth_url;
      auth_url = "https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/cloudprint+https://www.googleapis.com/auth/userinfo.profile&access_type=offline&response_type=code&redirect_uri=" + redirect_uri + "&client_id=" + client_id;
      return callback(auth_url);
    },
    getToken: function(reqToken, callback) {
      var params;
      params = {
        "code": reqToken,
        "client_id": client_id,
        "client_secret": client_secret,
        "redirect_uri": redirect_uri,
        "grant_type": "authorization_code"
      };
      return request.post({
        url: url,
        form: params
      }, function(err, res, body) {
        if (err) {
          throw err;
        }
        console.log(res.statusCode);
        if (res.statusCode === 200) {
          return callback(JSON.parse(body));
        } else {
          return console.log("you're fucked by first one");
        }
      });
    },
    refresh: function(token, callback) {
      var params;
      params = {
        client_secret: client_secret,
        grant_type: "refresh_token",
        refresh_token: token,
        client_id: client_id
      };
      return request.post({
        url: "https://accounts.google.com/o/oauth2/token",
        form: params
      }, function(err, res, body) {
        body = JSON.parse(body);
        return callback(body.access_token);
      });
    },
    test: function() {
      return request.get({
        url: apiBase + 'submit',
        headers: {
          authorization: "Bearer ya29.AHES6ZQHTH12OgzUR1zvRh-9IdOp1zFHVSpkue8kauW2Tuk"
        }
      }, function(err, res, body) {
        return console.log(body);
      });
    },
    getPrinters: function(token, callback) {
      var _this = this;
      return request.get({
        url: apiBase + 'search?access_token=' + token,
        headers: {
          "X-Cloudprint-Proxy": "Google-JS"
        }
      }, function(err, res, body) {
        if (err) {
          throw err;
        }
        if (res.statusCode === 200) {
          return callback(JSON.parse(body));
        } else if (res.statusCode === 401) {
          return console.log("nope");
        }
      });
    },
    print: function(image, printerid, token, callback) {
      return request.get({
        url: "" + apiBase + "submit?title=test&content=" + image + "&tag=null&contentType=url&printerid=" + printerid,
        headers: {
          authorization: "Bearer " + token
        }
      }, function(err, res, body) {
        return callback(JSON.parse(body));
      });
    },
    jobs: function(printerid) {
      return request.get({
        url: "" + apiBase + "jobs?printerid={#printerid}"
      }, function(err, res, body) {
        return console.log(body);
      });
    }
  };

}).call(this);
