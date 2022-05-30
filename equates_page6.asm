;--------------------------------------
;--------------------------------------
                * = $0600
;--------------------------------------
;   first come locations used by the interrupt service routine
XPOSL           .byte ?         ; [$00]   Horizontal position of
YPOSL           .byte ?                 ; Vertical position of
YPOSH           .byte ?                 ; upper-left corner of screen window
SCY             .byte ?                 ; vert position of cursor (player frame)
SHPOS0          .byte ?                 ; shadows player 0 position

;   seasonal values
TRCOLR          .byte ?
EARTH           .byte ?
ICELAT          .byte ?
SEASN1          .byte ?         ; [$08]
SEASN2          .byte ?
SEASN3          .byte ?
DAY             .byte ?
MONTH           .byte ?
YEAR            .byte ?

BUTFLG          .byte ?
BUTMSK          .byte ?
TYL             .byte ?         ; [$10]
TYH             .byte ?
DELAY           .byte ?                 ; acceleration delay on scrolling
TIMSCL          .byte ?                 ; frame to scroll in
TEMPLO          .byte ?                 ; temporary
TEMPHI          .byte ?
BASEX           .byte ?                 ; start position for arrow (player frame)
BASEY           .byte ?
STEPX           .byte ?         ; [$18]   intermediate position of arrow
STEPY           .byte ?
STPCNT          .byte ?                 ; which intermediate steps arrow is on
ORDCNT          .byte ?                 ; which order arrow is showing
ORD1            .byte ?                 ; orders record
ORD2            .byte ?
ARRNDX          .byte ?                 ; arrow index
HOWMNY          .byte ?                 ; how many orders for unit under cursor
KRZX            .byte ?         ; [$20]   maltakreuze coords (player frame)
KRZY            .byte ?
DBTIMR          .byte ?                 ; joystick debounce timer
STICKI          .byte ?                 ; coded value of stick direction (0-3)
ERRFLG          .byte ?
KRZFLG          .byte ?
STKFLG          .byte ?
HITFLG          .byte ?
TXL             .byte ?         ; [$28]   temporary values---slightly shifted
TXH             .byte ?
OLDLAT          .byte ?
TRNCOD          .byte ?
TLO             .byte ?
THI             .byte ?
TICK            .byte ?
UNTCOD          .byte ?
UNTCD1          .byte ?         ; [$30]
BVAL            .byte ?                 ; best value
BONE            .byte ?                 ; best index
DIR             .byte ?                 ; direction
TARGX           .byte ?                 ; square under consideration
TARGY           .byte ?
SQX             .byte ?                 ; adjacent square
SQY             .byte ?
JCNT            .byte ?         ; [$38]   counter for adjacent squares
LINCOD          .byte ?                 ; code value of line configuration
NBVAL           .byte ?                 ; another best value
RORD1           .byte ?                 ; Russian orders
RORD2           .byte ?
HDIR            .byte ?                 ; horizontal direction
VDIR            .byte ?                 ; vertical direction
LDIR            .byte ?                 ; larger direction
SDIR            .byte ?         ; [$40]   smaller direction
HRNGE           .byte ?                 ; horizontal range
VRNGE           .byte ?                 ; vertical range
LRNGE           .byte ?                 ; larger range
SRNGE           .byte ?                 ; smaller range
CHRIS           .byte ?                 ; midway counter
RANGE           .byte ?                 ; just that
RCNT            .byte ?                 ; counter for Russian orders
SECDIR          .byte ?         ; [$48]   secondary direction
POTATO          .byte ?                 ; a stupid temporary
BAKARR          .fill 25        ; [$4A]
LINARR          .fill 25        ; [$63]
IFR0            .byte ?         ; [$7C]
IFR1            .byte ?
IFR2            .byte ?
IFR3            .byte ?
XLOC            .byte ?         ; [$80]
YLOC            .byte ?
TEMPX           .byte ?
TEMPY           .byte ?
LV              .fill 5         ; [$84]
LPTS            .byte ?         ; [$89]
COLUM           .byte ?
OCOLUM          .byte ?
IFRHI           .byte ?
PASSCT          .byte ?
DELAY2          .byte ?
HANDCP          .byte ?
TOTGS           .byte ?         ; [$90]
TOTRS           .byte ?
OFR             .byte ?
HOMEDR          .byte ?
ZOC             .byte ?
TEMPQ           .byte ?
LLIM            .byte ?
VICTRY          .byte ?         ; [$97]
