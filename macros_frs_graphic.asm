frsGraphics     .macro
                lda #\1
                sta MASTER_CTRL_L

                lda #\2
                sta MASTER_CTRL_H
                .endmacro

frsGraphics_s   .macro
                php
                pha

                .m8
                .frsGraphics \@

                pla
                plp
                .endmacro

frsBorder_off   .macro
                lda #0
                sta BORDER_CTRL
                sta BORDER_X_SIZE
                sta BORDER_Y_SIZE
                .endmacro

frsBorder_off_s .macro
                php

                .m8
                .frsBorder_off

                plp
                .endmacro

frsBorder_on    .macro color, xSize, ySize
                php

                .m8
                lda #$01
                sta BORDER_CTRL_REG

                lda \xSize
                sta BORDER_X_SIZE

                lda \ySize
                sta BORDER_Y_SIZE

                lda \color>>16&$FF
                sta BORDER_COLOR_R
                lda \color>>8&$FF
                sta BORDER_COLOR_G
                lda \color&$FF
                sta BORDER_COLOR_B

                plp
                .endmacro
