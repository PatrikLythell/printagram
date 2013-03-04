$ ->

  colors = ['red', 'yellow', 'green', 'blue', 'green']

  times = ['8', '9', '10', '11']

  colObject =
    red: "#FF4057"
    yellow: "#FFF540"
    green: "#78C130"
    blue: "#3DB5F2"

  random = (arr) ->
    return arr[Math.floor(Math.random() * arr.length)]

  pickColor = (wrong, callback) ->
    color = random(colors)
    time = random(times)
    if color is wrong
      pickColor(wrong, callback)
    else
      for val, i in colors
        colors.splice(i,1) if val is color
      for val, i in times
        times.splice(i,1) if val is time
      callback(color, time)

  $('.moving').each ->
    wrongColor = $(this).parent().attr('class').replace('color ', '')
    pickColor wrongColor, (color, time) =>
      color = color

      from = colObject[wrongColor]
      to = colObject[color]
    
      setTimeout => 
        $(this).css
          height: 5000
          marginTop: -5000
          background: "-webkit-gradient(linear, left top, left bottom, from(#{from}), color-stop(50%, #{to}), to(#{from}))"
          "-webkit-animation": "move #{time}s linear infinite "
        .addClass('move')
      , 5000