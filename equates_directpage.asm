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
cursorMapX      .word ?                 ; cursor coordinates on screen (map pixel frame)
cursorMapY      .word ?         ; [$07]
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

TYL             .byte ?
TYH             .byte ?         ; [$18]
DELAY           .byte ?                 ; acceleration delay on scrolling
scrollTimer     .byte ?                 ; frame to scroll in
TEMPLO          .byte ?                 ; temporary
TEMPHI          .byte ?
BASEX           .byte ?                 ; start position for arrow (player frame)
BASEY           .byte ?
STEPX           .byte ?                 ; intermediate position of arrow
STEPY           .byte ?         ; [$20]
STPCNT          .byte ?                 ; which intermediate steps arrow is on
ORDCNT          .byte ?                 ; which order arrow is showing
ORD1            .byte ?                 ; orders record
ORD2            .byte ?
ARRNDX          .byte ?                 ; arrow index
HOWMNY          .byte ?                 ; how many orders for unit under cursor
KRZX            .byte ?                 ; maltakreuze coords (player frame)
KRZY            .byte ?         ; [$28]
DEBOUNCE_TIMER  .byte ?                 ; joystick debounce timer
STICKI          .byte ?                 ; coded value of stick direction (0-3)
ERRFLG          .byte ?
KRZFLG          .byte ?
STKFLG          .byte ?
HITFLG          .byte ?
TXL             .byte ?                 ; temporary values---slightly shifted
TXH             .byte ?         ; [$30]
OLDLAT          .byte ?
TRNCOD          .byte ?
TLO             .byte ?
THI             .byte ?
TICK            .byte ?
UNTCOD          .byte ?
UNTCD1          .byte ?
BVAL            .byte ?         ; [$38]   best value
BONE            .byte ?                 ; best index
DIR             .byte ?                 ; direction
TARGX           .byte ?                 ; square under consideration
TARGY           .byte ?
SQX             .byte ?                 ; adjacent square
SQY             .byte ?
JCNT            .byte ?                 ; counter for adjacent squares
LINCOD          .byte ?         ; [$40]   code value of line configuration
NBVAL           .byte ?                 ; another best value
RORD1           .byte ?                 ; Russian orders
RORD2           .byte ?
HDIR            .byte ?                 ; horizontal direction
VDIR            .byte ?                 ; vertical direction
LDIR            .byte ?                 ; larger direction
SDIR            .byte ?                 ; smaller direction
HRNGE           .byte ?         ; [$48]   horizontal range
VRNGE           .byte ?                 ; vertical range
LRNGE           .byte ?                 ; larger range
SRNGE           .byte ?                 ; smaller range
CHRIS           .byte ?                 ; midway counter
RANGE           .byte ? ; just that
RCNT            .byte ?                 ; counter for Russian orders
SECDIR          .byte ?                 ; secondary direction
POTATO          .byte ?         ; [$50]   a stupid temporary
BAKARR          .fill 25        ; [$51]
LINARR          .fill 25        ; [$6A]
IFR0            .byte ?         ; [$83]
IFR1            .byte ?
IFR2            .byte ?
IFR3            .byte ?
XLOC            .byte ?
YLOC            .byte ?         ; [$88]
TEMPX           .byte ?
TEMPY           .byte ?
LV              .fill 5         ; [$8B]
LPTS            .byte ?         ; [$90]
COLUM           .byte ?
OCOLUM          .byte ?
IFRHI           .byte ?
PASSCT          .byte ?
DELAY2          .byte ?
HANDICAP        .byte ?
TOTGS           .byte ?
TOTRS           .byte ?         ; [$98]
OFR             .byte ?
HOMEDIRECTION   .byte ?                 ; Direction toward Home
                                        ; 1 = East (Russian)
                                        ; 3 = West (German)
ZOC             .byte ?
TEMPQ           .byte ?
LLIM            .byte ?
VICTRY          .byte ?
IFR             .byte ?
JIFFYCLOCK      .byte ?         ; [$A0]

;   These locations are used by the interrupt service routine
OFFLO           .byte ?                 ; How far to offset new LMS value
OFFHI           .byte ?
TEMPI           .byte ?                 ; An all-purpose temporary register
IRQ_PRIOR       .word ?


;   These locations are for the mainline routines
MAPPTR          .word ?
ARMY            .byte ?         ; [$A8]
UNITNO          .byte ?
DEFNDR          .byte ?
TEMPR           .byte ?
TEMPZ           .byte ?
ACCLO           .byte ?
ACCHI           .byte ?
TURN            .byte ?
LATITUDE        .byte ?         ; [$B0]
LONGITUDE       .byte ?
RFR             .byte ?
TRNTYP          .byte ?
SQVAL           .byte ?
KEYCHAR         .byte ?                 ; last key pressed
    ; TODO: Keyboard Interrupt Handler
CONSOL          .byte ?                 ; state of OPTION,SELECT,START
    ; TODO: Keyboard Interrupt Handler
SOURCE          .dword ?        ; [$B7]   Starting address for the source data (4 bytes)
DEST            .dword ?        ; [$BB]   Starting address for the destination block (4 bytes)
SIZE            .dword ?        ; [$BF]   Number of bytes to copy (4 bytes)
blockIndex      .byte ?         ; [$C3]   [0-63]
blockRow        .word ?
ptrMap          .word ?
X_POS           .word ?
Y_POS           .word ?
pBuffer         .word ?
pGlyph          .word ?
pSource         .word ?         ; [$D0]
