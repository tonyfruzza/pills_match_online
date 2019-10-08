require 'aws-sdk-sns'
require 'zlib'
require 'base64'

class Producer
  def initialize
    @sns = Aws::SNS::Client.new(region: AWS_REGION)
    @worker_queue = []
    Thread.new{producer_thread}
    @@worker_queue_mutex = Mutex.new
  end

  def send_game_field_state(game_field)
    cells_with_content = []
    game_field.each do |x|
      cells_with_content += x.select{|cell| cell[:state] != FCS_EMPTY}.map{ |cell|
        {
          s: FCS_CELL_CHAR_SET.index(cell[:state]),
          x: cell[:x]/CHAR_SIZE - BOTTLE_X_OFFSET,
          y: cell[:y]/CHAR_SIZE + BOTTLE_Y_OFFSET,
          c: PILL_COLORS.index(cell[:img].color.to_s)
        }
      }
    end
    @@worker_queue_mutex.synchronize { @worker_queue << cells_with_content }
  end

  def producer_thread
    puts "Producer engine initialized sending messages to #{SNS_TOPIC_ARN}"
    loop do
      @@worker_queue_mutex.synchronize do
        unless @worker_queue.empty?
          @sns.publish({
            topic_arn: SNS_TOPIC_ARN,
            message: Base64.encode64(Zlib::Deflate.deflate(@worker_queue.pop.to_json))
          })
        end
      end
      sleep SLEEP_FREQ_FOR_PRODUCER
    end
  end

end
