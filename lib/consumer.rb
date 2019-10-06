require 'aws-sdk-sqs'
require 'thread'
# require 'zlib'
require 'base64'

class Consumer
  def initialize
    @sqs = Aws::SQS::Client.new(region: AWS_REGION)
    begin
      puts "Is queue empty? We donno"
      # @sqs.purge_queue({queue_url: SQS_QUEUE_URL})
    rescue
      puts "Already has been purged within last 60 seconds"
    end
  end

  def poll_for_game_data
    poller = Aws::SQS::QueuePoller.new(SQS_QUEUE_URL)
    poller.poll do |msg|
      puts @ghost_pos = JSON.parse(
        Zlib::Inflate.inflate(
          Base64.decode64(
            JSON.parse(msg.to_h[:body]).to_h['Message']
          )
        )
      )
      update_ghost
      sleep SLEEP_FREQ_FOR_CONSUMER
    end
  end

  def handle_consuming
    Thread.new{poll_for_game_data}
  end

  def update_ghost
    puts "Got data working creating a pill"
    @ghost_pos.each do |cell|
      new_pill = Image.new PILL_IMG_SET[cell['s']]
      new_pill.height = new_pill.width = CHAR_SIZE
      new_pill.x = (CHAR_SIZE * M_BOTTLE_X_OFFSET) + (cell['x'] * CHAR_SIZE)
      new_pill.y = (cell['y'] * CHAR_SIZE) - (CHAR_SIZE * M_BOTTLE_Y_OFFSET)
      new_pill.color = cell['c']
    end
  end
end
