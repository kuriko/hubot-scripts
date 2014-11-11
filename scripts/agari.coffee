# Description:
#   麻雀問題
#   ※フォーマットについてはここ
#   http://jyanryu.blog.fc2.com/blog-entry-18.html
#
# Commands:
#   agari - ランダムに選ばれた和了状態を表示します。
#   tensuu - 麻雀の点数計算問題を表示します。
#   machi - 麻雀の待ち当て問題を表示します。
#   yaku - 麻雀の役当て問題を表示します。
#   result - 直前に表示した麻雀問題の回答を表示します。
KEY_RESULT_1 = 'key_result_1'
KEY_RESULT_2 = 'key_result_2'

request = require 'request'
cheerio = require 'cheerio'

#天鳳用コード変換クラス
class Mahjong
  @SOUZ = [
    {code:"0",name:"１"},
    {code:"1",name:"２"},
    {code:"2",name:"３"},
    {code:"3",name:"４"},
    {code:"4",name:"５"},
    {code:"5",name:"６"},
    {code:"6",name:"７"},
    {code:"7",name:"８"},
    {code:"8",name:"９"}]
  @PINZ = [
    {code:"9",name:"①"},
    {code:"10",name:"②"},
    {code:"11",name:"③"},
    {code:"12",name:"④"},
    {code:"13",name:"⑤"},
    {code:"14",name:"⑥"},
    {code:"15",name:"⑦"},
    {code:"16",name:"⑧"},
    {code:"17",name:"⑨"}]
  @MANZ = [
    {code:"18",name:"一"},
    {code:"19",name:"二"},
    {code:"20",name:"三"},
    {code:"21",name:"四"},
    {code:"22",name:"五"},
    {code:"23",name:"六"},
    {code:"24",name:"七"},
    {code:"25",name:"八"},
    {code:"26",name:"九"}]
  @FANP = [
    {code:"27",name:"東"},
    {code:"28",name:"南"},
    {code:"29",name:"西"},
    {code:"30",name:"北"}]
  @SANP = [
    {code:"31",name:"白"},
    {code:"32",name:"発"},
    {code:"33",name:"中"}]
  @HAIS = [].concat(Mahjong.SOUZ, Mahjong.PINZ, Mahjong.MANZ, Mahjong.FANP, Mahjong.SANP)
  @YAKU = [
    "ツモ",
    "リーチ",
    "一発",
    "槍槓",
    "嶺上開花",
    "海底撈月",
    "河底撈魚",
    "平和",
    "断ヤオ",
    "一盃口",
    "東(自風)",
    "南(自風)",
    "西(自風)",
    "北(自風)",
    "東(場風)",
    "南(場風)",
    "西(場風)",
    "北(場風)",
    "白",
    "發",
    "中",
    "ダブル立直",
    "七対子",
    "混全帯ヤオ",
    "一気通貫",
    "三色同順",
    "三色同刻",
    "三槓子",
    "対々和",
    "三暗刻",
    "小三元",
    "混老頭",
    "二盃口",
    "純全帯ヤオ",
    "混一色",
    "清一色",
    "？",
    "天和",
    "地和",
    "大三元",
    "四暗刻",
    "四暗刻単騎",
    "字一色",
    "緑一色",
    "清老頭",
    "九連宝燈",
    "純正九蓮宝燈",
    "国士無双",
    "国士無双13面待ち",
    "四槓子",
    "小四喜和",
    "大四喜和",
    "ドラ",
    "裏ドラ",
    "赤ドラ"]
  @TENHYO = 
    "親番":
      "ツモ":
        "20符" :[         "-", "700オール","1300オール","2600オール","4000オール","6000オール","6000オール","8000オール","8000オール","8000オール","12000オール","12000オール"]
        "25符" :[         "-",         "-","1600オール","3200オール","4000オール","6000オール","6000オール","8000オール","8000オール","8000オール","12000オール","12000オール"]
        "30符" :[ "500オール","1000オール","2000オール","4000オール","4000オール","6000オール","6000オール","8000オール","8000オール","8000オール","12000オール","12000オール"]
        "40符" :[ "700オール","1300オール","2600オール","4000オール","4000オール","6000オール","6000オール","8000オール","8000オール","8000オール","12000オール","12000オール"]
        "50符" :[ "800オール","1600オール","3200オール","4000オール","4000オール","6000オール","6000オール","8000オール","8000オール","8000オール","12000オール","12000オール"]
        "60符" :["1000オール","2000オール","4000オール","4000オール","4000オール","6000オール","6000オール","8000オール","8000オール","8000オール","12000オール","12000オール"]
        "70符" :["1200オール","2300オール","4000オール","4000オール","4000オール","6000オール","6000オール","8000オール","8000オール","8000オール","12000オール","12000オール"]
        "80符" :["1300オール","2600オール","4000オール","4000オール","4000オール","6000オール","6000オール","8000オール","8000オール","8000オール","12000オール","12000オール"]
        "90符" :["1500オール","2900オール","4000オール","4000オール","4000オール","6000オール","6000オール","8000オール","8000オール","8000オール","12000オール","12000オール"]
        "100符":["1600オール","3200オール","4000オール","4000オール","4000オール","6000オール","6000オール","8000オール","8000オール","8000オール","12000オール","12000オール"]
        "110符":["1800オール","3600オール","4000オール","4000オール","4000オール","6000オール","6000オール","8000オール","8000オール","8000オール","12000オール","12000オール"]
      "ロン":
        "20符" :[     "-", "2000点", "3900点", "7700点","12000点","18000点","18000点","24000点","24000点","24000点","32000点","32000点"]
        "25符" :[     "-", "2400点", "4800点", "9600点","12000点","18000点","18000点","24000点","24000点","24000点","32000点","32000点"]
        "30符" :["1500点", "2900点", "5800点","12000点","12000点","18000点","18000点","24000点","24000点","24000点","32000点","32000点"]
        "40符" :["2000点", "3900点", "7700点","12000点","12000点","18000点","18000点","24000点","24000点","24000点","32000点","32000点"]
        "50符" :["2400点", "4800点", "9600点","12000点","12000点","18000点","18000点","24000点","24000点","24000点","32000点","32000点"]
        "60符" :["2900点", "5800点","12000点","12000点","12000点","18000点","18000点","24000点","24000点","24000点","32000点","32000点"]
        "70符" :["3400点", "6800点","12000点","12000点","12000点","18000点","18000点","24000点","24000点","24000点","32000点","32000点"]
        "80符" :["3900点", "7700点","12000点","12000点","12000点","18000点","18000点","24000点","24000点","24000点","32000点","32000点"]
        "90符" :["4400点", "8700点","12000点","12000点","12000点","18000点","18000点","24000点","24000点","24000点","32000点","32000点"]
        "100符":["4800点", "9600点","12000点","12000点","12000点","18000点","18000点","24000点","24000点","24000点","32000点","32000点"]
        "110符":["5300点","10600点","12000点","12000点","12000点","18000点","18000点","24000点","24000点","24000点","32000点","32000点"]
    "子番":
      "ツモ":
        "20符" :[         "-",  "400/700点", "700/1300点","1300/2600点","2000/4000点","3000/6000点","3000/6000点","4000/8000点","4000/8000点","4000/8000点","6000/12000点","6000/12000点"]
        "25符" :[         "-",          "-", "800/1600点","1600/3200点","2000/4000点","3000/6000点","3000/6000点","4000/8000点","4000/8000点","4000/8000点","6000/12000点","6000/12000点"]
        "30符" :[ "300/500点", "500/1000点","1000/2000点","2000/4000点","2000/4000点","3000/6000点","3000/6000点","4000/8000点","4000/8000点","4000/8000点","6000/12000点","6000/12000点"]
        "40符" :[ "400/700点", "700/1300点","1300/2600点","2000/4000点","2000/4000点","3000/6000点","3000/6000点","4000/8000点","4000/8000点","4000/8000点","6000/12000点","6000/12000点"]
        "50符" :[ "400/800点", "800/1600点","1600/3200点","2000/4000点","2000/4000点","3000/6000点","3000/6000点","4000/8000点","4000/8000点","4000/8000点","6000/12000点","6000/12000点"]
        "60符" :["500/1000点","1000/2000点","2000/4000点","2000/4000点","2000/4000点","3000/6000点","3000/6000点","4000/8000点","4000/8000点","4000/8000点","6000/12000点","6000/12000点"]
        "70符" :["600/1200点","1200/2300点","2000/4000点","2000/4000点","2000/4000点","3000/6000点","3000/6000点","4000/8000点","4000/8000点","4000/8000点","6000/12000点","6000/12000点"]
        "80符" :["700/1300点","1300/2600点","2000/4000点","2000/4000点","2000/4000点","3000/6000点","3000/6000点","4000/8000点","4000/8000点","4000/8000点","6000/12000点","6000/12000点"]
        "90符" :["800/1500点","1500/2900点","2000/4000点","2000/4000点","2000/4000点","3000/6000点","3000/6000点","4000/8000点","4000/8000点","4000/8000点","6000/12000点","6000/12000点"]
        "100符":["800/1600点","1600/3200点","2000/4000点","2000/4000点","2000/4000点","3000/6000点","3000/6000点","4000/8000点","4000/8000点","4000/8000点","6000/12000点","6000/12000点"]
        "110符":["900/1800点","1800/3600点","2000/4000点","2000/4000点","2000/4000点","3000/6000点","3000/6000点","4000/8000点","4000/8000点","4000/8000点","6000/12000点","6000/12000点"]
      "ロン":
        "20符" :[     "-",     "-",     "-",     "-","8000点","12000点","12000点","18000点","18000点","18000点","24000点","24000点"]
        "25符" :[     "-","1600点","3200点","6400点","8000点","12000点","12000点","18000点","18000点","18000点","24000点","24000点"]
        "30符" :["1000点","2000点","3900点","8000点","8000点","12000点","12000点","18000点","18000点","18000点","24000点","24000点"]
        "40符" :["1300点","2600点","5200点","8000点","8000点","12000点","12000点","18000点","18000点","18000点","24000点","24000点"]
        "50符" :["1600点","3200点","6400点","8000点","8000点","12000点","12000点","18000点","18000点","18000点","24000点","24000点"]
        "60符" :["2000点","3900点","8000点","8000点","8000点","12000点","12000点","18000点","18000点","18000点","24000点","24000点"]
        "70符" :["2300点","4500点","8000点","8000点","8000点","12000点","12000点","18000点","18000点","18000点","24000点","24000点"]
        "80符" :["2600点","5200点","8000点","8000点","8000点","12000点","12000点","18000点","18000点","18000点","24000点","24000点"]
        "90符" :["2900点","5800点","8000点","8000点","8000点","12000点","12000点","18000点","18000点","18000点","24000点","24000点"]
        "100符":["3200点","6400点","8000点","8000点","8000点","12000点","12000点","18000点","18000点","18000点","24000点","24000点"]
        "110符":["3600点","7100点","8000点","8000点","8000点","12000点","12000点","18000点","18000点","18000点","24000点","24000点"]

  _selector = undefined

  constructor: (selector)->
    _selector = selector

  getOyaPlayer: ->
    _selector.closest("INIT").attr("oya")

  getHoraPlayer: ->
    _selector.attr("who")

  getHojuPlayer: ->
    _selector.attr("fromwho")

  getKaze: ->
    kaze = ""
    switch this.getOyaPlayer() - this.getHoraPlayer()
      when 0
        kaze =  "東"
      when 1,-3
        kaze =  "南"
      when 2,-2
        kaze =  "西"
      when 3,-1
        kaze =  "北"
    "#{kaze}家"

  getTumoRon: ->
    return if this.getHoraPlayer() is this.getHojuPlayer() then "ツモ" else "ロン"

  getBan: ->
    return if this.getKaze() is "東家" then "親番" else "子番"

  getTehai: ->
    tehai_code = _selector.attr("hai").split(",")
    machi_code = _selector.attr("machi")
    tehai_machi_idx = tehai_code.indexOf(machi_code)
    tehai_code.splice(tehai_machi_idx, 1) # 手牌に待ち牌が含まれているので削除する
    mj = this
    tehai_code.map((i)->mj.getHai(i).name).join("")

  getMachi: ->
    machi_code = _selector.attr("machi")
    this.getHai(machi_code).name

  getHuro: ->
    mentsu_code = _selector.attr("m")
    mentsu_list = []
    if mentsu_code != undefined
      mj = this
      mentsu_list = mentsu_code.split(",").map((mentsu) -> mj.getMentsuName(mentsu))
    mentsu_list.join(" ")

  getYaku: ->
    yaku = _selector.attr("yaku").split(",")
    yaku_list = []
    for i in [0..yaku.length]
      if (i+2)%2 is 0
        yaku_name = undefined
        if yaku[i] < 52
          yaku_name = Mahjong.YAKU[yaku[i]]
        else
          if yaku[i+1] > 0
            yaku_name = Mahjong.YAKU[yaku[i]] + yaku[i+1]
        if yaku_name isnt undefined
          yaku_list = yaku_list.concat(yaku_name)
    "<#{yaku_list.join(" ")}>"

  getTen: ->
    yaku = _selector.attr("yaku").split(",")
    han = 0
    for i in [0..yaku.length]
      if (i+2)%2 is 0
      else
        han += parseInt(yaku[i])
    #符、点数
    ten = _selector.attr("ten").split(",")
    hu = ten[0]
    # ten = ten[1]
    ten = Mahjong.TENHYO[this.getBan()][this.getTumoRon()]["#{hu}符"][han-1]
    "#{hu}符#{han}翻 #{ten}"

  # 牌取得
  getHai: (code)->
    code = parseInt(code/4).toString()
    Mahjong.HAIS.filter((hai) -> hai.code is code)[0]

  convMentsu: (m)->
    kui=(m&3)
    if (m&(1<<2)) # SYUNNTSU
      t=((m&0xFC00)>>10)
      r=t%3
      t=parseInt(t/3)
      t=parseInt(t/7)*9+(t%7)
      t*=4
      h=[t+4*0+((m&0x0018)>>3), t+4*1+((m&0x0060)>>5), t+4*2+((m&0x0180)>>7)]
      switch(r)
        when 1
          h.unshift(h.splice(1,1)[0])
        when 2
          h.unshift(h.splice(2,1)[0])
      return {"hai": h, "kui":kui}
      
    else if (m&(1<<3)) # KOUTSU
      unused=(m&0x0060)>>5
      t=(m&0xFE00)>>9
      r=t%3
      t=parseInt(t/3)
      t*=4
      h=[t,t,t]
      switch(unused)
        when 0
          h[0]+=1
          h[1]+=2
          h[2]+=3
        when 1
          h[0]+=0
          h[1]+=2
          h[2]+=3
        when 2
          h[0]+=0
          h[1]+=1
          h[2]+=3
        when 3
          h[0]+=0
          h[1]+=1
          h[2]+=2
      
      switch(r)
        when 1
          h.unshift(h.splice(1,1)[0])
        when 2
          h.unshift(h.splice(2,1)[0])
      
      if (kui<3)
        h.unshift(h.splice(2,1)[0])
      if (kui<2)
        h.unshift(h.splice(2,1)[0])
      return {"hai": h, "kui":kui}
      
    else if (m&(1<<4)) # CHAKANN
      added=(m&0x0060)>>5
      t=(m&0xFE00)>>9
      r=t%3
      t=parseInt(t/3)
      t*=4
      h=[t,t,t]
      switch(added)
        when 0
          h[0]+=1
          h[1]+=2
          h[2]+=3
        when 1
          h[0]+=0
          h[1]+=2
          h[2]+=3
        when 2
          h[0]+=0
          h[1]+=1
          h[2]+=3
        when 3
          h[0]+=0
          h[1]+=1
          h[2]+=2
      
      switch(r)
        when 1
          h.unshift(h.splice(1,1)[0])
        when 2
          h.unshift(h.splice(2,1)[0])
      return {"hai": h.concat(t+added), "kui":kui}
      
    else if (m&(1<<5)) # NUKI
      # nop
      
    else # MINNKANN, ANNKANN
      hai0=(m&0xFF00)>>8
      if (!kui)
        hai0=(hai0&~3)+3 # ANNKAN
      t=parseInt(hai0/4)*4
      h=[t,t,t]
      switch(hai0%4)
        when 0
          h[0]+=1
          h[1]+=2
          h[2]+=3
        when 1
          h[0]+=0
          h[1]+=2
          h[2]+=3
        when 2
          h[0]+=0
          h[1]+=1
          h[2]+=3
        when 3
          h[0]+=0
          h[1]+=1
          h[2]+=2
      
      if (kui==1)
        a=hai0
        hai0=h[2]
        h[2]=a
      if (kui==2)
        a=hai0
        hai0=h[0]
        h[0]=a
      return {"hai": h.concat(hai0), "kui":kui}

  getMentsuName: (mentsu)->
    mj = this
    convedMentsu = mj.convMentsu(mentsu)
    #kuiName = Mahjong.getKuiName(convedMentsu.kui)
    mentsuName = convedMentsu.hai.map((i)->mj.getHai(i).name)
    # return "#{kuiName}(#{mentsuName.join("")})"
    if convedMentsu.kui is 0
      return "暗(#{mentsuName.join("")})"
    else
      return "(#{mentsuName.join("")})"

