module.exports = (robot) ->

  robot.hear "https://www.assetstore.unity3d.com/(.*)/#!/content/(.*)", (msg) ->
    session = process.env.ASSET_STORE_SESSION
    return unless session?
    fields = []

    msg.http("https://www.assetstore.unity3d.com/api/ja-JP/content/overview/#{msg.match[2]}.json")
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
