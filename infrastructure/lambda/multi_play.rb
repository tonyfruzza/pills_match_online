require 'aws-sdk-sns'
require 'aws-sdk-sqs'
require 'aws-sdk-dynamodb'
require 'securerandom'
require './lambda/multiplex_manager.rb'

def lambda_handler(event:, context:)
  p event
  if event.key? 'Records'
    puts event['Records'].first['Sns']['Message']
    return
  end

  mm = MultiplexManager.new
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
