express = require 'express'
jade = require 'jade'
instagram = require './instagram'
google = require './reader'
db = require('mongojs').connect('printagram', ['users'])
config = require './config'

instagram.config(config.instagram)

google.config(config.google)

app = express()

# CONFIGURATION

app.configure ->
	app.set 'view engine', 'jade'
	app.set 'views', "#{__dirname}/views"
	app.set 'port', process.env.PORT || 3000

	app.use express.bodyParser()
	app.use express.static(__dirname + '/public')
	app.use express.cookieParser()
	app.use express.session
		secret : "shhhhhhhhhhhhhh!"
	#app.use express.logger()
	app.use express.methodOverride()
	app.use app.router

app.configure 'development', () ->
	app.use express.errorHandler
		dumpExceptions: true
		showStack     : true

app.configure 'production', () ->
	app.use express.errorHandler()

# ROUTES

app.get '/', (req, res) ->
	instagram.getSubscriptions (resp) ->
		console.log resp
	res.render 'index',
		title: 'Hello World!'

app.get '/auth', (req, res) ->
	instagram.auth (resp) ->
		res.redirect(resp)

app.get '/google-auth', (req, res) ->
	google.auth (resp) ->
		res.redirect(resp)

app.get '/callback', (req, res) ->
	instagram.reqAccToken req.query.code, (resp) ->
		req.session.instagram = resp
		res.redirect '/finished'

app.get '/oauth2callback', (req, res) -> 
	google.getToken req.query.code, (resp) ->
		req.session.google = resp
		res.redirect '/find-printer'

app.get '/create-push', (req, res) ->
	instagram.subscribe (resp) ->
		console.log "ok"
	res.end()

app.post '/push', (req, res) ->
	console.log req.body
	db.users.findOne {id: req.body[0].object_id}, (err, docs) ->
		throw err if err
		token = docs.instagram.access_token
		google_token = docs.google.access_token
		printer = docs.printer
		instagram.getMedia token, (resp) ->
			image = resp.data[0].images.standard_resolution.url
			google.print image, printer, google_token, (resp) ->
				console.log resp
	res.end()

app.get '/push', (req, res) ->
	# Handle first incoming get request
	console.log req.query['hub.challenge']
	# console.log challenge
	res.send(req.query['hub.challenge'])
		
	#instagram.confirm challenge, (resp) ->
		#console.log "ok"

app.get '/find-printer', (req, res) ->
	console.log req.session
	google.getPrinters req.session.google.access_token, (resp) ->
		console.log resp
		res.render 'find-printer'
			printers: resp
			
app.get '/save-printer', (req, res) ->
	req.session.printer = req.query.printerID
	res.redirect '/add-instagram'

app.get '/add-instagram', (req, res) ->
	res.render 'add-instagram'
		printer: req.session.printer

app.get '/finished', (req, res) ->
	console.log req.session
	user =
		printer: req.session.printer
		id: req.session.instagram.user.id
		instagram:
			access_token: req.session.instagram.access_token
			id: req.session.instagram.user.id
			username: req.session.instagram.user.username
			profile_picture: req.session.instagram.user.profile_picture
		google:
			access_token: req.session.google.access_token
			refresh_token: req.session.google.refresh_token
	db.users.insert user, (err) ->
		throw err if err
		console.log "saved to database"

	res.render 'finished'
		instagram: req.session.instagram.user.username
		google: req.session.google.access_token
		printer: req.session.printer

# SERVER
	
app.listen(app.get('port'))
console.log "Express server listening on port #{ app.get 'port' }"