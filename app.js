// Generated by CoffeeScript 1.3.3
(function() {
  var app, db, express, google, instagram, jade, uid;

  express = require('express');

  jade = require('jade');

  instagram = require('./instagram');

  google = require('./reader');

  db = require('mongojs').connect('printagram', ['users']);

  instagram.config({
    client_id: '5e74d68db242474daa26bc02ebdd3007',
    client_secret: 'c9017bccf8504d6e9f540850dc7ea6ba',
    redirect_uri: 'http://prin.localtunnel.me/callback'
  });

  google.config({
    redirect_uri: 'http://prin.localtunnel.me/oauth2callback',
    client_id: '1031440145368.apps.googleusercontent.com',
    client_secret: 'gD5lFDE-lyJ3zMzV33lvzYEb'
  });

  app = express();

  app.configure(function() {
    app.set('view engine', 'jade');
    app.set('views', "" + __dirname + "/views");
    app.set('port', process.env.PORT || 3000);
    app.use(express.bodyParser());
    app.use(express["static"](__dirname + '/public'));
    app.use(express.cookieParser());
    app.use(express.session({
      secret: "shhhhhhhhhhhhhh!"
    }));
    app.use(express.methodOverride());
    return app.use(app.router);
  });

  app.configure('development', function() {
    return app.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
  });

  app.configure('production', function() {
    return app.use(express.errorHandler());
  });

  uid = '8247617';

  app.get('/', function(req, res) {
    instagram.getSubscriptions(function(resp) {
      return console.log(resp);
    });
    google.test();
    return res.render('index', {
      title: 'Hello World!'
    });
  });

  app.get('/auth', function(req, res) {
    return instagram.auth(function(resp) {
      return res.redirect(resp);
    });
  });

  app.get('/google-auth', function(req, res) {
    return google.auth(function(resp) {
      return res.redirect(resp);
    });
  });

  app.get('/callback', function(req, res) {
    return instagram.reqAccToken(req.query.code, function(resp) {
      req.session.instagram = resp;
      return res.redirect('/finished');
    });
  });

  app.get('/oauth2callback', function(req, res) {
    return google.getToken(req.query.code, function(resp) {
      req.session.google = resp;
      return res.redirect('/find-printer');
    });
  });

  app.get('/create-push', function(req, res) {
    instagram.subscribe(function(resp) {
      return console.log("ok");
    });
    return res.end();
  });

  app.post('/push', function(req, res) {
    console.log(req.body);
    db.users.findOne({
      id: uid
    }, function(err, docs) {
      var token;
      if (err) {
        throw err;
      }
      token = docs.instagram.access_token;
      return instagram.getMedia(token, function(resp) {
        var image;
        return image = resp.data[0].images.standard_resolution.url;
      });
    });
    return res.end();
  });

  app.get('/push', function(req, res) {
    console.log(req.query['hub.challenge']);
    return res.send(req.query['hub.challenge']);
  });

  app.get('/find-printer', function(req, res) {
    console.log(req.session);
    return google.getPrinters(req.session.google.access_token, function(resp) {
      console.log(resp);
      return res.render('find-printer', {
        printers: resp
      });
    });
  });

  app.get('/save-printer', function(req, res) {
    req.session.printer = req.query.printerID;
    return res.redirect('/add-instagram');
  });

  app.get('/add-instagram', function(req, res) {
    return res.render('add-instagram', {
      printer: req.session.printer
    });
  });

  app.get('/finished', function(req, res) {
    var user;
    console.log(req.session);
    user = {
      printer: req.session.printer,
      id: req.session.instagram.user.id,
      instagram: {
        access_token: req.session.instagram.access_token,
        id: req.session.instagram.user.id,
        username: req.session.instagram.user.username,
        profile_picture: req.session.instagram.user.profile_picture
      },
      google: {
        access_token: req.session.google.access_token,
        refresh_token: req.session.google.refresh_token
      }
    };
    db.users.insert(user, function(err) {
      if (err) {
        throw err;
      }
      return console.log("saved to database");
    });
    return res.render('finished', {
      instagram: req.session.instagram.user.username,
      google: req.session.google.access_token,
      printer: req.session.printer
    });
  });

  app.listen(app.get('port'));

  console.log("Express server listening on port " + (app.get('port')));

}).call(this);
