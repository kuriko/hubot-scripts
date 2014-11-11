# Description:
#   戦績URL
#
# Commands:
#   senseki - URL_SENSEKIに設定された値を表示します'

module.exports = (robot) ->
  robot.hear /SENSEKI$/i, (msg) ->
    msg.send process.env.URL_SENSEKI
