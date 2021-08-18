.const spacescraft_sprite = 0
.const fire_sprite = 1

.const spacescraft_x_adr = $d000
.const spacescraft_y_adr = $d001

.const fire_x_adr = $d002
.const fire_y_adr = $d003

.const sprite_enable_adr = $d015
.const sprite_bit9_adr = $d010

.const screen = $0400
.const CHROUT= $FFD2
.const CHRIN = $FFCF
.const PLOT = $FFF0

.const BORDER_COLOR = $d020
.const BACKGROUP_COLOR1 = $d021
.const SPACE = $20

.const KEY_LEFT = 12 // 
.const KEY_RIGHT = 12 //
.const KET_UP = 12 //
.const KEY_DOWN = 12
.const KEY_WALK = 12
.const KEY_RUN = 12
.const KEY_JUMP = 12
.const KEY_SNEAK = 12

.const MOUSE_LEFT = 12
.const MOUSE_RIGHT = 12

//    .pc = * "Keyboard Scan Routine"