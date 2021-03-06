class GamePlay < Window
  attr_accessor :paused, :pill

  def initialize(network_info)
    @network_info = network_info
    @tick = 0
    @paused = false
    @gf = GameField.new
    @cf = ConnectFour.new(@gf)
    @producer = Producer.new(@gf, @network_info) if ENABLE_MULTI_PLAY_PRODUCER
    @consumer = Consumer.new(@network_info) if ENABLE_MULTI_PLAY_CONSUMER
    @viruses = Viruses.new(@gf)
    @pill = Pill.new(@gf)
  end

  def frame
    if @tick % DROP_TICKS == 0
      # Hit bottom
      if @pill.move_down == FCS_OCUPIED
        @gf.commit_pill(@pill)
        total_clears = @cf.perform_clear_iteration
        if total_clears > 0
          puts "Cleared: #{total_clears}"
        end
        # Reset
        @pill = Pill.new(@gf)
        @key_down_repeats = @key_repeats = 0
        @producer.send_game_field_state if ENABLE_MULTI_PLAY_PRODUCER
        @consumer.read_from_queue if ENABLE_MULTI_PLAY_CONSUMER
      end
    end
    @tick += 1
  end
end
