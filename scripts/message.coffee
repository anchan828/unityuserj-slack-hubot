


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

<#general> は、コミュニティにとって重要な話をする場所です。基本、会話は控えてください。

<#question> は、質問をする場所です。何か困ったことがあったらここで質問してみましょう。

<#pub> は、話す内容は何でもアリなチャンネルです。まずはそこで自己紹介でもしてみませんか？
そこからチャットが弾み、とても快適なコミュニティになると思います。

<#slack-management> は、このコミュニティの運営について話す場です。ぜひあなたのご意見をお聞かせください。
"""
