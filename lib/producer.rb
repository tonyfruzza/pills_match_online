require 'aws-sdk-sns'
require 'zlib'
require 'base64'

# ruby 2.4.0p0 crashes in .to_json

class Producer
  def initialize(game_field)
    @gf = game_field
    @gfm = @gf.game_field_map
    # @sns = Aws::SNS::Client.new(region: AWS_REGION)
    @sns = Aws::SNS::Resource.new(region: AWS_REGION)
    @topic = @sns.topic(SNS_TOPIC_ARN)
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

    message = Base64.encode64(Zlib::Deflate.deflate(cells_with_content.to_json))
    puts "Sending #{message.length} bytes to SNS"
    @topic.publish({
      topic_arn: SNS_TOPIC_ARN,
      message: message
    })
  end
end
