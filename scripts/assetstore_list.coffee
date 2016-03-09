http = require('http');
fs = require('fs');
glob = require("glob");
spawn = require('child_process').spawn;
Gyazo = require('gyazo-api');
client = new Gyazo(process.env.GYAZO_ACCESS_TOKEN);

short_pattern = /https?:\/\/u3d\.as\/(.*)\s?/
pattern = /https?:\/\/www\.assetstore\.unity3d\.com\/?(.*)?\/#!?\/list\/(.*)\s?/

convertLang = (lang) ->
  return "ja-JP" if lang is "jp"
  return "zh-CN" if lang is "cn"
  return "ko-KR" if lang is "kr"
  return "en-US" if lang is "en" or lang is "" or lang is undefined

module.exports = (robot) ->
  robot.hear short_pattern, (msg) ->
    msg.http(msg.match[0])
    .get() (err, res, body) ->
      if match = res.headers?.location?.match(pattern)
        emit msg, convertLang(match[1]), match[2]

  robot.hear pattern, (msg) -> emit msg, convertLang(msg.match[1]), msg.match[2]

  emit = (msg, lang, contentID) ->
    session = process.env.ASSET_STORE_SESSION

    unless session?
      msg.send "Missing ASSET_STORE_SESSION in environment: please set and try again"
      return

    fields = []
    msg.http("https://www.assetstore.unity3d.com/api/#{lang}/home/list/#{contentID}.json")
    .header("X-Requested-With", "SlackBot")
    .header("X-Unity-Session", session)
    .get() (err, res, body) ->
      return if res.statusCode isnt 200

      json = JSON.parse(body)

      getThumbUrl json, (err, url) ->
        payload =
          message: msg.message
          content:
            color: "#ededed"
            title: json.name
            title_link: "https://www.assetstore.unity3d.com/#!/list/#{contentID}"
            text: json.description
            image_url: url

        robot.emit "slack-attachment", payload


getIcon = (i, url) ->
  new Promise (resolve, reject) =>
    console.log(i)
    file = fs.createWriteStream("#{i}.png");
    http.get "http:#{url}", (res) =>
      res.pipe(file)
      res.on 'end', -> resolve()

outputImage = (i, images) ->
  new Promise (resolve, reject) =>
    args = ['+append']
    images.map (v) -> args.push v
    args.push "out#{i}.png"
    convert = spawn 'convert', args
    convert.on 'close', (code, signal) -> resolve()

getThumbUrl = (obj, callback) ->
  console.log obj
  Promise.all(obj.packages.map (v, i) -> getIcon i, v.icon).then ->
    image_rows = (obj.packages.map (v, i) -> "#{i}.png").divide(10)

    Promise.all(image_rows.map((image_row, j)-> outputImage(j, image_row))).then ->
      args = ['-append']
      image_rows.map (v, i) -> args.push "out#{i}.png"
      args.push "out.png"
      convert = spawn 'convert', args
      convert.on 'close', (code, signal) ->
        client.upload "out.png",
          title: obj.name
          desc: "AssetStore My Lists"
        .then((res) ->
          glob.sync("*.png").map (v) -> fs.unlink v
          callback(null, "#{res.data.permalink_url}.png")
        )
        .catch((err) ->
          callback(err)
        );


Array::divide = (n) ->
  ary = this
  idx = 0
  results = []
  length = ary.length
  while idx + n < length
    result = ary.slice(idx, idx + n)
    results.push result
    idx = idx + n
  rest = ary.slice(idx, length + 1)
  results.push rest
  results
