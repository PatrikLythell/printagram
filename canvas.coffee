Canvas = require 'canvas'
Image = Canvas.Image
fs = require 'fs'
request = require 'request'

module.exports =

  makeA6: (caption, pic, date, callback) ->
    canvas = new Canvas(1240, 1748)
    ctx = canvas.getContext('2d')
    ctx.patternQuality = 'best'
    ctx.fillStyle = '#fff'
    ctx.fillRect(0, 0, 1240, 1748)
    request.get 
      url: pic
      encoding: null
    , (err, res, body) ->
      throw err if err
      console.log body
      date = new Date(parseInt(date)*1000)
      month = date.getMonth() + 1
      date = date.getDate().toString() + '/' + month + '/' + date.getFullYear().toString()
      img = new Image
      img.src = body
      ctx.drawImage(img, 75, 75, 1090, 1090)
      ctx.fillStyle = '#000'
      ctx.font = '36px sans-serif'
      ctx.fillText(caption, 100, 1240)
      ctx.fillText(date, 960, 1240)

      out = fs.createWriteStream(__dirname + '/test.jpeg')
      stream = canvas.jpegStream()

      stream.on 'data', (chunk) ->
        out.write(chunk)

      stream.on 'end', ->
        console.log "saved image"
        callback()