require 'aws-sdk-sns'
require 'aws-sdk-sqs'
require 'aws-sdk-dynamodb'
require 'zlib'
require 'base64'

def gamer_ping(game_id)
  Aws.config.update({region: ENV['AWS_REGION']})
  @ddb = Aws::DynamoDB::Client.new
  @ddb.update_item({
    table_name: ENV['DDB_TABLE'],
    key: {gameId: game_id},
    attribute_updates: {
      last_activity: {
        value: Time.now.to_i,
        action: 'PUT'
      }
    }
  })
end

def lambda_handler(event:, context:)
  p event
  if event.key? 'Records'
    game_data = JSON.parse(
      Zlib::Inflate.inflate(
        Base64.decode64(
          event['Records'].first['Sns']['Message']
        )
      )
    )
    gamer_ping(game_data['game_id']) if game_data.key? 'game_id'
  end
end
