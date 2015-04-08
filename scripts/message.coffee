


module.exports = (robot) ->
  robot.hear /^おはよう/i, (msg) ->
    msg.reply "おはよう"

  robot.hear /^こんばん[は|わ]/i, (msg) ->
    msg.reply "こんばんは"
