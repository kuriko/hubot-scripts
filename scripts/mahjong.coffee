# Description:
#   １人麻雀ゲーム.
#
# Commands:
#   mahjong - 麻雀ゲームを開始します
#   [-(捨て牌)] - 麻雀ゲーム用：指定した牌を切ります、指定なしでツモ切りします
#   [-kawa] - 麻雀ゲーム用：現在の自分の河を表示します
KEY_TEHAI='key_tehai'
KEY_YAMA='key_yama'
KEY_KAWA='key_kawa'

class Mahjong
  @SOUZ = [
    {code:"s1",name:"１",next:"２"},
    {code:"s2",name:"２",next:"３"},
    {code:"s3",name:"３",next:"４"},
    {code:"s4",name:"４",next:"５"},
    {code:"s5",name:"５",next:"６"},
    {code:"s6",name:"６",next:"７"},
    {code:"s7",name:"７",next:"８"},
    {code:"s8",name:"８",next:"９"},
    {code:"s9",name:"９",next:"１"}]
  @PINZ = [
    {code:"p1",name:"①",next:"②"},
    {code:"p2",name:"②",next:"③"},
    {code:"p3",name:"③",next:"④"},
    {code:"p4",name:"④",next:"⑤"},
    {code:"p5",name:"⑤",next:"⑥"},
    {code:"p6",name:"⑥",next:"⑦"},
    {code:"p7",name:"⑦",next:"⑧"},
    {code:"p8",name:"⑧",next:"⑨"},
    {code:"p9",name:"⑨",next:"①"}]
  @MANZ = [
    {code:"m1",name:"一",next:"二"},
    {code:"m2",name:"二",next:"三"},
    {code:"m3",name:"三",next:"四"},
    {code:"m4",name:"四",next:"五"},
    {code:"m5",name:"五",next:"六"},
    {code:"m6",name:"六",next:"七"},
    {code:"m7",name:"七",next:"八"},
    {code:"m8",name:"八",next:"九"},
    {code:"m9",name:"九",next:"一"}]
  @FANP = [
    {code:"x1",name:"東",next:"南"},
    {code:"x2",name:"南",next:"西"},
    {code:"x3",name:"西",next:"北"},
    {code:"x4",name:"北",next:"東"}]
  @SANP = [
    {code:"y1",name:"白",next:"発"},
    {code:"y2",name:"発",next:"中"},
    {code:"y3",name:"中",next:"白"}]
  @HAIS = [].concat(Mahjong.SOUZ, Mahjong.PINZ, Mahjong.MANZ, Mahjong.FANP, Mahjong.SANP)

  createHaipai: (yama)->
    [1..13].map (i)->yama.pop()

  tumo: (yama)->
    yama.pop()

  createYama: ->
    set = []
    [4..1].map (i) -> set = set.concat(Mahjong.HAIS)
    yama=[]
    for i in [1..set.length]
      idx = Math.floor(Math.random() * (set.length))
      yama.push(set[idx].code)
      set.splice(idx,1)
    yama

  # 牌取得
  getHaiByCode: (code)->
    Mahjong.HAIS.filter((hai) -> hai.code is code)[0]

  getHaiByName: (name)->
    Mahjong.HAIS.filter((hai) -> hai.name is name)[0]

  # ドラ取得
  getDora: (yama)->
    this.getHaiByCode(yama[yama.length-5]).next

# 配牌コマンド
module.exports = (robot) ->
  robot.hear /(^MAHJONG$|^-(１|２|３|４|５|６|７|８|９|①|②|③|④|⑤|⑥|⑦|⑧|⑨|一|二|三|四|五|六|七|八|九|東|南|西|北|白|発|中|KAWA)?$)/i, (msg) ->
    try
      mj = new Mahjong
      cmd = msg.match[1].toUpperCase().replace('-','')
      switch cmd
        when "MAHJONG"
          yama = mj.createYama()
          dora = mj.getDora(yama)
          tehai = mj.createHaipai(yama)
          tumo =  mj.tumo(yama)
          kawa = []
          msg.send "東1局 東家 ドラ:#{dora}"
        when "KAWA"
          kawa = robot.brain.get(KEY_KAWA + msg.message.user.name).split(',')
          kawa.shift()
          msg.send kawa.map((i) -> mj.getHaiByCode(i).name).join("")
          return
        else
          yama = robot.brain.get(KEY_YAMA + msg.message.user.name).split(',')
          tehai = robot.brain.get(KEY_TEHAI + msg.message.user.name).split(',')
          kawa = robot.brain.get(KEY_KAWA + msg.message.user.name).split(',')
          if yama.length is 0 then return
          if cmd is "" #ツモ切り
            sutehai_code = tehai.pop()
          else #手出し
            sutehai_code =  mj.getHaiByName(cmd).code
            sutehai_idx = tehai.indexOf(sutehai_code)
            if sutehai_idx is -1 then return
            tehai.splice(sutehai_idx, 1)
          kawa.push(sutehai_code)
          tumo = mj.tumo(yama)

      #表示
      tehai_name = tehai.sort((a, b) -> a.localeCompare(b)).map((i) -> mj.getHaiByCode(i).name).join("")
      tumo_name = mj.getHaiByCode(tumo).name
      if yama.length > 105
        msg.send "#{tehai_name} #{tumo_name}"
      else
        msg.send "#{tehai_name} #{tumo_name} 流局"

      #保存
      tehai.push(tumo)
      robot.brain.set KEY_TEHAI + msg.message.user.name, tehai.join(',')
      robot.brain.set KEY_YAMA + msg.message.user.name, yama.join(',')
      robot.brain.set KEY_KAWA + msg.message.user.name, kawa.join(',')

    catch error
