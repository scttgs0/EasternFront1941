;---------------------------------------
; System Equates for Foenix C256
;---------------------------------------

INT_PENDING_REG0        = $00_0140
INT_PENDING_REG1        = $00_0141
INT_MASK_REG0           = $00_014C
FNX0_INT00_SOF      = $01
INT_MASK_REG1           = $00_014D
FNX1_INT00_KBD      = $01

vecCOP                  = $00_FFE4
vecBRK                  = $00_FFE6
vecABORT                = $00_FFE8
vecNMI                  = $00_FFEA
vecEmuRESET             = $00_FFFC
vecIRQ                  = $00_FFEE

;---------------------------------------

MASTER_CTRL_L           = $AF_0000
mcTextOn            = $01               ; Enable the Text Mode
mcOverlayOn         = $02               ; Enable the Overlay of the text mode on top of Graphic Mode (the Background Color is ignored)
mcGraphicsOn        = $04               ; Enable the Graphic Mode
mcBitmapOn          = $08               ; Enable the Bitmap Module In Vicky
mcTileMapOn         = $10               ; Enable the Tile Module in Vicky
mcSpriteOn          = $20               ; Enable the Sprite Module in Vicky
mcDisableVideo      = $80               ; This will disable the Scanning of the Video hence giving 100% bandwith to the CPU

MASTER_CTRL_H           = $AF_0001
mcVideoMode640      = $00               ; 0 - 640x480 (Clock @ 25.175Mhz)
mcVideoMode800      = $01               ; 1 - 800x600 (Clock @ 40Mhz)
mcVideoMode320      = $02               ; 2 - 320x240 pixel-doubling (Clock @ 25.175Mhz)
mcVideoMode400      = $03               ; 3 - 400x300 pixel-doubling (Clock @ 40Mhz)

BORDER_CTRL             = $AF_0004      ; Bit[0] - Enable (1 by default)
bcEnable            = $01               ; Bit[4..6]: X Scroll Offset (Will scroll Left)

BORDER_COLOR_B          = $AF_0005
BORDER_COLOR_G          = $AF_0006
BORDER_COLOR_R          = $AF_0007
BORDER_X_SIZE           = $AF_0008      ; Values: 0 - 32 (Default: 32)
BORDER_Y_SIZE           = $AF_0009      ; Values: 0 - 32 (Default: 32)

;---------------------------------------

BITMAP0_CTRL            = $AF_0100
bmcEnable           = $01
BITMAP0_START_ADDR      = $AF_0101

;---------------------------------------

TILE0_CTRL              = $AF_0200
tcEnable            = $01
TILE0_START_ADDR        = $AF_0201
TILE0_X_SIZE            = $AF_0204
TILE0_Y_SIZE            = $AF_0206
TILE0_WINDOW_X_POS      = $AF_0208
TILE0_WINDOW_Y_POS      = $AF_020A

TILE1_CTRL              = $AF_020C
TILE1_START_ADDR        = $AF_020D
TILE1_X_SIZE            = $AF_0210
TILE1_Y_SIZE            = $AF_0212
TILE1_WINDOW_X_POS      = $AF_0214
TILE1_WINDOW_Y_POS      = $AF_0216

TILE2_CTRL              = $AF_0218
TILE2_START_ADDR        = $AF_0219
TILE2_X_SIZE            = $AF_021C
TILE2_Y_SIZE            = $AF_021E
TILE2_WINDOW_X_POS      = $AF_0220
TILE2_WINDOW_Y_POS      = $AF_0222

TILE3_CTRL              = $AF_0224
TILE3_START_ADDR        = $AF_0225
TILE3_X_SIZE            = $AF_0228
TILE3_Y_SIZE            = $AF_022A
TILE3_WINDOW_X_POS      = $AF_022C
TILE3_WINDOW_Y_POS      = $AF_022E

TILESET0_ADDR           = $AF_0280
TILESET0_ADDR_CFG       = $AF_0283
tclVertical         = $00
tclSquare           = $08

;---------------------------------------

VDMA_CTRL               = $AF_0400
vdcEnable       = $01
vdc1D_2D        = $02                   ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
vdcTRF_Fill     = $04                   ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
vdcInt_Enable   = $08                   ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
vdcSysRAM_Src   = $10                   ; Set to 1 to Indicate that the Source is the System Ram Memory
vdcSysRAM_Dst   = $20                   ; Set to 1 to Indicate that the Destination is the System Ram Memory
vdcStart_TRF    = $80                   ; Set to 1 To Begin Process, Need to Cleared before, you can start another
VDMA_STATUS             = $AF_0401      ; Read only
vdsSize_Err     = $01                   ; If Set to 1, Overall Size is Invalid
vdsDst_Add_Err  = $02                   ; If Set to 1, Destination Address Invalid
vdsSrc_Add_Err  = $04                   ; If Set to 1, Source Address Invalid
vdsVDMA_IPS     = $80                   ; If Set to 1, VDMA Transfer in Progress (this Inhibit CPU Access to Mem)
VDMA_DST_ADDR           = $AF_0405      ; Destination Pointer within Vicky's video memory Range
VDMA_SIZE               = $AF_0408      ; Maximum Value: $40:0000 (4Megs)

