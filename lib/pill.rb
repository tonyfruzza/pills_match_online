class Pill
  attr_reader :pill_left, :pill_right, :rotate_state
  def initialize(game_field_object)
    @gf = game_field_object
    @pill_left  = Image.new PILL_IMG_LEFT
    @pill_right = Image.new PILL_IMG_RIGHT

    # Try twice if dual colors
    c1, c2 = PILL_COLORS[rand(0...3)], PILL_COLORS[rand(0...3)]
    if c1 == c2
      c1, c2 = PILL_COLORS[rand(0...3)], PILL_COLORS[rand(0...3)]
    end
    @pill_left.color, @pill_right.color = c1, c2

    @pill_left.height = @pill_left.width = @pill_right.height = @pill_right.width = CHAR_SIZE
    @pill_left.y = @pill_right.y = CHAR_SIZE * (BOTTLE_Y_OFFSET + 1)
    @pill_left.x = CHAR_SIZE * (SCREEN_COLS/2-1)
    @pill_right.x = CHAR_SIZE + CHAR_SIZE * (SCREEN_COLS/2-1)
    @rotate_state = 0
  end

  def move_right(dry_run = false)
    # has it hit the wall?
    return FCS_OCUPIED if @pill_right.x == BOTTLE_RIGHT_SIDE
    # is here another object in the way?
    return FCS_OCUPIED if @gf.screen_loc_2_game_field_cell(@pill_left.x + CHAR_SIZE, @pill_left.y)[:state] != FCS_EMPTY || @gf.screen_loc_2_game_field_cell(@pill_right.x + CHAR_SIZE, @pill_right.y)[:state] != FCS_EMPTY

    @pill_left.x += CHAR_SIZE unless dry_run
    @pill_right.x += CHAR_SIZE unless dry_run
    return true
  end

  def move_left(dry_run = false)
    # has it hit the wall?
    return FCS_OCUPIED if @pill_left.x == BOTTLE_LEFT_SIDE
    # is here another object in the way?
    return FCS_OCUPIED if @gf.screen_loc_2_game_field_cell(@pill_left.x - CHAR_SIZE, @pill_left.y)[:state] != FCS_EMPTY || @gf.screen_loc_2_game_field_cell(@pill_right.x - CHAR_SIZE, @pill_right.y)[:state] != FCS_EMPTY

    @pill_left.x -= CHAR_SIZE unless dry_run
    @pill_right.x -= CHAR_SIZE unless dry_run
    return true
  end

  def rotate
    case @rotate_state
    when PILL_ORIENTATION_FLAT
      # Transition to tall

      # look for room on top
      also_move_down = nil
      also_move_left = nil
      also_move_right = nil
      if @gf.screen_loc_2_game_field_cell(@pill_left.x, @pill_left.y - CHAR_SIZE)[:state] != FCS_EMPTY
        # There's something above!
        if @gf.screen_loc_2_game_field_cell(@pill_left.x + CHAR_SIZE, @pill_left.y )[:state] == FCS_EMPTY &&  @gf.screen_loc_2_game_field_cell(@pill_left.x + CHAR_SIZE, @pill_left.y - CHAR_SIZE)[:state] == FCS_EMPTY
          # There's room to the right and up
          also_move_right = true
        elsif @gf.screen_loc_2_game_field_cell(@pill_left.x, @pill_left.y + CHAR_SIZE)[:state] != FCS_EMPTY
          # There's room below
          also_move_down = true
        else
          return
        end
      end
      color_temp_1 = @pill_left.color.to_s
      color_temp_2 = @pill_right.color.to_s

      @pill_left.rotate = 270
      @pill_right.rotate = 270

      @pill_right.x -= CHAR_SIZE
      @pill_right.y -= CHAR_SIZE
      @pill_left.color = color_temp_2
      @pill_right.color = color_temp_1
      move_down if also_move_down
      move_right if also_move_right
      @rotate_state = PILL_ORIENTATION_TALL
      # @gf.screen_loc_2_game_field_cell(@pill_left.x, @pill_left.y)[:state] = FCS_PILL_LEFT
      # @gf.screen_loc_2_game_field_cell(@pill_right.x, @pill_right.y)[:state] = FCS_PILL_RIGHT
    when PILL_ORIENTATION_TALL
      # Transition to flat
      # Look for collision on right
      if @pill_right.x == BOTTLE_RIGHT_SIDE
        # wall collision on right
        # is there room on left to scoot over?
        return if @gf.screen_loc_2_game_field_cell(@pill_left.x - CHAR_SIZE, @pill_left.y)[:state] != FCS_EMPTY
        also_move_left = true
      elsif @gf.screen_loc_2_game_field_cell(@pill_left.x + CHAR_SIZE, @pill_left.y)[:state] != FCS_EMPTY
        return if @gf.screen_loc_2_game_field_cell(@pill_left.x - CHAR_SIZE, @pill_left.y)[:state] != FCS_EMPTY
        also_move_left = true
      end
      @pill_left.rotate = 0
      @pill_right.rotate = 0
      @pill_right.x += CHAR_SIZE
      @pill_right.y += CHAR_SIZE
      move_left if also_move_left
      @rotate_state = PILL_ORIENTATION_FLAT
      # @gf.screen_loc_2_game_field_cell(@pill_left.x, @pill_left.y)[:state] = FCS_PILL_TOP
      # @gf.screen_loc_2_game_field_cell(@pill_right.x, @pill_right.y)[:state] = FCS_PILL_BOTTOM
    end
  end

  def move_down
    # Collision detection down
    return FCS_OCUPIED if (@pill_right.y ? @pill_left.y : @pill_right.y) == (BOTTLE_Y_OFFSET*CHAR_SIZE + CHAR_SIZE*(BOTTLE_HEIGHT-1))

    return FCS_OCUPIED if @gf.screen_loc_2_game_field_cell(@pill_left.x, @pill_left.y + CHAR_SIZE)[:state] != FCS_EMPTY || @gf.screen_loc_2_game_field_cell(@pill_right.x, @pill_right.y + CHAR_SIZE)[:state] != FCS_EMPTY
    @pill_left.y += CHAR_SIZE
    @pill_right.y += CHAR_SIZE
    return FCS_EMPTY
  end
end
