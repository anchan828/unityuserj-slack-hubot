short_pattern = "https?://u3d.as/(.*)"
pattern = "https://www.assetstore.unity3d.com(/.*)?/#!?/content/(.*)"

# jp = ja-JP
# cn = zh-CN
# kr = ko-KR
# en = en-US

module.exports = (robot) ->
  robot.hear short_pattern, (msg) ->
    msg.http(msg.match[0])
    .get() (err, res, body) ->
      emit msg, "ja-JP", match[2] if match = res.headers?.location?.match(pattern)

  robot.hear pattern, (msg) -> emit msg, "ja-JP", msg.match[2]

  emit = (msg, lang, contentID) ->
    session = process.env.ASSET_STORE_SESSION

    unless session?
      msg.send "Missing ASSET_STORE_SESSION in environment: please set and try again"
      return

    fields = []

    msg.http("https://www.assetstore.unity3d.com/api/#{lang}/content/overview/#{contentID}.json")
    .header("X-Requested-With", "SlackBot")
    .header("X-Unity-Session", session)
    .get() (err, res, body) ->
      return if res.statusCode isnt 200

      json = JSON.parse(body)

      fields.push
        title: json.content.title
        value: json.content.category.label
        short: true

      fields.push
        title: if json.content.price then "$#{json.content.price.USD}" else "無料"
        value: json.content.sizetext
        short: true

      payload =
        message: msg.message
        content:
          fallback: "Fallback Text"
          color: "#ededed"
          fields: fields

      msg.send "https:#{json.content.keyimage.big}"

      setTimeout ->
        robot.emit "slack-attachment", payload
      , 500


