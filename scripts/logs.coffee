# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md
moment = require('moment')
fs = require('fs')
module.exports = (robot) ->


#  robot.hear /.*/i, (msg) ->
#    date = moment().locale('ja')
#    prefix = date.format("YYYY_MM_DD_")
#    key = prefix + msg.message.room
#    msg.message.time = date.format("HH:mm:ss")
#    msg.message.date = date
#    append key, msg.message
#
#
#  append = (key, value) ->
#    path = "./logs/#{key}.json"
#    fs.writeFileSync path, "" unless fs.existsSync path
#    fs.readFile path, {encoding: 'utf-8'}, (err, data) ->
#      json = if data is "" then {logs: []} else JSON.parse(data)
#      json.logs.push(value)
#      fs.writeFile(path, JSON.stringify(json))

