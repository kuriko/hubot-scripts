# Description:
#   今日の配牌.
#
# Commands:
#   haipai - ランダムに選ばれた配牌を返します

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
  @PINZ = [
    {code:"p1",name:"①"},
    {code:"p2",name:"②"},
    {code:"p3",name:"③"},
    {code:"p4",name:"④"},
    {code:"p5",name:"⑤"},
    {code:"p6",name:"⑥"},
    {code:"p7",name:"⑦"},
    {code:"p8",name:"⑧"},
    {code:"p9",name:"⑨"}]
  @MANZ = [
    {code:"m1",name:"一"},
    {code:"m2",name:"二"},
    {code:"m3",name:"三"},
    {code:"m4",name:"四"},
    {code:"m5",name:"五"},
    {code:"m6",name:"六"},
    {code:"m7",name:"七"},
    {code:"m8",name:"八"},
    {code:"m9",name:"九"}]
  @FANP = [
    {code:"x1",name:"東"},
    {code:"x2",name:"南"},
    {code:"x3",name:"西"},
    {code:"x4",name:"北"}]
  @SANP = [
    {code:"y1",name:"白"},
    {code:"y2",name:"発"},
    {code:"y3",name:"中"}]
  @HAIS = [].concat(Mahjang.SOUZ, Mahjang.PINZ, Mahjang.MANZ, Mahjang.FANP, Mahjang.SANP)

  _yama = []

  constructor: ->
    _yama =[]
    [4..1].map((i) -> _yama = _yama.concat(Mahjang.HAIS))

  # 牌取得
  getHai: (code)->
    Mahjang.HAIS.filter((hai) -> hai.code is code)[0]

  # ドラ取得
  getDora: ->
    code = this.tumo().code #ドラ表示牌
    next_code = code[0] + (parseInt(code[1], 10) + 1)
    hai = this.getHai(next_code)
    if hai is undefined
      hai = this.getHai(code[0]+"1")
    hai

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
  robot.hear /HAIPAI$/i, (msg) ->
    try
      hai = new Mahjang()
      haipai = hai.createHaipai().sort((a, b) -> a.code.localeCompare(b.code)).map((item,i) -> item.name)
      tumo = hai.tumo().name
      dora = hai.getDora().name
      msg.send "東1局 東家 ドラ:#{dora}"
      msg.send "#{haipai.join("")} #{tumo}"
    catch error
      msg.send error