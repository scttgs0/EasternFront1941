;---------------------------------------
; System Equates for Atari
;---------------------------------------

;   OS registers
SDLSTL          = $0230                 ; [word] Existing OS pointer to display list

;--------------------------------------

;   ANTIC registers
PMBASE          = $D407
CHBASE          = $D409
WSYNC           = $D40A
NMIEN           = $D40E

;   ANTIC instructions
AJMP            = $0001
AVB             = $0040
AHSCR           = $0010
AVSCR           = $0020
ALMS            = $0040
ADLI            = $0080
AEMPTY0         = $0000
AEMPTY8         = $0070

;--------------------------------------

;   Vectors
SETVBV          = $E45C
XITVBV          = $E462
