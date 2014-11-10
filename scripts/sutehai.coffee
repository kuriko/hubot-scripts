# Description:
#   捨て牌
#   ※フォーマットについてはここ
#   http://jyanryu.blog.fc2.com/blog-entry-18.html
#
# Commands:
#   sutehai - ランダムに選ばれた捨て牌を表示します。

#天鳳用コード変換クラス
class Mahjang
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
  @HAIS = [].concat(Mahjang.SOUZ, Mahjang.PINZ, Mahjang.MANZ, Mahjang.FANP, Mahjang.SANP)

  # 牌取得
  getHai: (code)->
    code = parseInt(code/4).toString()
    Mahjang.HAIS.filter((hai) -> hai.code is code)[0]

request = require 'request'
cheerio = require 'cheerio'

module.exports = (robot) ->
  robot.hear /SUTEHAI/i, (msg) ->
    options =
      url: "http://tenhou.net/0/mjloglist.cgi?mjlog_pf4-20_n6"
      timeout: 2000
      headers: {'user-agent': 'node title fetcher'}
    request options, (error, response, body) ->
      $ = cheerio.load body
      seed1 = Math.floor(Math.random() * $("a").length)
      element = $("a").get(seed1)
      log_id = $(element).attr("href")[25..55]
      options =
        url: "http://ee.tenhou.net/0/log/?" + log_id
        timeout: 2000
        headers: {'user-agent': 'node title fetcher'}
      request options, (error, response, body) ->
        mj = new Mahjang
        kyoku = body.split("INIT")
        kyoku = kyoku.filter (i) -> i.indexOf("REACH") >= 0 && i.indexOf("AGARI") >= 0 # 流局のログはドラが取れない（INITのseedから山を作れば取れる…）
        if kyoku.length is 0
          return
        kyoku = kyoku[0].split('>').map (i) -> (i.replace "/" , "").replace("<", "")

        #ドラ
        agari = kyoku.filter((i)-> i.match /^AGARI/i)[0]
        dora = agari.slice(agari.indexOf("doraHai")+9).split('"')[0].split(',')[0]
        dora_name = mj.getHai(dora).name

        #捨て牌
        first_reach = kyoku.filter((i)-> i.match /^REACH/i)[0] #初回リーチ
        kyoku = kyoku.slice(0,kyoku.indexOf(first_reach)+1+1) #ログを初回リーチまでに絞る
        #sute_code = ["D","E","F","G"][first_reach.slice(11,12)] #初回リーチ者の捨て牌Prefix
        who = Math.floor(Math.random() * 4) #プレイヤーコード
        tumo_prefix = ["T","U","V","W"][who]
        sute_prefix = ["D","E","F","G"][who]
        tumo_sute_codes = kyoku.filter((i)->i.match ///^(#{tumo_prefix}|#{sute_prefix})[1-9]///i)
        sute_names = []
        for i in [0..tumo_sute_codes.length-1]
          if tumo_sute_codes[i].match ///^#{sute_prefix}///i
            is_tedasi = ""
            sute_code = tumo_sute_codes[i].slice(1)
            if i-1 >= 0 && tumo_sute_codes[i-1] .match ///^#{tumo_prefix}///i
              tumo_code = tumo_sute_codes[i-1].slice(1)
              if sute_code isnt tumo_code.slice(1)
                is_tedasi = "!"
            sute_names = sute_names.concat(is_tedasi + mj.getHai(sute_code).name)

        msg.send "ドラ:#{dora_name}  #{sute_names.join(" ")}"