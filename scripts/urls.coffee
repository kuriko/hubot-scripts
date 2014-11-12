# Description:
#   Home URL
#
# Commands:
#   home - URL_HOMEに指定した値を返します
#   senseki - URL_SENSEKIに設定された値を表示します

module.exports = (robot) ->
  robot.hear /^SENSEKI$/i, (msg) ->
    msg.send process.env.URL_SENSEKI

module.exports = (robot) ->
  robot.hear /^HOME$/i, (msg) ->
    msg.send process.env.URL_HOME
