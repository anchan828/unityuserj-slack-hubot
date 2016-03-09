short_pattern = "https?://u3d.as/(.*)"
pattern = "https://www.assetstore.unity3d.com(/.*)?/#!?/list/(.*)"

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
    msg.http("https://www.assetstore.unity3d.com/api/#{lang}/home/list/#{contentID}.json")
    .header("X-Requested-With", "SlackBot")
    .header("X-Unity-Session", session)
    .get() (err, res, body) ->
      return if res.statusCode isnt 200

      json = JSON.parse(body)

      fields.push
        title: "Creator"
        value: json.creator
        short: true

      payload =
        message: msg.message
        content:
          color: "#ededed"
          title: json.name
          title_link: "https://www.assetstore.unity3d.com/#!/list/#{contentID}"
          text : json.description
          fields: fields
          
      robot.emit "slack-attachment", payload
