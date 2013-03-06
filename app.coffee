express = require 'express'
jade = require 'jade'
instagram = require './instagram'
google = require './reader'
db = require('mongojs').connect('printagram', ['users'])
config = require './config'
canvas = require './canvas'

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
	# google.jobs('a63a5007-5ab5-5db1-f6d8-45a2a972a3b6')
	# canvas.makeA6 "hej", "ho", (resp) ->
	# console.log new Date(1362353601*1000)
	res.render 'index',
		title: 'Hello World!'

app.get '/auth', (req, res) ->
	instagram.auth (resp) ->
		res.redirect(resp)

app.get '/google-auth', (req, res) ->
	if req.session.instagram and req.session.instagram.user.id
		db.users.findOne
			id: req.session.instagram.user.id
		, (err, docs) ->
			if docs is null
				google.auth (resp) ->
					res.redirect(resp)
			else
				res.redirect 'profile'
	else
		google.auth (resp) ->
			res.redirect(resp)

app.get '/callback', (req, res) ->
	instagram.reqAccToken req.query.code, (resp) ->
		req.session.instagram = resp
		res.redirect '/paper-size'

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
		printer = docs.printer.id
		instagram.getMedia token, (resp) ->
			# console.log resp
			console.log resp.data[0].caption
			image = resp.data[0].images.standard_resolution.url
			caption = resp.data[0].caption.text
			date = resp.data[0].caption.created_time
			docs.google.refresh_token
			google.refresh docs.google.refresh_token, (resp) ->
				google_token = resp
				canvas.makeA6 caption, image, date, ->
					console.log "printed pic"
				#google.print image, printer, google_token, (resp) ->
					#console.log resp
	res.end()

app.get '/push', (req, res) ->
	res.send(req.query['hub.challenge'])

app.get '/find-printer', (req, res) ->
	console.log req.session
	google.getPrinters req.session.google.access_token, (resp) ->
		console.log resp
		res.render 'find-printer'
			printers: resp
			
app.get '/save-printer', (req, res) ->
	console.log req.headers
	req.session.printer = 
		name: req.query.printerName
		id: req.query.printerId
	console.log req.session
	if req.headers['x-pjax']
		res.render 'pjax/add-instagram'
			printer: req.query.printerName
	else
		res.render 'add-instagram'
		  printer: req.query.printerName

app.get '/save-size', (req, res) ->
	req.session.size = 
		size: req.query.paperSize
	if req.headers['x-pjax']
		res.render 'pjax/profile'
	else
		res.render 'profile'

app.get '/profile', (req, res) ->
	if req.headers['x-pjax']
		res.render 'pjax/profile'
	else
		res.render 'profile'

app.get '/add-instagram', (req, res) ->
	res.render 'add-instagram'
		printer: req.session.printer

app.get '/paper-size', (req, res) ->
	res.render 'paper-size'

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