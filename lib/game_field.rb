class GameField
  def initialize
    @bg_blocks = []
    @game_field_map = []

    fill_background
    clear_game_field
  end

  def clear_game_field
    BOTTLE_WIDTH.times do |col|
      @game_field_map[col] = []
      BOTTLE_HEIGHT.times do |row|
        @bg_blocks[col+BOTTLE_X_OFFSET][row+BOTTLE_Y_OFFSET].remove
        @game_field_map[col][row] = {
          x: (BOTTLE_X_OFFSET + col) * CHAR_SIZE,
          y: (BOTTLE_Y_OFFSET + row) * CHAR_SIZE,
          state: FCS_EMPTY,
          to_clear: nil,
          img: nil,
          r: nil
        }
      end
    end
  end

  def game_field_map
    @game_field_map
  end

  def commit_pill(pill)
    left_commit = screen_loc_2_game_field_cell(pill.left.x, pill.left.y)
    right_commit = screen_loc_2_game_field_cell(pill.right.x, pill.right.y)

    left_commit[:img] = pill.left
    left_commit[:state] = pill.rotate_state == PILL_ORIENTATION_FLAT ? FCS_PILL_LEFT : FCS_PILL_BOTTOM
    right_commit[:img] = pill.right
    right_commit[:state] = pill.rotate_state == PILL_ORIENTATION_FLAT ? FCS_PILL_RIGHT : FCS_PILL_TOP
  end

  def screen_loc_2_game_field_cell(x, y)
    finds = []
    @game_field_map.each{|i| finds << i.find{|n| n[:x] == x && n[:y] == y}}
    return {state: FCS_OUT_OF_RANGE} unless finds.any?
    return finds.find{|x| x != nil}
  end

  def fill_background
    SCREEN_COLS.times do |col|
      @bg_blocks[col] = []
      SCREEN_ROWS.times do |row|
        @bg_blocks[col][row] = Image.new 'assets/back_ground.png'
        @bg_blocks[col][row].height = @bg_blocks[col][row].width = CHAR_SIZE
        @bg_blocks[col][row].x = col * CHAR_SIZE
        @bg_blocks[col][row].y = row * CHAR_SIZE
      end
    end

    M_BOTTLE_WIDTH.times do |col|
      M_BOTTLE_HEIGHT.times do |row|
        @bg_blocks[col+M_BOTTLE_X_OFFSET][row+M_BOTTLE_Y_OFFSET].remove
      end
    end
  end

end
