;======================================
; Direct-page variables
;======================================

;--------------------------------------
;--------------------------------------
                * = $0800
;--------------------------------------

;   first come locations used by the interrupt service routine
XPOSL           .byte ?         ; [$00]   Horizontal position of
YPOSL           .byte ?                 ; Vertical position of
YPOSH           .byte ?                 ; upper-left corner of screen window
shSpr0PositionY .word ?                 ; [51]  shadows player-0 y-position (player frame)
shSpr0PositionX .word ?                 ; [120] shadows player-0 x-position

;   seasonal values
TRCOLR          .byte ?
EARTH           .byte ?         ; [$08]
ICELAT          .byte ?
SEASN1          .byte ?
SEASN2          .byte ?
SEASN3          .byte ?
DAY             .byte ?
MONTH           .byte ?
YEAR            .byte ?

BUTTON_FLAG     .byte ?         ; [$10] ; 0=button press has NOT occurred; FF=button press has occurred
BUTTON_MASK     .byte ?                 ; 0=allow; 1=prevent
TYL             .byte ?
TYH             .byte ?
DELAY           .byte ?                 ; acceleration delay on scrolling
TIMSCL          .byte ?                 ; frame to scroll in
TEMPLO          .byte ?                 ; temporary
TEMPHI          .byte ?
BASEX           .byte ?         ; [$18] ; start position for arrow (player frame)
BASEY           .byte ?
STEPX           .byte ?                 ; intermediate position of arrow
STEPY           .byte ?
STPCNT          .byte ?                 ; which intermediate steps arrow is on
ORDCNT          .byte ?                 ; which order arrow is showing
ORD1            .byte ?                 ; orders record
ORD2            .byte ?
ARRNDX          .byte ?         ; [$20]   arrow index
HOWMNY          .byte ?                 ; how many orders for unit under cursor
KRZX            .byte ?                 ; maltakreuze coords (player frame)
KRZY            .byte ?
DEBOUNCE_TIMER  .byte ?                 ; joystick debounce timer
STICKI          .byte ?                 ; coded value of stick direction (0-3)
ERRFLG          .byte ?
KRZFLG          .byte ?
STKFLG          .byte ?         ; [$28]
HITFLG          .byte ?
TXL             .byte ?                 ; temporary values---slightly shifted
TXH             .byte ?
OLDLAT          .byte ?
TRNCOD          .byte ?
TLO             .byte ?
THI             .byte ?
TICK            .byte ?         ; [$30]
UNTCOD          .byte ?
UNTCD1          .byte ?
BVAL            .byte ?                 ; best value
BONE            .byte ?                 ; best index
DIR             .byte ?                 ; direction
TARGX           .byte ?                 ; square under consideration
TARGY           .byte ?
SQX             .byte ?         ; [$38]   adjacent square
SQY             .byte ?
JCNT            .byte ?                 ; counter for adjacent squares
LINCOD          .byte ?                 ; code value of line configuration
NBVAL           .byte ?                 ; another best value
RORD1           .byte ?                 ; Russian orders
RORD2           .byte ?
HDIR            .byte ?                 ; horizontal direction
VDIR            .byte ?         ; [$40]   vertical direction
LDIR            .byte ?                 ; larger direction
SDIR            .byte ?                 ; smaller direction
HRNGE           .byte ?                 ; horizontal range
VRNGE           .byte ?                 ; vertical range
LRNGE           .byte ?                 ; larger range
SRNGE           .byte ?                 ; smaller range
CHRIS           .byte ?                 ; midway counter
RANGE           .byte ?         ; [$48] ; just that
RCNT            .byte ?                 ; counter for Russian orders
SECDIR          .byte ?                 ; secondary direction
POTATO          .byte ?                 ; a stupid temporary
BAKARR          .fill 25        ; [$4C]
LINARR          .fill 25        ; [$65]
IFR0            .byte ?         ; [$7E]
IFR1            .byte ?
IFR2            .byte ?         ; [$80]
IFR3            .byte ?
XLOC            .byte ?
YLOC            .byte ?
TEMPX           .byte ?
TEMPY           .byte ?
LV              .fill 5         ; [$86]
LPTS            .byte ?         ; [$8B]
COLUM           .byte ?
OCOLUM          .byte ?
IFRHI           .byte ?
PASSCT          .byte ?
DELAY2          .byte ?         ; [$90]
HANDICAP        .byte ?
TOTGS           .byte ?
TOTRS           .byte ?
OFR             .byte ?
HOMEDIRECTION   .byte ?                 ; Direction toward Home
                                        ; 1 = East (Russian)
                                        ; 3 = West (German)
ZOC             .byte ?
TEMPQ           .byte ?
LLIM            .byte ?         ; [$98]
VICTRY          .byte ?
IFR             .byte ?
JIFFYCLOCK      .byte ?

;   These locations are used by the interrupt service routine
DLSTPT          .word ?                 ; pointer to display list
MAPLO           .byte ?
MAPHI           .byte ?
CORPS           .byte ?         ; [A0]    number of unit under window
CURSOR_MapX     .word ?                 ; cursor x-coordinates on screen (map frame)
CURSOR_MapY     .word ?                 ; cursor y-coordinates on screen (map frame)

OFFLO           .byte ?                 ; How far to offset new LMS value
OFFHI           .byte ?
TEMPI           .byte ?                 ; An all-purpose temporary register
IRQ_PRIOR       .word ?         ; [A8]
CHUNKX          .byte ?                 ; cursor coordinates (pixel frame)
CHUNKY          .byte ?


;   These locations are for the mainline routines
MAPPTR          .word ?
ARMY            .byte ?
UNITNO          .byte ?
DEFNDR          .byte ?         ; [B0]
TEMPR           .byte ?
TEMPZ           .byte ?
ACCLO           .byte ?
ACCHI           .byte ?
TURN            .byte ?
LATITUDE        .byte ?
LONGITUDE       .byte ?
RFR             .byte ?         ; [B8]
TRNTYP          .byte ?
SQVAL           .byte ?
KEYCHAR         .byte ?                 ; last key pressed
    ; TODO: Keyboard Interrupt Handler
CONSOL          .byte ?                 ; state of OPTION,SELECT,START
    ; TODO: Keyboard Interrupt Handler
SOURCE          .dword ?        ; [BD]    Starting address for the source data (4 bytes)
DEST            .dword ?        ; [C1]    Starting address for the destination block (4 bytes)
SIZE            .dword ?        ; [C5]    Number of bytes to copy (4 bytes)
blockIndex      .byte ?         ; [C9]   [0-63]
blockRow        .word ?
ptrMap          .word ?
X_POS           .word ?
Y_POS           .word ?         ; [D0]
pBuffer         .word ?
pGlyph          .word ?
pSource         .word ?
