// Generated by CoffeeScript 1.3.3
(function() {
  var Canvas, Image, createPic, fs, paperSizes, request;

  Canvas = require('canvas');

  Image = Canvas.Image;

  fs = require('fs');

  request = require('request');

  createPic = (function() {

    function createPic(paper, caption, pic, date, callback) {
      this.paper = paper;
      this.caption = caption;
      this.pic = pic;
      this.date = date;
      this.callback = callback;
      this.date = new Date(parseInt(date) * 1000);
      this.i = 0;
      this.canvas = new Canvas(this.paper.width, this.paper.height);
      this.ctx = this.canvas.getContext('2d');
      this.ctx.patternQuality = 'best';
      this.ctx.fillStyle = '#fff';
      this.ctx.fillRect(0, 0, this.paper.width, this.paper.height);
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
        _this.ctx.drawImage(img, _this.paper.margin, _this.paper.margin, _this.paper.image, _this.paper.image);
        return _this.callbackCounter("drawimage");
      });
    };

    createPic.prototype.drawText = function() {
      var breakPoint, caption, char, date, i, lineHeight, linebreak, month, num, start, stringArr, _i, _j, _k, _len, _ref, _ref1;
      caption = this.caption;
      month = this.date.getMonth() + 1;
      date = this.date.getFullYear().toString() + '.' + month + '.' + this.date.getDate().toString();
      this.ctx.fillStyle = '#000';
      this.ctx.font = this.paper.fontSize + ' PrestigeEliteStd-Bd';
      linebreak = this.paper.lineBreak;
      lineHeight = this.paper.lineHeight;
      stringArr = [];
      if (caption.length > 45) {
        stringArr = [];
        i = 0;
        for (num = _i = 0, _ref = Math.floor(caption.length / 45); 0 <= _ref ? _i <= _ref : _i >= _ref; num = 0 <= _ref ? ++_i : --_i) {
          for (char = _j = _ref1 = i + 45; _ref1 <= i ? _j <= i : _j >= i; char = _ref1 <= i ? ++_j : --_j) {
            if (caption.charAt(char) === " ") {
              stringArr.push(char);
              break;
            }
          }
          i += 45;
        }
        start = 0;
        for (i = _k = 0, _len = stringArr.length; _k < _len; i = ++_k) {
          breakPoint = stringArr[i];
          if (i + 1 === stringArr.length) {
            breakPoint = void 0;
          }
          this.ctx.fillText(str.slice(start, breakPoint), 100, linebreak);
          start += breakPoint - start + 1;
          linebreak += lineHeight;
        }
        this.ctx.fillText(date, 100, lineHeight + (lineHeight * 1.2));
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

  paperSizes = {
    A6: {
      height: 1748,
      width: 1240,
      lineHeight: 60,
      lineBreak: 1240,
      margin: 75,
      image: 1090,
      fontSize: '36px'
    }
  };

  module.exports = {
    make: function(size, caption, pic, date, callback) {
      return createPic(paperSizes[size], caption, pic, date, function(resp) {
        return callback(resp);
      });
    }
  };

}).call(this);
