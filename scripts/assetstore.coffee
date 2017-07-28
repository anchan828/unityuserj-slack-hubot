short_pattern = /https?:\/\/u3d\.as\/(.*)\s?/
pattern = /https?:\/\/www\.assetstore\.unity3d\.com\/?(.*)?\/#!?\/content\/(.*)\s?/

# jp = ja-JP
# cn = zh-CN
# kr = ko-KR
# en = en-US

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
    
    msg.http("https://www.assetstore.unity3d.com/api/#{lang}/content/price/#{contentID}.json")
    .header("X-Requested-With", "SlackBot")
    .header("X-Unity-Session", session)
    .get() (err, res, priceBody) ->
      
      priceJson = JSON.parse(priceBody)
      
      msg.http("https://www.assetstore.unity3d.com/api/#{lang}/content/overview/#{contentID}.json")
      .header("X-Requested-With", "SlackBot")
      .header("X-Unity-Session", session)
      .get() (err, res, body) ->
        return if res.statusCode isnt 200

        json = JSON.parse(body)

        fields.push
          title: "Category"
          value: json.content.category.label
          short: true

        fields.push
          title: "Price"
          value: if priceJson.price then "#{priceJson.price}" else "Free"
          short: true

        fields.push
          title: "Rating"
          value: new Array(parseInt(json.content.rating.average, 0) + 1).join(":star:") || "-"
          short: true

        fields.push
          title: "Publisher"
          value: json.content.publisher.label
          short: true

        payload =
          message: msg.message
          content:
            title: json.content.title
            title_link: json.content.short_url
            color: "#ededed"
            fields: fields
            image_url: "https:#{json.content.keyimage.big}"

        robot.emit "slack-attachment", payload
