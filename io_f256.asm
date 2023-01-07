;;;
;;; Define the I/O addresses on the F256
;;;

;
; MMU control registers
;
MMU_MEM_CTRL = $0000
MMU_IO_CTRL = $0001
MMU_IO_PAGE_0 = $00
MMU_IO_PAGE_1 = $01
MMU_IO_PAGE_TEXT = $02
MMU_IO_PAGE_COLOR = $03

;
; TinyVicky Master Control Registers
;
VKY_MST_CTRL_0 = $d000
VKY_MST_TEXT = $01
VKY_MST_OVLY = $02
VKY_MST_GRAPHICS = $04
VKY_MST_BITMAP = $08
VKY_MST_TILE = $10
VKY_MST_SPRITE = $20
VKY_MST_GAMMA = $40

VKY_MST_CTRL_1 = $d001
VKY_MST_RES_400 = $01
VKY_MST_DBL_X = $02
VKY_MST_DBL_Y = $04
VKY_MST_SLEEP = $08
VKY_MST_OVLY_TRANS = $10

;
; TinyVicky Border Control Registers
;
VKY_BRD_CTRL = $d004
VKY_BRD_BLUE = $d005
VKY_BRD_GREEN = $d006
VKY_BRD_RED = $d007
VKY_BRD_SIZE_X = $d008
VKY_BRD_SIZE_Y = $d009

;
; Tiny Vicky Cursor Control Registers
;
VKY_CURS_CTRL = $d010
VKY_CURS_ENABLE = $01
VKY_CURS_FLASH_1S = $08
VKY_CURS_FLASH_0_5S = $0a
VKY_CURS_FLASH_0_25S = $0c
VKY_CURS_FLASH_0_125S = $0d

VKY_CURS_CHAR = $d012
VKY_CURS_X = $d014
VKY_CURS_Y = $d016

VKY_TEXT_MATRIX = $c000
VKY_TEXT_FG_LUT = $d800
VKY_TEXT_BG_LUT = $d840

VKY_TEXT_FONT = $c000

INT_MASK_0 = $D66C
INT_PEND_0 = $D660
INT_MASK_1 = $D66D
INT_PEND_1 = $D661
INT_PS2_KBD = $04
