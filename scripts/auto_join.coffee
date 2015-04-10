SLACK_API_URL = "https://slack.com/api"
SLACK_API_TOKEN = process.env.SLACK_API_TOKEN
HUBOT_USER_ID = process.env.HUBOT_USER_ID

module.exports = (robot) ->
  robot.adapter?.client?.on 'raw_message', (message) =>
    if message?.type is 'channel_created'
      robot.http("#{SLACK_API_URL}/channels.invite?token=#{SLACK_API_TOKEN}&channel=#{message.channel.id}&user=#{HUBOT_USER_ID}")
      .get() (err, res, body) ->

