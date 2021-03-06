# Window States
@key_repeats = 0
@key_rotate_repeats = 0
@key_down_repeats = 0
@in_drop_state = false
@in_drop_state_count = 0

# SCREEN
SCREEN_COLS = 40
CHAR_SIZE = (get :width) / SCREEN_COLS
SCREEN_ROWS = 25

MATCHES_TO_CLEAR = 4
DROP_TICKS = 60
# Game Field
BOTTLE_WIDTH = 8
BOTTLE_HEIGHT = 18
BOTTLE_X_OFFSET = SCREEN_COLS/2 - BOTTLE_WIDTH/2
BOTTLE_Y_OFFSET = 1
BOTTLE_LEFT_SIDE = BOTTLE_X_OFFSET*CHAR_SIZE
BOTTLE_RIGHT_SIDE = BOTTLE_X_OFFSET*CHAR_SIZE + (BOTTLE_WIDTH-1) * CHAR_SIZE
# Field Cell States
FCS_OUT_OF_RANGE = -1
FCS_EMPTY = 0
FCS_OCUPIED = 1
FCS_PILL_RIGHT = 2
FCS_PILL_LEFT = 3
FCS_PILL_TOP = 4
FCS_PILL_BOTTOM = 5
FCS_PILL_HALF = 6
FCS_PILL_VIRUS_ONE = 7
FCS_PILL_VIRUS_TWO = 8
FCS_PILL_VIRUS_THREE = 9

FCS_CELL_CHAR_SET = [
  FCS_EMPTY,
  FCS_OCUPIED,
  FCS_PILL_RIGHT,
  FCS_PILL_LEFT,
  FCS_PILL_TOP,
  FCS_PILL_BOTTOM,
  FCS_PILL_HALF,
  FCS_PILL_VIRUS_ONE,
  FCS_PILL_VIRUS_TWO,
  FCS_PILL_VIRUS_THREE
]

PILL_IMG_RIGHT = 'assets/h_pill_right.png'
PILL_IMG_LEFT = 'assets/h_pill_left.png'
PILL_IMG_HALF = 'assets/pill_half.png'
VIRUS_IMG_ONE = 'assets/virus_one.png'
VIRUS_IMG_TWO = 'assets/virus_two.png'
VIRUS_IMG_THREE = 'assets/virus_three.png'

PILL_IMG_SET = [
  nil,
  nil,
  PILL_IMG_RIGHT, # 2
  PILL_IMG_LEFT,  # 3
  PILL_IMG_RIGHT, # 4
  PILL_IMG_LEFT,  # 5
  PILL_IMG_HALF,  # 6
  VIRUS_IMG_ONE,  # 7
  VIRUS_IMG_TWO,  # 8
  VIRUS_IMG_THREE # 9
]

# Mirror Game Field
M_BOTTLE_WIDTH = 8
M_BOTTLE_HEIGHT = 18
M_BOTTLE_X_OFFSET = 2
M_BOTTLE_Y_OFFSET = 1

# Input Control
KEY_TIME_REPEAT = 7
KEY_TIME_REPEAT_FOR_DOWN = 2

# Color
CYAN = '#5dfffb'
YELLOW = '#fcff1e'
L_BLUE = '#9587f7'

PILL_COLORS = [CYAN, YELLOW, L_BLUE]

VIRUS_TYPE = {
  FCS_PILL_VIRUS_ONE: {color: CYAN, img: VIRUS_IMG_ONE},
  FCS_PILL_VIRUS_TWO: {color: YELLOW, img: VIRUS_IMG_TWO},
  FCS_PILL_VIRUS_THREE: {color: L_BLUE, img: VIRUS_IMG_THREE}
}

PILL_ORIENTATION_FLAT = 0
PILL_ORIENTATION_TALL = 1
C64_FONT = 'assets/fonts/C64_Pro-STYLE.ttf'
EXIT_FROM_LOGIN = 'done_here'

# AWS
ENABLE_MULTI_PLAY_PRODUCER = true
ENABLE_MULTI_PLAY_CONSUMER = true
AWS_REGION = 'us-west-2'
TICKS_TO_SEND_SCREEN_STATE = 60
BASE_API_URL = 'https://xmfb0egn52.execute-api.us-west-2.amazonaws.com/dev/'

# Protocol
MSG_TYPE_GAME_STATE = 0
MSG_TYPE_FIELD_UPDATE = 1
