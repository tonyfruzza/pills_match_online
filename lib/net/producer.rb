require 'aws-sdk-sns'
require 'zlib'
require 'base64'

class Producer
  def initialize(game_field, network_info)
    @gf = game_field
    @network_info = network_info
    @gfm = @gf.game_field_map
    @sns = Aws::SNS::Resource.new(region: AWS_REGION, credentials: network_info.aws_credentials)
    @topic = @sns.topic(@network_info.sns_topic_arn)
  end

  def send_game_field_state
    cells_with_content = []
    @gfm.each do |x|
      cells_with_content += x.select{|cell| cell[:state] != FCS_EMPTY}.map do |cell|
        {
          s: FCS_CELL_CHAR_SET.index(cell[:state]),
          x: cell[:x]/CHAR_SIZE - BOTTLE_X_OFFSET,
          y: cell[:y]/CHAR_SIZE - BOTTLE_Y_OFFSET,
          c: PILL_COLORS.index(cell[:img].color.to_s),
          r: cell[:img].rotate
        }
      end
    end

    cells_with_content.select{|i| i[:c] == nil}.each do |error_pos|
      puts error_pos
      error = Image.new VIRUS_IMG_THREE
      error.color = 'red'
      error.x = (error_pos[:x] * CHAR_SIZE) + (BOTTLE_X_OFFSET * CHAR_SIZE)
      error.y = (error_pos[:y] * CHAR_SIZE) + (BOTTLE_Y_OFFSET * CHAR_SIZE)
    end

    game_field_update_struct = {
      type: MSG_TYPE_FIELD_UPDATE,
      game_id: @network_info.game_id,
      user_id: @network_info.user_id,
      cells_with_content: cells_with_content
    }

    message = Base64.encode64(Zlib::Deflate.deflate(game_field_update_struct.to_json))
    puts "Sending #{message.length} bytes to SNS"
    @topic.publish({
      topic_arn: @network_info.sns_topic_arn,
      message: message
    })
  end
end
