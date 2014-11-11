# Description:
#   Home URL
#
# Commands:
#   home - URL_HOMEに指定した値を返します

module.exports = (robot) ->
  robot.hear /HOME$/i, (msg) ->
    msg.send process.env.URL_HOME
