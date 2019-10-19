require 'aws-sdk-sqs'
require 'zlib'
require 'base64'

class Consumer
  def initialize(network_info)
    @network_info = network_info
    @sqs = Aws::SQS::Client.new(region: AWS_REGION, credentials: @network_info.aws_credentials)
  end

  def read_from_queue
    res = @sqs.receive_message({queue_url: @network_info.sqs_url, max_number_of_messages: 10}).to_h
    return unless res.key?(:messages)
    res[:messages].each do |msg|
      msg_parsed = JSON.parse(
        Zlib::Inflate.inflate(
          Base64.decode64(
            msg[:body]
          )
        )
      )
      codec(msg_parsed)
      delete_item(msg[:receipt_handle])
    end
  end

  def codec(msg)
    # Perform some sanity checks
    case msg['type']
    when MSG_TYPE_FIELD_UPDATE
      update_ghost(msg['cells_with_content']) unless msg['user_id'] == @network_info.user_id
    end

  end

  def delete_item(receipt_handle)
    @sqs.delete_message({queue_url: @network_info.sqs_url, receipt_handle: receipt_handle})
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
