require 'aws-sdk-sns'
require 'aws-sdk-sqs'
require 'aws-sdk-dynamodb'

Aws.config.update({region: ENV['AWS_REGION']})

def lambda_handler(event:, context:)
  p event
  deactive_games.each do |to_prune|
    puts "Pruning resources assoicated with game_id: #{to_prune}"
    remove_sqs_queues(to_prune)
    remove_subscriptions(to_prune)
  end
end

def remove_sqs_queues(game_id)
  @sqs = Aws::SQS::Client.new
  queues = @sqs.list_queues({queue_name_prefix: "DrRuby_#{game_id}_"}).to_h
  if queues.key?(:queue_url)
    queues[:queue_urls].each do |q|
      puts "Removing queue #{q}"
      @sqs.delete_queue({queue_url: q})
    end
  end
end

def remove_subscriptions(game_id)
  @sns = Aws::SNS::Client.new
  @sns.list_subscriptions_by_topic({topic_arn: ENV['SNS_TOPIC_ARN']}).to_h[:subscriptions].select{|sqs| /DrRuby_#{game_id}_/ =~ sqs[:endpoint]}.each do |s|
    puts "Removing sub: #{s[:endpoint]}..."
    @sns.unsubscribe({subscription_arn: s[:subscription_arn]})
  end
end

def deactive_games
  @ddb = Aws::DynamoDB::Client.new
  deactive_games = @ddb.scan({table_name: ENV['DDB_TABLE']}).to_h[:items].select do |game|
    game['last_activity'].to_f < (Time.new.to_i - 60)
  end.map{|matches| matches['gameId']}
  return [] unless deactive_games
  deactive_games
end
