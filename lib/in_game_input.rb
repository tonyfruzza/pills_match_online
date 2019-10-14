on :key_up do |k|
  key = k['key']
  case key
  when 'left'
    @key_repeats = 0
  when 'right'
    @key_repeats = 0
  when 'down'
    @key_down_repeats = 0
  when 'up'
    @key_rotate_repeats = 0
  end
end

on :key_held do |k|
  key = k['key']
  case key
  when 'left'
    @game_play.pill.move_left if @key_repeats == 0
    @key_repeats += 1
    @key_repeats = 0 if @key_repeats == KEY_TIME_REPEAT
  when 'right'
    @game_play.pill.move_right if @key_repeats == 0
    @key_repeats += 1
    @key_repeats = 0 if @key_repeats == KEY_TIME_REPEAT
  when 'up'
    @game_play.pill.rotate if @key_rotate_repeats == 0
    @key_rotate_repeats += 1
    @key_rotate_repeats = 0 if @key_rotate_repeats == KEY_TIME_REPEAT
  when 'down'
    @game_play.pill.move_down if @key_down_repeats == 0
    @key_down_repeats += 1
    @key_down_repeats = 0 if @key_down_repeats == KEY_TIME_REPEAT_FOR_DOWN
  end
end

on :key_down do |k|
  key = k['key']
  case key
  when 'backspace'
    exit
    close
  when 'p'
    @game_play.paused = true
  when 's'
    @game_play.paused = false
  else
  end
end
