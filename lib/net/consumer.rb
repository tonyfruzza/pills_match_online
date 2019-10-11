require 'aws-sdk-sqs'
require 'zlib'
require 'base64'

class Consumer
  def initialize
    @sqs = Aws::SQS::Client.new(region: AWS_REGION)
    begin
      # puts "Is queue empty? We donno"
      # @sqs.purge_queue({queue_url: SQS_QUEUE_URL})
    rescue
      puts "Already has been purged within last 60 seconds"
    end
  end

  def read_from_queue
    res = @sqs.receive_message({queue_url: SQS_QUEUE_URL, max_number_of_messages: 10}).to_h
    res[:messages].each do |msg|
      ghost_data = JSON.parse(
        Zlib::Inflate.inflate(
          Base64.decode64(
            msg[:body]
          )
        )
      )
      update_ghost(ghost_data)
      delete_item(msg[:receipt_handle])
    end
  end

  def delete_item(receipt_handle)
    @sqs.delete_message({queue_url: SQS_QUEUE_URL, receipt_handle: receipt_handle})
  end

  def update_ghost(ghost_data)
    ghost_data.each do |cell|
      # puts "Creating image based on #{PILL_IMG_SET[cell['s']]}"
      new_pill = Image.new PILL_IMG_SET[cell['s']]
      new_pill.height = new_pill.width = CHAR_SIZE
      new_pill.x = (CHAR_SIZE * M_BOTTLE_X_OFFSET) + (cell['x'] * CHAR_SIZE)
      new_pill.y = (cell['y'] * CHAR_SIZE) + (CHAR_SIZE * M_BOTTLE_Y_OFFSET)
      new_pill.color = PILL_COLORS[cell['c']] if cell['c']
      new_pill.rotate = cell['r']
    end
  end
end
