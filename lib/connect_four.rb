module Ruby2D
  class Color
    def initialize(c)
      @c = c
      if !self.class.is_valid? c
        raise Error, "`#{c}` is not a valid color"
      else
        case c
        when String
          if c == 'random'
            @r, @g, @b, @a = rand, rand, rand, 1.0
          elsif self.class.is_hex?(c)
            @r, @g, @b, @a = hex_to_f(c)
          else
            @r, @g, @b, @a = hex_to_f(@@colors[c])
          end
        when Array
          @r, @g, @b, @a = [c[0], c[1], c[2], c[3]]
        when Color
          @r, @g, @b, @a = [c.r, c.g, c.b, c.a]
        end
      end
    end

    def to_s
      @c
    end

    def ==(other_color)
      return self.r == other_color.r && self.g == other_color.g && self.b == other_color.b
    end

    def copy_colors(other_color)
      self.r = other_color.r
      self.g = other_color.g
      self.b = other_color.b
      self.a = other_color.a
    end
  end
end

class ConnectFour
  def initialize(game_field)
    @gf = game_field
    @gfm = @gf.game_field_map
  end

  def flag_verticals_for_clear
    found_clears = false
    # Look down
    BOTTLE_WIDTH.times do |x|
      clear_set = []
      offset = 0
      BOTTLE_HEIGHT.times do |y|
        begin
          if @gfm[x][y][:state] != FCS_EMPTY
            # There is a piece here, start the drill down
            clear_set << @gfm[x][y]
            loop do
              offset += 1
              # Have we reached the bottom
              if (y + offset) >= BOTTLE_HEIGHT
                if clear_set.count >= MATCHES_TO_CLEAR
                  clear_set.collect!{|p| p[:to_clear] = true}
                  found_clears = true
                end
                clear_set = []
                offset = 0
                break
              end

              # Do we have a match below?
              if @gfm[x][y + offset][:state] != FCS_EMPTY && @gfm[x][y][:img].color == @gfm[x][y + offset][:img].color
                clear_set << @gfm[x][y + offset]
              else
                # No more contiguous color matches in this column
                if clear_set.count >= MATCHES_TO_CLEAR
                  clear_set.collect!{|p| p[:to_clear] = true}
                  found_clears = true
                end
                clear_set = []
                offset = 0
                break
              end
            end
          end
        rescue
          mark_bad_read(x, y)
          puts "Out of bounds with #{x}, #{y}"
        end
      end
    end
    return found_clears
  end

  def flag_horizontal_for_clear
    found_clears = false
    # Look left to right
    BOTTLE_HEIGHT.times do |y|
      clear_set = []
      offset = 0
      BOTTLE_WIDTH.times do |x|
        begin
          if @gfm[x][y][:state] != FCS_EMPTY
            # There is a piece here, start the drill down
            clear_set << @gfm[x][y]
            loop do
              offset += 1
              # Have we reached the bottom
              if (x + offset) >= BOTTLE_WIDTH
                if clear_set.count >= MATCHES_TO_CLEAR
                  clear_set.collect!{|p| p[:to_clear] = true}
                  found_clears = true
                end
                clear_set = []
                offset = 0
                break
              end

              # Do we have a match below?
              if @gfm[x + offset][y][:state] != FCS_EMPTY && @gfm[x][y][:img].color == @gfm[x + offset][y][:img].color
                clear_set << @gfm[x + offset][y]
              else
                # No more contiguous color matches in this column
                if clear_set.count >= MATCHES_TO_CLEAR
                  clear_set.collect!{|p| p[:to_clear] = true}
                  found_clears = true
                end
                clear_set = []
                offset = 0
                break
              end
            end
          end
        rescue
          mark_bad_read(x, y)
          puts "Out of bounds with #{x}, #{y}"
        end
      end
    end
    return found_clears
  end

  def perform_clears
    BOTTLE_WIDTH.times do |x|
      BOTTLE_HEIGHT.times do |y|
        if @gfm[x][y][:to_clear]
          # Convert the other pill half to a pill half
          case @gfm[x][y][:state]
          when FCS_PILL_LEFT
            # This side is set to clear, should we convert the other half
            # to a half pill?
            if @gfm[x+1][y][:to_clear] != true && @gfm[x+1][y][:state] == FCS_PILL_RIGHT
              new_image = Image.new PILL_IMG_HALF
              new_image.color.copy_colors(@gfm[x+1][y][:img].color)
              new_image.x = @gfm[x+1][y][:x]
              new_image.y = @gfm[x+1][y][:y]
              new_image.height = new_image.width = CHAR_SIZE
              begin
                @gfm[x+1][y][:img].remove
              rescue
                mark_bad_read(x+1, y)
                puts "No image at #{x+1}, #{y} expecting FCS_PILL_RIGHT"
              end
              @gfm[x+1][y][:img] = new_image
              @gfm[x+1][y][:state] = FCS_PILL_HALF
            end
          when FCS_PILL_RIGHT # if we're clearing the whole pill then skip
            if @gfm[x-1][y][:to_clear] != true && @gfm[x-1][y][:state] == FCS_PILL_LEFT
              new_image = Image.new PILL_IMG_HALF
              begin
                new_image.color.copy_colors(@gfm[x-1][y][:img].color)
                new_image.x = @gfm[x-1][y][:x]
                new_image.y = @gfm[x-1][y][:y]
                new_image.height = new_image.width = CHAR_SIZE
              rescue
                mark_bad_read(x-1, y)
                $paused = true
              end
              begin
                @gfm[x-1][y][:img].remove
              rescue
                mark_bad_read(x-1, y)
                puts "No image at #{x-1}, #{y} expecting FCS_PILL_LEFT"
              end
              @gfm[x-1][y][:img] = new_image
              @gfm[x-1][y][:state] = FCS_PILL_HALF
            end
          when FCS_PILL_TOP
            if @gfm[x][y+1][:to_clear] != true && @gfm[x][y+1][:state] == FCS_PILL_BOTTOM
              new_image = Image.new PILL_IMG_HALF
              new_image.color.copy_colors(@gfm[x][y+1][:img].color)
              new_image.x = @gfm[x][y+1][:x]
              new_image.y = @gfm[x][y+1][:y]
              new_image.height = new_image.width = CHAR_SIZE
              begin
                @gfm[x][y+1][:img].remove
              rescue
                mark_bad_read(x, y+1)
                puts "No image at #{x}, #{y+1} expecting FCS_PILL_BOTTOM"
              end
              @gfm[x][y+1][:img] = new_image
              @gfm[x][y+1][:state] = FCS_PILL_HALF
            end
          when FCS_PILL_BOTTOM
            if @gfm[x][y-1][:to_clear] != true && @gfm[x][y-1][:state] == FCS_PILL_TOP
              new_image = Image.new PILL_IMG_HALF
              begin
                new_image.color.copy_colors(@gfm[x][y-1][:img].color)
              rescue
              end
              new_image.x = @gfm[x][y-1][:x]
              new_image.y = @gfm[x][y-1][:y]
              new_image.height = new_image.width = CHAR_SIZE
              begin
                @gfm[x][y-1][:img].remove
              rescue
                mark_bad_read(x, y-1)
                puts "No image at #{x}, #{y-1} expecting FCS_PILL_TOP"
              end
              @gfm[x][y-1][:img] = new_image
              @gfm[x][y-1][:state] = FCS_PILL_HALF
            end
          end

          @gfm[x][y][:state] = FCS_EMPTY
          @gfm[x][y][:color] = nil
          @gfm[x][y][:to_clear] = nil
          @gfm[x][y][:img].remove
          @gfm[x][y][:img] = nil
        end
      end
    end
  end

  def do_drops
    did_drops = false
    BOTTLE_WIDTH.times do |x|
      (BOTTLE_HEIGHT-1).times do |y|
        case @gfm[x][y][:state]
        when FCS_PILL_HALF
          if @gfm[x][y+1][:state] == FCS_EMPTY
            @gfm[x][y+1][:state] = @gfm[x][y][:state]
            @gfm[x][y+1][:img] = @gfm[x][y][:img]
            @gfm[x][y+1][:img].y += CHAR_SIZE
            @gfm[x][y][:img] = nil
            @gfm[x][y][:state] = FCS_EMPTY
            did_drops = true
          end
        when FCS_PILL_BOTTOM
          if @gfm[x][y+1][:state] == FCS_EMPTY
            # Bottom piece shift down
            @gfm[x][y+1][:state] = @gfm[x][y][:state]
            @gfm[x][y+1][:img] = @gfm[x][y][:img]
            @gfm[x][y+1][:img].y += CHAR_SIZE
            # Top half shift down
            @gfm[x][y][:state] = @gfm[x][y-1][:state]
            @gfm[x][y][:img] = @gfm[x][y-1][:img]
            @gfm[x][y][:img].y += CHAR_SIZE
            @gfm[x][y-1][:img] = nil
            @gfm[x][y-1][:state] = FCS_EMPTY
            did_drops = true
          end
        when FCS_PILL_LEFT
          if @gfm[x][y+1][:state] == FCS_EMPTY && @gfm[x+1][y+1][:state] == FCS_EMPTY
            # Drop leftside
            @gfm[x][y+1][:state] = @gfm[x][y][:state]
            @gfm[x][y+1][:img] = @gfm[x][y][:img]
            @gfm[x][y+1][:img].y += CHAR_SIZE
            @gfm[x][y][:img] = nil
            @gfm[x][y][:state] = FCS_EMPTY
            # Drop rightside
            @gfm[x+1][y+1][:state] = @gfm[x+1][y][:state]
            @gfm[x+1][y+1][:img] = @gfm[x+1][y][:img]
            @gfm[x+1][y+1][:img].y += CHAR_SIZE
            @gfm[x+1][y][:img] = nil
            @gfm[x+1][y][:state] = FCS_EMPTY
            did_drops = true
          end
        end
      end
    end
    return did_drops
  end

  def mark_bad_read(x, y)
    error_image = Image.new 'assets/error_pill_half.png'
    error_image.color = 'red'
    error_image.x = @gfm[x][y][:x]
    error_image.y = @gfm[x][y][:y]
    error_image.height = error_image.width = CHAR_SIZE
    $paused = true
  end

  def perform_clear_iteration
    loop do
      break unless flag_verticals_for_clear || flag_horizontal_for_clear
      perform_clears
      loop do
        did_a_drop = do_drops # Do this until there are no more
        in_drop_state = true if did_a_drop
        break unless did_a_drop
      end
    end
  end

end
