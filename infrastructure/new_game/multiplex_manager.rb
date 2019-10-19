MSG_NEW_GAME_REQ = 0
MSG_CONNECTION_INFO = 1
MSG_READY_STATE = 2
MSG_READY_STATE_RES = 3

class MultiplexManager
  MSG_TYPE_GAME_STATE = 0
  MSG_TYPE_FIELD_UPDATE = 1

  def initialize
    Aws.config.update({region: ENV['AWS_REGION']})
    @sns = Aws::SNS::Client.new
    @sqs = Aws::SQS::Client.new
    @ddb = Aws::DynamoDB::Client.new
    @sts = Aws::STS::Client.new
  end

  def start_new_game
    # @game_id = SecureRandom.uuid.split('-').first
    @game_id = 'notsorandom'
    @game_seed = rand(0..9999)
    puts "Starting new game #{@game_id}"
    parms = {
      table_name: ENV['DDB_TABLE'],
      key: {gameId: @game_id},
      attribute_updates: {
        last_activity: {
          value: Time.now.to_i,
          action: 'PUT'
        },
        game_seed: {
          value: @game_seed,
          action: 'PUT'
        },
        started: {
          value: false,
          action: 'PUT'
        },
        gamers: {
          value: [],
          action: 'PUT'
        }
      }
    }
    @ddb.update_item(parms)
  end

  def is_there_an_active_game?
    active_game = @ddb.scan({table_name: ENV['DDB_TABLE']}).to_h[:items].find do |game|
      game['last_activity'].to_f > (Time.new.to_i - 10)
    end
    if active_game
      @game_seed = active_game['game_seed'].to_f.to_i
      @game_id = active_game['gameId']
      return true
    end
    return false
  end

  def add_new_player(player_name)
    return throw_error('invalid username') if player_name.empty?
    user_id = SecureRandom.uuid.split('-').first
    puts "Creating resources for player: #{player_name} AKA #{user_id}"

    start_new_game unless is_there_an_active_game?
    sub_queue(user_id)
    creds = get_player_permissions(user_id)
    sqs_url = create_queue(user_id)
    add_perms_to_queue(sqs_url, user_id, creds[:assumed_role_user][:arn])

    @ddb.update_item({
      table_name: ENV['DDB_TABLE'],
      key: {gameId: @game_id},
      update_expression: 'SET gamers = list_append(gamers, :i)',
      expression_attribute_values: {
        ':i': [player_name]
      }
    })

    # Return structure
    {
      type: MSG_CONNECTION_INFO,
      user_id: user_id,
      game_id: @game_id,
      access_key_id: creds[:credentials][:access_key_id],
      secret_access_key: creds[:credentials][:secret_access_key],
      session_token: creds[:credentials][:session_token],
      sns_topic_arn: ENV['SNS_TOPIC_ARN'],
      sqs_url: sqs_url,
      game_seed: @game_seed
    }
  end

  def throw_error(message)
    {
      statusCode: 504,
      body: JSON.generate({
        message: message
      })
    }
  end

  def gamer_ping(game_id)
    parms = {
      table_name: ENV['DDB_TABLE'],
      key: {gameId: game_id},
      attribute_updates: {
        last_activity: {
          value: Time.now.to_i,
          action: 'PUT'
        }
      }
    }
    @ddb.update_item(parms)
  end

  #
  # IAM Role for player
  #
  def get_player_permissions(user_id)
    # Returns a hash containing:
    # :access_key_id
    # :secret_access_key
    # :session_token
    role_info = @sts.assume_role({
      duration_seconds: 3600,
      external_id: "#{@game_id}-#{user_id}",
      policy: {
        Version: '2012-10-17',
        Statement: [
          {
            Effect: 'Allow',
            Action: 'sns:Publish',
            Resource: ENV['SNS_TOPIC_ARN']
          },
          {
            Effect: 'Allow',
            Action: ['SQS:ReceiveMessage', 'SQS:DeleteMessage'],
            Resource: "arn:aws:sqs:#{ENV['AWS_REGION']}:#{ENV['AWS_ACCOUNT_ID']}:#{ENV['SQS_NAMESPACE']}_#{@game_id}_#{user_id}",
          }
        ]
      }.to_json,
      role_arn: ENV['USER_ROLE_ARN'],
      role_session_name: "#{@game_id}-#{user_id}"
    })
    puts role_info
    role_info
  end

  #
  # SNS Operations
  #
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
    total_subs
  end


  #
  # SQS Operations
  #
  def add_perms_to_queue(q_url, user_id, user_assumed_role_arn)
    @sqs.set_queue_attributes({
      queue_url: q_url,
      attributes: {
        Policy: JSON.generate({
          Version: '2012-10-17',
          Statement: [
            Sid: "User #{user_id}",
            Effect: 'Allow',
            Principal: {
              AWS: '*'
            },
            Action: ['SQS:SendMessage', 'SQS:ReceiveMessage', 'SQS:DeleteMessage'],
            Resource: "arn:aws:sqs:#{ENV['AWS_REGION']}:#{ENV['AWS_ACCOUNT_ID']}:#{ENV['SQS_NAMESPACE']}_#{@game_id}_#{user_id}",
            Condition: {
              ArnEquals: {
                'AWS:SourceArn' => [ENV['SNS_TOPIC_ARN'], user_assumed_role_arn]
              },

            }
          ]
        })
      }
    })
  end

  def create_queue(user_id)
    q_url = @sqs.create_queue({
      queue_name: "#{ENV['SQS_NAMESPACE']}_#{@game_id}_#{user_id}",
      attributes: {
        VisibilityTimeout: 60.to_s
      }
    }).to_h[:queue_url]
  end

  def sub_queue(user_id)
    sub_arn = @sns.subscribe({
      topic_arn: ENV['SNS_TOPIC_ARN'],
      protocol: 'sqs',
      endpoint: "arn:aws:sqs:#{ENV['AWS_REGION']}:#{ENV['AWS_ACCOUNT_ID']}:#{ENV['SQS_NAMESPACE']}_#{@game_id}_#{user_id}",
      return_subscription_arn: true,
      attributes: {
        RawMessageDelivery: 'true'
      }
    }).to_h[:subscription_arn]
  end

end
