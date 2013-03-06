$ ->

  colors = ['red', 'yellow', 'green', 'blue']

  times = ['8', '9', '10', '11']

  colObject =
    red: "#FF4057"
    yellow: "#FFF540"
    green: "#78C130"
    blue: "#3DB5F2"

  random = (arr) ->
    return arr[Math.floor(Math.random() * arr.length)]

  pickColor = (wrong, callback) ->
    color = random(_.without(colors, wrong))
    color = 'red' if !color
    time = random(times)
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

  instaI = 1

  setInterval ->
    $('.hide').css('opacity', '1')
    if instaI < 3 then instaI++ else instaI = 1
    setTimeout ->
      $('.insta-overlay').first().css("background-image", "url('/img/insta-#{instaI}.jpg')")
      $('.hide').css('opacity', '0')
    , 100
  , 5000

  $('.printer-icon').click ->
    $('#printername').val($(this).data('name'))
    $('#printerid').val($(this).data('id'))
    $(this).addClass('active').siblings().removeClass('active')
    $('.disabled').removeClass('disabled')

  $('.paper-icon').click ->
    $('#papersize').val($(this).data('name'))
    $('.selected').removeClass('selected')
    $(this).addClass('selected')

  $(document).on 'submit', 'form[data-pjax]', (event) ->
    $.pjax.submit(event, '.main')

  $(document).on 'pjax:timeout', (event) ->
    # Prevent default timeout redirection behavior
    event.preventDefault()

  $(document).on 'pjax:send', ->
    $('.main').addClass('fadeout')
    $('#loading').show()
  .on 'pjax:complete', ->
    $('.main').removeClass('fadeout')
    $('#loading').hide()