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
  end
end
