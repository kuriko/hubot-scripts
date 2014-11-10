# Description:
#   戦績URL
#
# Commands:
#   senseki - 麻雀部戦績URLを表示します
KEY_URL_SENSEKI = 'key_url_senseki'

module.exports = (robot) ->
  robot.hear /SENSEKI$/i, (msg) ->
    #robot.brain.set KEY_URL_SENSEKI, "http://"
    msg.send robot.brain.get KEY_URL_SENSEKI
