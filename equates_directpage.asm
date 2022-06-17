;======================================
; Direct-page variables
;======================================

;--------------------------------------
;--------------------------------------
                * = $0800
;--------------------------------------

;   locations used by the interrupt service routine
activeCorpsX    .byte ?         ; [$00]   cursor coordinates (map grid frame; origin lower-right)
activeCorpsY    .byte ?

;--------------------------------------
;   initialized at start
pMap            .word ?
activeCorps     .byte ?                 ; number of unit under window
cursorMapX      .word ?                 ; cursor position in map coordinates (lower-right origin)
                                        ; range [735:0]     46*16=736
cursorMapY      .word ?         ; [$07]   range [623:0]     39*16=624
shSpr0PositionX .word ?                 ; shadows player-0 position (player frame)
shSpr0PositionY .word ?

;   seasonal values
EARTH           .byte ?
ICELAT          .byte ?
SEASN1          .byte ?
SEASN2          .byte ?         ; [$10]
SEASN3          .byte ?
DAY             .byte ?
MONTH           .byte ?
YEAR            .byte ?
BUTTON_FLAG     .byte ?                 ; 0=button press has NOT occurred; FF=button press has occurred
BUTTON_MASK     .byte ?                 ; 0=allow; 1=prevent

;--------------------------------------

wTY             .word ?         ; [$17]
DELAY           .byte ?                 ; acceleration delay on scrolling
scrollTimer     .byte ?                 ; frame to scroll in
wTEMP           .word ?                 ; temporary
BASEX           .word ?                 ; start position for arrow (player frame)
BASEY           .word ?         ; [$1F]
STEPX           .word ?                 ; intermediate position of arrow
STEPY           .word ?
StepCount       .byte ?                 ; which intermediate steps arrow is on
OrderCount      .byte ?                 ; which order arrow is showing
ORD1            .byte ?                 ; orders record
ORD2            .byte ?         ; [$28]
ArrowIndex      .byte ?
HOWMNY          .byte ?                 ; how many orders for unit under cursor
CrossX          .byte ?                 ; maltakreuze coords (player frame)
CrossY          .byte ?
DEBOUNCE_TIMER  .byte ?                 ; joystick debounce timer
STICKI          .byte ?                 ; coded value of stick direction (0-3)
ERRFLG          .byte ?
CrossFlag       .byte ?         ; [$30]
JoystickFlag    .byte ?
HitFlag         .byte ?
wTX             .word ?                 ; temporary values---slightly shifted
OLDLAT          .byte ?
TRNCOD          .byte ?
TLO             .byte ?
THI             .byte ?         ; [$38]
TICK            .byte ?
UNTCOD          .byte ?
UNTCD1          .byte ?
BVAL            .byte ?                 ; best value
BONE            .byte ?                 ; best index
DIR             .byte ?                 ; direction
TARGX           .byte ?                 ; square under consideration
TARGY           .byte ?         ; [$40]
SQX             .byte ?                 ; adjacent square
SQY             .byte ?
JCNT            .byte ?                 ; counter for adjacent squares
LINCOD          .byte ?                 ; code value of line configuration
NBVAL           .byte ?                 ; another best value
RORD1           .byte ?                 ; Russian orders
RORD2           .byte ?
HDIR            .byte ?         ; [$48]   horizontal direction
VDIR            .byte ?                 ; vertical direction
LDIR            .byte ?                 ; larger direction
SDIR            .byte ?                 ; smaller direction
HRNGE           .byte ?                 ; horizontal range
VRNGE           .byte ?                 ; vertical range
LRNGE           .byte ?                 ; larger range
SRNGE           .byte ?                 ; smaller range
CHRIS           .byte ?         ; [$50]   midway counter
RANGE           .byte ?                 ; just that
RCNT            .byte ?                 ; counter for Russian orders
SECDIR          .byte ?                 ; secondary direction
POTATO          .byte ?                 ; a stupid temporary
BAKARR          .fill 25        ; [$55]
LINARR          .fill 25        ; [$6E]
IFR0            .byte ?
IFR1            .byte ?         ; [$88]
IFR2            .byte ?
IFR3            .byte ?
XLOC            .byte ?
YLOC            .byte ?
TEMPX           .byte ?
TEMPY           .byte ?
LV              .fill 5         ; [$8F]
LPTS            .byte ?         ; [$94]
COLUM           .byte ?
OCOLUM          .byte ?
IFRHI           .byte ?
PASSCT          .byte ?         ; [$98]
DELAY2          .byte ?
HANDICAP        .byte ?
TOTGS           .byte ?
TOTRS           .byte ?
OFR             .byte ?
HOMEDIRECTION   .byte ?                 ; Direction toward Home
                                        ; 1 = East (Russian)
                                        ; 3 = West (German)
ZOC             .byte ?
TEMPQ           .byte ?         ; [$A0]
LLIM            .byte ?
VICTRY          .byte ?
IFR             .byte ?
JIFFYCLOCK      .byte ?

;   These locations are used by the interrupt service routine
OFFLO           .byte ?                 ; How far to offset new LMS value
OFFHI           .byte ?
TEMPI           .byte ?                 ; An all-purpose temporary register
IRQ_PRIOR       .word ?         ; [$A8]


;   These locations are for the mainline routines
MAPPTR          .word ?
ARMY            .byte ?
UNITNO          .byte ?
DEFNDR          .byte ?
TEMPR           .byte ?
TEMPZ           .byte ?         ; [$B0]
ACCLO           .byte ?
ACCHI           .byte ?
TURN            .byte ?
LATITUDE        .byte ?
LONGITUDE       .byte ?
RFR             .byte ?
TRNTYP          .byte ?
SQVAL           .byte ?         ; [$B8]
KEYCHAR         .byte ?                 ; last key pressed
    ; TODO: Keyboard Interrupt Handler
CONSOL          .byte ?                 ; state of OPTION,SELECT,START
    ; TODO: Keyboard Interrupt Handler
SOURCE          .dword ?        ; [$BB]   Starting address for the source data (4 bytes)
DEST            .dword ?        ; [$BF]   Starting address for the destination block (4 bytes)
SIZE            .dword ?        ; [$C3]   Number of bytes to copy (4 bytes)
blockIndex      .byte ?                 ; [0-63]
blockRow        .word ?         ; [$C8]
ptrMap          .word ?
X_POS           .word ?
Y_POS           .word ?
pBuffer         .word ?         ; [$D0]
pGlyph          .word ?
pSource         .word ?         ; [$D4]
