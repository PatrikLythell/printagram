express = require 'express'
jade = require 'jade'
instagram = require './instagram'
google = require './reader'

instagram.config
	client_id: '5e74d68db242474daa26bc02ebdd3007'
	client_secret: 'c9017bccf8504d6e9f540850dc7ea6ba'
	redirect_uri: 'http://localhost:3000/callback'

google.config
  redirect_uri: 'http://ogilvypi.herokuapp.com/auth'
  client_id: '1096377820701.apps.googleusercontent.com'
  client_secret: 'u_OulT_9UDPlR4VtR06lwYTc'


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
	# instagram.getSubscriptions (resp) ->
		# console.log resp
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
		access_token = resp
		console.log access_token

app.post '/create-push', (req, res) ->
	tag = req.body.hash_tag
	instagram.subscribe tag, (resp) ->
		console.log "ok"
	res.end()

app.post '/push', (req, res) ->
	console.log req.body
	res.end()

app.get '/push', (req, res) ->
	# Handle first incoming get request
	console.log req.query['hub.challenge']
	# console.log challenge
	res.send(req.query['hub.challenge'])
		
	#instagram.confirm challenge, (resp) ->
		#console.log "ok"


			
# SERVER
	
app.listen(app.get('port'))
console.log "Express server listening on port #{ app.get 'port' }"