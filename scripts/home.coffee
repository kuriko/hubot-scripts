# Description:
#   コンフルURL
#
# Commands:
#   home - 麻雀同好会のコンフルページURLを返します
KEY_URL_HOME = 'key_url_home'

module.exports = (robot) ->
  robot.hear /HOME$/i, (msg) ->
    #robot.brain.set KEY_URL_HOME, "http://"
    msg.send robot.brain.get KEY_URL_HOME
