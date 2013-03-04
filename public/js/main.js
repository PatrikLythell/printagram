// Generated by CoffeeScript 1.3.1
(function() {

  $(function() {
    var colObject, colors, pickColor, random, times;
    colors = ['red', 'yellow', 'green', 'blue', 'green'];
    times = ['8', '9', '10', '11'];
    colObject = {
      red: "#FF4057",
      yellow: "#FFF540",
      green: "#78C130",
      blue: "#3DB5F2"
    };
    random = function(arr) {
      return arr[Math.floor(Math.random() * arr.length)];
    };
    pickColor = function(wrong, callback) {
      var color, i, time, val, _i, _j, _len, _len1;
      color = random(colors);
      time = random(times);
      if (color === wrong) {
        return pickColor(wrong, callback);
      } else {
        for (i = _i = 0, _len = colors.length; _i < _len; i = ++_i) {
          val = colors[i];
          if (val === color) {
            colors.splice(i, 1);
          }
        }
        for (i = _j = 0, _len1 = times.length; _j < _len1; i = ++_j) {
          val = times[i];
          if (val === time) {
            times.splice(i, 1);
          }
        }
        return callback(color, time);
      }
    };
    return $('.moving').each(function() {
      var wrongColor,
        _this = this;
      wrongColor = $(this).parent().attr('class').replace('color ', '');
      return pickColor(wrongColor, function(color, time) {
        var from, to;
        color = color;
        from = colObject[wrongColor];
        to = colObject[color];
        return setTimeout(function() {
          return $(_this).css({
            height: 5000,
            marginTop: -5000,
            background: "-webkit-gradient(linear, left top, left bottom, from(" + from + "), color-stop(50%, " + to + "), to(" + from + "))",
            "-webkit-animation": "move " + time + "s linear infinite "
          }).addClass('move');
        }, 5000);
      });
    });
  });

}).call(this);