SDMA0_CTRL              = $AF_0420
sdcEnable       = $01
sdc1D_2D        = $02                   ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
sdcTRF_Fill     = $04                   ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
sdcInt_Enable   = $08                   ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
sdcSysRAM_Src   = $10                   ; Set to 1 to Indicate that the Source is the System Ram Memory
sdcSysRAM_Dst   = $20                   ; Set to 1 to Indicate that the Destination is the System Ram Memory
sdcStart_TRF    = $80                   ; Set to 1 To Begin Process, Need to Cleared before, you can start another
SDMA_SRC_ADDR           = $AF_0422      ; Pointer to the Source of the Data to be stransfered
SDMA_SIZE               = $AF_0428      ; Maximum Value: $40:0000 (4Megs)

;---------------------------------------

MOUSE_PTR_CTRL          = $AF_0700

C256F_MODEL_MAJOR       = $AF_070B
C256F_MODEL_MINOR       = $AF_070C

;---------------------------------------

SP00_CTRL               = $AF_0C00
scEnable            = $01

scLUT0              = $00
scLUT1              = $02
scLUT2              = $04
scLUT3              = $06
scLUT4              = $08
scLUT5              = $0A
scLUT6              = $0C
scLUT7              = $0E

scDEPTH0            = $00
scDEPTH1            = $10
scDEPTH2            = $20
scDEPTH3            = $30
scDEPTH4            = $40
scDEPTH5            = $50
scDEPTH6            = $60

SP00_ADDR               = $AF_0C01      ; [long]
SP00_X_POS              = $AF_0C04      ; [word]
SP00_Y_POS              = $AF_0C06      ; [word]

SP01_CTRL               = $AF_0C08
SP01_ADDR               = $AF_0C09
SP01_X_POS              = $AF_0C0C
SP01_Y_POS              = $AF_0C0E

SP02_CTRL               = $AF_0C10
SP02_ADDR               = $AF_0C11
SP02_X_POS              = $AF_0C14
SP02_Y_POS              = $AF_0C16

;---------------------------------------

KEYBOARD_SCAN_CODE      = $AF_115F
KBD_INPT_BUF            = $AF_1803
irqKBD          = $01                   ; keyboard Interrupt
FG_CHAR_LUT_PTR         = $AF_1F40      ; 16 entries = ARGB     $008060FF (medium slate blue)
                                        ;                       $00108020 (la salle green)
BG_CHAR_LUT_PTR		    = $AF_1F80      ; 16 entries = ARGB

;---------------------------------------

GRPH_LUT0_PTR	        = $AF_2000

;---------------------------------------

FONT_MEMORY_BANK0       = $AF_8000      ; $AF8000 - $AF87FF
CS_TEXT_MEM_PTR         = $AF_A000      ; ascii code for text character
CS_COLOR_MEM_PTR        = $AF_C000      ; HiNibble = Foreground; LoNibble = Background
                                        ; 0-15 = index into the CHAR_LUT tables

;---------------------------------------

SID_FREQ1               = $AF_E400      ; [word]
SID_PULSE1              = $AF_E402      ; [word]
SID_CTRL1               = $AF_E404
SID_ATDCY1              = $AF_E405
SID_SUREL1              = $AF_E406

SID_FREQ2               = $AF_E407      ; [word]
SID_PULSE2              = $AF_E409      ; [word]
SID_CTRL2               = $AF_E40B
SID_ATDCY2              = $AF_E40C
SID_SUREL2              = $AF_E40D

SID_FREQ3               = $AF_E40E      ; [word]
SID_PULSE3              = $AF_E410      ; [word]
SID_CTRL3               = $AF_E412
SID_ATDCY3              = $AF_E413
SID_SUREL3              = $AF_E414

SID_CUTOFF              = $AF_E415      ; [word]
SID_RESON               = $AF_E417
SID_SIGVOL              = $AF_E418
SID_RANDOM              = $AF_E41B
SID_ENV3                = $AF_E41C

;--------------------------------------

JOYSTICK0               = $AF_E800      ; (R) Joystick 0

                                        ;           1110            bit-0   UP
                                        ;      1010   |   0110      bit-1   DOWN
                                        ;          \  |  /          bit-2   LEFT
                                        ;   1011----1111----0111    bit-3   RIGHT
                                        ;          /  |  \
                                        ;      1001   |   0101
                                        ;           1101

LUTBkColor      = 0
LUTPfColor0     = 1
LUTPfColor1     = 2
LUTPfColor2     = 3
LUTPfColor3     = 4
LUTPfColor4     = 5
LUTPfColor5     = 6
LUTPfColor6     = 7
LUTPfColor7     = 8
LUTSprColor0    = 9
LUTSprColor1    = 10
LUTSprColor2    = 11
LUTSprColor3    = 12
LUTSprColor4    = 13
LUTSprColor5    = 14
LUTSprColor6    = 15
LUTSprColor7    = 16