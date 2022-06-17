TXTWDW          .text '           EASTERN FRONT 1941           '
                .text '      COPYRIGHT 1981 CHRIS CRAWFORD     '
                .text '      PLEASE ENTER YOUR ORDERS NOW      '
TXTWDWTOP       .text '                                        '

HeaderText      = TXTWDWTOP
FooterText1     = TXTWDW
FooterText2     = TXTWDW+40
FooterText3     = TXTWDW+80


;--------------------------------------
;--------------------------------------
                .align $40
;--------------------------------------
Text2Bitmap     .fill 640*16,$00

ColumnOffset    .word ?
GlyphOffset     .word ?
ForeColor       .byte ?
BackColor       .byte ?


;--------------------------------------
;--------------------------------------
                .align $100

;======================================
; Convert ASCII text to Bitmap
;--------------------------------------
; on entry
;   SP+05       Font Color
;   SP+06       Background Color
;   SP+07       ASCII source pointer
;======================================
TransformText   .proc
                php
                .setbank $04

;   clear the line buffer
                .m8i8
                lda 5,S                 ; retrieve and save
                sta ForeColor

                lda 6,S                 ; FooterPrimary
                sta BackColor
                xba
                lda 6,S

                .m16i16
                ldy #$27fe
_nextClear      sta Text2Bitmap,Y
                dey
                dey
                bpl _nextClear

;   retrieve the source addr
                lda 7,S
                sta pSource

;   retrieve char
                .m8
                ldx #$FFFF
                phx
_nextChar       plx
                inx
                cpx #41
                beq _XIT

                phx

                txy
                lda (pSource),Y
                cmp #$20                ; skip spaces
                beq _nextChar

;   set the column pointer
                .m16
                pha                     ; remember Char

                txa
                asl                     ; *16
                asl
                asl
                asl
                sta ColumnOffset        ; E=[c0]

                lda #<>Text2Bitmap
                clc
                adc ColumnOffset
                sta pBuffer

                pla                     ; restore A

;   get the glyph pointer
                and #$00FF
                xba                     ; *256
                sta GlyphOffset

                lda #<>font
                clc
                adc GlyphOffset
                sta pGlyph

;   populate the buffer
                .m8i16
                ldx #$00
_nextRow        ldy #$00
_nextCol        phy
                txy
                lda (pGlyph),Y
                cmp #$00
                bne _1

                lda BackColor
                bra _2

_1              cmp #$FF
                bne _2

                lda ForeColor
_2              ply
                sta (pBuffer),Y

                inx
                iny
                cpy #$10
                bne _nextCol

                .m16
                lda pBuffer
                clc
                adc #640
                sta pBuffer

                .m8
                cpx #$100
                bne _nextRow
                bra _nextChar

_XIT            .setbank $03
                plp
                rtl
                .endproc
