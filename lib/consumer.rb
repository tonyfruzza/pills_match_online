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
    puts "Consumer engine initialized polling #{SQS_QUEUE_URL}"
    poller = Aws::SQS::QueuePoller.new(SQS_QUEUE_URL)
    poller.poll do |msg|
      ghost_data = JSON.parse(
        Zlib::Inflate.inflate(
          Base64.decode64(
            JSON.parse(msg.to_h[:body]).to_h['Message']
          )
        )
      )
      update_ghost(ghost_data)
      sleep SLEEP_FREQ_FOR_CONSUMER
    end
  end

  def handle_consuming
    Thread.new{poll_for_game_data}
  end

  def update_ghost(ghost_data)
    ghost_data.each do |cell|
      # puts "Creating image based on #{PILL_IMG_SET[cell['s']]}"
      new_pill = Image.new PILL_IMG_SET[cell['s']]
      new_pill.height = new_pill.width = CHAR_SIZE
      new_pill.x = (CHAR_SIZE * M_BOTTLE_X_OFFSET) + (cell['x'] * CHAR_SIZE)
      new_pill.y = (cell['y'] * CHAR_SIZE) - (CHAR_SIZE * M_BOTTLE_Y_OFFSET)
      new_pill.color = PILL_COLORS[cell['c']] == nil ? 'red' : PILL_COLORS[cell['c']]
    end
  end
end
