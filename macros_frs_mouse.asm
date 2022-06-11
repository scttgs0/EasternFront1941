frsMouse_off    .macro
                lda #0
                sta MOUSE_PTR_CTRL
                .endmacro

frsMouse_off_s  .macro
                php

                .m8
                .mouse_off

                plp
                .endmacro

frsMouse_on     .macro
                lda #1
                sta MOUSE_PTR_CTRL
                .endmacro

frsMouse_on_s   .macro
                php
                pha

                .m8
                .mouse_on

                pla
                plp
                .endmacro
