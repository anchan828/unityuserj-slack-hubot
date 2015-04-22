


module.exports = (robot) ->
  robot.hear /^おはよう/i, (msg) ->
    msg.reply "おはよう"

  robot.hear /^こんばん[は|わ]/i, (msg) ->
    msg.reply "こんばんは"

  robot.hear /^こんにち[は|わ]/i, (msg) ->
    msg.reply "こんにちは"


  robot.adapter?.client?.on 'raw_message', (message) =>
    if message?.type is 'team_join'
      slack = robot.adapter?.client

      slack.openDM message.user.id, ->
        robot.send {room: message.user.name}, welcome_message


welcome_message = """
Unityユーザーグループへようこそ！

このグループはUnityユーザー同士がコミュニケーションをとるための場所です。

このグループの使い方については下記のWebページにて紹介しています。ぜひご覧ください。
<http://qiita.com/kyusyukeigo/items/7ad6fd51a14dc23935d1>


<#pub> は、話す内容は何でもアリなチャンネルです。まずは自己紹介でもしてみませんか？
そこからチャットが弾み、とても快適なコミュニティになると思います。
"""
