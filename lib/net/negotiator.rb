require 'aws-sdk-core'
require 'net/http'
require 'uri'
require 'zlib'
require 'base64'
require './lib/net/net_defs.rb'
require './lib/random.rb'

class Negotiator
  attr_accessor :player_name
  attr_reader :game_id, :user_id, :aws_credentials, :sqs_url, :sns_topic_arn, :rand

  def initialize
  end

  def handoff_user_info
    uri           = URI.parse("#{BASE_API_URL}add_new_player")
    https         = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req           = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'application/json'})
    req.body      = {player_name: @player_name}.to_json
    results = https.request(req)
    parse_response(JSON.parse(results.body))
  end

  def parse_response(r)
    # Do some sanity checking
    unless r.key?('type')
      puts "Fatal error reaching server."
      p r
      exit
    end

    case r['type']
    when MSG_CONNECTION_INFO
      puts "Received new game response"
      access_key_id, secret_access_key, session_token = nil
      @aws_credentials = Aws::Credentials.new(
        r['access_key_id'],
        r['secret_access_key'],
        r['session_token']
      )
      @sns_topic_arn = r['sns_topic_arn']
      @sqs_url = r['sqs_url']
      @user_id = r['user_id']
      @game_id = r['game_id']
      @rand = Random::MT19937.new(r['game_seed'])
    end
  end
end
