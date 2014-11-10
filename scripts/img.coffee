# Description:
#   戦績URL
#
# Commands:
#   img <牌情報> - 指定した牌の画像のURLを表示します。 http://d.hatena.ne.jp/wistery_k/20120801/1349072683

module.exports = (robot) ->
  robot.hear /(IMG) (.*)/i, (msg) ->
    msg.send "http://haigacat.herokuapp.com/" + msg.match[2]
