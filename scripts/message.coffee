


module.exports = (robot) ->
  robot.hear /^おはよう/i, (msg) ->
    msg.reply "おはよう"

  robot.hear /^こんばんは/i, (msg) ->
    msg.reply "こんばんは"
