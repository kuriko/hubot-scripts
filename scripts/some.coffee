# Description:
#   染め手.
#
# Commands:
#   some - ランダムに選ばれた染め手の手牌を返します

class Mahjang
  @SOUZ = [
    {code:"s1",name:"１"},
    {code:"s2",name:"２"},
    {code:"s3",name:"３"},
    {code:"s4",name:"４"},
    {code:"s5",name:"５"},
    {code:"s6",name:"６"},
    {code:"s7",name:"７"},
    {code:"s8",name:"８"},
    {code:"s9",name:"９"}]

  _yama = []

  constructor: ->
    _yama =[]
    [4..1].map((i) -> _yama = _yama.concat(Mahjang.SOUZ))

  # 牌取得
  getHai: (code)->
    Mahjang.HAIS.filter((hai) -> hai.code is code)[0]

  # ツモ牌取得
  tumo: -> 
    tumo_idx = Math.floor(Math.random() * (_yama.length))
    tumo_hai = _yama[tumo_idx]
    _yama.splice(tumo_idx,1)
    tumo_hai

  # 配牌取得
  createHaipai: ->
    haipai = []
    for i in [13..1]
      haipai.push(this.tumo())
    haipai

# 配牌コマンド
module.exports = (robot) ->
  robot.hear /SOME$/i, (msg) ->
    try
      hai = new Mahjang()
      haipai = hai.createHaipai().sort((a, b) -> a.code.localeCompare(b.code)).map((item,i) -> item.name)
      tumo = hai.tumo().name
      msg.send "#{haipai.join("")} #{tumo}"
    catch error
      msg.send error