module.exports = (robot) ->
  robot.hear /(AGARI|TENSUU|YAKU|MACHI|RESULT)( [0-9]+)?$/i, (msg) ->
    cmd = msg.match[1].toUpperCase()
    if cmd is "RESULT"
      msg.send robot.brain.get KEY_RESULT_1 + msg.message.user.room
      msg.send robot.brain.get KEY_RESULT_2 + msg.message.user.room
      return

    if msg.match[2] && msg.match[2].match /( [0-9]+)/
      seed1 = Math.floor(msg.match[2].trim() / 100)
      seed2 = msg.match[2].trim() % 100
    options =
      url: "http://tenhou.net/0/mjloglist.cgi?mjlog_pf4-20_n6"
      timeout: 2000
      headers: {'user-agent': 'node title fetcher'}
    request options, (error, response, body) ->
      $ = cheerio.load body
      seed1 = seed1 ? Math.floor(Math.random() * $("a").length)
      element = $("a").get(seed1)
      log_id = $(element).attr("href")[25..55]
      options =
        url: "http://ee.tenhou.net/0/log/?" + log_id
        timeout: 2000
        headers: {'user-agent': 'node title fetcher'}
      request options, (error, response, body) ->

        $ = cheerio.load body
        #sprintTehai
        seed2 = seed2 ? Math.floor(Math.random() * $("AGARI").length)
        agari = $("AGARI").get(seed2)

        mj = new Mahjong($(agari))

        tehai = mj.getTehai()
        machi = mj.getMachi()
        huro = mj.getHuro()
        kaze = mj.getKaze()
        tumoron = mj.getTumoRon()
        ban = mj.getBan()
        yaku = mj.getYaku()
        ten = mj.getTen()

        switch cmd
          when "MACHI"
            msg.send "#{tehai} #{huro}"
          when "YAKU"
            msg.send "#{tehai} #{tumoron}:#{machi} #{huro}"
            msg.send "#{kaze} #{ban}"
          when "TENSUU"
            msg.send "#{tehai} #{tumoron}:#{machi} #{huro}"
            msg.send "#{kaze} #{ban} #{yaku}"
          when "AGARI"
            msg.send "#{tehai} #{tumoron}:#{machi} #{huro}"
            msg.send "#{kaze} #{ban} #{yaku} #{ten}"

        robot.brain.set KEY_RESULT_1 + msg.message.user.room, "#{tehai} #{tumoron}:#{machi} #{huro}"
        robot.brain.set KEY_RESULT_2 + msg.message.user.room, "#{kaze} #{ban} #{yaku} #{ten}"