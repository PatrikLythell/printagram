request = require 'request'

client_id = ''
client_secret = ''
redirect_uri = ''

access_token = '8247617.5e74d68.c23047f134fb431ba956391a229a179c'

module.exports =
  
  config: (config) ->
    client_id = config.client_id
    client_secret = config.client_secret
    redirect_uri = config.redirect_uri

  auth: (callback) ->
    auth_url = "https://api.instagram.com/oauth/authorize/?client_id=#{client_id}&redirect_uri=#{redirect_uri}&response_type=code"
    callback(auth_url)

  reqAccToken: (code, callback) ->
    params =
      client_id     : client_id
      client_secret : client_secret
      grant_type    : 'authorization_code'
      redirect_uri  : redirect_uri
      code          : code
    request.post
      url: 'https://api.instagram.com/oauth/access_token'
      form: params
    , (err, res, body) ->
      throw err if err
      callback(JSON.parse(body))

  subscribe: (tag, callback) ->
    console.log "subscribe"
    params = 
      client_id     : client_id
      client_secret : client_secret
      object        : 'user'
      aspect        : 'media'
      # object_id     : tag
      callback_url  : 'http://4f7e.localtunnel.com/push'
    console.log params
    request.post
      url: 'https://api.instagram.com/v1/subscriptions/'
      form: params
    , (err, res, body) ->
      throw err if err
      console.log body
      callback()

  getSubscriptions: (callback) ->
    params = 
      client_id     : client_id
      client_secret : client_secret
    request.get
      url: 'https://api.instagram.com/v1/subscriptions'
      qs: params
    , (err, res, body) ->
      callback(JSON.parse(body))

  delSubscriptions: (callback) ->
    params = 
      client_id     : client_id
      client_secret : client_secret
      object        : "all"
    request.del 
      url: 'https://api.instagram.com/v1/subscriptions'
      qs: params
    , (err, res, body) ->
      callback(JSON.parse(body))
  

