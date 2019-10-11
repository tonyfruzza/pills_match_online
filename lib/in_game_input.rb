@key_repeats = 0
@key_rotate_repeats = 0
@key_down_repeats = 0
@in_drop_state = false
@in_drop_state_count = 0

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
    @pill.move_left if @key_repeats == 0
    @key_repeats += 1
    @key_repeats = 0 if @key_repeats == KEY_TIME_REPEAT
  when 'right'
    @pill.move_right if @key_repeats == 0
    @key_repeats += 1
    @key_repeats = 0 if @key_repeats == KEY_TIME_REPEAT
  when 'up'
    @pill.rotate if @key_rotate_repeats == 0
    @key_rotate_repeats += 1
    @key_rotate_repeats = 0 if @key_rotate_repeats == KEY_TIME_REPEAT
  when 'down'
    @pill.move_down if @key_down_repeats == 0
    @key_down_repeats += 1
    @key_down_repeats = 0 if @key_down_repeats == KEY_TIME_REPEAT_FOR_DOWN
  end
end

on :key_down do |k|
  key = k['key']
  case key
  when 'space'
    clear
  when 'backspace'
    close
  when 'p'
    $paused = true
  when 's'
    $paused = false
  else
  end
end
