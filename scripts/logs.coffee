moment = require('moment')
google = require('googleapis')
fs = require('fs')

GOOGLE_DRIVE_ROOT_FOLDER_ID = process.env.GOOGLE_DRIVE_ROOT_FOLDER_ID
GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET
GOOGLE_REDIRECT_URL = process.env.GOOGLE_REDIRECT_URL
GOOGLE_REFRESH_TOKEN = process.env.GOOGLE_REFRESH_TOKEN


oauth2Client = new google.auth.OAuth2(GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URL);
drive = google.drive
  version: 'v2'
  auth: oauth2Client
oauth2Client.setCredentials refresh_token: GOOGLE_REFRESH_TOKEN

module.exports = (robot) ->
  robot.hear /.*/i, (msg) ->
    return unless GOOGLE_DRIVE_ROOT_FOLDER_ID? or GOOGLE_CLIENT_ID? or GOOGLE_CLIENT_SECRET? or GOOGLE_REDIRECT_URL? or GOOGLE_REFRESH_TOKEN?


    date = moment().locale('ja')
    msg.message.time = date.format("HH:mm:ss")
    msg.message.date = date
    upload msg.message.room, msg.message


  upload = (channel, message) ->
    oauth2Client.refreshAccessToken (err, res) ->
      drive.files.list {q: "title='#{channel}' and '#{GOOGLE_DRIVE_ROOT_FOLDER_ID}' in parents and trashed = false"}, (err, res) ->
        console.error err if err?
        if res.items.length is 0
          drive.files.insert
            auth: oauth2Client
            resource:
              title: channel
              mimeType: "application/vnd.google-apps.folder"
              parents: [{id: "#{GOOGLE_DRIVE_ROOT_FOLDER_ID}"}]
          , (err, res) ->
            console.error err if err?
            upload_log_file drive, res.id, message
        else
          upload_log_file drive, res.items[0].id, message

  upload_log_file = (drive, parentID, message) ->
    filename = "#{moment().format("YYYY_MM_DD_HH_mm_ss_SSS")}.json"
    drive.files.insert
      auth: oauth2Client
      resource:
        title: filename
        mimeType: 'applica/json'
        parents: [{id: parentID}]
      media:
        mimeType: 'applica/json'
        body: JSON.stringify(message)
    , (err, res) ->
      console.error err if err?
