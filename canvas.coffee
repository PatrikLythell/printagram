Canvas = require 'canvas'
Image = Canvas.Image
fs = require 'fs'
request = require 'request'

class createPic
  
  constructor: (@caption, @pic, @date, @callback) ->
    @date = new Date(parseInt(date)*1000)
    @i = 0
    @canvas = new Canvas(1240, 1748)
    @ctx = @canvas.getContext('2d')
    @ctx.patternQuality = 'best'
    @ctx.fillStyle = '#fff'
    @ctx.fillRect(0, 0, 1240, 1748)
    @drawImage()
    @drawText()

  drawImage: ->
    request.get
      url: @pic
      encoding: null
    , (err, res, body) =>
      img = new Image
      img.src = body
      @ctx.drawImage(img, 75, 75, 1090, 1090)
      @callbackCounter("drawimage")

  drawText: ->
    caption = @caption
    month = @date.getMonth() + 1
    date = @date.getFullYear().toString() + '.' + month + '.' + @date.getDate().toString()
    @ctx.fillStyle = '#000'
    @ctx.font = '36px PrestigeEliteStd-Bd'
    linebreak = 1240
    if caption.length > 100
        caption = caption.slice(0, 130) + '...' if caption.length > 135
        for num in [90..0]
          letter = caption.charAt(num)
          if letter is " "
            thirdLine = caption.slice(num+1)
            for nextNum in [45..0]
              letter = caption.charAt(nextNum)
              if letter is " "
                secondLine = caption.slice(nextNum+1, num)
                firstLine = caption.slice(0, nextNum)
                break
            break
        @ctx.fillText(firstLine, 100, linebreak)
        linebreak +=60
        @ctx.fillText(secondLine, 100, linebreak)
        linebreak +=60
        @ctx.fillText(thirdLine, 100, linebreak)
        @ctx.fillText(date, 100, linebreak+80)
        @callbackCounter("drawtext")
      else if caption.length > 50
        for num in [45..0]
          letter = caption.charAt(num)
          if letter is " "
            firstLine = caption.slice(0, num)
            secondLine = caption.slice(num+1)
            break
        @ctx.fillText(firstLine, 100, linebreak)
        linebreak +=60
        @ctx.fillText(secondLine, 100, linebreak)
        @ctx.fillText(date, 100, linebreak+80)
        @callbackCounter()
      else
        @ctx.fillText(caption, 100, linebreak)
        @ctx.fillText(date, 100, linebreak+80)
        @callbackCounter()

  callbackCounter: (who) ->
    @i++
    console.log who
    @writeFile() if @i is 2

  writeFile: ->
    uniqueId = ->
      id = ""
      id += Math.random().toString(36).substr(2) while id.length < 8
      id.substr(0,8)
    picName = uniqueId()
    out = fs.createWriteStream(__dirname + '/public/img/tmp/' + picName + '.jpeg')
    stream = @canvas.jpegStream()

    stream.on 'data', (chunk) ->
      out.write(chunk)

    stream.on 'end', =>
      console.log "saved image"
      @callback(picName + '.jpeg')


module.exports =
  
  make: (size, caption, pic, date, callback) ->
    createPic caption, pic, date, (resp) ->
      callback(resp)