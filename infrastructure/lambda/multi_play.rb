require 'aws-sdk-sns'
require 'aws-sdk-sqs'

class MultiplexManager
  def initialize
    @sns = Aws::SNS::Client.new(region: ENV['AWS_REGION'])
    @sqs = Aws::SQS::Client.new(region: ENV['AWS_REGION'])
    @account_id = ''
  end

  def subscribers
    next_token = nil
    total_subs = []
    loop do
      subs = @sns.list_subscriptions_by_topic({
        topic_arn: ENV['SNS_TOPIC_ARN'],
        next_token: next_token,
      }).to_h
      total_subs += subs[:subscriptions]
      break unless next_token = subs[:next_token]
    end

    # q = create_queue('user2')
    # sub_queue('users')
    total_subs
  end

  def create_queue(userId)
    q_url = @sqs.create_queue({
      queue_name: "#{ENV['SQS_NAMESPACE']}_#{userId}",
      attributes: {
        VisibilityTimeout: 60.to_s
      }
    }).to_h[:queue_url]

    @account_id = q_url.split('/')[3]

    @sqs.set_queue_attributes({
      queue_url: q_url,
      attributes: {
        Policy: JSON.generate({
          Version: '2012-10-17',
          Statement: [
            Sid: "User #{userId}",
            Effect: 'Allow',
            Principal: {
              AWS: '*'
            },
            Action: ['SQS:SendMessage'],
            Resource: "arn:aws:sqs:#{ENV['AWS_REGION']}:#{@account_id}:#{ENV['SQS_NAMESPACE']}_#{userId}",
            Condition: {
              ArnEquals: {
                'AWS:SourceArn' => ENV['SNS_TOPIC_ARN']
              }
            }
          ]
        })
      }
    })
  end

  def sub_queue(userId)
    sub_arn = @sns.subscribe({
      topic_arn: ENV['SNS_TOPIC_ARN'],
      protocol: 'sqs',
      endpoint: "arn:aws:sqs:#{ENV['AWS_REGION']}:#{@account_id}:#{ENV['SQS_NAMESPACE']}_#{userId}",
      return_subscription_arn: true,
      attributes: {
        RawMessageDelivery: 'true'
      }
    }).to_h[:subscription_arn]
  end

end

def lambda_handler(event:, context:)
  mm = MultiplexManager.new
  case event['path']
  when '/multiplay'
    return {
      statusCode: 200,
      body: JSON.generate({
        message: mm.subscribers,
        input: event['body']
      })
    }
  else
    return {statusCode: 404, body: "unknown request #{event['path']}"}
  end
end
