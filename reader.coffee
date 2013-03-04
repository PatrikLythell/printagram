request = require 'request'
#qs = require 'querystring'

redirect_uri = ''
client_id = ''
client_secret = ''

authorization_code = true

url = 'https://accounts.google.com/o/oauth2/token'

hej = "https://www.google.com/cloudprint/submit?title=test&content=http://distilleryimage1.s3.amazonaws.com%2ff5d487fc6eef11e28a3222000a9f17b2_7.jpg&tag=test&printerid=e359c37c-fca4-00b2-3080-35f63bd65b1b&contentType=url"

apiBase = 'https://www.google.com/cloudprint/'

module.exports =

	# CONFIGS

	config: (config) ->
		redirect_uri = config.redirect_uri
		client_id = config.client_id
		client_secret = config.client_secret
		return

	auth: (callback) ->
		auth_url = "https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/cloudprint+https://www.googleapis.com/auth/userinfo.profile&access_type=offline&response_type=code&redirect_uri=#{ redirect_uri }&client_id=#{ client_id }"
		callback(auth_url)

	getToken: (reqToken, callback) ->
		params =
			"code": reqToken
			"client_id": client_id
			"client_secret": client_secret
			"redirect_uri": redirect_uri
			"grant_type": "authorization_code"
		request.post
			url: url
			form: params
		, (err, res, body) ->	
			throw err if err
			console.log res.statusCode
			if res.statusCode is 200 # IF 401 exchange refresh token for access token or just log user out and start over. Second might be safer
				callback(JSON.parse(body))
			else
				console.log "you're fucked by first one"
				#console.log res

	getPrinters: (token, callback) ->
		request.get 
			url: apiBase+'search?access_token='+token
			headers:
				"X-Cloudprint-Proxy": "Google-JS"
		, (err, res, body) =>
			# https://www.googleapis.com/oauth2/v1/userinfo?output=json&access_token
			# for getting profile picture in future
			throw err if err
			if res.statusCode is 200 # IF 401 exchange refresh token for access token or just log user out and start over. Second might be safer
				callback(JSON.parse(body))
			else if res.statusCode is 401
				console.log "nope"

	test: ->
		token = 'ya29.AHES6ZQrbctO7uVG13GlnZ4Pi22PNZmwck64vQZOiuyHMFmpcfFEGg'
		request.get
			url: apiBase+'submit'
			headers:
				authorization: "Bearer #{token}"
			, (err, res, body) ->
				console.log body
