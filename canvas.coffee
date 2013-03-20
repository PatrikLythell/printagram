Canvas = require 'canvas'
Image = Canvas.Image
fs = require 'fs'
request = require 'request'

class createPic
  
  constructor: (@paper, @caption, @pic, @date, @callback) ->
    @date = new Date(parseInt(date)*1000)
    @i = 0
    @canvas = new Canvas(@paper.width, @paper.height)
    @ctx = @canvas.getContext('2d')
    @ctx.patternQuality = 'best'
    @ctx.fillStyle = '#fff'
    @ctx.fillRect(0, 0, @paper.width, @paper.height)
    @drawImage()
    @drawText()

  drawImage: ->
    request.get
      url: @pic
      encoding: null
    , (err, res, body) =>
      img = new Image
      img.src = body
      @ctx.drawImage(img, @paper.margin, @paper.margin, @paper.image, @paper.image)
      @callbackCounter("drawimage")

  drawText: ->
    caption = @caption
    month = @date.getMonth() + 1
    date = @date.getFullYear().toString() + '.' + month + '.' + @date.getDate().toString()
    @ctx.fillStyle = '#000'
    @ctx.font = @paper.fontSize + ' PrestigeEliteStd-Bd'
    linebreak = @paper.lineBreak
    lineHeight = @paper.lineHeight
    stringArr = []
    if caption.length > 45
      stringArr = []
      i = 0
      for num in [0..Math.floor(caption.length/45)]
        for char in [(i+45)..i]
          if caption.charAt(char) is " "
            stringArr.push(char) 
            break
        i += 45
      start = 0
      for breakPoint, i in stringArr
        breakPoint = undefined if i+1 is stringArr.length 
        @ctx.fillText(str.slice(start, breakPoint), 100, linebreak)
        start += breakPoint-start+1
        linebreak +=lineHeight
      @ctx.fillText(date, 100, lineHeight+(lineHeight*1.2))
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

paperSizes =
  A6:
    height: 1748
    width : 1240
    lineHeight: 60
    lineBreak: 1240
    margin: 75
    image: 1090
    fontSize: '36px'

module.exports =
  
  make: (size, caption, pic, date, callback) ->
    createPic paperSizes[size], caption, pic, date, (resp) ->
      callback(resp)