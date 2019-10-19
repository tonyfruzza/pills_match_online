class SignIn
  LEADING_PX = 24
  LEFT_PADDING_PX = 8
  attr_accessor :name

  def initialize(negotiator)
    @n = negotiator
    prompt = Text.new('Player Name:', font: C64_FONT, x: LEFT_PADDING_PX, y: 0, color: CYAN)
    @name = Text.new('', font: C64_FONT, x: LEFT_PADDING_PX, y: LEADING_PX * 1)
    @l_shift_held = false
    @r_shift_held = false
  end

  def handle_input(key)
    case key
      when 'space'
        @name.text += ' '
      when 'backspace'
        @name.text = @name.text.chop
      when /^[a-z]$/
        @name.text += @l_shift_held || @r_shift_held ? key.upcase : key
      when 'left shift'
        @l_shift_held = true
      when 'right shift'
        @r_shift_held = true
      when 'return'
        Text.new('Negotiating connection', font: C64_FONT, x: LEFT_PADDING_PX, y: LEADING_PX * 2, color: L_BLUE)
        return @name.text
      else
    end
    return nil
  end

  def handle_input_up(key)
    case key
    when 'left shift'
      @l_shift_held = false
    when 'right shift'
      @r_shift_held = false
    end
  end
end
