RenderText      .macro bkgColorIndex,foreColorIndex,srcAddr,destAddr
                .m16i8
                pea #<>\srcAddr
                ldx #\bkgColorIndex
                phx
                ldx #\foreColorIndex
                phx
                jsl TransformText
                pla                     ; clean up stack
                pla

                lda #<>(\destAddr-VRAM)
                sta DEST
                lda #`(\destAddr-VRAM)
                sta DEST+2
                jsr BlitText
                .endmacro
