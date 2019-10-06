class Viruses
  def initialize(gf)
    @gf = gf
    viruses = 12
    seed_virsus(:FCS_PILL_VIRUS_ONE, viruses)
    seed_virsus(:FCS_PILL_VIRUS_TWO, viruses)
    seed_virsus(:FCS_PILL_VIRUS_THREE, viruses)
  end

  def seed_virsus(virus_type, count)
    count.times do |v|
      x, y = (rand(0..(BOTTLE_WIDTH-1))+BOTTLE_X_OFFSET)*CHAR_SIZE, (rand(9..BOTTLE_HEIGHT)+BOTTLE_Y_OFFSET)*CHAR_SIZE

      cell_to_v = @gf.screen_loc_2_game_field_cell(x, y)
      if(cell_to_v[:state] == FCS_OUT_OF_RANGE)
        puts "Was looking for #{x}, #{y}, but is out of range"
        next
      end
      if cell_to_v[:state] != FCS_EMPTY
        puts "Already a virus here, moving on"
        next
      end

      cell_to_v[:state] = virus_type
      cell_to_v[:img] = Image.new VIRUS_TYPE[virus_type][:img]
      cell_to_v[:img].x = cell_to_v[:x]
      cell_to_v[:img].y = cell_to_v[:y]
      cell_to_v[:img].height = cell_to_v[:img].width = CHAR_SIZE
      cell_to_v[:img].color = VIRUS_TYPE[virus_type][:color]
    end
  end
end
