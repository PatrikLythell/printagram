// Generated by CoffeeScript 1.3.3
(function() {
  var Canvas, Image, createPic, fs, request;

  Canvas = require('canvas');

  Image = Canvas.Image;

  fs = require('fs');

  request = require('request');

  createPic = (function() {

    function createPic(caption, pic, date, callback) {
      this.caption = caption;
      this.pic = pic;
      this.date = date;
      this.callback = callback;
      this.date = new Date(parseInt(date) * 1000);
      this.i = 0;
      this.canvas = new Canvas(1240, 1748);
      this.ctx = this.canvas.getContext('2d');
      this.ctx.patternQuality = 'best';
      this.ctx.fillStyle = '#fff';
      this.ctx.fillRect(0, 0, 1240, 1748);
      this.drawImage();
      this.drawText();
    }

    createPic.prototype.drawImage = function() {
      var _this = this;
      return request.get({
        url: this.pic,
        encoding: null
      }, function(err, res, body) {
        var img;
        img = new Image;
        img.src = body;
        _this.ctx.drawImage(img, 75, 75, 1090, 1090);
        return _this.callbackCounter("drawimage");
      });
    };

    createPic.prototype.drawText = function() {
      var caption, date, firstLine, letter, linebreak, month, nextNum, num, secondLine, thirdLine, _i, _j, _k;
      caption = this.caption;
      month = this.date.getMonth() + 1;
      date = this.date.getFullYear().toString() + '.' + month + '.' + this.date.getDate().toString();
      this.ctx.fillStyle = '#000';
      this.ctx.font = '36px PrestigeEliteStd-Bd';
      linebreak = 1240;
      if (caption.length > 100) {
        if (caption.length > 135) {
          caption = caption.slice(0, 130) + '...';
        }
        for (num = _i = 90; _i >= 0; num = --_i) {
          letter = caption.charAt(num);
          if (letter === " ") {
            thirdLine = caption.slice(num + 1);
            for (nextNum = _j = 45; _j >= 0; nextNum = --_j) {
              letter = caption.charAt(nextNum);
              if (letter === " ") {
                secondLine = caption.slice(nextNum + 1, num);
                firstLine = caption.slice(0, nextNum);
                break;
              }
            }
            break;
          }
        }
        this.ctx.fillText(firstLine, 100, linebreak);
        linebreak += 60;
        this.ctx.fillText(secondLine, 100, linebreak);
        linebreak += 60;
        this.ctx.fillText(thirdLine, 100, linebreak);
        this.ctx.fillText(date, 100, linebreak + 80);
        return this.callbackCounter("drawtext");
      } else if (caption.length > 50) {
        for (num = _k = 45; _k >= 0; num = --_k) {
          letter = caption.charAt(num);
          if (letter === " ") {
            firstLine = caption.slice(0, num);
            secondLine = caption.slice(num + 1);
            break;
          }
        }
        this.ctx.fillText(firstLine, 100, linebreak);
        linebreak += 60;
        this.ctx.fillText(secondLine, 100, linebreak);
        this.ctx.fillText(date, 100, linebreak + 80);
        return this.callbackCounter();
      } else {
        this.ctx.fillText(caption, 100, linebreak);
        this.ctx.fillText(date, 100, linebreak + 80);
        return this.callbackCounter();
      }
    };

    createPic.prototype.callbackCounter = function(who) {
      this.i++;
      console.log(who);
      if (this.i === 2) {
        return this.writeFile();
      }
    };

    createPic.prototype.writeFile = function() {
      var out, picName, stream, uniqueId,
        _this = this;
      uniqueId = function() {
        var id;
        id = "";
        while (id.length < 8) {
          id += Math.random().toString(36).substr(2);
        }
        return id.substr(0, 8);
      };
      picName = uniqueId();
      out = fs.createWriteStream(__dirname + '/public/img/tmp/' + picName + '.jpeg');
      stream = this.canvas.jpegStream();
      stream.on('data', function(chunk) {
        return out.write(chunk);
      });
      return stream.on('end', function() {
        console.log("saved image");
        return _this.callback(picName + '.jpeg');
      });
    };

    return createPic;

  })();

  module.exports = {
    make: function(size, caption, pic, date, callback) {
      return createPic(caption, pic, date, function(resp) {
        return callback(resp);
      });
    }
  };

}).call(this);
