class LinebotController < ApplicationController
  # LINEから呼び出されるアクション
  def callback
    # リクエストのbody（StringIOクラス）を文字列（Stringクラス）に変更
    body = request.body.read
    # parse_events_fromはline-bot-apiのオリジナルメソッド
    # clientは以下で定義したプライベートアクション（が返したインスタンス）
    events = client.parse_events_from(body)
    
    # eventsは配列に入っているので、eachでアクセス。events[0]でもだいたい同じ。
    events.each do |event|
      message = []
      case event
      when Line::Bot::Event::Message # eventが「Message」のとき
        case event.type
        when Line::Bot::Event::MessageType::Text # さらに、送られてきたのがテキストだったとき
          # 送り返すメッセージを作成
          case event.message['text']
          when 'クラッカー' then
            message.push(sticker)
          when 'らんてくん' then
            message.push(runtequn_image)
          else
            message.push(parroting(event))
          end
        end
      end
      client.reply_message(event['replyToken'], message)
    end
  end

  private

  def parroting(event)
    {type: 'text', text: event.message['text']}
  end

  def runtequn_image
    runtequn = 'https://stickershop.line-scdn.net/stickershop/v1/product/18201714/LINEStorePC/main.png?v=1'
    {type: 'image', originalContentUrl: runtequn, previewImageUrl: runtequn}
  end
  def sticker
    {
      "type": "sticker",
      "packageId": "11537",
      "stickerId": "52002734"
    }
  end
  def narou_api
    uri = URI('https://api.syosetu.com/novelapi/api/')
    params = {
      out: 'json',
      ncode: 'n8920ex',
    }
    uri.query = URI.encode_www_form(params)
  
    res = Net::HTTP.get_response(uri)
    novel = JSON.parse(res.body)
    p novel
    {type: 'text', text: "#{novel[1]['title']}\n\n最終更新：#{novel[1]['general_lastup']}"}
  end
  def confirm_template
    {
      "type": "template",
      "altText": "これは確認テンプレートです",
      "template": {
        "type": "confirm",
        "text": "本当に？",
        "actions": [
          {
            "type": "message",
            "label": "はい",
            "text": "はい"
          },
          {
            "type": "message",
            "label": "いいえ",
            "text": "いいえ"
          }
        ]
      }
    }
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end
end
