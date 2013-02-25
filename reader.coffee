request = require 'request'
#qs = require 'querystring'

redirect_uri = ''
client_id = ''
client_secret = ''

authorization_code = true

url = 'https://accounts.google.com/o/oauth2/token'

https://www.google.com/cloudprint/submit?title=test&content=http://distilleryimage1.s3.amazonaws.com%2ff5d487fc6eef11e28a3222000a9f17b2_7.jpg&capabilities=ColorModel:BlackWhite&tag=test&printerid=e359c37c-fca4-00b2-3080-35f63bd65b1b&contentType=url


https://www.google.com/cloudprint/printer?printerid=e359c37c-fca4-00b2-3080-35f63bd65b1b


apiBase = 'https://www.google.com/reader/api/0/'

module.exports =

	# CONFIGS

	config: (config) ->
		redirect_uri = config.redirect_uri
		client_id = config.client_id
		client_secret = config.client_secret
		return

	auth: (callback) ->
		auth_url = "https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/cloudprint+https://www.googleapis.com/auth/userinfo.profile&response_type=code&redirect_uri=#{ redirect_uri }&client_id=#{ client_id }"
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

	getUser: (token, callback, i) ->
		request.get apiBase+'user-info?output=json&access_token='+token, (err, res, body) =>
			# https://www.googleapis.com/oauth2/v1/userinfo?output=json&access_token
			# for getting profile picture in future
			throw err if err
			if res.statusCode is 200 # IF 401 exchange refresh token for access token or just log user out and start over. Second might be safer
				callback(null, JSON.parse(body))
			else if res.statusCode is 401
				callback({code: 'login'}, null)
			else
				if !i or i < 4
					i = 0 if !i
					setTimeout ( => @.getUser(token, callback, i+1)), 50
				else
					callback({code: 500}, null)

	getFeed: (token, callback) ->
		request.get apiBase+'stream/contents?output=json&n=5&access_token='+token, (err, res, body) ->
			throw err if err
			console.log res.statusCode
			if res.statusCode is 200
				callback(JSON.parse(body))
			else
				console.log "you're fucked by third one"
				#console.log res

	getUnread: (token, callback) ->
		#initial call to get unread posts than forEach loop on response's to get appropriate articles from feeds
		request.get apiBase+'unread-count?output=json&access_token='+token, (err, res, body) ->
			throw err if err
			console.log res.statusCode
			callback(JSON.parse(body))



