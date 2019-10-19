require 'aws-sdk-sns'
require 'aws-sdk-sqs'
require 'aws-sdk-dynamodb'
require 'securerandom'
require './lambda/multiplex_manager.rb'
require 'zlib'
require 'base64'

def lambda_handler(event:, context:)
  mm = MultiplexManager.new
  p event
  if event.key? 'Records'
    game_data = JSON.parse(
      Zlib::Inflate.inflate(
        Base64.decode64(
          event['Records'].first['Sns']['Message']
        )
      )
    )
    mm.gamer_ping(game_data['game_id']) if game_data.key? 'game_id'
    return
  end

  case event['path']
  when '/multiplay'
    return {
      statusCode: 200,
      body: JSON.generate({
        message: eval(JSON.parse(event['body'])['test']),
        input: event['body']
      })
    }
  when '/add_new_player'
    p JSON.parse(event['body'])
    return {
      statusCode: 200,
      body: JSON.generate(
        mm.add_new_player(JSON.parse(event['body'])['player_name'])
      )
    }
  else
    return {statusCode: 404, body: "unknown request #{event['path']}"}
  end
end
